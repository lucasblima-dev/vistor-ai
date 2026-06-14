import logging
import base64
import json
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

def compress_image_for_ai(image_bytes: bytes) -> bytes:
    from PIL import Image
    import io
    try:
        img = Image.open(io.BytesIO(image_bytes))
        img.thumbnail((800, 800))
        
        buffer = io.BytesIO()
        if img.mode in ("RGBA", "P"):
            img = img.convert("RGB")
        img.save(buffer, format="JPEG", quality=80)
        return buffer.getvalue()
    except Exception as e:
        logger.error(f"Error compressing image for AI: {e}")
        return image_bytes

async def classify_image(image_bytes: bytes) -> dict:
    url = "https://router.huggingface.co/v1/chat/completions"
    
    headers = {
        "Authorization": f"Bearer {settings.HF_API_KEY}",
        "Content-Type": "application/json"
    }
    
    compressed_bytes = compress_image_for_ai(image_bytes)
    image_b64 = base64.b64encode(compressed_bytes).decode("utf-8")
    
    prompt = (
        "Classifique a severidade e o tipo de dano estrutural desta imagem de inspeção técnica.\n"
        "Categorias possíveis:\n"
        "1. 'rachadura crítica'\n"
        "2. 'infiltração ou umidade'\n"
        "3. 'corrosão de armadura'\n"
        "4. 'estrutura intacta e sem danos'\n\n"
        "Retorne a resposta EXCLUSIVAMENTE em formato JSON puro, sem blocos de código ```json ou qualquer outro texto adicional. "
        "O JSON deve conter os campos 'label' (exatamente igual a uma das categorias acima) e 'score' (um float de confiança entre 0.0 e 1.0).\n"
        "Exemplo:\n"
        "{\"label\": \"infiltração ou umidade\", \"score\": 0.95}"
    )

    payload = {
        "model": settings.HF_MODEL_ID,
        "messages": [
            {
                "role": "user",
                "content": [
                    {
                        "type": "text",
                        "text": prompt
                    },
                    {
                        "type": "image_url",
                        "image_url": {
                            "url": f"data:image/jpeg;base64,{image_b64}"
                        }
                    }
                ]
            }
        ],
        "max_tokens": 100,
        "temperature": 0.0
    }
    
    try:
        async with httpx.AsyncClient(timeout=settings.HF_TIMEOUT_SECONDS) as client:
            response = await client.post(url, headers=headers, json=payload)
            
            if response.status_code == 503:
                logger.warning("HuggingFace model is loading (503). Using fallback.")
                return await _classify_local_fallback(image_bytes)
                
            response.raise_for_status()
            
            result = response.json()
            content = result['choices'][0]['message']['content'].strip()
            
            # Limpa blocos de código markdown se o modelo gerou apesar das instruções
            if content.startswith("```json"):
                content = content[7:]
            elif content.startswith("```"):
                content = content[3:]
            if content.endswith("```"):
                content = content[:-3]
            content = content.strip()
            
            parsed = json.loads(content)
            label = parsed.get("label", "unknown")
            score = float(parsed.get("score", 0.0))
            
            return {
                "label": label,
                "score": score,
                "raw": result,
                "source": "huggingface"
            }
            
    except Exception as e:
        logger.error(f"Error calling HuggingFace API: {e}")
        return await _classify_local_fallback(image_bytes)

def map_severity(score: float, label: str) -> str:
    if score < settings.HF_CONFIDENCE_THRESHOLD:
        return "pending_review"
        
    label_lower = label.lower().strip()
    
    if label_lower in ["rachadura crítica", "corrosão de armadura"]:
        return "critical"
    elif label_lower == "infiltração ou umidade":
        return "moderate"
    elif label_lower == "estrutura intacta e sem danos":
        return "low"
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
