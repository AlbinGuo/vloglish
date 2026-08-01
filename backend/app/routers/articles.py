from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import func, or_
from sqlalchemy.orm import Session, joinedload

from ..database import get_db
from ..deps import get_current_user, get_current_user_optional, get_device_id
from ..models import Article, User
from ..schemas import ArticleProgressUpdateIn
from ..serializers import article_detail, article_list_item, article_progress_out, article_segment_out
from ..services.article_access import (
    can_access_article,
    continue_reading_articles,
    get_article_quota,
    progress_map_for_articles,
    record_article_open,
    update_article_progress,
)
from ..services.article_admin import get_article_by_ref

router = APIRouter(prefix="/api/articles", tags=["articles"])


def _get_published_article(db: Session, article_id: str) -> Article:
    article = get_article_by_ref(db, article_id)
    if not article or article.status != "published":
        raise HTTPException(status_code=404, detail="文章不存在")
    return article


@router.get("/filters/")
def article_filters(db: Session = Depends(get_db)):
    sources = [
        r[0]
        for r in db.query(Article.source)
        .filter(Article.status == "published", Article.source != "")
        .distinct()
        .order_by(Article.source.asc())
        .all()
    ]
    topics = [
        r[0]
        for r in db.query(Article.topic)
        .filter(Article.status == "published", Article.topic != "")
        .distinct()
        .order_by(Article.topic.asc())
        .all()
    ]
    return {"sources": sources, "topics": topics}


@router.get("/")
def list_articles(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=50),
    source: str | None = None,
    topic: str | None = None,
    stars: int | None = None,
    status: str | None = Query(None, pattern="^(all|in_progress|completed)$"),
    ordering: str = Query("-published_at", pattern="^(-published_at|published_at|stars|-stars)$"),
    q: str | None = None,
    db: Session = Depends(get_db),
    device_id: str = Depends(get_device_id),
    user: User | None = Depends(get_current_user_optional),
):
    query = db.query(Article).filter(Article.status == "published")

    if source:
        query = query.filter(Article.source == source)
    if topic:
        query = query.filter(Article.topic == topic)
    if stars is not None:
        query = query.filter(Article.stars == stars)
    if q and q.strip():
        term = f"%{q.strip()}%"
        query = query.filter(or_(Article.title.ilike(term), Article.summary.ilike(term)))

    # 上传/发布时间：published_at 为空时回退 created_at
    upload_time = func.coalesce(Article.published_at, Article.created_at)
    order_map = {
        "-published_at": upload_time.desc(),
        "published_at": upload_time.asc(),
        "stars": Article.stars.asc(),
        "-stars": Article.stars.desc(),
    }
    query = query.order_by(order_map.get(ordering, upload_time.desc()), Article.id.desc())

    all_matched = query.all()
    progress_map: dict[int, object] = {}
    if user:
        progress_map = progress_map_for_articles(db, user.id, [a.id for a in all_matched])

    if status == "in_progress" and user:
        all_matched = [
            a
            for a in all_matched
            if (p := progress_map.get(a.id)) and not p.is_completed and p.last_segment_index > 0
        ]
    elif status == "completed" and user:
        all_matched = [a for a in all_matched if (p := progress_map.get(a.id)) and p.is_completed]
    elif status in ("in_progress", "completed") and not user:
        all_matched = []

    total = len(all_matched)
    start = (page - 1) * page_size
    page_rows = all_matched[start : start + page_size]

    results = []
    for article in page_rows:
        results.append(
            article_list_item(
                article,
                progress=progress_map.get(article.id),
                accessible=can_access_article(db, article, user, device_id),
            )
        )

    next_page = f"?page={page + 1}" if start + page_size < total else None
    return {
        "count": total,
        "next": next_page,
        "results": results,
        "quota": get_article_quota(db, user, device_id),
    }


@router.get("/continue/")
def continue_reading(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    rows = continue_reading_articles(db, user)
    if not rows:
        return {"results": []}
    articles = {
        a.id: a
        for a in db.query(Article)
        .filter(Article.id.in_([r.article_id for r in rows]))
        .all()
    }
    results = []
    for row in rows:
        article = articles.get(row.article_id)
        if not article:
            continue
        results.append(
            {
                "article_id": article.article_id,
                "title": article.title,
                "source": article.source or "",
                "cover": article.cover or "",
                "completion_percent": round(row.completion_percent, 1),
                "last_read_at": row.last_read_at.isoformat() if row.last_read_at else None,
            }
        )
    return {"results": results}


@router.get("/{article_id}/")
def get_article(
    article_id: str,
    db: Session = Depends(get_db),
    device_id: str = Depends(get_device_id),
    user: User | None = Depends(get_current_user_optional),
):
    article = _get_published_article(db, article_id)
    if not can_access_article(db, article, user, device_id):
        quota = get_article_quota(db, user, device_id)
        raise HTTPException(
            status_code=403,
            detail={
                "code": "article_limit_reached",
                "message": "已达到本月可读文章上限",
                "quota": quota,
            },
        )

    record_article_open(db, article, user, device_id)

    segments = (
        db.query(Article)
        .options(joinedload(Article.segments))
        .filter(Article.id == article.id)
        .first()
        .segments
    )

    progress = None
    if user:
        from ..models import UserArticleProgress

        progress = (
            db.query(UserArticleProgress)
            .filter(UserArticleProgress.user_id == user.id, UserArticleProgress.article_id == article.id)
            .first()
        )

    return article_detail(article, segments, progress=progress)


@router.patch("/{article_id}/progress/")
def patch_progress(
    article_id: str,
    body: ArticleProgressUpdateIn,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    article = _get_published_article(db, article_id)
    row = update_article_progress(
        db,
        user,
        article,
        last_segment_index=body.last_segment_index,
        read_time_delta_sec=body.read_time_delta_sec,
    )
    return article_progress_out(row)
