from __future__ import annotations

from datetime import datetime

from sqlalchemy import func
from sqlalchemy.orm import Session

from ..demo_access import user_is_member
from ..models import Article, User, UserArticleOpen, UserArticleProgress
from .site_settings import content_access_unlocked

GUEST_ARTICLE_LIMIT = 3
NON_MEMBER_MONTHLY_LIMIT = 5


def _month_start() -> datetime:
    now = datetime.utcnow()
    return datetime(now.year, now.month, 1)


def opened_article_ids_this_period(
    db: Session,
    *,
    user: User | None,
    device_id: str,
) -> set[int]:
    if user_is_member(user) or content_access_unlocked(db, user):
        return set()

    if user:
        rows = (
            db.query(UserArticleOpen.article_id)
            .filter(
                UserArticleOpen.user_id == user.id,
                UserArticleOpen.opened_at >= _month_start(),
            )
            .distinct()
            .all()
        )
        return {r[0] for r in rows}

    rows = (
        db.query(UserArticleOpen.article_id)
        .filter(
            UserArticleOpen.device_id == device_id,
            UserArticleOpen.user_id.is_(None),
        )
        .distinct()
        .limit(GUEST_ARTICLE_LIMIT)
        .all()
    )
    return {r[0] for r in rows}


def has_opened_article(
    db: Session,
    *,
    user: User | None,
    device_id: str,
    article_id: int,
) -> bool:
    q = db.query(UserArticleOpen.id).filter(UserArticleOpen.article_id == article_id)
    if user:
        q = q.filter(UserArticleOpen.user_id == user.id)
    else:
        q = q.filter(UserArticleOpen.device_id == device_id, UserArticleOpen.user_id.is_(None))
    return q.first() is not None


def can_access_article(db: Session, article: Article, user: User | None, device_id: str) -> bool:
    if article.status != "published":
        return False
    # 用户投稿未转全站：仅投稿者可看（不占免费额度）
    if article.submitted_by_user_id is not None and not bool(
        getattr(article, "is_catalog_public", False)
    ):
        return user is not None and user.id == article.submitted_by_user_id
    if user_is_member(user):
        return True
    if content_access_unlocked(db, user):
        return True
    if has_opened_article(db, user=user, device_id=device_id, article_id=article.id):
        return True
    opened = opened_article_ids_this_period(db, user=user, device_id=device_id)
    limit = NON_MEMBER_MONTHLY_LIMIT if user else GUEST_ARTICLE_LIMIT
    return len(opened) < limit


def record_article_open(db: Session, article: Article, user: User | None, device_id: str) -> None:
    if has_opened_article(db, user=user, device_id=device_id, article_id=article.id):
        return
    db.add(
        UserArticleOpen(
            user_id=user.id if user else None,
            device_id=device_id if not user else "",
            article_id=article.id,
        )
    )
    db.commit()


def get_article_quota(db: Session, user: User | None, device_id: str) -> dict:
    if user_is_member(user):
        return {
            "is_member": True,
            "monthly_limit": None,
            "opened_this_month": 0,
            "remaining": None,
        }
    # 关门槛期间登录用户文章不限量；is_member 仍为 False（AI 配额照旧）
    if content_access_unlocked(db, user):
        return {
            "is_member": False,
            "monthly_limit": None,
            "opened_this_month": 0,
            "remaining": None,
        }
    opened = opened_article_ids_this_period(db, user=user, device_id=device_id)
    limit = NON_MEMBER_MONTHLY_LIMIT if user else GUEST_ARTICLE_LIMIT
    count = len(opened)
    return {
        "is_member": False,
        "monthly_limit": limit,
        "opened_this_month": count,
        "remaining": max(0, limit - count),
    }


def progress_map_for_articles(db: Session, user_id: int, article_ids: list[int]) -> dict[int, UserArticleProgress]:
    if not article_ids:
        return {}
    rows = (
        db.query(UserArticleProgress)
        .filter(
            UserArticleProgress.user_id == user_id,
            UserArticleProgress.article_id.in_(article_ids),
        )
        .all()
    )
    return {r.article_id: r for r in rows}


def article_progress_to_dict(row: UserArticleProgress | None) -> dict | None:
    if not row:
        return None
    return {
        "last_segment_index": row.last_segment_index,
        "max_reached_index": row.max_reached_index,
        "completion_percent": round(row.completion_percent, 1),
        "is_completed": row.is_completed,
        "last_read_at": row.last_read_at.isoformat() if row.last_read_at else None,
    }


def update_article_progress(
    db: Session,
    user: User,
    article: Article,
    *,
    last_segment_index: int,
    read_time_delta_sec: int = 0,
) -> UserArticleProgress:
    row = (
        db.query(UserArticleProgress)
        .filter(
            UserArticleProgress.user_id == user.id,
            UserArticleProgress.article_id == article.id,
        )
        .first()
    )
    now = datetime.utcnow()
    seg_count = max(article.segment_count, 1)
    max_idx = max(0, min(last_segment_index, seg_count - 1))
    completion = min(100.0, (max_idx + 1) / seg_count * 100)
    is_completed = completion >= 80.0

    if not row:
        row = UserArticleProgress(
            user_id=user.id,
            article_id=article.id,
            last_segment_index=max_idx,
            max_reached_index=max_idx,
            read_time_sec=max(0, read_time_delta_sec),
            completion_percent=completion,
            is_completed=is_completed,
            first_opened_at=now,
            last_read_at=now,
            completed_at=now if is_completed else None,
        )
        db.add(row)
    else:
        row.last_segment_index = max_idx
        row.max_reached_index = max(row.max_reached_index, max_idx)
        row.read_time_sec += max(0, read_time_delta_sec)
        row.completion_percent = max(row.completion_percent, completion)
        row.last_read_at = now
        if is_completed and not row.is_completed:
            row.is_completed = True
            row.completed_at = now

    db.commit()
    db.refresh(row)
    return row


def continue_reading_articles(db: Session, user: User, limit: int = 5) -> list[UserArticleProgress]:
    return (
        db.query(UserArticleProgress)
        .filter(
            UserArticleProgress.user_id == user.id,
            UserArticleProgress.is_completed.is_(False),
            UserArticleProgress.last_segment_index > 0,
        )
        .order_by(UserArticleProgress.last_read_at.desc())
        .limit(limit)
        .all()
    )
