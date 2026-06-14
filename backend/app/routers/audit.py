from typing import List, Optional
from uuid import UUID
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.dependencies.auth import get_current_user, require_role
from app.dependencies.db import get_db
from app.models.user import User
from app.models.audit_log import AuditLog
from app.schemas.audit_log import AuditLogOut

router = APIRouter()

@router.get("/", response_model=List[AuditLogOut])
async def list_audit_logs(
    entity: Optional[str] = None,
    entity_id: Optional[UUID] = None,
    limit: int = Query(50, ge=1, le=100),
    offset: int = Query(0, ge=0),
    db: AsyncSession = Depends(get_db),
    user: User = Depends(require_role(["admin"])),
):
    query = select(AuditLog, User.name).outerjoin(User, AuditLog.user_id == User.id)
    
    if entity is not None:
        query = query.where(AuditLog.entity == entity)
    if entity_id is not None:
        query = query.where(AuditLog.entity_id == entity_id)
        
    query = query.order_by(AuditLog.created_at.desc()).offset(offset).limit(limit)
    
    result = await db.execute(query)
    logs = []
    for row in result.all():
        audit_log, user_name = row
        # Atribui dinamicamente o atributo user_name para conversão do Pydantic
        audit_log.user_name = user_name
        if audit_log.ip_address is not None:
            audit_log.ip_address = str(audit_log.ip_address)
        logs.append(audit_log)
        
    return logs
