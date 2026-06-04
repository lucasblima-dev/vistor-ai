import enum
from sqlalchemy import Column, String, Integer, DateTime, Enum, ForeignKey, text, func, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.database import Base

class MediaType(str, enum.Enum):
    photo = "photo"
    video = "video"
    pdf = "pdf"

class MediaStatus(str, enum.Enum):
    pending = "pending"
    confirmed = "confirmed"
    error = "error"

class Media(Base):
    __tablename__ = "media"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    inspection_id = Column(UUID(as_uuid=True), ForeignKey("inspections.id", ondelete="CASCADE"), nullable=False)
    type = Column(Enum(MediaType, name="media_type_enum"), nullable=False)
    status = Column(Enum(MediaStatus, name="media_status_enum"), server_default="pending", nullable=False)
    minio_key = Column(Text, nullable=False)
    thumbnail_key = Column(Text, nullable=True)
    mime_type = Column(String(80), nullable=False)
    size_bytes = Column(Integer, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    inspection = relationship("Inspection", back_populates="media")
