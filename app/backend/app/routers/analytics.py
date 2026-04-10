from datetime import datetime, timedelta

from fastapi import APIRouter, Depends, Request
from pydantic import BaseModel
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import PageVisit

router = APIRouter(prefix="/analytics", tags=["analytics"])


class VisitCreate(BaseModel):
    path: str
    referrer: str | None = None


class VisitStats(BaseModel):
    total_visits: int
    unique_paths: int
    visits_today: int
    visits_this_week: int
    top_pages: list[dict]


@router.post("/visit", status_code=201)
def record_visit(
    visit: VisitCreate,
    request: Request,
    db: Session = Depends(get_db),
):
    db_visit = PageVisit(
        path=visit.path,
        referrer=visit.referrer,
        user_agent=request.headers.get("user-agent", ""),
        ip_address=request.client.host if request.client else None,
    )
    db.add(db_visit)
    db.commit()
    return {"status": "recorded"}


@router.get("/stats", response_model=VisitStats)
def get_stats(db: Session = Depends(get_db)):
    now = datetime.utcnow()
    today_start = now.replace(hour=0, minute=0, second=0, microsecond=0)
    week_start = today_start - timedelta(days=7)

    total = db.query(func.count(PageVisit.id)).scalar() or 0
    unique = (
        db.query(func.count(func.distinct(PageVisit.path))).scalar() or 0
    )
    today = (
        db.query(func.count(PageVisit.id))
        .filter(PageVisit.created_at >= today_start)
        .scalar()
        or 0
    )
    week = (
        db.query(func.count(PageVisit.id))
        .filter(PageVisit.created_at >= week_start)
        .scalar()
        or 0
    )

    top = (
        db.query(PageVisit.path, func.count(PageVisit.id).label("count"))
        .group_by(PageVisit.path)
        .order_by(func.count(PageVisit.id).desc())
        .limit(10)
        .all()
    )

    return VisitStats(
        total_visits=total,
        unique_paths=unique,
        visits_today=today,
        visits_this_week=week,
        top_pages=[{"path": p, "count": c} for p, c in top],
    )
