import time

from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import Response

from app.metrics import (
    REQUEST_COUNT,
    REQUEST_DURATION,
    track_visitor,
)


class MetricsMiddleware(BaseHTTPMiddleware):
    """Track request metrics and visitor analytics."""

    async def dispatch(self, request: Request, call_next) -> Response:
        start = time.time()

        response = await call_next(request)

        duration = time.time() - start
        path = request.url.path

        # Skip metrics/health endpoints from tracking
        if path in ("/metrics", "/api/health", "/api/ready"):
            return response

        method = request.method
        status = str(response.status_code)

        # Simplify path for metrics (avoid high cardinality)
        metric_path = _simplify_path(path)

        REQUEST_COUNT.labels(
            method=method,
            endpoint=metric_path,
            status=status,
        ).inc()

        REQUEST_DURATION.labels(
            method=method,
            endpoint=metric_path,
        ).observe(duration)

        # Track visitor on page loads (GET requests, not assets)
        if method == "GET" and not _is_asset(path):
            ip = request.headers.get(
                "x-forwarded-for", ""
            ).split(",")[0].strip()
            if not ip:
                ip = request.client.host if request.client else ""

            country = request.headers.get(
                "cf-ipcountry",
                request.headers.get("x-country-code", None),
            )

            track_visitor(
                ip=ip,
                user_agent_str=request.headers.get("user-agent"),
                path=metric_path,
                country=country,
            )

        return response


def _simplify_path(path: str) -> str:
    """Reduce path cardinality for Prometheus labels."""
    if path.startswith("/api/"):
        parts = path.split("/")
        if len(parts) >= 3:
            return "/api/" + parts[2]
    if path.startswith("/experience"):
        return "/experience"
    if path.startswith("/projects"):
        return "/projects"
    if path.startswith("/skills"):
        return "/skills"
    return path


def _is_asset(path: str) -> bool:
    """Check if path is a static asset."""
    asset_exts = (
        ".css", ".js", ".png", ".jpg", ".jpeg",
        ".gif", ".ico", ".svg", ".woff", ".woff2",
        ".ttf", ".eot", ".map",
    )
    return path.endswith(asset_exts)
