import logging
from datetime import datetime, timedelta

import httpx
from fastapi import APIRouter, Depends, Request
from pydantic import BaseModel
from sqlalchemy import func, cast, Date
from sqlalchemy.orm import Session
from user_agents import parse as parse_ua

from app.database import get_db
from app.models import PageVisit

router = APIRouter(prefix="/analytics", tags=["analytics"])
logger = logging.getLogger(__name__)

# In-memory GeoIP cache to avoid hitting the API too often
_geo_cache: dict[str, dict] = {}


async def _geoip_lookup(ip: str) -> dict:
    """Lookup country/city from IP using free API."""
    if not ip or ip in ("127.0.0.1", "::1", "localhost"):
        return {"country": "Local", "city": ""}

    if ip in _geo_cache:
        return _geo_cache[ip]

    try:
        async with httpx.AsyncClient(timeout=2.0) as client:
            r = await client.get(f"http://ip-api.com/json/{ip}?fields=country,city")
            if r.status_code == 200:
                data = r.json()
                result = {
                    "country": data.get("country", "Unknown"),
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
    db: Session = Depends(get_db),
):
    # Get real IP (behind ingress/proxy)
    ip = request.headers.get("x-forwarded-for", "").split(",")[0].strip()
    if not ip:
        ip = request.client.host if request.client else None

    # GeoIP
    geo = await _geoip_lookup(ip or "")

    # Parse user agent
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

    db_visit = PageVisit(
        path=visit.path,
        referrer=visit.referrer,
        user_agent=ua_str,
        ip_address=ip,
        country=geo["country"],
        city=geo["city"],
        browser=ua.browser.family or "Unknown",
        os=ua.os.family or "Unknown",
        device_type=device,
    )
    db.add(db_visit)
    db.commit()
    return {"status": "recorded"}


@router.get("/dashboard")
def get_dashboard(db: Session = Depends(get_db)):
    """Rich analytics data for the stats page."""
    now = datetime.utcnow()
    today_start = now.replace(hour=0, minute=0, second=0, microsecond=0)
    week_start = today_start - timedelta(days=7)
    month_start = today_start - timedelta(days=30)

    total = db.query(func.count(PageVisit.id)).scalar() or 0
    today = (
        db.query(func.count(PageVisit.id))
        .filter(PageVisit.created_at >= today_start)
        .scalar() or 0
    )
    this_week = (
        db.query(func.count(PageVisit.id))
        .filter(PageVisit.created_at >= week_start)
        .scalar() or 0
    )
    unique_ips = (
        db.query(func.count(func.distinct(PageVisit.ip_address)))
        .scalar() or 0
    )

    # Top pages
    top_pages = (
        db.query(PageVisit.path, func.count(PageVisit.id).label("c"))
        .group_by(PageVisit.path)
        .order_by(func.count(PageVisit.id).desc())
        .limit(10)
        .all()
    )

    # By country
    by_country = (
        db.query(PageVisit.country, func.count(PageVisit.id).label("c"))
        .filter(PageVisit.country.isnot(None))
        .group_by(PageVisit.country)
        .order_by(func.count(PageVisit.id).desc())
        .limit(15)
        .all()
    )

    # By city
    by_city = (
        db.query(
            PageVisit.city,
            PageVisit.country,
            func.count(PageVisit.id).label("c"),
        )
        .filter(PageVisit.city.isnot(None), PageVisit.city != "")
        .group_by(PageVisit.city, PageVisit.country)
        .order_by(func.count(PageVisit.id).desc())
        .limit(10)
        .all()
    )

    # By browser
    by_browser = (
        db.query(PageVisit.browser, func.count(PageVisit.id).label("c"))
        .filter(PageVisit.browser.isnot(None))
        .group_by(PageVisit.browser)
        .order_by(func.count(PageVisit.id).desc())
        .limit(10)
        .all()
    )

    # By OS
    by_os = (
        db.query(PageVisit.os, func.count(PageVisit.id).label("c"))
        .filter(PageVisit.os.isnot(None))
        .group_by(PageVisit.os)
        .order_by(func.count(PageVisit.id).desc())
        .limit(10)
        .all()
    )

    # By device type
    by_device = (
        db.query(PageVisit.device_type, func.count(PageVisit.id).label("c"))
        .filter(PageVisit.device_type.isnot(None))
        .group_by(PageVisit.device_type)
        .order_by(func.count(PageVisit.id).desc())
        .all()
    )

    # Visits per day (last 30 days)
    daily = (
        db.query(
            cast(PageVisit.created_at, Date).label("day"),
            func.count(PageVisit.id).label("c"),
        )
        .filter(PageVisit.created_at >= month_start)
        .group_by(cast(PageVisit.created_at, Date))
        .order_by(cast(PageVisit.created_at, Date))
        .all()
    )

    # Recent visitors (last 20)
    recent = (
        db.query(PageVisit)
        .order_by(PageVisit.created_at.desc())
        .limit(20)
        .all()
    )

    return {
        "summary": {
            "total_visits": total,
            "visits_today": today,
            "visits_this_week": this_week,
            "unique_visitors": unique_ips,
        },
        "top_pages": [{"path": p, "count": c} for p, c in top_pages],
        "by_country": [{"country": co, "count": c} for co, c in by_country],
        "by_city": [
            {"city": ci, "country": co, "count": c}
            for ci, co, c in by_city
        ],
        "by_browser": [{"browser": b, "count": c} for b, c in by_browser],
        "by_os": [{"os": o, "count": c} for o, c in by_os],
        "by_device": [{"device": d, "count": c} for d, c in by_device],
        "daily": [
            {"date": str(d), "count": c} for d, c in daily
        ],
        "recent": [
            {
                "path": v.path,
                "country": v.country,
                "city": v.city,
                "browser": v.browser,
                "os": v.os,
                "device": v.device_type,
                "time": v.created_at.isoformat() if v.created_at else None,
            }
            for v in recent
        ],
    }
