import os


class Settings:
    APP_NAME: str = "Arian Svirsky Resume API"
    APP_VERSION: str = os.getenv("APP_VERSION", "0.1.0")
    DATABASE_URL: str = os.getenv("DATABASE_URL", "sqlite:///./data/resume.db")
    ENVIRONMENT: str = os.getenv("ENVIRONMENT", "development")
    CORS_ORIGINS: list = os.getenv(
        "CORS_ORIGINS", "http://localhost,http://localhost:8080"
    ).split(",")
    LOG_LEVEL: str = os.getenv("LOG_LEVEL", "INFO")


settings = Settings()
