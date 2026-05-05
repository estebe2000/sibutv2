import os
from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import Optional

class Settings(BaseSettings):
    PROJECT_NAME: str = "Skills Hub Remaster"
    API_V1_STR: str = "/api/v1"
    
    # Database
    DATABASE_URL: str = os.getenv("DATABASE_URL", "postgresql://app_user:app_password@db:5432/skills_db")
    
    # Auth (Keycloak)
    KEYCLOAK_URL: str = os.getenv("KEYCLOAK_URL", "http://keycloak:8080")
    KEYCLOAK_REALM: str = os.getenv("KEYCLOAK_REALM", "but-tc")
    KEYCLOAK_CLIENT_ID: Optional[str] = os.getenv("KEYCLOAK_CLIENT_ID", "skills-hub-app")
    KEYCLOAK_CLIENT_SECRET: Optional[str] = os.getenv("KEYCLOAK_CLIENT_SECRET", "")
    
    # Redis
    REDIS_URL: str = os.getenv("REDIS_URL", "redis://redis:6379/0")
    
    # Project Settings
    DOMAIN: str = os.getenv("DOMAIN", "localhost")
    SECRET_KEY: str = os.getenv("SECRET_KEY", "your-secret-key-here") # For JWT fallback
    
    # AI Service
    AI_SERVICE_URL: str = os.getenv("AI_SERVICE_URL", "http://172.16.87.140:8080/v1/chat/completions")
    AI_MODEL_NAME: str = os.getenv("AI_MODEL_NAME", "llama-3.2-3b")

    # SMTP
    SMTP_SERVER: str = os.getenv("SMTP_SERVER", "smtp.educ-ai.fr")
    SMTP_PORT: int = int(os.getenv("SMTP_PORT", 587))
    SMTP_USER: str = os.getenv("SMTP_USER", "")
    SMTP_PASSWORD: str = os.getenv("SMTP_PASSWORD", "")
    SMTP_FROM_EMAIL: str = os.getenv("SMTP_FROM_EMAIL", "noreply@educ-ai.fr")

    model_config = SettingsConfigDict(
        env_file=".env",
        case_sensitive=True
    )

settings = Settings()
