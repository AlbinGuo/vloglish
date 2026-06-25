from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Query
from fastapi.responses import FileResponse
from sqlalchemy import func, or_
from sqlalchemy.orm import Session, joinedload

from ..database import get_db
from ..demo_access import can_access_episode, get_episode_limit, user_is_member
from ..deps import get_current_user_optional, get_device_id
from ..favorites import favorite_video_ids
from ..media import find_episode_audio_file, find_episode_video_file
from ..models import Author, Episode, EpisodeFavorite, Tag, User, UserEpisodeFavorite
from ..serializers import episode_detail, episode_summary

router = APIRouter(prefix="/api", tags=["episodes"])


@router.get("/episode-list/")
def episode_list(
    page: int = Query(1, ge=1),
    page_size: int = Query(12, ge=1, le=50),
    offset: int | None = Query(None, ge=0),
    stars: int | None = None,
    accent: str | None = None,
    accents: str | None = None,
    gender: str | None = None,
    tag: int | None = None,
    tags: str | None = None,
    date: str | None = None,
    status: str | None = Query(None, pattern="^(all|learned|unlearned|favorite)$"),
    ordering: str = Query("created_at", pattern="^(index|-index|stars|-stars|created_at|-created_at)$"),
    search: str | None = None,
    db: Session = Depends(get_db),
    device_id: str = Depends(get_device_id),
    user: User | None = Depends(get_current_user_optional),
):
    user_id = user.id if user else None
    fav_ids = favorite_video_ids(db, device_id, user_id)
    q = db.query(Episode).options(joinedload(Episode.author), joinedload(Episode.tags))
    q = q.filter(Episode.status == "published")

    author_joined = False

    def ensure_author_join():
        nonlocal q, author_joined
        if not author_joined:
            q = q.join(Author)
            author_joined = True

    if stars is not None:
        q = q.filter(Episode.stars == stars)
    accent_values: list[str] = []
    if accents:
        accent_values = [a.strip() for a in accents.split(",") if a.strip()]
    elif accent:
        accent_values = [accent]
    if accent_values:
        ensure_author_join()
        q = q.filter(Author.accent.in_(accent_values))
    if gender:
        ensure_author_join()
        q = q.filter(Author.gender == gender)
    if search and search.strip():
        ensure_author_join()
        term = f"%{search.strip()}%"
        q = q.filter(or_(Episode.short_title.ilike(term), Author.name.ilike(term)))
    tag_ids: list[int] = []
    if tags:
        tag_ids = [int(t) for t in tags.split(",") if t.strip().isdigit()]
    elif tag is not None:
        tag_ids = [tag]
    for tag_id in tag_ids:
        q = q.filter(Episode.tags.any(Tag.id == tag_id))
    if date:
        try:
            day = datetime.strptime(date, "%Y-%m-%d").date()
            q = q.filter(func.date(Episode.created_at) == day)
        except ValueError:
            pass
    if status == "learned":
        q = q.filter(Episode.id < 0)
    elif status == "favorite":
        if fav_ids:
            q = q.filter(Episode.video_id.in_(fav_ids))
        else:
            q = q.filter(Episode.id < 0)

    order_map = {
        "index": Episode.index.desc(),
        "-index": Episode.index.asc(),
        "stars": Episode.stars.desc(),
        "-stars": Episode.stars.asc(),
        "created_at": Episode.created_at.desc(),
        "-created_at": Episode.created_at.asc(),
    }
    q = q.order_by(order_map.get(ordering, Episode.created_at.desc()))

    limit = get_episode_limit(user)
    start = offset if offset is not None else (page - 1) * page_size
    if limit is not None:
        matched = q.limit(limit).all()
        total = len(matched)
        items = matched[start : start + page_size]
    else:
        total = q.count()
        items = q.offset(start).limit(page_size).all()
    return {
        "count": total,
        "results": [
            episode_summary(
                ep,
                is_favorite=ep.video_id in fav_ids if user_is_member(user) else False,
            )
            for ep in items
        ],
    }


@router.post("/episodes/{video_id}/favorite/")
def add_episode_favorite(
    video_id: str,
    db: Session = Depends(get_db),
    device_id: str = Depends(get_device_id),
    user: User | None = Depends(get_current_user_optional),
):
    episode = db.query(Episode).filter(Episode.video_id == video_id, Episode.status == "published").first()
    if not episode:
        raise HTTPException(status_code=404, detail="Episode not found")
    if not user_is_member(user):
        raise HTTPException(status_code=403, detail="需要激活会员")
    if not can_access_episode(db, episode, user):
        raise HTTPException(status_code=403, detail="无权访问该内容")

    exists = (
        db.query(UserEpisodeFavorite)
        .filter(UserEpisodeFavorite.user_id == user.id, UserEpisodeFavorite.episode_id == episode.id)
        .first()
    )
    if not exists:
        db.add(UserEpisodeFavorite(user_id=user.id, episode_id=episode.id))
        db.commit()
    return {"success": True, "is_favorite": True}


@router.delete("/episodes/{video_id}/favorite/")
def remove_episode_favorite(
    video_id: str,
    db: Session = Depends(get_db),
    device_id: str = Depends(get_device_id),
    user: User | None = Depends(get_current_user_optional),
):
    episode = db.query(Episode).filter(Episode.video_id == video_id, Episode.status == "published").first()
    if not episode:
        raise HTTPException(status_code=404, detail="Episode not found")
    if not user_is_member(user):
        raise HTTPException(status_code=403, detail="需要激活会员")

    db.query(UserEpisodeFavorite).filter(
        UserEpisodeFavorite.user_id == user.id,
        UserEpisodeFavorite.episode_id == episode.id,
    ).delete()
    db.commit()
    return {"success": True, "is_favorite": False}


@router.get("/episode/{video_id}/detail/")
def get_episode_detail(
    video_id: str,
    db: Session = Depends(get_db),
    user: User | None = Depends(get_current_user_optional),
):
    episode = (
        db.query(Episode)
        .options(joinedload(Episode.author), joinedload(Episode.tags), joinedload(Episode.subtitles))
        .filter(Episode.video_id == video_id, Episode.status == "published")
        .first()
    )
    if not episode:
        raise HTTPException(status_code=404, detail="Episode not found")
    if not can_access_episode(db, episode, user):
        raise HTTPException(status_code=403, detail="需要激活会员")

    total = db.query(Episode).filter(Episode.status == "published").count()
    if not user_is_member(user):
        limit = get_episode_limit(user) or 0
        total = limit
    return episode_detail(episode, total)


@router.get("/episode/{video_id}/audio/")
def get_episode_audio(
    video_id: str,
    db: Session = Depends(get_db),
    user: User | None = Depends(get_current_user_optional),
):
    episode = db.query(Episode).filter(Episode.video_id == video_id, Episode.status == "published").first()
    if not episode:
        raise HTTPException(status_code=404, detail="Episode not found")
    if not can_access_episode(db, episode, user):
        raise HTTPException(status_code=403, detail="需要激活会员")

    found = find_episode_audio_file(video_id)
    if found:
        audio_path, media_type = found
        return FileResponse(audio_path, media_type=media_type, filename=audio_path.name)

    raise HTTPException(
        status_code=404,
        detail="Audio file not found. Run: python scripts/download_episode_audio.py 26PrgjTboVQ",
    )


@router.get("/episode/{video_id}/video/")
def get_episode_video(
    video_id: str,
    db: Session = Depends(get_db),
    user: User | None = Depends(get_current_user_optional),
):
    episode = db.query(Episode).filter(Episode.video_id == video_id, Episode.status == "published").first()
    if not episode:
        raise HTTPException(status_code=404, detail="Episode not found")
    if not can_access_episode(db, episode, user):
        raise HTTPException(status_code=403, detail="需要激活会员")

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

    rows = db.query(distinct(Author.accent)).filter(Author.accent != "").all()
    return [{"accent": r[0]} for r in rows if r[0]]
