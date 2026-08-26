"""需求墙：公开建议、点赞。"""

from __future__ import annotations

from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import func
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from ..database import get_db, is_postgresql
from ..deps import get_current_user, get_current_user_optional
from ..models import User, WishRequest, WishRequestLike
from ..schemas import WishCreateIn, WishCreateOut, WishItemOut, WishLikeOut, WishListOut

router = APIRouter(prefix="/api/wish-wall", tags=["wish-wall"])

_DAILY_LIMIT = 5
_ALLOWED_SORT = {"hot", "new"}


def _fmt_dt(value: datetime | None) -> str:
    if not value:
        return ""
    return value.strftime("%Y-%m-%d %H:%M:%S")


def _item_out(
    row: WishRequest,
    *,
    liked_ids: set[int],
    user_id: int | None,
) -> WishItemOut:
    return WishItemOut(
        id=row.id,
        title=row.title,
        body=row.body or "",
        admin_reply=row.admin_reply or "",
        like_count=max(0, row.like_count or 0),
        liked=row.id in liked_ids,
        status=row.status or "pending",
        mine=bool(user_id and row.user_id == user_id),
        created_at=_fmt_dt(row.created_at),
    )


@router.get("/", response_model=WishListOut)
def list_wishes(
    sort: str = Query("hot"),
    page: int = Query(1, ge=1),
    page_size: int = Query(40, ge=1, le=80),
    user: User | None = Depends(get_current_user_optional),
    db: Session = Depends(get_db),
):
    sort_key = (sort or "hot").strip().lower()
    if sort_key not in _ALLOWED_SORT:
        raise HTTPException(status_code=400, detail="排序无效")

    q = db.query(WishRequest).filter(WishRequest.hidden.is_(False))
    total = q.count()
    if sort_key == "new":
        q = q.order_by(WishRequest.created_at.desc(), WishRequest.id.desc())
    else:
        q = q.order_by(
            WishRequest.like_count.desc(),
            WishRequest.created_at.desc(),
            WishRequest.id.desc(),
        )
    rows = q.offset((page - 1) * page_size).limit(page_size).all()

    liked_ids: set[int] = set()
    if user and rows:
        liked_ids = {
            r.wish_id
            for r in db.query(WishRequestLike)
            .filter(
                WishRequestLike.user_id == user.id,
                WishRequestLike.wish_id.in_([row.id for row in rows]),
            )
            .all()
        }

    uid = user.id if user else None
    return WishListOut(
        count=total,
        results=[_item_out(row, liked_ids=liked_ids, user_id=uid) for row in rows],
    )


@router.post("/", response_model=WishCreateOut)
def create_wish(
    body: WishCreateIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    title = body.title.strip()
    content = body.body.strip()
    if len(title) < 2:
        raise HTTPException(status_code=400, detail="标题至少 2 个字")
    if len(content) < 8:
        raise HTTPException(status_code=400, detail="请再写清楚一点，至少 8 个字")

    day_start = datetime.utcnow().replace(hour=0, minute=0, second=0, microsecond=0)
    today_count = (
        db.query(func.count(WishRequest.id))
        .filter(WishRequest.user_id == user.id, WishRequest.created_at >= day_start)
        .scalar()
        or 0
    )
    if today_count >= _DAILY_LIMIT:
        raise HTTPException(status_code=400, detail="今天已经贴了不少，明天再来吧")

    row = WishRequest(
        user_id=user.id,
        title=title[:80],
        body=content[:2000],
        status="pending",
    )
    db.add(row)
    db.commit()
    db.refresh(row)
    return WishCreateOut(id=row.id)


@router.post("/{wish_id}/like/", response_model=WishLikeOut)
def toggle_wish_like(
    wish_id: int,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    q = db.query(WishRequest).filter(WishRequest.id == wish_id, WishRequest.hidden.is_(False))
    if is_postgresql():
        q = q.with_for_update()
    row = q.first()
    if not row:
        raise HTTPException(status_code=404, detail="这条需求不存在")

    existing = (
        db.query(WishRequestLike)
        .filter(WishRequestLike.user_id == user.id, WishRequestLike.wish_id == wish_id)
        .first()
    )
    if existing:
        db.delete(existing)
        row.like_count = max(0, (row.like_count or 0) - 1)
        liked = False
    else:
        db.add(WishRequestLike(user_id=user.id, wish_id=wish_id))
        row.like_count = (row.like_count or 0) + 1
        liked = True
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
        row = db.query(WishRequest).filter(WishRequest.id == wish_id).first()
        if not row:
            raise HTTPException(status_code=404, detail="这条需求不存在") from None
        liked = (
            db.query(WishRequestLike)
            .filter(WishRequestLike.user_id == user.id, WishRequestLike.wish_id == wish_id)
            .first()
            is not None
        )
        return WishLikeOut(liked=liked, like_count=max(0, row.like_count or 0))
    db.refresh(row)
    return WishLikeOut(liked=liked, like_count=max(0, row.like_count or 0))
