"""Application Configuration"""

from pydantic_settings import BaseSettings
from typing import List
import os


class Settings(BaseSettings):
    """Application settings"""

    # Application
    APP_NAME: str = "Landing Zone Portal"
    ENVIRONMENT: str = "development"
    DEBUG: bool = False
    API_V1_PREFIX: str = "/api/v1"

    # Database
    DATABASE_URL: str = "postgresql://postgres:postgres@localhost:5432/landing_zone_portal"
    DATABASE_POOL_SIZE: int = 10
    DATABASE_MAX_OVERFLOW: int = 20

    # Redis
    REDIS_URL: str = "redis://localhost:6379/0"
    CACHE_TTL: int = 300  # 5 minutes

    # Security
    SECRET_KEY: str = "change-this-in-production-to-a-secure-random-key"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7

    # CORS
    CORS_ORIGINS: List[str] = [
        "http://localhost:3000",
        "http://localhost:8080",
    ]

    # Azure AD OAuth (optional)
    AZURE_AD_TENANT_ID: str = ""
    AZURE_AD_CLIENT_ID: str = ""
    AZURE_AD_CLIENT_SECRET: str = ""
    AZURE_AD_ENABLED: bool = False

    # GitHub OAuth (optional)
    GITHUB_CLIENT_ID: str = ""
    GITHUB_CLIENT_SECRET: str = ""
    GITHUB_ENABLED: bool = False

    # Deployment Platform
    DEPLOYMENT_PLATFORM: str = "spacelift"  # spacelift or github_actions

    # Spacelift Configuration
    SPACELIFT_API_KEY_ENDPOINT: str = ""
    SPACELIFT_API_KEY_ID: str = ""
    SPACELIFT_API_KEY_SECRET: str = ""
    SPACELIFT_ENDPOINT: str = "https://example.app.spacelift.io"

    # GitHub Configuration
    GITHUB_TOKEN: str = ""
    GITHUB_ORGANIZATION: str = ""
    GITHUB_REPOSITORY: str = ""

    # Azure Configuration
    AZURE_SUBSCRIPTION_ID: str = ""
    AZURE_TENANT_ID: str = ""
    AZURE_CLIENT_ID: str = ""
    AZURE_CLIENT_SECRET: str = ""

    # Cost Management
    AZURE_COST_MANAGEMENT_ENABLED: bool = False
    COST_UPDATE_INTERVAL_MINUTES: int = 60

    # Email Notifications
    SMTP_HOST: str = ""
    SMTP_PORT: int = 587
    SMTP_USER: str = ""
    SMTP_PASSWORD: str = ""
    SMTP_FROM_EMAIL: str = "noreply@example.com"
    EMAIL_ENABLED: bool = False

    # Celery
    CELERY_BROKER_URL: str = "redis://localhost:6379/0"
    CELERY_RESULT_BACKEND: str = "redis://localhost:6379/0"

    # Monitoring
    PROMETHEUS_ENABLED: bool = True
    LOG_LEVEL: str = "INFO"

    class Config:
        env_file = ".env"
        case_sensitive = True


# Create settings instance
settings = Settings()
