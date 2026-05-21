from typing import AsyncGenerator
from redis.asyncio import Redis, from_url
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import AsyncSessionLocal
from app.config import settings

async def get_db() -> AsyncGenerator[AsyncSession, None]:
    async with AsyncSessionLocal() as session:
        try:
            yield session
        finally:
            await session.close()

async def get_redis() -> AsyncGenerator[Redis, None]:
    redis = from_url(settings.REDIS_URL)
    try:
        yield redis
    finally:
        await redis.close()
