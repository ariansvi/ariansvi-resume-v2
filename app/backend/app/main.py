import logging

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from prometheus_client import make_asgi_app

from app.config import settings
from app.database import init_db
from app.routers import analytics, contact, health

logging.basicConfig(
    level=getattr(logging, settings.LOG_LEVEL),
    format="%(asctime)s %(levelname)s %(name)s: %(message)s",
)

app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    docs_url="/api/docs",
    redoc_url="/api/redoc",
    openapi_url="/api/openapi.json",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Prometheus metrics endpoint
metrics_app = make_asgi_app()
app.mount("/metrics", metrics_app)

# Routers
app.include_router(health.router, prefix="/api")
app.include_router(analytics.router, prefix="/api")
app.include_router(contact.router, prefix="/api")


@app.on_event("startup")
def startup():
    init_db()
    logging.getLogger(__name__).info(
        "Resume API started | env=%s version=%s",
        settings.ENVIRONMENT,
        settings.APP_VERSION,
    )
