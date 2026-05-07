from sqlalchemy import Column, String, Integer, DateTime, Enum, ForeignKey, text, func, Text
from sqlalchemy.dialects.postgresql import UUID
from app.database import Base
import enum

class MediaType(str, enum.Enum):
    photo = "photo"
    video = "video"
    pdf = "pdf"

class Media(Base):
    __tablename__ = "media"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    inspection_id = Column(UUID(as_uuid=True), ForeignKey("inspections.id", ondelete="CASCADE"), nullable=False)
    type = Column(Enum(MediaType, name="media_type_enum"), nullable=False)
    minio_key = Column(Text, nullable=False)
    thumbnail_key = Column(Text, nullable=True)
    mime_type = Column(String(80), nullable=False)
    size_bytes = Column(Integer, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
