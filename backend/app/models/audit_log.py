from sqlalchemy import Column, String, DateTime, ForeignKey, text, func
from sqlalchemy.dialects.postgresql import UUID, JSONB, INET
from app.database import Base

class AuditLog(Base):
    __tablename__ = "audit_log"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text("gen_random_uuid()"))
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    entity = Column(String(60), nullable=False)
    entity_id = Column(UUID(as_uuid=True), nullable=False)
    action = Column(String(30), nullable=False)
    old_value = Column(JSONB, nullable=True)
    new_value = Column(JSONB, nullable=True)
    ip_address = Column(INET, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
