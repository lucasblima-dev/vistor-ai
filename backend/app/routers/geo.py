from datetime import datetime
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, Response, status
from fastapi.responses import StreamingResponse
from sqlalchemy.ext.asyncio import AsyncSession

from app.dependencies.auth import get_current_user, require_role
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
    radius_m: float = Query(300, ge=50, le=50000),
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
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    category: Optional[str] = None,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(require_role(["manager", "admin"])),
):
    output, filename = await geo_service.export_data(
        db, format, status, severity, start_date, end_date, category
    )
    
    # Compressão gzip obrigatória na resposta
    import gzip
    compressed_content = gzip.compress(output.getvalue())
    
    media_type = "application/geo+json" if format == "geojson" else "text/csv"
    
    return Response(
        content=compressed_content,
        media_type=media_type,
        headers={
            "Content-Encoding": "gzip",
            "Content-Disposition": f"attachment; filename={filename}.gz"
        }
    )

@router.get("/heatmap")
async def get_heatmap(
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    severity: Optional[InspectionSeverity] = None,
    category: Optional[str] = None,
    status: Optional[InspectionStatus] = None,
    db: AsyncSession = Depends(get_db),
    user: User = Depends(require_role(["manager", "admin"])),
):
    geojson = await geo_service.get_heatmap_data(
        db,
        start_date=start_date,
        end_date=end_date,
        severity=severity,
        category=category,
        status=status
    )
    
    # Compressão gzip obrigatória na resposta
    import gzip
    import json
    compressed_content = gzip.compress(json.dumps(geojson).encode("utf-8"))
    
    return Response(
        content=compressed_content,
        media_type="application/geo+json",
        headers={
            "Content-Encoding": "gzip",
            "Content-Disposition": "attachment; filename=heatmap.geojson.gz"
        }
    )

