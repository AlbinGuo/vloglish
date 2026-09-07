from sqlalchemy.orm import Session, joinedload

from .models import DemoCode, Episode
from .episode_visibility import can_view_published_episode, published_visibility_filter
from .services.site_settings import content_access_unlocked


def user_is_member(user) -> bool:
    if user is None or not getattr(user, "is_member", False):
        return False
    until = getattr(user, "member_until", None)
    if until is not None:
        from datetime import datetime

        return until > datetime.utcnow()
    return True


def get_episode_limit(db: Session, user) -> int | None:
    """已不再按固定集数截断；None 表示目录总量不截断。"""
    _ = (db, user)
    return None


def episode_order(ordering: str):
    order_map = {
        "index": Episode.index.desc(),
        "-index": Episode.index.asc(),
        "stars": Episode.stars.desc(),
        "-stars": Episode.stars.asc(),
        "created_at": Episode.created_at.desc(),
        "-created_at": Episode.created_at.asc(),
    }
    return order_map.get(ordering, Episode.created_at.desc())


def get_visible_episode_ids(db: Session, user, ordering: str = "created_at") -> set[int]:
    """普通用户可播放的剧集（管理员勾选了对普通用户开放）。"""
    if user_is_member(user) or content_access_unlocked(db, user):
        return set()
    _ = ordering
    rows = (
        db.query(Episode.id)
        .filter(Episode.status == "published")
        .filter(published_visibility_filter(user))
        .filter(Episode.open_to_free_users.is_(True))
        .all()
    )
    return {row[0] for row in rows}


def get_demo_episodes(db: Session) -> list[Episode]:
    demo = (
        db.query(DemoCode)
        .options(
            joinedload(DemoCode.episodes).joinedload(Episode.author),
            joinedload(DemoCode.episodes).joinedload(Episode.tags),
        )
        .filter(DemoCode.code == "ALICE")
        .first()
    )
    if demo and demo.episodes:
        return list(demo.episodes)
    return (
        db.query(Episode)
        .options(joinedload(Episode.author), joinedload(Episode.tags))
        .filter(Episode.is_demo.is_(True), Episode.status == "published")
        .all()
    )


def get_visible_demo_episodes(db: Session, user) -> list[Episode]:
    episodes = sorted(get_demo_episodes(db), key=lambda e: e.index, reverse=True)
    if user_is_member(user) or content_access_unlocked(db, user):
        return episodes
    return [ep for ep in episodes if getattr(ep, "open_to_free_users", False)]


def can_access_episode(db: Session, episode: Episode, user, ordering: str = "created_at") -> bool:
    if episode.status != "published":
        return False
    if not can_view_published_episode(episode, user):
        return False
    if (
        episode.submitted_by_user_id is not None
        and user is not None
        and user.id == episode.submitted_by_user_id
    ):
        return True
    if user_is_member(user):
        return True
    if content_access_unlocked(db, user):
        return True
    # 未登录不可看
    if user is None:
        return False
    # 普通用户：仅管理员勾选「对普通用户开放」的剧集可播放
    return bool(getattr(episode, "open_to_free_users", False))


def can_access_series_content(db: Session, user) -> bool:
    if user_is_member(user):
        return True
    return content_access_unlocked(db, user)
