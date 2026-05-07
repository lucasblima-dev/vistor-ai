from sqlalchemy import Column, String, Float, Text, DateTime, Enum, ForeignKey, text, func
from sqlalchemy.dialects.postgresql import UUID, JSONB
from geoalchemy2 import Geometry
from app.database import Base
import enum

class InspectionSeverity(str, enum.Enum):
    critical = "critical"
    moderate = "moderate"
    low = "low"
    pending_review = "pending_review"

class InspectionStatus(str, enum.Enum):
    draft = "draft"
    open = "open"
    in_progress = "in_progress"
    resolved = "resolved"
    archived = "archived"

class Inspection(Base):
    __tablename__ = "inspections"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    inspector_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    assigned_to = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    category = Column(String(60), nullable=False)
    description = Column(Text, nullable=True)
    severity = Column(Enum(InspectionSeverity, name="severity_enum"), nullable=True)
    ai_label = Column(String, nullable=True)
    ai_score = Column(Float, nullable=True)
    ai_raw = Column(JSONB, nullable=True)
    human_label = Column(String, nullable=True)
    location = Column(Geometry("POINT", srid=4326), nullable=False)
    gps_accuracy = Column(Float, nullable=False)
    address = Column(Text, nullable=True)
    status = Column(Enum(InspectionStatus, name="status_enum"), nullable=False, server_default="open")
    deleted_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)
