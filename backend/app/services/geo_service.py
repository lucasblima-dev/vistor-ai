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
    severity: Optional[InspectionSeverity] = None
) -> tuple[io.BytesIO, str]:
    query = select(Inspection).where(Inspection.deleted_at.is_(None))
    
    if status:
        query = query.where(Inspection.status == status)
    if severity:
        query = query.where(Inspection.severity == severity)
        
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
        media_type = "text/csv"
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
        media_type = "application/geo+json"
        
    output.seek(0)
    return output, filename
