import asyncio
import pytest
import pytest_asyncio
from typing import AsyncGenerator
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from sqlalchemy import text
from sqlalchemy.pool import NullPool
from httpx import AsyncClient, ASGITransport
from fakeredis.aioredis import FakeRedis

from app.main import app
from app.database import Base
from app.config import settings
from app.dependencies.db import get_db, get_redis
from app.models.user import User, UserRole
from app.services.auth_service import create_user
from app.schemas.user import UserCreate

# Configuração do banco de teste
TEST_DB_NAME = "vistor_ai_test"
SQLALCHEMY_DATABASE_URL_TEST = settings.DATABASE_URL.replace("vistor_ai", TEST_DB_NAME)

@pytest.fixture(scope="session")
def event_loop():
    loop = asyncio.new_event_loop()
    yield loop
    loop.close()

async def create_test_db():
    admin_url = settings.DATABASE_URL.replace("vistor_ai", "postgres")
    admin_engine = create_async_engine(admin_url, isolation_level="AUTOCOMMIT")
    async with admin_engine.connect() as conn:
        result = await conn.execute(text(f"SELECT 1 FROM pg_database WHERE datname='{TEST_DB_NAME}'"))
        if not result.fetchone():
            await conn.execute(text(f"CREATE DATABASE {TEST_DB_NAME}"))
    await admin_engine.dispose()

@pytest_asyncio.fixture(scope="session", autouse=True)
async def setup_db():
    await create_test_db()
    
    # Habilita extensões
    ext_engine = create_async_engine(SQLALCHEMY_DATABASE_URL_TEST, isolation_level="AUTOCOMMIT")
    async with ext_engine.connect() as conn:
        await conn.execute(text("CREATE EXTENSION IF NOT EXISTS postgis"))
        await conn.execute(text("CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\""))
    await ext_engine.dispose()

    engine = create_async_engine(SQLALCHEMY_DATABASE_URL_TEST, poolclass=NullPool)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    
    yield
    
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
    await engine.dispose()

@pytest_asyncio.fixture
async def db_session() -> AsyncGenerator[AsyncSession, None]:
    engine = create_async_engine(SQLALCHEMY_DATABASE_URL_TEST, poolclass=NullPool)
    session_factory = async_sessionmaker(bind=engine, class_=AsyncSession, expire_on_commit=False)
    async with session_factory() as session:
        yield session
        await session.execute(text("TRUNCATE users, audit_log CASCADE"))
        await session.commit()
    await engine.dispose()

@pytest_asyncio.fixture
async def redis_client():
    return FakeRedis()

@pytest_asyncio.fixture
async def client(db_session: AsyncSession, redis_client: FakeRedis) -> AsyncGenerator[AsyncClient, None]:
    app.dependency_overrides[get_db] = lambda: db_session
    app.dependency_overrides[get_redis] = lambda: redis_client
    
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        yield ac
    
    app.dependency_overrides.clear()

@pytest_asyncio.fixture
async def test_user(db_session: AsyncSession):
    payload = UserCreate(
        name="Test User",
        email="test@example.com",
        password="password123",
        role=UserRole.inspector
    )
    return await create_user(db_session, payload)

@pytest_asyncio.fixture
async def inspector_token(client: AsyncClient, db_session: AsyncSession):
    payload = UserCreate(
        name="Inspector",
        email="inspector@vistor.ai",
        password="password123",
        role=UserRole.inspector
    )
    await create_user(db_session, payload)
    response = await client.post("/api/auth/login", json={
        "email": "inspector@vistor.ai",
        "password": "password123"
    })
    return response.json()["access_token"]

@pytest_asyncio.fixture
async def manager_token(client: AsyncClient, db_session: AsyncSession):
    payload = UserCreate(
        name="Manager",
        email="manager@vistor.ai",
        password="password123",
        role=UserRole.manager
    )
    await create_user(db_session, payload)
    response = await client.post("/api/auth/login", json={
        "email": "manager@vistor.ai",
        "password": "password123"
    })
    return response.json()["access_token"]
