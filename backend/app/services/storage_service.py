import io
import logging
from PIL import Image
from aiobotocore.session import get_session
from fastapi import HTTPException, status
from app.config import settings

logger = logging.getLogger(__name__)

def get_s3_client_context():
    session = get_session()
    return session.create_client(
        "s3",
        region_name="us-east-1",
        endpoint_url=settings.MINIO_ENDPOINT,
        aws_access_key_id=settings.MINIO_USER,
        aws_secret_access_key=settings.MINIO_PASSWORD,
        use_ssl=settings.ENVIRONMENT != "development",
    )

def get_external_s3_client_context():
    """Contexto para gerar URLs que o cliente externo (App/Browser) consegue acessar."""
    session = get_session()
    return session.create_client(
        "s3",
        region_name="us-east-1",
        endpoint_url=settings.MINIO_EXTERNAL_ENDPOINT,
        aws_access_key_id=settings.MINIO_USER,
        aws_secret_access_key=settings.MINIO_PASSWORD,
        use_ssl=settings.ENVIRONMENT != "development",
    )

async def get_presigned_upload_url(
    bucket: str, key: str, content_type: str, expires: int = 3600
) -> str:
    try:
        async with get_external_s3_client_context() as client:
            return await client.generate_presigned_url(
                "put_object",
                Params={
                    "Bucket": bucket,
                    "Key": key,
                    "ContentType": content_type,
                },
                ExpiresIn=expires,
            )
    except Exception as e:
        logger.error(f"Error generating presigned upload URL: {e}")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Erro ao conectar com o serviço de armazenamento",
        )

async def get_presigned_download_url(bucket: str, key: str, expires: int = 3600) -> str:
    try:
        async with get_external_s3_client_context() as client:
            return await client.generate_presigned_url(
                "get_object",
                Params={
                    "Bucket": bucket,
                    "Key": key,
                },
                ExpiresIn=expires,
            )
    except Exception as e:
        logger.error(f"Error generating presigned download URL: {e}")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Erro ao conectar com o serviço de armazenamento",
        )

async def get_internal_presigned_download_url(bucket: str, key: str, expires: int = 3600) -> str:
    """Gera uma URL pré-assinada acessível pela rede interna do Docker (usado pelo WeasyPrint)."""
    try:
        async with get_s3_client_context() as client:
            return await client.generate_presigned_url(
                "get_object",
                Params={
                    "Bucket": bucket,
                    "Key": key,
                },
                ExpiresIn=expires,
            )
    except Exception as e:
        logger.error(f"Error generating internal presigned download URL: {e}")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Erro ao conectar com o serviço de armazenamento",
        )

async def delete_object(bucket: str, key: str) -> None:
    try:
        async with get_s3_client_context() as client:
            await client.delete_object(Bucket=bucket, Key=key)
    except Exception as e:
        logger.error(f"Error deleting object from MinIO: {e}")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Erro ao conectar com o serviço de armazenamento",
        )

async def ensure_buckets_exist() -> None:
    buckets = ["inspections", "thumbnails", "reports", "avatars"]
    try:
        async with get_s3_client_context() as client:
            for bucket in buckets:
                try:
                    await client.head_bucket(Bucket=bucket)
                except Exception:
                    logger.info(f"Creating bucket: {bucket}")
                    await client.create_bucket(Bucket=bucket)
    except Exception as e:
        logger.error(f"Error ensuring buckets exist: {e}")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Erro ao inicializar o serviço de armazenamento",
        )

async def generate_thumbnail(image_bytes: bytes, key: str) -> str:
    try:
        img = Image.open(io.BytesIO(image_bytes))
        img.thumbnail((300, 300))
        
        buffer = io.BytesIO()
        img_format = img.format if img.format else "JPEG"
        img.save(buffer, format=img_format)
        buffer.seek(0)
        
        async with get_s3_client_context() as client:
            await client.put_object(
                Bucket="thumbnails",
                Key=key,
                Body=buffer.getvalue(),
                ContentType=f"image/{img_format.lower()}"
            )
        
        return key
    except Exception as e:
        logger.error(f"Error generating thumbnail: {e}")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Erro ao processar imagem para thumbnail",
        )
