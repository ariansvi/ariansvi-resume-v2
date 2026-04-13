import logging

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from prometheus_client import make_asgi_app

from app.config import settings
from app.middleware import MetricsMiddleware
from app.routers import analytics, contact, health
from app.security import InternalTokenMiddleware, RateLimitMiddleware

logging.basicConfig(
    level=getattr(logging, settings.LOG_LEVEL),
    format="%(asctime)s %(levelname)s %(name)s: %(message)s",
)

_is_prod = settings.ENVIRONMENT == "production"

app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    docs_url=None if _is_prod else "/api/docs",
    redoc_url=None if _is_prod else "/api/redoc",
    openapi_url=None if _is_prod else "/api/openapi.json",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=False,
    allow_methods=["GET", "POST"],
    allow_headers=["Authorization", "Content-Type"],
)

# Per-IP rate limit on the write endpoints + the auth endpoint.
# Order: this runs AFTER InternalTokenMiddleware (Starlette adds in reverse).
app.add_middleware(
    RateLimitMiddleware,
    rules={
        "/api/analytics/visit": (60, 60),       # 60 visits/min/IP
        "/api/contact/": (5, 600),              # 5 messages/10 min/IP
        "/api/analytics/dashboard": (30, 60),   # 30/min/IP — also gated by Basic auth lockout
    },
)

# Internal-token gate: rejects anyone hitting the backend *.run.app URL
# directly. Only nginx (which adds X-Internal-Token) and Cloud Run probes
# (which hit /api/health) get through.
app.add_middleware(InternalTokenMiddleware)

app.add_middleware(MetricsMiddleware)

# Prometheus metrics endpoint (also protected by InternalTokenMiddleware
# above — anyone hitting /metrics needs the token).
metrics_app = make_asgi_app()
app.mount("/metrics", metrics_app)

# Routers
app.include_router(health.router, prefix="/api")
app.include_router(analytics.router, prefix="/api")
app.include_router(contact.router, prefix="/api")


@app.on_event("startup")
def startup():
    logging.getLogger(__name__).info(
        "Resume API started | env=%s version=%s",
        settings.ENVIRONMENT,
        settings.APP_VERSION,
    )
