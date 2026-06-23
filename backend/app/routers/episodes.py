from fastapi import APIRouter, Depends, HTTPException, Query
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session, joinedload

from ..database import get_db
from ..media import find_episode_audio_file, find_episode_video_file
from ..models import Author, Episode, Tag
from ..serializers import episode_detail, episode_summary

router = APIRouter(prefix="/api", tags=["episodes"])


@router.get("/episode-list/")
def episode_list(
    page: int = Query(1, ge=1),
    page_size: int = Query(12, ge=1, le=50),
    stars: int | None = None,
    accent: str | None = None,
    gender: str | None = None,
    tag: int | None = None,
    ordering: str = Query("index", pattern="^(index|-index|stars|-stars)$"),
    db: Session = Depends(get_db),
):
    q = db.query(Episode).options(joinedload(Episode.author), joinedload(Episode.tags))

    if stars is not None:
        q = q.filter(Episode.stars == stars)
    if accent:
        q = q.join(Author).filter(Author.accent == accent)
    if gender:
        q = q.join(Author).filter(Author.gender == gender)
    if tag is not None:
        q = q.filter(Episode.tags.any(Tag.id == tag))

    order_map = {
        "index": Episode.index.desc(),
        "-index": Episode.index.asc(),
        "stars": Episode.stars.desc(),
        "-stars": Episode.stars.asc(),
    }
    q = q.order_by(order_map.get(ordering, Episode.index.desc()))

    total = q.count()
    items = q.offset((page - 1) * page_size).limit(page_size).all()
    return {"count": total, "results": [episode_summary(ep) for ep in items]}


@router.get("/episode/{video_id}/detail/")
def get_episode_detail(video_id: str, db: Session = Depends(get_db)):
    episode = (
        db.query(Episode)
        .options(joinedload(Episode.author), joinedload(Episode.tags), joinedload(Episode.subtitles))
        .filter(Episode.video_id == video_id)
        .first()
    )
    if not episode:
        raise HTTPException(status_code=404, detail="Episode not found")
    total = db.query(Episode).count()
    return episode_detail(episode, total)


@router.get("/episode/{video_id}/audio/")
def get_episode_audio(video_id: str, db: Session = Depends(get_db)):
    episode = db.query(Episode).filter(Episode.video_id == video_id).first()
    if not episode:
        raise HTTPException(status_code=404, detail="Episode not found")

    found = find_episode_audio_file(video_id)
    if found:
        audio_path, media_type = found
        return FileResponse(audio_path, media_type=media_type, filename=audio_path.name)

    raise HTTPException(
        status_code=404,
        detail="Audio file not found. Run: python scripts/download_episode_audio.py 26PrgjTboVQ",
    )


@router.get("/episode/{video_id}/video/")
def get_episode_video(video_id: str, db: Session = Depends(get_db)):
    episode = db.query(Episode).filter(Episode.video_id == video_id).first()
    if not episode:
        raise HTTPException(status_code=404, detail="Episode not found")

    found = find_episode_video_file(video_id)
    if found:
        video_path, media_type = found
        return FileResponse(video_path, media_type=media_type, filename=video_path.name)

    raise HTTPException(
        status_code=404,
        detail="Video file not found. Run: python scripts/download_episode_audio.py 26PrgjTboVQ",
    )


@router.get("/episode-tags/")
def episode_tags(db: Session = Depends(get_db)):
    tags = db.query(Tag).order_by(Tag.name).all()
    return [{"id": t.id, "name": t.name} for t in tags]


@router.get("/author-accents/")
def author_accents(db: Session = Depends(get_db)):
    from sqlalchemy import distinct
    from ..models import Author

    rows = db.query(distinct(Author.accent)).filter(Author.accent != "").all()
    return [{"accent": r[0]} for r in rows if r[0]]
