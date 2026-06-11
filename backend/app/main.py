from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import settings
from app.routers import auth, users, inspections, media, reports, geo, audit
from app.services import storage_service


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Inicializa buckets no MinIO
    await storage_service.ensure_buckets_exist()
    yield


app = FastAPI(
    title="Vistor AI API",
    description="API para o sistema de inspeção técnica Vistor AI",
    version="0.1.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/api/auth", tags=["Auth"])
app.include_router(users.router, prefix="/api/users", tags=["Users"])
app.include_router(inspections.router, prefix="/api/inspections", tags=["Inspections"])
app.include_router(media.router, prefix="/api/media", tags=["Media"])
app.include_router(reports.router, prefix="/api/reports", tags=["Reports"])
app.include_router(geo.router, prefix="/api/geo", tags=["Geo"])
app.include_router(audit.router, prefix="/api/audit-logs", tags=["Audit Logs"])


@app.get("/health", tags=["Health"])
async def health_check():
    return {
        "status": "ok",
        "environment": settings.ENVIRONMENT,
        "version": "0.1.0"
    }
