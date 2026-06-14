import asyncio
import sys
from unittest.mock import MagicMock

# Mock problematic libraries for Windows environment (Pre-emptive)
if sys.platform == "win32":
    # Mock magic
    try:
        import magic
    except ImportError:
        mock_magic = MagicMock()
        mock_magic.from_buffer.return_value = "image/jpeg"
        sys.modules["magic"] = mock_magic

    # Mock weasyprint pre-emptively to avoid native library issues
    mock_weasyprint = MagicMock()
    mock_html_inst = MagicMock()
    mock_html_inst.write_pdf.return_value = b"fake pdf content"
    mock_weasyprint.HTML.return_value = mock_html_inst
    sys.modules["weasyprint"] = mock_weasyprint
else:
    # On non-windows, still try to mock if missing
    try:
        import magic
    except ImportError:
        mock_magic = MagicMock()
        sys.modules["magic"] = mock_magic
    
    try:
        import weasyprint
    except (ImportError, OSError):
        mock_weasyprint = MagicMock()
        mock_html_inst = MagicMock()
        mock_html_inst.write_pdf.return_value = b"fake pdf content"
        mock_weasyprint.HTML.return_value = mock_html_inst
        sys.modules["weasyprint"] = mock_weasyprint

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
# Se estiver rodando fora do Docker, 'db' não será resolvido. Trocar para localhost se necessário.
db_url = settings.DATABASE_URL
import os
if not os.path.exists('/.dockerenv') and "db:5432" in db_url:
    db_url = db_url.replace("db:5432", "localhost:5432")
SQLALCHEMY_DATABASE_URL_TEST = db_url.replace("vistor_ai", TEST_DB_NAME)

@pytest.fixture(scope="session")
def event_loop():
    loop = asyncio.new_event_loop()
    yield loop
    loop.close()

async def create_test_db():
    admin_url = db_url.replace("vistor_ai", "postgres")
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
        await session.execute(text("TRUNCATE users, audit_log, inspections CASCADE"))
        await session.commit()
    await engine.dispose()

@pytest_asyncio.fixture
async def redis_client():
    return FakeRedis()

@pytest_asyncio.fixture
async def client(db_session: AsyncSession, redis_client: FakeRedis) -> AsyncGenerator[AsyncClient, None]:
    app.dependency_overrides[get_db] = lambda: db_session
    app.dependency_overrides[get_redis] = lambda: redis_client
    
    # Mock AsyncSessionLocal for background tasks in tests
    from unittest.mock import patch, AsyncMock
    from contextlib import asynccontextmanager
    
    @asynccontextmanager
    async def mock_session_local():
        yield db_session
        
    @asynccontextmanager
    async def mock_s3_context():
        mock_client = AsyncMock()
        mock_body = AsyncMock()
        mock_body.read.return_value = b"fake image content"
        mock_client.get_object.return_value = {"Body": mock_body}
        yield mock_client

    # We patch it where it is imported inside the functions
    with patch("app.database.AsyncSessionLocal", side_effect=mock_session_local), \
         patch("app.services.storage_service.get_s3_client_context", side_effect=mock_s3_context):
        async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
            yield ac
    
    app.dependency_overrides.clear()

@pytest_asyncio.fixture
async def authed_client(client: AsyncClient, inspector_token: str) -> AsyncClient:
    client.headers.update({"Authorization": f"Bearer {inspector_token}"})
    return client

@pytest_asyncio.fixture
async def manager_client(client: AsyncClient, manager_token: str) -> AsyncClient:
    client.headers.update({"Authorization": f"Bearer {manager_token}"})
    return client

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

@pytest_asyncio.fixture
async def admin_token(client: AsyncClient, db_session: AsyncSession):
    payload = UserCreate(
        name="Admin User",
        email="admin_test@vistor.ai",
        password="password123",
        role=UserRole.admin
    )
    await create_user(db_session, payload)
    response = await client.post("/api/auth/login", json={
        "email": "admin_test@vistor.ai",
        "password": "password123"
    })
    return response.json()["access_token"]

@pytest_asyncio.fixture
async def admin_client(client: AsyncClient, admin_token: str) -> AsyncClient:
    client.headers.update({"Authorization": f"Bearer {admin_token}"})
    return client

