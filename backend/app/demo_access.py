from sqlalchemy.orm import Session, joinedload

from .models import DemoCode, Episode

GUEST_EPISODE_LIMIT = 2
LOGGED_IN_EPISODE_LIMIT = 5


def user_is_member(user) -> bool:
    return user is not None and user.is_member


def get_episode_limit(user) -> int | None:
    if user_is_member(user):
        return None
    if user is not None:
        return LOGGED_IN_EPISODE_LIMIT
    return GUEST_EPISODE_LIMIT


def episode_order(ordering: str):
    order_map = {
        "index": Episode.index.desc(),
        "-index": Episode.index.asc(),
        "stars": Episode.stars.desc(),
        "-stars": Episode.stars.asc(),
    }
    return order_map.get(ordering, Episode.index.desc())


def get_visible_episode_ids(db: Session, user, ordering: str = "index") -> set[int]:
    limit = get_episode_limit(user)
    if limit is None:
        return set()
    rows = (
        db.query(Episode.id)
        .filter(Episode.status == "published")
        .order_by(episode_order(ordering))
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


def can_access_episode(db: Session, episode: Episode, user, ordering: str = "index") -> bool:
    if user_is_member(user):
        return True
    return episode.id in get_visible_episode_ids(db, user, ordering)
