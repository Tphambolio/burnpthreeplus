"""Application configuration."""
from typing import List
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings."""

    # Project metadata
    PROJECT_NAME: str = "BurnP3+ API"
    VERSION: str = "0.1.0"
    API_V1_STR: str = "/api/v1"
    ENVIRONMENT: str = "development"

    # Security
    SECRET_KEY: str = "dev-secret-key-change-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24  # 24 hours
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7

    # CORS
    CORS_ORIGINS: List[str] = [
        "http://localhost:3000",
        "http://localhost:8000",
        "http://frontend:3000",
    ]

    # Database
    DATABASE_URL: str = "postgresql://burnp3:burnp3_dev_password@localhost:5432/burnp3"
    DATABASE_POOL_SIZE: int = 5
    DATABASE_MAX_OVERFLOW: int = 10

    # Redis
    REDIS_URL: str = "redis://localhost:6379/0"

    # Celery
    CELERY_BROKER_URL: str = "redis://localhost:6379/0"
    CELERY_RESULT_BACKEND: str = "redis://localhost:6379/0"

    # S3 / MinIO
    S3_ENDPOINT: str = "http://localhost:9000"
    S3_ACCESS_KEY: str = "minioadmin"
    S3_SECRET_KEY: str = "minioadmin"
    S3_BUCKET_DATA: str = "burnp3-data"
    S3_BUCKET_RESULTS: str = "burnp3-results"
    S3_REGION: str = "us-east-1"

    # File upload limits
    MAX_UPLOAD_SIZE: int = 500 * 1024 * 1024  # 500 MB
    ALLOWED_RASTER_EXTENSIONS: List[str] = [".tif", ".tiff", ".geotiff"]

    # Logging
    LOG_LEVEL: str = "INFO"

    # Simulation defaults
    DEFAULT_IGNITION_COUNT: int = 1000
    DEFAULT_ITERATION_COUNT: int = 1000
    MAX_PARALLEL_FIRES: int = 4

    model_config = SettingsConfigDict(
        env_file=".env",
        case_sensitive=True,
        extra="ignore"
    )


# Create settings instance
settings = Settings()
