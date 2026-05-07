from sqlalchemy import Column, String, DateTime, ForeignKey, text, func, Text
from sqlalchemy.dialects.postgresql import UUID
from app.database import Base

class Report(Base):
    __tablename__ = "reports"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    inspection_id = Column(UUID(as_uuid=True), ForeignKey("inspections.id"), nullable=False)
    generated_by = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    minio_key = Column(Text, nullable=False)
    sha256 = Column(String(64), nullable=False)
    signature_key = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
