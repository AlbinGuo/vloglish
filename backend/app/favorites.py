from sqlalchemy.orm import Session

from .models import Episode, EpisodeFavorite, UserEpisodeFavorite


def favorite_video_ids(
    db: Session,
    device_id: str,
    user_id: int | None = None,
) -> set[str]:
    if user_id is not None:
        rows = (
            db.query(Episode.video_id)
            .join(UserEpisodeFavorite, UserEpisodeFavorite.episode_id == Episode.id)
            .filter(UserEpisodeFavorite.user_id == user_id)
            .all()
        )
        return {row[0] for row in rows}

    if not device_id or device_id == "anonymous":
        return set()

    rows = (
        db.query(Episode.video_id)
        .join(EpisodeFavorite, EpisodeFavorite.episode_id == Episode.id)
        .filter(EpisodeFavorite.device_id == device_id)
        .all()
    )
    return {row[0] for row in rows}


def merge_device_favorites(db: Session, user_id: int, device_id: str) -> None:
    if not device_id or device_id == "anonymous":
        return

    device_favs = db.query(EpisodeFavorite).filter(EpisodeFavorite.device_id == device_id).all()
    existing = {
        row[0]
        for row in db.query(UserEpisodeFavorite.episode_id)
        .filter(UserEpisodeFavorite.user_id == user_id)
        .all()
    }

    for fav in device_favs:
        if fav.episode_id in existing:
            continue
        db.add(UserEpisodeFavorite(user_id=user_id, episode_id=fav.episode_id))
        existing.add(fav.episode_id)

    db.commit()
