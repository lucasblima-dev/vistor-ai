from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from fastapi.responses import StreamingResponse
from sqlalchemy.ext.asyncio import AsyncSession

from app.dependencies.auth import get_current_user
from app.dependencies.db import get_db
from app.models.user import User
from app.models.inspection import InspectionStatus, InspectionSeverity
from app.schemas.inspection import InspectionNearby, InspectionOut
from app.services import inspection_service, geo_service

router = APIRouter()

@router.get("/nearby", response_model=List[InspectionNearby])
async def get_nearby_inspections(
    lat: float = Query(..., ge=-90, le=90),
    lon: float = Query(..., ge=-180, le=180),
    radius_m: float = Query(300, ge=50, le=5000),
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    results = await inspection_service.get_nearby(db, lat, lon, radius_m, current_user=user)
    # results é List[tuple[Inspection, float]]
    return [{"inspection": r[0], "distance_m": r[1]} for r in results]

@router.get("/export")
async def export_inspections(
    format: str = Query("geojson", pattern="^(geojson|csv)$"),
    status: Optional[InspectionStatus] = None,
    severity: Optional[InspectionSeverity] = None,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
):
    output, filename = await geo_service.export_data(db, format, status, severity)
    
    media_type = "application/geo+json" if format == "geojson" else "text/csv"
    
    return StreamingResponse(
        output,
        media_type=media_type,
        headers={"Content-Disposition": f"attachment; filename={filename}"}
    )
