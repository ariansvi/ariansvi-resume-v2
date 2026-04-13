from fastapi import APIRouter

from app.config import settings

router = APIRouter(tags=["health"])


@router.get("/health")
def health_check():
    # Intentionally minimal — this endpoint is unauthenticated and called
    # from outside our token-gate (Cloud Run probes). Don't leak version,
    # environment, or anything else useful for recon.
    return {"status": "ok"}


@router.get("/ready")
def readiness_check():
    return {"status": "ready"}


# /info was removed in favor of zero-leak health checks.
# Version/env are still available internally via metrics + logs.
_ = settings  # silence unused import
