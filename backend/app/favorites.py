from sqlalchemy.orm import Session

from .models import Episode, EpisodeFavorite


def favorite_video_ids(db: Session, device_id: str) -> set[str]:
    rows = (
        db.query(Episode.video_id)
        .join(EpisodeFavorite, EpisodeFavorite.episode_id == Episode.id)
        .filter(EpisodeFavorite.device_id == device_id)
        .all()
    )
    return {row[0] for row in rows}
