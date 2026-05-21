import uuid
from typing import Any, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.audit_log import AuditLog

async def log_action(
    db: AsyncSession,
    user_id: str,
    entity: str,
    entity_id: str,
    action: str,
    old_value: Optional[Any] = None,
    new_value: Optional[Any] = None,
    ip: Optional[str] = None
) -> AuditLog:
    # Garante que user_id e entity_id sejam UUIDs se forem strings
    u_id = uuid.UUID(user_id) if isinstance(user_id, str) else user_id
    e_id = uuid.UUID(entity_id) if isinstance(entity_id, str) else entity_id

    log_entry = AuditLog(
        user_id=u_id,
        entity=entity,
        entity_id=e_id,
        action=action,
        old_value=old_value,
        new_value=new_value,
        ip_address=ip
    )
    db.add(log_entry)
    await db.commit()
    await db.refresh(log_entry)
    return log_entry
