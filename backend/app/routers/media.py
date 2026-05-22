from uuid import uuid4
from fastapi import APIRouter, Depends, HTTPException, status, BackgroundTasks
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.dependencies.db import get_db
from app.dependencies.auth import get_current_user
from app.models.user import User
from app.models.media import Media, MediaType, MediaStatus
from app.schemas.media import PresignedUrlResponse, MediaPresignRequest, MediaOut
from app.services import storage_service, inspection_service
import magic

router = APIRouter()

ALLOWED_MIME_TYPES = {
    "image/jpeg": MediaType.photo,
    "image/png": MediaType.photo,
    "video/mp4": MediaType.video,
    "application/pdf": MediaType.pdf
}

MAX_PHOTO_SIZE = 20 * 1024 * 1024  # 20MB
MAX_VIDEO_SIZE = 100 * 1024 * 1024 # 100MB

@router.post("/presign", response_model=PresignedUrlResponse)
async def get_presigned_url(
    payload: MediaPresignRequest,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user)
):
    await inspection_service.get_by_id(db, payload.inspection_id, user)
    
    if payload.content_type not in ALLOWED_MIME_TYPES:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"MIME type {payload.content_type} não permitido"
        )
    
    media_type = ALLOWED_MIME_TYPES[payload.content_type]
    if media_type == MediaType.photo and payload.file_size > MAX_PHOTO_SIZE:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Foto excede o tamanho máximo de 20MB"
        )
    if media_type == MediaType.video and payload.file_size > MAX_VIDEO_SIZE:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Vídeo excede o tamanho máximo de 100MB"
        )
    
    key = f"{payload.inspection_id}/{uuid4()}_{payload.filename}"
    bucket = "inspections"
    
    upload_url = await storage_service.get_presigned_upload_url(
        bucket, key, payload.content_type
    )
    
    media = Media(
        inspection_id=payload.inspection_id,
        type=media_type,
        status=MediaStatus.pending,
        minio_key=key,
        mime_type=payload.content_type,
        size_bytes=payload.file_size
    )
    db.add(media)
    await db.commit()
    await db.refresh(media)
    
    return PresignedUrlResponse(
        upload_url=upload_url,
        key=key,
        expires_in=3600
    )

@router.post("/{id}/confirm", response_model=MediaOut)
async def confirm_upload(
    id: str,
    background_tasks: BackgroundTasks,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user)
):
    query = select(Media).where(Media.id == id)
    result = await db.execute(query)
    media = result.scalar_one_or_none()
    
    if not media:
        raise HTTPException(status_code=404, detail="Mídia não encontrada")
    
    await inspection_service.get_by_id(db, media.inspection_id, user)
    
    media.status = MediaStatus.confirmed
    await db.commit()
    await db.refresh(media)
    
    if media.type in [MediaType.photo, MediaType.video, MediaType.pdf]:
        background_tasks.add_task(process_media_upload, str(media.id))
        
    return media

async def process_media_upload(media_id: str):
    from app.database import async_session_maker
    async with async_session_maker() as db:
        query = select(Media).where(Media.id == media_id)
        result = await db.execute(query)
        media = result.scalar_one_or_none()
        if not media:
            return

        try:
            async with storage_service.get_s3_client_context() as client:
                response = await client.get_object(Bucket="inspections", Key=media.minio_key)
                file_bytes = await response["Body"].read()

            mime = magic.from_buffer(file_bytes, mime=True)
            if mime != media.mime_type:
                import logging
                logging.warning(f"MIME type mismatch for media {media_id}: expected {media.mime_type}, got {mime}")
            
            if media.type == MediaType.photo:
                thumb_key = await storage_service.generate_thumbnail(file_bytes, media.minio_key)
                media.thumbnail_key = thumb_key
                await db.commit()
                        
        except Exception as e:
            import logging
            logging.error(f"Error processing upload for media {media_id}: {e}")

@router.get("/{id}/url")
async def get_download_url(
    id: str,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user)
):
    query = select(Media).where(Media.id == id)
    result = await db.execute(query)
    media = result.scalar_one_or_none()
    
    if not media:
        raise HTTPException(status_code=404, detail="Mídia não encontrada")
    
    await inspection_service.get_by_id(db, media.inspection_id, user)
    
    if media.status != MediaStatus.confirmed:
        raise HTTPException(status_code=400, detail="Upload da mídia ainda não foi confirmado")
        
    download_url = await storage_service.get_presigned_download_url("inspections", media.minio_key)
    
    return {"url": download_url}
