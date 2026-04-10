import platform
from datetime import datetime

from fastapi import APIRouter

from app.config import settings

router = APIRouter(tags=["health"])

START_TIME = datetime.utcnow()


@router.get("/health")
def health_check():
    return {
        "status": "healthy",
        "version": settings.APP_VERSION,
        "environment": settings.ENVIRONMENT,
    }


@router.get("/ready")
def readiness_check():
    return {"status": "ready"}


@router.get("/info")
def app_info():
    uptime = (datetime.utcnow() - START_TIME).total_seconds()
    return {
        "app": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "environment": settings.ENVIRONMENT,
        "uptime_seconds": round(uptime, 1),
        "python_version": platform.python_version(),
        "platform": platform.platform(),
    }
