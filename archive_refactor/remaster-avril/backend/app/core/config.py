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
    
    # Matrix (Synapse)
    MATRIX_HOMESERVER: str = os.getenv("MATRIX_HOMESERVER", "https://matrix.educ-ai.fr")
    MATRIX_BOT_USER: str = os.getenv("MATRIX_BOT_USER", "@hub-bot:educ-ai.fr")
    MATRIX_BOT_PASSWORD: Optional[str] = os.getenv("MATRIX_BOT_PASSWORD", None)
    MATRIX_ACCESS_TOKEN: Optional[str] = os.getenv("MATRIX_ACCESS_TOKEN", None)
    MATRIX_ROOM_GENERAL: str = os.getenv("MATRIX_ROOM_GENERAL", "!your-room-id:educ-ai.fr")

    model_config = SettingsConfigDict(
        env_file=".env",
        case_sensitive=True
    )

settings = Settings()
