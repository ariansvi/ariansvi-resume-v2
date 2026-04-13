import os


class Settings:
    APP_NAME: str = "Arian Svirsky Resume API"
    APP_VERSION: str = os.getenv("APP_VERSION", "0.1.0")
    ENVIRONMENT: str = os.getenv("ENVIRONMENT", "development")
    GCP_PROJECT_ID: str = os.getenv("GCP_PROJECT_ID", "")
    FIRESTORE_EMULATOR_HOST: str = os.getenv("FIRESTORE_EMULATOR_HOST", "")
    CORS_ORIGINS: list = os.getenv(
        "CORS_ORIGINS", "http://localhost,http://localhost:8080"
    ).split(",")
    LOG_LEVEL: str = os.getenv("LOG_LEVEL", "INFO")
    STATS_USERNAME: str = os.getenv("STATS_USERNAME", "arian")
    STATS_PASSWORD: str = os.getenv("STATS_PASSWORD", "devops2024")
    INTERNAL_TOKEN: str = os.getenv("INTERNAL_TOKEN", "")


settings = Settings()
