"""Cross-cutting security helpers: internal-token gate + per-IP rate limit.

These run at the ASGI middleware layer so they protect every route, including
the Prometheus /metrics mount that doesn't go through the FastAPI router.
"""
from __future__ import annotations

import secrets
import time
from collections import defaultdict, deque

from fastapi import HTTPException, Request, status
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.responses import JSONResponse, Response
from starlette.types import ASGIApp

from app.config import settings

# Cloud Run + browser preflights need to reach these without our token.
# Health/ready: hit by Cloud Run probes from internal Google network.
# OPTIONS: CORS preflight, browsers strip custom headers from preflight.
_TOKEN_EXEMPT_PATHS = {"/api/health", "/api/ready"}


def _client_ip(request: Request) -> str:
    fwd = request.headers.get("x-forwarded-for", "")
    if fwd:
        return fwd.split(",")[0].strip()
    return request.client.host if request.client else "unknown"


class InternalTokenMiddleware(BaseHTTPMiddleware):
    """Reject requests that don't carry the shared frontend↔backend token.

    Lets us keep the backend's *.run.app URL public (so Cloud Run probes
    work) without exposing it as a real attack surface.
    """

    async def dispatch(self, request: Request, call_next) -> Response:
        path = request.url.path
        if (
            request.method == "OPTIONS"
            or path in _TOKEN_EXEMPT_PATHS
            or not settings.INTERNAL_TOKEN  # disabled when not configured
        ):
            return await call_next(request)

        provided = request.headers.get("x-internal-token", "")
        if not secrets.compare_digest(provided, settings.INTERNAL_TOKEN):
            return JSONResponse(
                status_code=status.HTTP_403_FORBIDDEN,
                content={"detail": "Forbidden"},
            )
        return await call_next(request)


class RateLimitMiddleware(BaseHTTPMiddleware):
    """Sliding-window per-IP+path rate limit.

    In-memory only — resets when Cloud Run scales to zero, which is fine.
    Default rule covers /api/* write endpoints; everything else is unbounded.
    """

    def __init__(
        self,
        app: ASGIApp,
        rules: dict[str, tuple[int, int]] | None = None,
    ) -> None:
        super().__init__(app)
        # path-prefix → (max_hits, window_seconds)
        self.rules = rules or {}
        self._hits: dict[str, deque[float]] = defaultdict(deque)

    def _rule_for(self, path: str) -> tuple[int, int] | None:
        for prefix, rule in self.rules.items():
            if path.startswith(prefix):
                return rule
        return None

    async def dispatch(self, request: Request, call_next) -> Response:
        rule = self._rule_for(request.url.path)
        if rule is None:
            return await call_next(request)

        limit, window = rule
        key = f"{_client_ip(request)}|{request.url.path}"
        now = time.time()
        bucket = self._hits[key]

        # Drop expired entries
        while bucket and now - bucket[0] > window:
            bucket.popleft()

        if len(bucket) >= limit:
            retry_after = int(window - (now - bucket[0])) + 1
            return JSONResponse(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                content={"detail": "Too many requests"},
                headers={"Retry-After": str(retry_after)},
            )

        bucket.append(now)
        return await call_next(request)
