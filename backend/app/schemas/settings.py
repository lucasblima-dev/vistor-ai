from pydantic import BaseModel, Field
from typing import Optional

class AISettingsUpdate(BaseModel):
    model_id: Optional[str] = None
    confidence_threshold: Optional[float] = Field(None, ge=0.0, le=1.0)

class AISettingsOut(BaseModel):
    model_id: str
    confidence_threshold: float
