from typing import List, Optional
from uuid import UUID
from datetime import datetime
from fastapi import APIRouter, Depends, status, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.dependencies.auth import get_current_user
from app.dependencies.db import get_db
from app.models.user import User
from app.models.inspection import InspectionStatus, InspectionSeverity
from app.schemas.inspection import InspectionCreate, InspectionUpdate, InspectionOut
from app.schemas.audit_log import AuditLogOut
from app.services import inspection_service

router = APIRouter()

@router.post("/", response_model=InspectionOut, status_code=status.HTTP_201_CREATED)
async def create_inspection(
    payload: InspectionCreate,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    return await inspection_service.create(db, payload, owner_id=user.id)

@router.get("/", response_model=List[InspectionOut])
async def list_inspections(
    status: Optional[InspectionStatus] = None,
    severity: Optional[InspectionSeverity] = None,
    limit: int = Query(20, ge=1, le=100),
    cursor: Optional[datetime] = None,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    return await inspection_service.list_by_user(
        db, 
        current_user=user, 
        status_filter=status, 
        severity_filter=severity,
        limit=limit, 
        cursor=cursor
    )

@router.get("/{id}", response_model=InspectionOut)
async def get_inspection(
    id: UUID,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    return await inspection_service.get_by_id(db, id, current_user=user)

@router.patch("/{id}", response_model=InspectionOut)
async def update_inspection(
    id: UUID,
    payload: InspectionUpdate,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    return await inspection_service.update(db, id, payload, current_user=user)

@router.delete("/{id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_inspection(
    id: UUID,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    await inspection_service.soft_delete(db, id, current_user=user)

@router.post("/{id}/reclassify", response_model=InspectionOut)
async def reclassify_inspection(
    id: UUID,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    return await inspection_service.reclassify(db, id, current_user=user)

@router.get("/{id}/history", response_model=List[AuditLogOut])
async def get_inspection_history(
    id: UUID,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    return await inspection_service.get_history(db, id, current_user=user)
