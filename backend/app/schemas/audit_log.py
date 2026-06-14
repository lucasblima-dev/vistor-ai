from pydantic import BaseModel, field_validator
from uuid import UUID
from datetime import datetime
from typing import Optional, Dict, Any

class AuditLogOut(BaseModel):
    id: UUID
    user_id: Optional[UUID] = None
    entity: str
    entity_id: UUID
    action: str
    old_value: Optional[Dict[str, Any]] = None
    new_value: Optional[Dict[str, Any]] = None
    ip_address: Optional[str] = None
    created_at: datetime
    user_name: Optional[str] = None

    @field_validator('ip_address', mode='before')
    @classmethod
    def serialize_ip(cls, v: Any) -> Optional[str]:
        if v is None:
            return None
        return str(v)

    class Config:
        from_attributes = True
