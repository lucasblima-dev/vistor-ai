import uuid
from datetime import datetime, timedelta, timezone
from fastapi import HTTPException, status
from pwdlib import PasswordHash
from pwdlib.hashers.bcrypt import BcryptHasher
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from redis.asyncio import Redis

from app.models.user import User, UserRole
from app.schemas.user import UserCreate
from app.schemas.auth import TokenResponse
from app.config import settings
from app.services.token_service import create_access_token

# Configuração explícita para Bcrypt
pwd_context = PasswordHash((BcryptHasher(),))

async def create_user(db: AsyncSession, payload: UserCreate) -> User:
    # Verifica email duplicado
    query = select(User).where(User.email == payload.email)
    result = await db.execute(query)
    if result.scalars().first():
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Este e-mail já está cadastrado."
        )

    # Hash da senha
    hashed_password = pwd_context.hash(payload.password)
    
    new_user = User(
        name=payload.name,
        email=payload.email,
        password=hashed_password,
        role=payload.role
    )
    
    db.add(new_user)
    await db.commit()
    await db.refresh(new_user)
    return new_user

async def login(db: AsyncSession, email: str, password: str, redis_client: Redis) -> TokenResponse:
    query = select(User).where(User.email == email)
    result = await db.execute(query)
    user = result.scalars().first()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Credenciais inválidas."
        )

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Conta desativada. Entre em contato com o administrador."
        )

    # Verifica bloqueio por tentativas falhas
    now = datetime.now(timezone.utc)
    if user.locked_until and user.locked_until > now:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"Conta bloqueada temporariamente. Tente novamente após {user.locked_until.strftime('%H:%M:%S')}."
        )

    # Verifica senha
    try:
        is_valid = pwd_context.verify(password, user.password)
    except Exception:
        # Captura erros de formato de hash ou internos do hasher
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Erro na validação de credenciais."
        )

    if not is_valid:
        user.failed_attempts += 1
        if user.failed_attempts >= 5:
            user.locked_until = now + timedelta(minutes=15)
        
        await db.commit()
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Credenciais inválidas."
        )

    # Captura valores ANTES do commit para evitar erros de lazy-loading em campos Enum
    user_id_str = str(user.id)
    user_role_val = user.role.value

    # Sucesso no login
    user.failed_attempts = 0
    user.locked_until = None
    await db.commit()

    # Gera Access Token usando os valores capturados
    access_token = create_access_token(data={"sub": user_id_str, "role": user_role_val})
    
    # Gera Refresh Token
    refresh_token = str(uuid.uuid4())
    redis_key = f"refresh:{refresh_token}"
    ttl = settings.REFRESH_TOKEN_TTL_DAYS * 86400
    
    await redis_client.setex(redis_key, ttl, user_id_str)

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token
    )

async def refresh_token(refresh_token_str: str, redis_client: Redis, db: AsyncSession) -> TokenResponse:
    redis_key = f"refresh:{refresh_token_str}"
    user_id_bytes = await redis_client.get(redis_key)
    
    if not user_id_bytes:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token de atualização inválido ou expirado."
        )

    user_id_str = user_id_bytes.decode("utf-8")
    query = select(User).where(User.id == uuid.UUID(user_id_str))
    result = await db.execute(query)
    user = result.scalars().first()
    
    if not user or not user.is_active:
        await redis_client.delete(redis_key)
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Usuário inválido ou inativo."
        )

    # Captura valores antes do commit
    current_user_id_str = str(user.id)
    current_user_role_val = user.role.value

    new_access_token = create_access_token(data={"sub": current_user_id_str, "role": current_user_role_val})
    
    new_refresh_token = str(uuid.uuid4())
    new_redis_key = f"refresh:{new_refresh_token}"
    ttl = settings.REFRESH_TOKEN_TTL_DAYS * 86400
    
    await redis_client.delete(redis_key)
    await redis_client.setex(new_redis_key, ttl, current_user_id_str)

    return TokenResponse(
        access_token=new_access_token,
        refresh_token=new_refresh_token
    )

async def logout(refresh_token_str: str, redis_client: Redis) -> None:
    redis_key = f"refresh:{refresh_token_str}"
    await redis_client.delete(redis_key)


async def create_initial_admin_if_not_exists(db: AsyncSession) -> None:
    # Verifica se já existe qualquer usuário com perfil de administrador
    try:
        query = select(User).where(User.role == UserRole.admin)
        result = await db.execute(query)
        admin_exists = result.scalars().first()
    except Exception as e:
        # Se as migrações não tiverem rodado ainda, a tabela 'users' não existirá
        print(f"⚠️ Pulando bootstrap do admin: tabelas não inicializadas ou banco inacessível ({type(e).__name__}).")
        return

    if admin_exists:
        return

    # Se não existe, cria com base nas variáveis de ambiente
    from app.services.audit_service import log_action
    
    # Validações básicas de preenchimento
    if not settings.INITIAL_ADMIN_EMAIL or not settings.INITIAL_ADMIN_PASSWORD:
        return

    hashed_password = pwd_context.hash(settings.INITIAL_ADMIN_PASSWORD)
    
    new_admin = User(
        name=settings.INITIAL_ADMIN_NAME,
        email=settings.INITIAL_ADMIN_EMAIL,
        password=hashed_password,
        role=UserRole.admin,
        is_active=True
    )
    
    db.add(new_admin)
    await db.commit()
    await db.refresh(new_admin)
    
    # Registra no log de auditoria
    await log_action(
        db, 
        user_id=str(new_admin.id), 
        entity="user", 
        entity_id=str(new_admin.id), 
        action="register_bootstrap",
        ip="127.0.0.1"
    )
    print(f"🎉 Administrador de Bootstrap criado com sucesso: {new_admin.email}")
