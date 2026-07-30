from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from ...database import get_db
from ...deps import get_current_admin
from ...models import Episode, EpisodeSeries, User
from ...schemas import (
    AdminSeriesCreateIn,
    AdminSeriesListOut,
    AdminSeriesOut,
    AdminSeriesUpdateIn,
)
from ...services.episode_series import (
    SERIES_STATUSES,
    sanitize_series_slug,
    series_episode_count,
)

router = APIRouter(prefix="/api/admin/series", tags=["admin-series"])


def _fmt_dt(value: datetime | None) -> str:
    if not value:
        return ""
    return value.strftime("%Y-%m-%d %H:%M:%S")


def _series_out(db: Session, series: EpisodeSeries) -> AdminSeriesOut:
    return AdminSeriesOut(
        id=series.id,
        slug=series.slug,
        title=series.title,
        summary=series.summary or "",
        cover=series.cover or "",
        status=series.status,
        sort_order=series.sort_order or 0,
        episode_count=series_episode_count(db, series.id),
        created_at=_fmt_dt(series.created_at),
        published_at=_fmt_dt(series.published_at),
    )


def _require_series(db: Session, series_id: int) -> EpisodeSeries:
    series = db.query(EpisodeSeries).filter(EpisodeSeries.id == series_id).first()
    if not series:
        raise HTTPException(status_code=404, detail="合集不存在")
    return series


@router.get("/", response_model=AdminSeriesListOut)
def list_series(
    status: str | None = Query(None, pattern="^(draft|published|archived)$"),
    search: str | None = None,
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    q = db.query(EpisodeSeries)
    if status:
        q = q.filter(EpisodeSeries.status == status)
    if search and search.strip():
        term = f"%{search.strip()}%"
        q = q.filter(EpisodeSeries.title.ilike(term) | EpisodeSeries.slug.ilike(term))
    rows = q.order_by(EpisodeSeries.sort_order.asc(), EpisodeSeries.id.desc()).all()
    return AdminSeriesListOut(count=len(rows), results=[_series_out(db, s) for s in rows])


@router.post("/", response_model=AdminSeriesOut)
def create_series(
    body: AdminSeriesCreateIn,
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    slug = sanitize_series_slug(body.slug)
    if db.query(EpisodeSeries).filter(EpisodeSeries.slug == slug).first():
        raise HTTPException(status_code=400, detail="合集 slug 已存在")
    if body.status not in SERIES_STATUSES:
        raise HTTPException(status_code=400, detail="无效状态")

    series = EpisodeSeries(
        slug=slug,
        title=body.title.strip(),
        summary=body.summary or "",
        cover=body.cover or "",
        status=body.status,
        sort_order=body.sort_order,
        published_at=datetime.utcnow() if body.status == "published" else None,
    )
    db.add(series)
    db.commit()
    db.refresh(series)
    return _series_out(db, series)


@router.get("/{series_id}/", response_model=AdminSeriesOut)
def get_series(
    series_id: int,
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    return _series_out(db, _require_series(db, series_id))


@router.patch("/{series_id}/", response_model=AdminSeriesOut)
def update_series(
    series_id: int,
    body: AdminSeriesUpdateIn,
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    series = _require_series(db, series_id)
    data = body.model_dump(exclude_unset=True)

    if "slug" in data and data["slug"] is not None:
        slug = sanitize_series_slug(data["slug"])
        conflict = (
            db.query(EpisodeSeries)
            .filter(EpisodeSeries.slug == slug, EpisodeSeries.id != series_id)
            .first()
        )
        if conflict:
            raise HTTPException(status_code=400, detail="合集 slug 已存在")
        series.slug = slug
    if "title" in data and data["title"] is not None:
        series.title = data["title"].strip()
    if "summary" in data:
        series.summary = data.get("summary") or ""
    if "cover" in data:
        series.cover = data.get("cover") or ""
    if "sort_order" in data and data["sort_order"] is not None:
        series.sort_order = data["sort_order"]
    if "status" in data and data["status"] is not None:
        status = data["status"]
        if status not in SERIES_STATUSES:
            raise HTTPException(status_code=400, detail="无效状态")
        if status == "published" and (series.status != "published" or series.published_at is None):
            series.published_at = datetime.utcnow()
        series.status = status

    db.commit()
    db.refresh(series)
    return _series_out(db, series)


@router.delete("/{series_id}/")
def delete_series(
    series_id: int,
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    series = _require_series(db, series_id)
    db.query(Episode).filter(Episode.series_id == series_id).update(
        {Episode.series_id: None, Episode.series_index: None},
        synchronize_session=False,
    )
    db.delete(series)
    db.commit()
    return {"success": True}
