import csv
import io
import json
from datetime import datetime, timezone
from typing import Optional, List
from uuid import UUID
from sqlalchemy import select, and_
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.inspection import Inspection, InspectionStatus, InspectionSeverity
from app.schemas.inspection import LocationPoint

async def export_data(
    db: AsyncSession,
    format_type: str,
    status: Optional[InspectionStatus] = None,
    severity: Optional[InspectionSeverity] = None,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    category: Optional[str] = None
) -> tuple[io.BytesIO, str]:
    query = select(Inspection).where(Inspection.deleted_at.is_(None))
    
    if status:
        query = query.where(Inspection.status == status)
    if severity:
        query = query.where(Inspection.severity == severity)
    if start_date:
        query = query.where(Inspection.created_at >= start_date)
    if end_date:
        query = query.where(Inspection.created_at <= end_date)
    if category:
        query = query.where(Inspection.category == category)
        
    result = await db.execute(query)
    inspections = result.scalars().all()
    
    output = io.BytesIO()
    filename = f"inspections_{datetime.now(timezone.utc).strftime('%Y%m%d_%H%M%S')}"
    
    if format_type == "csv":
        text_stream = io.StringIO()
        writer = csv.writer(text_stream)
        writer.writerow(["id", "category", "status", "severity", "latitude", "longitude", "created_at"])
        for insp in inspections:
            loc = LocationPoint.parse_wkb(insp.location)
            writer.writerow([
                str(insp.id),
                insp.category,
                insp.status.value if insp.status else "",
                insp.severity.value if insp.severity else "",
                loc.lat,
                loc.lon,
                insp.created_at.isoformat()
            ])
        output.write(text_stream.getvalue().encode('utf-8'))
        filename += ".csv"
    else:  # geojson
        features = []
        for insp in inspections:
            loc = LocationPoint.parse_wkb(insp.location)
            features.append({
                "type": "Feature",
                "geometry": {
                    "type": "Point",
                    "coordinates": [loc.lon, loc.lat]
                },
                "properties": {
                    "id": str(insp.id),
                    "category": insp.category,
                    "status": insp.status.value if insp.status else None,
                    "severity": insp.severity.value if insp.severity else None,
                    "created_at": insp.created_at.isoformat()
                }
            })
        geojson = {
            "type": "FeatureCollection",
            "features": features
        }
        output.write(json.dumps(geojson).encode('utf-8'))
        filename += ".geojson"
        
    output.seek(0)
    return output, filename

async def get_heatmap_data(
    db: AsyncSession,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    severity: Optional[InspectionSeverity] = None,
    category: Optional[str] = None,
    status: Optional[InspectionStatus] = None
) -> dict:
    from sqlalchemy import func
    
    # Query PostGIS: ST_Collect agrupando por severidade
    query = select(
        Inspection.severity,
        func.ST_AsGeoJSON(func.ST_Collect(Inspection.location))
    ).where(Inspection.deleted_at.is_(None))
    
    if start_date:
        query = query.where(Inspection.created_at >= start_date)
    if end_date:
        query = query.where(Inspection.created_at <= end_date)
    if severity:
        query = query.where(Inspection.severity == severity)
    if category:
        query = query.where(Inspection.category == category)
    if status:
        query = query.where(Inspection.status == status)
        
    query = query.group_by(Inspection.severity)
    
    result = await db.execute(query)
    rows = result.all()
    
    features = []
    for sev, geom_json_str in rows:
        if not geom_json_str:
            continue
            
        # Determinar peso com base na severidade (critical=1.0, moderate=0.6, low=0.3)
        if sev == InspectionSeverity.critical:
            weight = 1.0
        elif sev == InspectionSeverity.moderate:
            weight = 0.6
        elif sev == InspectionSeverity.low:
            weight = 0.3
        else:
            weight = 0.1
            
        geom_data = json.loads(geom_json_str)
        
        # Pode vir Point, MultiPoint ou GeometryCollection
        if geom_data["type"] == "Point":
            coords_list = [geom_data["coordinates"]]
        elif geom_data["type"] == "MultiPoint":
            coords_list = geom_data["coordinates"]
        elif geom_data["type"] == "GeometryCollection":
            coords_list = []
            for g in geom_data["geometries"]:
                if g["type"] == "Point":
                    coords_list.append(g["coordinates"])
                elif g["type"] == "MultiPoint":
                    coords_list.extend(g["coordinates"])
        else:
            coords_list = []
            
        for coords in coords_list:
            features.append({
                "type": "Feature",
                "geometry": {
                    "type": "Point",
                    "coordinates": coords
                },
                "properties": {
                    "severity": sev.value if sev else None,
                    "weight": weight
                }
            })
            
    return {
        "type": "FeatureCollection",
        "features": features
    }

