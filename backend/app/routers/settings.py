import uuid
from fastapi import APIRouter, Depends, HTTPException, status
from redis.asyncio import Redis
from sqlalchemy.ext.asyncio import AsyncSession

from app.dependencies.auth import require_role
from app.dependencies.db import get_db, get_redis
from app.models.user import User
from app.schemas.settings import AISettingsOut, AISettingsUpdate
from app.services import audit_service
from app.config import settings

router = APIRouter()

REDIS_KEY_MODEL_ID = "settings:ai:model_id"
REDIS_KEY_THRESHOLD = "settings:ai:confidence_threshold"

@router.get("/ai", response_model=AISettingsOut)
async def get_ai_settings(
    redis: Redis = Depends(get_redis),
    current_user: User = Depends(require_role(["admin", "manager"]))
):
    model_id = await redis.get(REDIS_KEY_MODEL_ID)
    threshold = await redis.get(REDIS_KEY_THRESHOLD)
    
    return {
        "model_id": model_id if model_id else settings.HF_MODEL_ID,
        "confidence_threshold": float(threshold) if threshold is not None else settings.HF_CONFIDENCE_THRESHOLD
    }

@router.patch("/ai", response_model=AISettingsOut)
async def update_ai_settings(
    payload: AISettingsUpdate,
    db: AsyncSession = Depends(get_db),
    redis: Redis = Depends(get_redis),
    current_user: User = Depends(require_role(["admin"]))
):
    old_model_id = await redis.get(REDIS_KEY_MODEL_ID)
    old_threshold = await redis.get(REDIS_KEY_THRESHOLD)
    
    old_value = {
        "model_id": old_model_id if old_model_id else settings.HF_MODEL_ID,
        "confidence_threshold": float(old_threshold) if old_threshold is not None else settings.HF_CONFIDENCE_THRESHOLD
    }
    
    new_model_id = payload.model_id if payload.model_id is not None else old_value["model_id"]
    new_threshold = payload.confidence_threshold if payload.confidence_threshold is not None else old_value["confidence_threshold"]
    
    # Update in Redis
    await redis.set(REDIS_KEY_MODEL_ID, new_model_id)
    await redis.set(REDIS_KEY_THRESHOLD, str(new_threshold))
    
    new_value = {
        "model_id": new_model_id,
        "confidence_threshold": new_threshold
    }
    
    await audit_service.log_action(
        db=db,
        user_id=str(current_user.id),
        entity="settings",
        entity_id=uuid.UUID(int=0), # Global settings representation
        action="ai_settings_updated",
        old_value=old_value,
        new_value=new_value
    )
    
    return new_value
