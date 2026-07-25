from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Query
from fastapi.responses import FileResponse
from sqlalchemy import func, or_
from sqlalchemy.orm import Session, joinedload, selectinload

from ..episode_visibility import published_visibility_filter
from ..database import get_db
from ..demo_access import can_access_episode, get_episode_limit, user_is_member
from ..deps import get_current_user_optional, get_device_id
from ..favorites import favorite_video_ids
from ..services.learning import learned_episode_ids, progress_map_for_episodes
from ..media import find_episode_audio_file, find_episode_video_file
from ..models import Author, Episode, EpisodeFavorite, EpisodeSeries, Tag, User, UserEpisodeFavorite
from ..serializers import episode_detail, episode_summary
from ..services.episode_series import list_series_episodes, series_nav_for_episode
from ..services.episode_word_cards import get_or_build_episode_word_cards, load_episode_for_word_cards

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
    series_id: int | None = None,
    series_slug: str | None = None,
    date: str | None = None,
    status: str | None = Query(None, pattern="^(all|learned|unlearned|favorite)$"),
    ordering: str = Query(
        "created_at",
        pattern="^(index|-index|stars|-stars|created_at|-created_at|series_index|-series_index)$",
    ),
    search: str | None = None,
    db: Session = Depends(get_db),
    device_id: str = Depends(get_device_id),
    user: User | None = Depends(get_current_user_optional),
):
    user_id = user.id if user else None
    fav_ids = favorite_video_ids(db, device_id, user_id)
    q = db.query(Episode).options(
        joinedload(Episode.author),
        joinedload(Episode.tags),
        joinedload(Episode.series),
    )
    q = q.filter(Episode.status == "published")
    q = q.filter(published_visibility_filter(user))

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
    if series_id is not None:
        q = q.filter(Episode.series_id == series_id)
    elif series_slug and series_slug.strip():
        q = q.join(EpisodeSeries).filter(EpisodeSeries.slug == series_slug.strip())
    else:
        # 视频列表只展示独立单集；合集内视频走 /series
        q = q.filter(Episode.series_id.is_(None))
    if date:
        try:
            day = datetime.strptime(date, "%Y-%m-%d").date()
            q = q.filter(func.date(Episode.created_at) == day)
        except ValueError:
            pass
    if status == "learned":
        if not user:
            q = q.filter(Episode.id < 0)
        else:
            learned_ids = learned_episode_ids(db, user.id)
            if learned_ids:
                q = q.filter(Episode.id.in_(learned_ids))
            else:
                q = q.filter(Episode.id < 0)
    elif status == "unlearned":
        if not user:
            q = q.filter(Episode.id < 0)
        else:
            learned_ids = learned_episode_ids(db, user.id)
            if learned_ids:
                q = q.filter(~Episode.id.in_(learned_ids))
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
        "series_index": Episode.series_index.asc().nulls_last(),
        "-series_index": Episode.series_index.desc().nulls_last(),
    }
    # 置顶视频始终排在最前（同置顶再按所选排序）
    q = q.order_by(Episode.is_pinned.desc(), order_map.get(ordering, Episode.created_at.desc()))

    limit = get_episode_limit(user)
    start = offset if offset is not None else (page - 1) * page_size
    if limit is not None:
        matched = q.limit(limit).all()
        total = len(matched)
        items = matched[start : start + page_size]
    else:
        total = q.count()
        items = q.offset(start).limit(page_size).all()
    prog_map = progress_map_for_episodes(db, user.id, [ep.id for ep in items]) if user else {}
    return {
        "count": total,
        "results": [
            episode_summary(
                ep,
                is_favorite=ep.video_id in fav_ids if user_is_member(user) else False,
                is_learned=prog_map.get(ep.id).is_completed if prog_map.get(ep.id) else False,
                progress_percent=prog_map.get(ep.id).completion_percent if prog_map.get(ep.id) else 0,
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


@router.get("/english/nav-counts/")
def english_nav_counts(
    db: Session = Depends(get_db),
    user: User | None = Depends(get_current_user_optional),
):
    """用户端顶栏：视频 / 合集 / 新闻阅读 可见数量。"""
    from ..models import Article

    video_q = (
        db.query(Episode)
        .filter(Episode.status == "published")
        .filter(Episode.series_id.is_(None))
        .filter(published_visibility_filter(user))
        .order_by(Episode.created_at.desc())
    )
    limit = get_episode_limit(user)
    if limit is not None:
        videos = len(video_q.limit(limit).all())
    else:
        videos = video_q.count()

    series_rows = (
        db.query(EpisodeSeries)
        .filter(EpisodeSeries.status == "published")
        .order_by(EpisodeSeries.sort_order.asc(), EpisodeSeries.id.desc())
        .all()
    )
    series_count = 0
    for series in series_rows:
        episodes = list_series_episodes(db, series.id, published_only=True)
        visible = [ep for ep in episodes if can_access_episode(db, ep, user)]
        if not visible and episodes:
            continue
        series_count += 1

    articles = db.query(Article).filter(Article.status == "published").count()

    return {"videos": videos, "series": series_count, "articles": articles}


@router.get("/series/")
def series_list(
    db: Session = Depends(get_db),
    user: User | None = Depends(get_current_user_optional),
):
    rows = (
        db.query(EpisodeSeries)
        .filter(EpisodeSeries.status == "published")
        .order_by(EpisodeSeries.sort_order.asc(), EpisodeSeries.id.desc())
        .all()
    )
    results = []
    for series in rows:
        episodes = list_series_episodes(db, series.id, published_only=True)
        visible = [ep for ep in episodes if can_access_episode(db, ep, user)]
        if not visible and episodes:
            continue
        results.append(
            {
                "id": series.id,
                "slug": series.slug,
                "title": series.title,
                "summary": series.summary or "",
                "cover": series.cover or (visible[0].cover if visible else ""),
                "episode_count": len(visible),
                "sort_order": series.sort_order or 0,
            }
        )
    return {"count": len(results), "results": results}


@router.get("/series/{slug}/")
def series_detail(
    slug: str,
    db: Session = Depends(get_db),
    device_id: str = Depends(get_device_id),
    user: User | None = Depends(get_current_user_optional),
):
    series = (
        db.query(EpisodeSeries)
        .filter(EpisodeSeries.slug == slug, EpisodeSeries.status == "published")
        .first()
    )
    if not series:
        raise HTTPException(status_code=404, detail="合集不存在")

    episodes = list_series_episodes(db, series.id, published_only=True)
    visible = [ep for ep in episodes if can_access_episode(db, ep, user)]
    user_id = user.id if user else None
    fav_ids = favorite_video_ids(db, device_id, user_id)
    prog_map = progress_map_for_episodes(db, user.id, [ep.id for ep in visible]) if user else {}

    return {
        "id": series.id,
        "slug": series.slug,
        "title": series.title,
        "summary": series.summary or "",
        "cover": series.cover or (visible[0].cover if visible else ""),
        "episode_count": len(visible),
        "episodes": [
            episode_summary(
                ep,
                is_favorite=ep.video_id in fav_ids if user_is_member(user) else False,
                is_learned=prog_map.get(ep.id).is_completed if prog_map.get(ep.id) else False,
                progress_percent=prog_map.get(ep.id).completion_percent if prog_map.get(ep.id) else 0,
            )
            for ep in visible
        ],
    }


@router.get("/episode/{video_id}/detail/")
def get_episode_detail(
    video_id: str,
    db: Session = Depends(get_db),
    user: User | None = Depends(get_current_user_optional),
):
    # collections must use selectinload: joinedload(subtitles) is ~20s on remote PG
    episode = (
        db.query(Episode)
        .options(
            joinedload(Episode.author),
            selectinload(Episode.tags),
            selectinload(Episode.subtitles),
            joinedload(Episode.series),
        )
        .filter(Episode.video_id == video_id, Episode.status == "published")
        .first()
    )
    if not episode:
        raise HTTPException(status_code=404, detail="Episode not found")
    if not can_access_episode(db, episode, user):
        raise HTTPException(status_code=403, detail="无权访问该内容")

    total_q = db.query(Episode).filter(
        Episode.status == "published",
        published_visibility_filter(user),
    )
    total = total_q.count()
    if not user_is_member(user):
        limit = get_episode_limit(user) or 0
        total = limit
    return episode_detail(episode, total, series_nav=series_nav_for_episode(db, episode))


@router.get("/episode/{video_id}/word-cards/")
def get_episode_word_cards(
    video_id: str,
    db: Session = Depends(get_db),
    user: User | None = Depends(get_current_user_optional),
):
    """整集词卡（带考试标签）。首次生成后写入共享缓存，后续用户直接读缓存。"""
    episode = load_episode_for_word_cards(db, video_id)
    if not episode:
        raise HTTPException(status_code=404, detail="Episode not found")
    if not can_access_episode(db, episode, user):
        raise HTTPException(status_code=403, detail="无权访问该内容")

    try:
        return get_or_build_episode_word_cards(db, episode)
    except RuntimeError as e:
        raise HTTPException(status_code=502, detail=str(e)) from e
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"词卡加载失败: {e}") from e


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
        raise HTTPException(status_code=403, detail="无权访问该内容")

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
        raise HTTPException(status_code=403, detail="无权访问该内容")

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
