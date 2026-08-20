"""用户关注作者。"""

from __future__ import annotations

from sqlalchemy.orm import Session

from ..models import Author, UserAuthorSubscription


def is_author_subscribed(db: Session, user_id: int | None, author_id: int) -> bool:
    if not user_id or not author_id:
        return False
    return (
        db.query(UserAuthorSubscription.user_id)
        .filter(
            UserAuthorSubscription.user_id == user_id,
            UserAuthorSubscription.author_id == author_id,
        )
        .first()
        is not None
    )


def author_subscriber_count(db: Session, author_id: int) -> int:
    if not author_id:
        return 0
    return (
        db.query(UserAuthorSubscription.user_id)
        .filter(UserAuthorSubscription.author_id == author_id)
        .count()
    )


def subscriber_user_ids(db: Session, author_id: int) -> set[int]:
    if not author_id:
        return set()
    rows = (
        db.query(UserAuthorSubscription.user_id)
        .filter(UserAuthorSubscription.author_id == author_id)
        .all()
    )
    return {row[0] for row in rows}


def attach_author_subscribe_fields(
    db: Session, payload: dict, author_id: int, user_id: int | None
) -> dict:
    payload = dict(payload)
    payload["is_subscribed"] = is_author_subscribed(db, user_id, author_id)
    payload["subscriber_count"] = author_subscriber_count(db, author_id)
    return payload


def set_author_subscribed(
    db: Session, user_id: int, author_id: int, subscribed: bool
) -> dict:
    author = db.query(Author).filter(Author.id == author_id).first()
    if not author:
        raise ValueError("作者不存在")

    row = (
        db.query(UserAuthorSubscription)
        .filter(
            UserAuthorSubscription.user_id == user_id,
            UserAuthorSubscription.author_id == author_id,
        )
        .first()
    )
    if subscribed and not row:
        db.add(UserAuthorSubscription(user_id=user_id, author_id=author_id))
        db.commit()
    elif not subscribed and row:
        db.delete(row)
        db.commit()

    return {
        "success": True,
        "is_subscribed": subscribed,
        "subscriber_count": author_subscriber_count(db, author_id),
    }
