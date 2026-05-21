from uuid import UUID
from datetime import datetime, timezone
from typing import Optional, List
from sqlalchemy import select, update as sa_update, and_, or_, desc, func as sa_func, cast
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload
from fastapi import HTTPException, status

from app.models.inspection import Inspection, InspectionStatus
from app.models.user import User, UserRole
from app.schemas.inspection import InspectionCreate, InspectionUpdate
from app.services import audit_service
from geoalchemy2 import Geometry as GeoGeometry, Geography
from geoalchemy2.functions import ST_GeomFromText, ST_DWithin, ST_Distance, ST_MakePoint

async def create(db: AsyncSession, payload: InspectionCreate, owner_id: UUID) -> Inspection:
    # Converte lat/lon para WKT (Longitude primeiro no WKT POINT)
    wkt_point = f"POINT({payload.lon} {payload.lat})"
    
    inspection = Inspection(
        inspector_id=owner_id,
        category=payload.category,
        description=payload.description,
        location=ST_GeomFromText(wkt_point, srid=4326),
        gps_accuracy=payload.gps_accuracy if payload.gps_accuracy is not None else 0.0,
        status=InspectionStatus.open
    )
    
    db.add(inspection)
    await db.commit()
    
    query = select(Inspection).where(Inspection.id == inspection.id).options(selectinload(Inspection.inspector))
    result = await db.execute(query)
    return result.scalar_one()

async def get_by_id(db: AsyncSession, inspection_id: UUID, current_user: User) -> Inspection:
    query = select(Inspection).where(
        and_(
            Inspection.id == inspection_id,
            Inspection.deleted_at.is_(None)
        )
    ).options(selectinload(Inspection.inspector))
    result = await db.execute(query)
    inspection = result.scalar_one_or_none()
    
    if not inspection:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Inspeção não encontrada"
        )
    
    # IDOR check
    if current_user.role == UserRole.inspector:
        is_owner = inspection.inspector_id == current_user.id
        is_assigned = inspection.assigned_to == current_user.id
        if not (is_owner or is_assigned):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Acesso negado — recurso pertence a outro usuário"
            )
            
    return inspection

async def list_by_user(
    db: AsyncSession, 
    current_user: User, 
    status_filter: Optional[InspectionStatus] = None, 
    limit: int = 20, 
    cursor: Optional[datetime] = None
) -> List[Inspection]:
    query = select(Inspection).where(Inspection.deleted_at.is_(None)).options(selectinload(Inspection.inspector))
    
    if current_user.role == UserRole.inspector:
        query = query.where(
            or_(
                Inspection.inspector_id == current_user.id,
                Inspection.assigned_to == current_user.id
            )
        )
    
    if status_filter:
        query = query.where(Inspection.status == status_filter)
        
    if cursor:
        query = query.where(Inspection.created_at < cursor)
        
    query = query.order_by(desc(Inspection.created_at)).limit(limit)
    
    result = await db.execute(query)
    return list(result.scalars().all())

async def update(
    db: AsyncSession, 
    inspection_id: UUID, 
    payload: InspectionUpdate, 
    current_user: User
) -> Inspection:
    inspection = await get_by_id(db, inspection_id, current_user)
    
    old_value = {
        "status": inspection.status,
        "description": inspection.description,
        "assigned_to": str(inspection.assigned_to) if inspection.assigned_to else None,
        "human_label": inspection.human_label
    }
    
    if payload.status and payload.status != inspection.status:
        # Exemplo: Não pode voltar de 'resolved' para 'open'
        if inspection.status == InspectionStatus.resolved and payload.status == InspectionStatus.open:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="Transição de status inválida: não é possível reabrir uma inspeção resolvida diretamente para 'open'"
            )
        # Mais regras podem ser adicionadas aqui conforme RNs
        inspection.status = payload.status
        
    if payload.description is not None:
        inspection.description = payload.description
    
    if payload.assigned_to is not None:
        inspection.assigned_to = payload.assigned_to
        
    if payload.human_label is not None:
        inspection.human_label = payload.human_label
        
    await db.commit()
    await db.refresh(inspection)

    query = select(Inspection).where(Inspection.id == inspection.id).options(selectinload(Inspection.inspector))
    result = await db.execute(query)
    inspection = result.scalar_one()
    
    new_value = payload.model_dump(exclude_unset=True)
    
    await audit_service.log_action(
        db,
        user_id=current_user.id,
        entity="inspection",
        entity_id=str(inspection.id),
        action="update",
        old_value=old_value,
        new_value=new_value
    )
    
    return inspection

async def soft_delete(db: AsyncSession, inspection_id: UUID, current_user: User) -> None:
    inspection = await get_by_id(db, inspection_id, current_user)
    
    inspection.deleted_at = datetime.now(timezone.utc)
    
    await db.commit()
    
    await audit_service.log_action(
        db,
        user_id=current_user.id,
        entity="inspection",
        entity_id=str(inspection.id),
        action="delete"
    )

async def get_nearby(
    db: AsyncSession, 
    lat: float, 
    lon: float, 
    radius_m: float, 
    current_user: User
) -> List[tuple[Inspection, float]]:
    # ST_MakePoint(lon, lat) -> SRID 4326
    point = ST_MakePoint(lon, lat)
    
    query = select(
        Inspection, 
        ST_Distance(
            cast(Inspection.location, Geography),
            cast(point, Geography)
        ).label("distance_m")
    ).where(
        and_(
            Inspection.deleted_at.is_(None),
            ST_DWithin(
                cast(Inspection.location, Geography),
                cast(point, Geography),
                radius_m
            )
        )
    ).options(selectinload(Inspection.inspector)).order_by("distance_m")
    
    result = await db.execute(query)
    return list(result.all())
