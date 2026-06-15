from typing import Optional, Any, List
from uuid import UUID
from datetime import datetime
from pydantic import BaseModel, Field, ConfigDict, field_validator
import struct
from app.models.inspection import InspectionStatus, InspectionSeverity
from app.schemas.user import UserOut
from app.schemas.media import MediaOut

class LocationPoint(BaseModel):
    lat: float
    lon: float

    @classmethod
    def parse_wkb(cls, wkb_data: Any) -> 'LocationPoint':
        if isinstance(wkb_data, dict) and "lat" in wkb_data and "lon" in wkb_data:
            return cls(lat=wkb_data["lat"], lon=wkb_data["lon"])
        if hasattr(wkb_data, "data"):
            wkb_data = wkb_data.data
        if isinstance(wkb_data, str):
            try:
                wkb_data = bytes.fromhex(wkb_data)
            except ValueError:
                pass
        
        if isinstance(wkb_data, bytes) and len(wkb_data) >= 21:
            byte_order = wkb_data[0]
            endian = '<' if byte_order == 1 else '>'
            geom_type = struct.unpack(f"{endian}I", wkb_data[1:5])[0]
            offset = 5
            if geom_type & 0x20000000:
                offset = 9
            if len(wkb_data) >= offset + 16:
                x, y = struct.unpack(f"{endian}dd", wkb_data[offset:offset+16])
                return cls(lat=y, lon=x)
        
        # Fallback
        return cls(lat=0.0, lon=0.0)

class InspectionCreate(BaseModel):
    title: str = Field(..., max_length=100)
    category: str = Field(..., max_length=60)
    description: Optional[str] = None
    lat: float = Field(..., ge=-90.0, le=90.0)
    lon: float = Field(..., ge=-180.0, le=180.0)
    gps_accuracy: Optional[float] = None
    address: Optional[str] = None

class InspectionUpdate(BaseModel):
    status: Optional[InspectionStatus] = None
    severity: Optional[InspectionSeverity] = None
    description: Optional[str] = None
    assigned_to: Optional[UUID] = None
    human_label: Optional[str] = None

class InspectionOut(BaseModel):
    id: UUID
    inspector_id: UUID
    assigned_to: Optional[UUID] = None
    title: str
    category: str
    description: Optional[str] = None
    severity: Optional[InspectionSeverity] = None
    ai_label: Optional[str] = None
    ai_score: Optional[float] = None
    ai_raw: Optional[Any] = None
    human_label: Optional[str] = None
    location: LocationPoint
    gps_accuracy: float
    address: Optional[str] = None
    status: InspectionStatus
    deleted_at: Optional[datetime] = None
    created_at: datetime
    updated_at: datetime
    
    inspector: UserOut
    assigned: Optional[UserOut] = None
    media: List[MediaOut] = []
 
    model_config = ConfigDict(from_attributes=True)

    @field_validator('location', mode='before')
    @classmethod
    def convert_location(cls, v: Any) -> Any:
        if isinstance(v, LocationPoint):
            return v
        return LocationPoint.parse_wkb(v)

class InspectionNearby(BaseModel):
    inspection: InspectionOut
    distance_m: float
