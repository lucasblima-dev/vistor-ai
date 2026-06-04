from typing import Optional
from uuid import UUID
from datetime import datetime
from pydantic import BaseModel, ConfigDict
from app.models.media import MediaType

class PresignedUrlResponse(BaseModel):
    id: UUID
    upload_url: str
    key: str
    expires_in: int = 3600

class MediaOut(BaseModel):
    id: UUID
    inspection_id: UUID
    type: MediaType
    minio_key: str
    thumbnail_key: Optional[str] = None
    thumbnail_url: Optional[str] = None
    mime_type: str
    size_bytes: int
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)

class MediaPresignRequest(BaseModel):
    inspection_id: UUID
    filename: str
    content_type: str
    file_size: int
