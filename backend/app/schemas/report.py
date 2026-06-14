from pydantic import BaseModel, ConfigDict
from uuid import UUID
from datetime import datetime
from typing import Optional

class ReportCreate(BaseModel):
    inspection_id: UUID

class ReportOut(BaseModel):
    id: UUID
    inspection_id: UUID
    generated_by: UUID
    generator_name: Optional[str] = None
    inspection_title: Optional[str] = None
    minio_key: str
    sha256: str
    download_url: Optional[str] = None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
