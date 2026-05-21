from fastapi import APIRouter, Depends, Request, status
from sqlalchemy.ext.asyncio import AsyncSession
from redis.asyncio import Redis

from app.dependencies.db import get_db, get_redis
from app.dependencies.auth import get_current_user
from app.schemas.auth import LoginRequest, TokenResponse, RefreshRequest, UserOut
from app.schemas.user import UserCreate
from app.services import auth_service, audit_service
from app.models.user import User

router = APIRouter()

@router.post("/login", response_model=TokenResponse)
async def login(
    payload: LoginRequest,
    request: Request,
    db: AsyncSession = Depends(get_db),
    redis: Redis = Depends(get_redis)
):
    token_response = await auth_service.login(db, payload.email, payload.password, redis)
    
    # Busca o user_id do token para o log (precisamos do ID do usuário que logou)
    # No login bem sucedido, o auth_service.login já retornou o token.
    # Para o audit log, o ideal seria o login retornar o user_id também ou buscarmos.
    # Vamos assumir que o login foi bem sucedido aqui.
    # Nota: Em produção, poderíamos buscar o user_id no DB novamente ou mudar a assinatura do login.
    # Para manter a simplicidade solicitada:
    from app.services.token_service import decode_access_token
    payload_jwt = decode_access_token(token_response.access_token)
    user_id = payload_jwt.get("sub")
    
    await audit_service.log_action(
        db, user_id=user_id, entity="user", entity_id=user_id, 
        action="login", ip=request.client.host
    )
    
    return token_response

@router.post("/refresh", response_model=TokenResponse)
async def refresh(
    payload: RefreshRequest,
    db: AsyncSession = Depends(get_db),
    redis: Redis = Depends(get_redis)
):
    return await auth_service.refresh_token(payload.refresh_token, redis, db)

@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
async def logout(
    payload: RefreshRequest,
    db: AsyncSession = Depends(get_db),
    redis: Redis = Depends(get_redis),
    user: User = Depends(get_current_user)
):
    await auth_service.logout(payload.refresh_token, redis)
    await audit_service.log_action(
        db, user_id=str(user.id), entity="user", entity_id=str(user.id), 
        action="logout"
    )

@router.get("/me", response_model=UserOut)
async def get_me(user: User = Depends(get_current_user)):
    return user
