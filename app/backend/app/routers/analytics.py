import logging
import secrets
from collections import Counter
from datetime import datetime, timedelta, timezone

import httpx
from fastapi import APIRouter, Depends, HTTPException, Request, status
from fastapi.security import HTTPBasic, HTTPBasicCredentials
from google.cloud import firestore
from pydantic import BaseModel
from user_agents import parse as parse_ua

from app.config import settings
from app.database import get_client

router = APIRouter(prefix="/analytics", tags=["analytics"])
logger = logging.getLogger(__name__)
security = HTTPBasic()

COLLECTION = "page_visits"


def verify_credentials(
    credentials: HTTPBasicCredentials = Depends(security),
):
    correct_user = secrets.compare_digest(
        credentials.username, settings.STATS_USERNAME
    )
    correct_pass = secrets.compare_digest(
        credentials.password, settings.STATS_PASSWORD
    )
    if not (correct_user and correct_pass):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials",
            headers={"WWW-Authenticate": "Basic"},
        )
    return credentials.username


# In-memory GeoIP cache to avoid hitting the API too often
_geo_cache: dict[str, dict] = {}


def _mask_ip(ip: str | None) -> str:
    """Mask last octet (IPv4) or last hextet (IPv6) for privacy."""
    if not ip:
        return "-"
    if "." in ip:
        parts = ip.split(".")
        if len(parts) == 4:
            return ".".join(parts[:3] + ["x"])
    if ":" in ip:
        parts = ip.split(":")
        if len(parts) > 1:
            return ":".join(parts[:-1] + ["x"])
    return ip


async def _geoip_lookup(ip: str) -> dict:
    if not ip or ip in ("127.0.0.1", "::1", "localhost"):
        return {"country": "Local", "city": ""}
    if ip in _geo_cache:
        return _geo_cache[ip]
    try:
        async with httpx.AsyncClient(timeout=2.0) as client:
            r = await client.get(f"https://ipapi.co/{ip}/json/")
            if r.status_code == 200:
                data = r.json()
                result = {
                    "country": data.get("country_name", "Unknown"),
                    "city": data.get("city", ""),
                }
                _geo_cache[ip] = result
                return result
    except Exception:
        logger.debug("GeoIP lookup failed for %s", ip)
    return {"country": "Unknown", "city": ""}


class VisitCreate(BaseModel):
    path: str
    referrer: str | None = None


@router.post("/visit", status_code=201)
async def record_visit(
    visit: VisitCreate,
    request: Request,
):
    ip = request.headers.get("x-forwarded-for", "").split(",")[0].strip()
    if not ip:
        ip = request.client.host if request.client else ""

    geo = await _geoip_lookup(ip or "")

    ua_str = request.headers.get("user-agent", "")
    ua = parse_ua(ua_str)
    if ua.is_mobile:
        device = "mobile"
    elif ua.is_tablet:
        device = "tablet"
    elif ua.is_bot:
        device = "bot"
    else:
        device = "desktop"

    doc = {
        "path": visit.path,
        "referrer": visit.referrer,
        "user_agent": ua_str,
        "ip_address": ip,
        "country": geo["country"],
        "city": geo["city"],
        "browser": ua.browser.family or "Unknown",
        "os": ua.os.family or "Unknown",
        "device_type": device,
        "created_at": firestore.SERVER_TIMESTAMP,
    }
    try:
        get_client().collection(COLLECTION).add(doc)
    except Exception:
        logger.exception("Failed to record visit")
        raise HTTPException(status_code=500, detail="Failed to record visit")

    return {"status": "recorded"}


def _bucket(docs: list[dict], key: str, limit: int = 10) -> list[dict]:
    counts = Counter(
        (d.get(key) or "Unknown") for d in docs if d.get(key) is not None
    )
    return [
        {key: k, "count": c}
        for k, c in counts.most_common(limit)
    ]


@router.get("/dashboard")
def get_dashboard(
    _user: str = Depends(verify_credentials),
):
    """Aggregate analytics for the stats page.

    We pull the last 30 days of visits once and aggregate in Python.
    Firestore has no SQL-style GROUP BY; for a personal site the daily
    volume is small enough that in-memory aggregation is fine.
    """
    now = datetime.now(timezone.utc)
    today_start = now.replace(hour=0, minute=0, second=0, microsecond=0)
    week_start = today_start - timedelta(days=7)
    month_start = today_start - timedelta(days=30)

    try:
        col = get_client().collection(COLLECTION)
        total = col.count().get()[0][0].value
        recent_30d = list(
            col.where("created_at", ">=", month_start)
            .order_by("created_at", direction=firestore.Query.DESCENDING)
            .stream()
        )
    except Exception:
        logger.exception("Firestore query failed")
        raise HTTPException(status_code=500, detail="Analytics unavailable")

    # Normalize to plain dicts with created_at as datetime
    visits = []
    for snap in recent_30d:
        data = snap.to_dict() or {}
        ts = data.get("created_at")
        if hasattr(ts, "to_datetime"):
            ts = ts.to_datetime()
        data["created_at"] = ts
        visits.append(data)

    today = sum(
        1 for v in visits
        if v.get("created_at") and v["created_at"] >= today_start
    )
    this_week = sum(
        1 for v in visits
        if v.get("created_at") and v["created_at"] >= week_start
    )
    unique_ips = len({v.get("ip_address") for v in visits if v.get("ip_address")})

    # Daily histogram
    by_day: Counter = Counter()
    for v in visits:
        ts = v.get("created_at")
        if ts:
            by_day[ts.date().isoformat()] += 1
    daily = [
        {"date": d, "count": by_day[d]}
        for d in sorted(by_day)
    ]

    # City-level aggregation
    city_counter: Counter = Counter()
    for v in visits:
        city = v.get("city") or ""
        country = v.get("country") or "Unknown"
        if city:
            city_counter[(city, country)] += 1
    by_city = [
        {"city": c[0], "country": c[1], "count": n}
        for c, n in city_counter.most_common(10)
    ]

    recent = [
        {
            "path": v.get("path"),
            "country": v.get("country"),
            "city": v.get("city"),
            "browser": v.get("browser"),
            "os": v.get("os"),
            "device": v.get("device_type"),
            "ip": _mask_ip(v.get("ip_address")),
            "time": v["created_at"].isoformat() if v.get("created_at") else None,
        }
        for v in visits[:20]
    ]

    return {
        "summary": {
            "total_visits": total,
            "visits_today": today,
            "visits_this_week": this_week,
            "unique_visitors": unique_ips,
        },
        "top_pages": _bucket(visits, "path"),
        "by_country": [
            {"country": r["country"], "count": r["count"]}
            for r in _bucket(visits, "country", limit=15)
        ],
        "by_city": by_city,
        "by_browser": [
            {"browser": r["browser"], "count": r["count"]}
            for r in _bucket(visits, "browser")
        ],
        "by_os": [
            {"os": r["os"], "count": r["count"]}
            for r in _bucket(visits, "os")
        ],
        "by_device": [
            {"device": r["device_type"], "count": r["count"]}
            for r in _bucket(visits, "device_type")
        ],
        "daily": daily,
        "recent": recent,
    }
