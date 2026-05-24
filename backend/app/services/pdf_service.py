import hashlib
import logging
import uuid
from typing import Tuple, List, Optional
from datetime import datetime
from jinja2 import Environment, FileSystemLoader, select_autoescape
from weasyprint import HTML
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from sqlalchemy.orm import selectinload

from app.models.inspection import Inspection
from app.models.media import Media, MediaType
from app.models.report import Report
from app.services import audit_service, storage_service
from app.schemas.inspection import LocationPoint

logger = logging.getLogger(__name__)

env = Environment(
    loader=FileSystemLoader("app/templates"),
    autoescape=select_autoescape(enabled_extensions=('html', 'xml'), default_for_string=True)
)

async def _get_media_urls(db: AsyncSession, inspection_id: uuid.UUID) -> List[str]:
    """Busca URLs pré-assinadas para as fotos da inspeção."""
    query = select(Media).where(
        Media.inspection_id == inspection_id,
        Media.type == MediaType.photo
    )
    result = await db.execute(query)
    photos = result.scalars().all()
    
    urls = []
    for photo in photos:
        try:
            url = await storage_service.get_presigned_download_url(
                bucket="inspections",
                key=photo.minio_key,
                expires=3600
            )
            urls.append(url)
        except Exception as e:
            logger.error(f"Error generating presigned URL for photo {photo.id}: {e}")
            
    return urls

async def generate_report(inspection_id: uuid.UUID, db: AsyncSession, generated_by: uuid.UUID) -> Tuple[str, str]:
    """Gera um laudo PDF para a inspeção."""
    try:
        # Busca a inspeção garantindo que o inspetor seja carregado na mesma query
        query = select(Inspection).where(
            Inspection.id == inspection_id
        ).options(
            selectinload(Inspection.inspector)
        )
        result = await db.execute(query)
        inspection = result.scalar_one_or_none()
        
        if not inspection:
            logger.error(f"Inspeção {inspection_id} não encontrada para geração de laudo")
            raise ValueError(f"Inspeção {inspection_id} não encontrada")

        # Verifica se o relatório já existe (idempotência)
        existing_report_query = select(Report).where(Report.inspection_id == inspection_id)
        existing_result = await db.execute(existing_report_query)
        existing_report = existing_result.scalar_one_or_none()
        
        if existing_report:
            logger.info(f"Relatório já existe para a inspeção {inspection_id}")
            return existing_report.minio_key, existing_report.sha256

        media_urls = await _get_media_urls(db, inspection_id)
        
        # localização para Lat/Lon
        loc = LocationPoint.parse_wkb(inspection.location)

        template = env.get_template("report.html")
        html_str = template.render(
            inspection=inspection,
            lat=loc.lat,
            lon=loc.lon,
            media_urls=media_urls,
            report_sha256=None # Será atualizado depois do cálculo
        )

        pdf_bytes = HTML(string=html_str).write_pdf()

        sha256_hash = hashlib.sha256(pdf_bytes).hexdigest()
        
        # Re-renderiza o HTML com o hash correto para que o PDF contenha o hash real
        html_str = template.render(
            inspection=inspection,
            lat=loc.lat,
            lon=loc.lon,
            media_urls=media_urls,
            report_sha256=sha256_hash
        )
        pdf_bytes = HTML(string=html_str).write_pdf()
        sha256_hash = hashlib.sha256(pdf_bytes).hexdigest()

        minio_key = f"reports/{inspection_id}/{sha256_hash[:8]}.pdf"
        async with storage_service.get_s3_client_context() as client:
            await client.put_object(
                Bucket="reports",
                Key=minio_key,
                Body=pdf_bytes,
                ContentType="application/pdf"
            )

        report = Report(
            inspection_id=inspection_id,
            generated_by=generated_by,
            minio_key=minio_key,
            sha256=sha256_hash
        )
        db.add(report)
        await db.commit()
        await db.refresh(report)

        await audit_service.log_action(
            db=db,
            user_id=str(generated_by),
            entity="report",
            entity_id=str(report.id),
            action="generate"
        )

        return minio_key, sha256_hash

    except Exception as e:
        logger.error(f"Erro ao gerar relatório para inspeção {inspection_id}: {e}")
        await db.rollback()
        raise

async def verify_report_hash(report_id: uuid.UUID, db: AsyncSession) -> bool:
    """Verifica se o hash do PDF no MinIO coincide com o banco."""
    try:
        query = select(Report).where(Report.id == report_id)
        report = await db.scalar(query)
        if not report:
            return False

        # Baixa do MinIO
        async with storage_service.get_s3_client_context() as client:
            response = await client.get_object(Bucket="reports", Key=report.minio_key)
            async with response['Body'] as stream:
                pdf_bytes = await stream.read()

        # Recalcula hash
        calculated_hash = hashlib.sha256(pdf_bytes).hexdigest()

        if calculated_hash != report.sha256:
            logger.critical(f"DIVERGÊNCIA DE HASH NO RELATÓRIO {report_id}! Banco: {report.sha256}, Real: {calculated_hash}")
            await audit_service.log_action(
                db=db,
                user_id=None,
                entity="report",
                entity_id=str(report.id),
                action="hash_mismatch",
                old_value={"sha256": report.sha256},
                new_value={"sha256": calculated_hash}
            )
            return False

        return True
    except Exception as e:
        logger.error(f"Erro ao verificar hash do relatório {report_id}: {e}")
        return False
