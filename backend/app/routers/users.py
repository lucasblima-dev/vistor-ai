from typing import Optional
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from pydantic import BaseModel
import magic
from app.dependencies.db import get_db
from app.dependencies.auth import get_current_user, require_role
from app.models.user import User, UserRole
from app.schemas.user import UserOut, UserUpdate, UserChangePassword, UserCreate

router = APIRouter()

class FCMTokenUpdate(BaseModel):
    fcm_token: str

@router.patch("/me/fcm-token", status_code=status.HTTP_204_NO_CONTENT)
async def update_fcm_token(
    payload: FCMTokenUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    current_user.fcm_token = payload.fcm_token
    await db.commit()
    return

@router.patch("/me", response_model=UserOut)
async def update_me(
    payload: UserUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if payload.email is not None and payload.email != current_user.email:
        query = select(User).where(User.email == payload.email)
        existing = await db.scalar(query)
        if existing:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Este email já está sendo utilizado."
            )
        current_user.email = payload.email
    
    if payload.name is not None:
        current_user.name = payload.name
        
    await db.commit()
    await db.refresh(current_user)
    
    from app.services import storage_service
    out = UserOut.model_validate(current_user)
    if current_user.avatar_key:
        out.avatar_url = await storage_service.get_presigned_download_url("avatars", current_user.avatar_key)
    return out

@router.post("/me/avatar", response_model=UserOut)
async def upload_avatar(
    file: UploadFile = File(...),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    contents = await file.read()
    mime = magic.from_buffer(contents, mime=True)
    if mime not in ["image/jpeg", "image/png"]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Tipo de arquivo não suportado. Apenas JPEG ou PNG são permitidos."
        )
    
    ext = "jpg" if mime == "image/jpeg" else "png"
    key = f"{current_user.id}.{ext}"
    
    from app.services import storage_service
    async with storage_service.get_s3_client_context() as client:
        await client.put_object(
            Bucket="avatars",
            Key=key,
            Body=contents,
            ContentType=mime,
        )
    
    current_user.avatar_key = key
    await db.commit()
    await db.refresh(current_user)
    
    out = UserOut.model_validate(current_user)
    out.avatar_url = await storage_service.get_presigned_download_url("avatars", key)
    return out

@router.post("/me/change-password", status_code=status.HTTP_204_NO_CONTENT)
async def change_password(
    payload: UserChangePassword,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    from app.services.auth_service import pwd_context
    
    if not pwd_context.verify(payload.current_password, current_user.password):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="A senha atual está incorreta."
        )
        
    current_user.password = pwd_context.hash(payload.new_password)
    await db.commit()
    return

# --- Novas rotas para gerenciamento de usuários ---

class UserAdminUpdate(BaseModel):
    role: Optional[UserRole] = None
    is_active: Optional[bool] = None

@router.get("/", response_model=list[UserOut])
async def list_users(
    role: Optional[UserRole] = None,
    is_active: Optional[bool] = None,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(require_role(["manager", "admin"])),
):
    query = select(User)
    if role is not None:
        query = query.where(User.role == role)
    if is_active is not None:
        query = query.where(User.is_active == is_active)
    
    query = query.order_by(User.name)
    result = await db.execute(query)
    users = result.scalars().all()
    
    from app.services import storage_service
    out_users = []
    for user in users:
        out = UserOut.model_validate(user)
        if user.avatar_key:
            out.avatar_url = await storage_service.get_presigned_download_url("avatars", user.avatar_key)
        out_users.append(out)
    return out_users

@router.patch("/{user_id}", response_model=UserOut)
async def update_user(
    user_id: UUID,
    payload: UserAdminUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(require_role(["admin"])),
):
    if user_id == current_user.id:
        if payload.is_active is False:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Você não pode desativar sua própria conta."
            )
        if payload.role is not None and payload.role != current_user.role:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Você não pode alterar seu próprio papel (role)."
            )

    query = select(User).where(User.id == user_id)
    result = await db.execute(query)
    user = result.scalars().first()
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Usuário não encontrado."
        )
        
    if payload.role is not None:
        user.role = payload.role
    if payload.is_active is not None:
        user.is_active = payload.is_active
        
    await db.commit()
    await db.refresh(user)
    
    from app.services import storage_service
    out = UserOut.model_validate(user)
    if user.avatar_key:
        out.avatar_url = await storage_service.get_presigned_download_url("avatars", user.avatar_key)
    return out

@router.post("/", response_model=UserOut, status_code=status.HTTP_201_CREATED)
async def create_user(
    payload: UserCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(require_role(["admin"])),
):
    query = select(User).where(User.email == payload.email)
    existing = await db.scalar(query)
    if existing:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Este email já está sendo utilizado."
        )
    
    from app.services import auth_service, audit_service
    user = await auth_service.create_user(db, payload)
    
    await audit_service.log_action(
        db, user_id=str(current_user.id), entity="user", entity_id=str(user.id), 
        action="user_created"
    )
    
    return UserOut.model_validate(user)
