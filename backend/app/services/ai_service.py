import logging
import uuid
import httpx
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.config import settings
from app.models.inspection import Inspection
from app.models.media import Media
from app.services import audit_service
from app.services.storage_service import get_s3_client_context

logger = logging.getLogger(__name__)

async def _classify_local_fallback(image_bytes: bytes) -> dict:
    return {
        "label": "unknown",
        "score": 0.0,
        "raw": [],
        "source": "local_fallback"
    }

async def classify_image(image_bytes: bytes) -> dict:
    # A URL para o novo router deve terminar com o ID do modelo sem barra adicional se já estiver no path
    url = f"https://router.huggingface.co/hf-inference/models/{settings.HF_MODEL_ID}"
    
    # Headers obrigatórios para o novo sistema de roteamento
    headers = {
        "Authorization": f"Bearer {settings.HF_API_KEY}",
        "Content-Type": "image/jpeg",  # Força o tipo de conteúdo para imagens
        "x-wait-for-model": "true"      # Instrução para o router esperar o carregamento do modelo
    }
    
    try:
        async with httpx.AsyncClient(timeout=settings.HF_TIMEOUT_SECONDS) as client:
            response = await client.post(url, headers=headers, content=image_bytes)
            
            # Se retornar 503, o modelo ainda está carregando
            if response.status_code == 503:
                logger.warning("HuggingFace model is loading (503). Using fallback.")
                return await _classify_local_fallback(image_bytes)
                
            response.raise_for_status()
            
            result = response.json()
            
            # O modelo ViT retorna uma lista de dicionários [{"label": "...", "score": ...}, ...]
            if isinstance(result, list) and len(result) > 0:
                # Pegamos o resultado com maior score
                best_match = max(result, key=lambda x: x.get("score", 0.0))
                return {
                    "label": best_match.get("label", "unknown"),
                    "score": float(best_match.get("score", 0.0)),
                    "raw": result,
                    "source": "huggingface"
                }
            
            logger.error(f"Unexpected HF response format: {result}")
            return await _classify_local_fallback(image_bytes)
            
    except Exception as e:
        logger.error(f"Error calling HuggingFace API: {e}")
        return await _classify_local_fallback(image_bytes)

def map_severity(score: float, label: str) -> str:
    if score < settings.HF_CONFIDENCE_THRESHOLD:
        return "pending_review"
        
    risk_words = ["crack", "damage", "broken", "leak", "rust", "corrosion", "fracture", "deterioration"]
    label_lower = label.lower()
    
    has_risk = any(word in label_lower for word in risk_words)
    
    if has_risk and score >= 0.8:
        return "critical"
    elif has_risk:
        return "moderate"
    else:
        return "low"

async def process_inspection_media(inspection_id: uuid.UUID, db: AsyncSession, media_id: uuid.UUID) -> None:
    try:
        media = await db.scalar(select(Media).where(Media.id == media_id))
        if not media:
            logger.error(f"Media {media_id} not found")
            return
            
        inspection = await db.scalar(select(Inspection).where(Inspection.id == inspection_id))
        if not inspection:
            logger.error(f"Inspection {inspection_id} not found")
            return

        bucket = "inspections"
        key = media.minio_key
        
        image_bytes = None
        try:
            async with get_s3_client_context() as client:
                response = await client.get_object(Bucket=bucket, Key=key)
                async with response['Body'] as stream:
                    image_bytes = await stream.read()
        except Exception as e:
            logger.error(f"Error downloading media {media_id} from MinIO: {e}")
            return
                
        if not image_bytes:
            logger.error(f"Empty bytes for media {media_id} from MinIO")
            return

        classification = await classify_image(image_bytes)
        
        old_value = {
            "ai_label": inspection.ai_label,
            "ai_score": inspection.ai_score,
            "ai_raw": inspection.ai_raw,
            "severity": inspection.severity.value if inspection.severity else None
        }
        
        inspection.ai_label = classification["label"]
        inspection.ai_score = classification["score"]
        inspection.ai_raw = classification["raw"]
        inspection.severity = map_severity(classification["score"], classification["label"])
        
        new_value = {
            "ai_label": inspection.ai_label,
            "ai_score": inspection.ai_score,
            "ai_raw": inspection.ai_raw,
            "severity": inspection.severity
        }
        
        await db.commit()
        await db.refresh(inspection)
        
        await audit_service.log_action(
            db=db,
            user_id=str(inspection.inspector_id),
            entity="inspection",
            entity_id=str(inspection.id),
            action="ai_classified",
            old_value=old_value,
            new_value=new_value
        )
        
    except Exception as e:
        logger.error(f"Error processing inspection media {media_id}: {e}")
        await db.rollback()
