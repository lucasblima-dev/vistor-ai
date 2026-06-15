from typing import List
from pydantic import Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    DATABASE_URL: str

    # Admin Inicial Bootstrap
    INITIAL_ADMIN_NAME: str = "Admin Inicial"
    INITIAL_ADMIN_EMAIL: str = "admin@vistor.ai"
    INITIAL_ADMIN_PASSWORD: str = "admin12345"

    # MinIO
    MINIO_ENDPOINT: str
    MINIO_EXTERNAL_ENDPOINT: str = "http://localhost:9000"
    MINIO_USER: str
    MINIO_PASSWORD: str

    @field_validator("MINIO_ENDPOINT", "MINIO_EXTERNAL_ENDPOINT")
    @classmethod
    def validate_minio_endpoints(cls, v: str) -> str:
        if not v.startswith(("http://", "https://")):
            raise ValueError("MINIO_ENDPOINT deve iniciar com http:// ou https://")
        return v

    REDIS_URL: str

    # HuggingFace
    HF_API_KEY: str
    HF_MODEL_ID: str = "Qwen/Qwen3-VL-8B-Instruct"
    HF_TIMEOUT_SECONDS: int = 10
    HF_CONFIDENCE_THRESHOLD: float = 0.55

    JWT_SECRET: str
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_TTL_MINUTES: int = 15
    REFRESH_TOKEN_TTL_DAYS: int = 7

    ALLOWED_ORIGINS: List[str] = Field(default_factory=lambda: ["http://localhost:3000"])
    ENVIRONMENT: str = "development"

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore"
    )


settings = Settings()
