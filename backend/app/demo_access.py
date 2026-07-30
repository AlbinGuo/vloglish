from sqlalchemy.orm import Session, joinedload

from .models import DemoCode, Episode
from .episode_visibility import can_view_published_episode, published_visibility_filter

GUEST_EPISODE_LIMIT = 8


def user_is_member(user) -> bool:
    return user is not None and user.is_member


def get_episode_limit(user) -> int | None:
    if user_is_member(user):
        return None
    return GUEST_EPISODE_LIMIT


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
    limit = get_episode_limit(user)
    if limit is None:
        return set()
    rows = (
        db.query(Episode.id)
        .filter(Episode.status == "published")
        .filter(Episode.series_id.is_(None))
        .filter(published_visibility_filter(user))
        .order_by(Episode.is_pinned.desc(), episode_order(ordering))
        .limit(limit)
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
    limit = get_episode_limit(user)
    if limit is None:
        return episodes
    return episodes[:limit]


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
    # 合集内视频不占用「视频」列表的访客限额，可从合集入口访问
    if episode.series_id is not None:
        return True
    return episode.id in get_visible_episode_ids(db, user, ordering)
