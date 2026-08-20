from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Query
from fastapi.responses import FileResponse
from sqlalchemy import func, or_
from sqlalchemy.orm import Session, joinedload, selectinload

from ..episode_visibility import published_visibility_filter
from ..database import get_db
from ..demo_access import (
    can_access_episode,
    can_access_series_content,
    get_episode_limit,
    get_visible_episode_ids,
    user_is_member,
)
from ..deps import get_current_user, get_current_user_optional, get_device_id
from ..favorites import favorite_video_ids
from ..services.episode_stats import learner_count_map_for_episodes
from ..services.learning import learned_episode_ids, progress_map_for_episodes
from ..media import find_episode_audio_file, find_episode_video_file, resolve_cover_url
from ..models import (
    Author,
    Episode,
    EpisodeFavorite,
    EpisodeSeries,
    Tag,
    User,
    UserEpisodeFavorite,
    UserEpisodeProgress,
    episode_tags,
)
from ..serializers import episode_detail, episode_summary
from ..services.episode_series import list_series_episodes, series_nav_for_episode
from ..services.episode_word_cards import (
    get_or_build_episode_word_cards,
    load_cached_episode_word_cards,
    load_episode_for_word_cards,
)

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
    author_id: int | None = None,
    date: str | None = None,
    duration: str | None = Query(None, pattern="^(lt3|lt8|gt8)$"),
    status: str | None = Query(None, pattern="^(all|learned|unlearned|favorite)$"),
    ordering: str = Query(
        "created_at",
        pattern="^(index|-index|stars|-stars|created_at|-created_at|series_index|-series_index)$",
    ),
    search: str | None = None,
    db: Session = Depends(get_db),
    device_id: str = Depends(get_device_id),
    user: User = Depends(get_current_user),
):
    """视频目录：须登录；普通用户返回完整列表，会员专属项标记 requires_membership。"""
    user_id = user.id
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
    # clip_length 单位：秒；lt8 = 大于3分钟且小于8分钟
    if duration == "lt3":
        q = q.filter(Episode.clip_length < 180)
    elif duration == "lt8":
        q = q.filter(Episode.clip_length > 180, Episode.clip_length < 480)
    elif duration == "gt8":
        q = q.filter(Episode.clip_length > 480)
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
    if author_id is not None:
        q = q.filter(Episode.author_id == author_id)
    if series_id is not None or (series_slug and series_slug.strip()):
        if not can_access_series_content(db, user):
            raise HTTPException(status_code=403, detail="需要开通会员才能查看合集内容")
        if series_id is not None:
            q = q.filter(Episode.series_id == series_id)
        else:
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

    # 普通用户也返回完整目录；不可播放项与 can_access_episode 对齐，标记 requires_membership
    free_ids = None if get_episode_limit(db, user) is None else get_visible_episode_ids(db, user)
    start = offset if offset is not None else (page - 1) * page_size
    total = q.count()
    items = q.offset(start).limit(page_size).all()
    prog_map = progress_map_for_episodes(db, user.id, [ep.id for ep in items]) if user else {}
    learner_map = learner_count_map_for_episodes(db, [ep.id for ep in items])

    def _requires_membership(ep: Episode) -> bool:
        if free_ids is None:
            return False
        if (
            ep.submitted_by_user_id is not None
            and user is not None
            and ep.submitted_by_user_id == user.id
        ):
            return False
        return ep.id not in free_ids

    return {
        "count": total,
        "results": [
            episode_summary(
                ep,
                is_favorite=ep.video_id in fav_ids if user_is_member(user) else False,
                is_learned=prog_map.get(ep.id).is_completed if prog_map.get(ep.id) else False,
                progress_percent=prog_map.get(ep.id).completion_percent if prog_map.get(ep.id) else 0,
                learner_count=learner_map.get(ep.id, 0),
                requires_membership=_requires_membership(ep),
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
    """用户端顶栏：视频 / 合集 / 文章阅读 可见数量。"""
    from ..models import Article

    # 顶栏数量展示全站可见总量（不受普通用户列表限额影响）
    videos = (
        db.query(Episode)
        .filter(Episode.status == "published")
        .filter(Episode.series_id.is_(None))
        .filter(published_visibility_filter(user))
        .count()
    )

    # 合集入口对普通用户可见，数量按已发布合集统计（不因内容需会员而显示为 0）
    series_rows = (
        db.query(EpisodeSeries)
        .filter(EpisodeSeries.status == "published")
        .order_by(EpisodeSeries.sort_order.asc(), EpisodeSeries.id.desc())
        .all()
    )
    series_count = 0
    for series in series_rows:
        episodes = list_series_episodes(db, series.id, published_only=True)
        if episodes:
            series_count += 1

    articles = db.query(Article).filter(Article.status == "published").count()

    return {"videos": videos, "series": series_count, "articles": articles}


@router.get("/english/nav-new/")
def english_nav_new(
    db: Session = Depends(get_db),
    user: User | None = Depends(get_current_user_optional),
):
    """合集 / 文章是否有 2 天内上新内容（与是否点进列表无关，持续显示）。"""
    from ..models import Article
    from ..services.content_new import content_is_new, latest_dt

    _ = user
    series_new = 0
    series_rows = (
        db.query(EpisodeSeries)
        .filter(EpisodeSeries.status == "published")
        .all()
    )
    for series in series_rows:
        episodes = list_series_episodes(db, series.id, published_only=True)
        if not episodes:
            continue
        ep_times = [(ep.published_at or ep.created_at) for ep in episodes]
        latest = latest_dt(series.published_at, series.created_at, *ep_times)
        if content_is_new(latest):
            series_new += 1

    articles_new = 0
    for article in db.query(Article).filter(Article.status == "published").all():
        if content_is_new(article.published_at):
            articles_new += 1

    return {
        "series": series_new,
        "articles": articles_new,
        "has_series_new": series_new > 0,
        "has_articles_new": articles_new > 0,
    }


@router.get("/series/")
def series_list(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """合集列表：登录用户可见；内容仍须会员才能进入详情。"""
    from ..services.content_new import content_is_new, fmt_dt, latest_dt

    _ = user
    rows = (
        db.query(EpisodeSeries)
        .filter(EpisodeSeries.status == "published")
        .order_by(EpisodeSeries.sort_order.asc(), EpisodeSeries.id.desc())
        .all()
    )
    results = []
    for series in rows:
        episodes = list_series_episodes(db, series.id, published_only=True)
        if not episodes:
            continue
        covers = [resolve_cover_url(ep.cover) for ep in episodes if ep.cover][:3]
        if not covers and series.cover:
            covers = [resolve_cover_url(series.cover)]
        ep_times = [(ep.published_at or ep.created_at) for ep in episodes]
        latest = latest_dt(series.published_at, series.created_at, *ep_times)
        results.append(
            {
                "id": series.id,
                "slug": series.slug,
                "title": series.title,
                "summary": series.summary or "",
                "cover": covers[0] if covers else resolve_cover_url(series.cover or ""),
                "covers": covers,
                "episode_count": len(episodes),
                "sort_order": series.sort_order or 0,
                "requires_membership": not can_access_series_content(db, user),
                "published_at": fmt_dt(series.published_at or series.created_at),
                "latest_content_at": fmt_dt(latest),
                "is_new": content_is_new(latest),
            }
        )
    return {"count": len(results), "results": results}


@router.get("/series/{slug}/")
def series_detail(
    slug: str,
    db: Session = Depends(get_db),
    device_id: str = Depends(get_device_id),
    user: User = Depends(get_current_user),
):
    series = (
        db.query(EpisodeSeries)
        .filter(EpisodeSeries.slug == slug, EpisodeSeries.status == "published")
        .first()
    )
    if not series:
        raise HTTPException(status_code=404, detail="合集不存在")

    episodes = list_series_episodes(db, series.id, published_only=True)
    if not can_access_series_content(db, user):
        raise HTTPException(status_code=403, detail="需要开通会员才能查看合集内容")

    # 列表按上传/发布时间倒序；上一集/下一集导航仍按 series_index（list_series_episodes）
    episodes_by_time = sorted(
        episodes,
        key=lambda ep: ep.published_at or ep.created_at or datetime.min,
        reverse=True,
    )

    fav_ids = favorite_video_ids(db, device_id, user.id)
    prog_map = progress_map_for_episodes(db, user.id, [ep.id for ep in episodes_by_time])
    learner_map = learner_count_map_for_episodes(db, [ep.id for ep in episodes_by_time])

    series_cover = series.cover or (episodes_by_time[0].cover if episodes_by_time else "")
    return {
        "id": series.id,
        "slug": series.slug,
        "title": series.title,
        "summary": series.summary or "",
        "cover": resolve_cover_url(series_cover),
        "episode_count": len(episodes_by_time),
        "episodes": [
            episode_summary(
                ep,
                is_favorite=ep.video_id in fav_ids if user_is_member(user) else False,
                is_learned=prog_map.get(ep.id).is_completed if prog_map.get(ep.id) else False,
                progress_percent=prog_map.get(ep.id).completion_percent if prog_map.get(ep.id) else 0,
                learner_count=learner_map.get(ep.id, 0),
            )
            for ep in episodes_by_time
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
        if episode.series_id is not None and user is not None and not user_is_member(user):
            raise HTTPException(status_code=403, detail="需要开通会员才能查看合集内容")
        if user is None:
            raise HTTPException(status_code=401, detail="请先登录")
        raise HTTPException(status_code=403, detail="无权访问该内容，请开通会员查看更多视频")

    total_q = db.query(Episode).filter(
        Episode.status == "published",
        published_visibility_filter(user),
    )
    total = total_q.count()
    ep_limit = get_episode_limit(db, user)
    if ep_limit is not None:
        total = ep_limit
    return episode_detail(episode, total, series_nav=series_nav_for_episode(db, episode))


@router.get("/episode/{video_id}/word-cards/")
def get_episode_word_cards(
    video_id: str,
    cache_only: bool = Query(False),
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
        if cache_only:
            cached = load_cached_episode_word_cards(db, episode)
            if cached:
                return cached
            return {
                "video_id": episode.video_id,
                "from_cache": False,
                "count": 0,
                "cards": [],
            }
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
def episode_tags_list(
    sort: str = Query("name", pattern="^(name|popular)$"),
    limit: int | None = Query(None, ge=1, le=500),
    db: Session = Depends(get_db),
):
    """标签列表。sort=popular 时按标签下已发布视频的学习人数（去重用户）降序；limit 为空则返回全部。"""
    if sort == "popular":
        visit_subq = (
            db.query(
                episode_tags.c.tag_id.label("tag_id"),
                func.count(func.distinct(UserEpisodeProgress.user_id)).label("visit_count"),
            )
            .join(Episode, Episode.id == episode_tags.c.episode_id)
            .outerjoin(
                UserEpisodeProgress,
                UserEpisodeProgress.episode_id == Episode.id,
            )
            .filter(Episode.status == "published")
            .group_by(episode_tags.c.tag_id)
            .subquery()
        )
        rows = (
            db.query(Tag, func.coalesce(visit_subq.c.visit_count, 0).label("visit_count"))
            .outerjoin(visit_subq, Tag.id == visit_subq.c.tag_id)
            .order_by(func.coalesce(visit_subq.c.visit_count, 0).desc(), Tag.name.asc())
        )
        if limit is not None:
            rows = rows.limit(limit)
        return [
            {"id": tag.id, "name": tag.name, "visit_count": int(visit_count or 0)}
            for tag, visit_count in rows.all()
        ]

    q = db.query(Tag).order_by(Tag.name)
    if limit is not None:
        q = q.limit(limit)
    return [{"id": t.id, "name": t.name} for t in q.all()]


@router.get("/author-accents/")
def author_accents(db: Session = Depends(get_db)):
    from sqlalchemy import distinct

    rows = db.query(distinct(Author.accent)).filter(Author.accent != "").all()
    return [{"accent": r[0]} for r in rows if r[0]]


@router.get("/authors/")
def authors_catalog(
    accents: str | None = None,
    gender: str | None = None,
    stars: int | None = None,
    tags: str | None = None,
    date: str | None = None,
    duration: str | None = Query(None, pattern="^(lt3|lt8|gt8)$"),
    status: str | None = Query(None, pattern="^(all|learned|unlearned|favorite)$"),
    search: str | None = None,
    db: Session = Depends(get_db),
    device_id: str = Depends(get_device_id),
    user: User | None = Depends(get_current_user_optional),
):
    """首页「按作者分类」：有可见独立单集的作者，附封面叠卡与数量。"""
    user_id = user.id if user else None
    fav_ids = favorite_video_ids(db, device_id, user_id)
    q = db.query(Episode).options(joinedload(Episode.author), joinedload(Episode.tags))
    q = q.filter(Episode.status == "published")
    q = q.filter(published_visibility_filter(user))
    q = q.filter(Episode.series_id.is_(None))

    author_joined = False

    def ensure_author_join():
        nonlocal q, author_joined
        if not author_joined:
            q = q.join(Author)
            author_joined = True

    if stars is not None:
        q = q.filter(Episode.stars == stars)
    accent_values = [a.strip() for a in (accents or "").split(",") if a.strip()]
    if accent_values:
        ensure_author_join()
        q = q.filter(Author.accent.in_(accent_values))
    if duration == "lt3":
        q = q.filter(Episode.clip_length < 180)
    elif duration == "lt8":
        q = q.filter(Episode.clip_length > 180, Episode.clip_length < 480)
    elif duration == "gt8":
        q = q.filter(Episode.clip_length > 480)
    if gender:
        ensure_author_join()
        q = q.filter(Author.gender == gender)
    if search and search.strip():
        ensure_author_join()
        term = f"%{search.strip()}%"
        q = q.filter(or_(Episode.short_title.ilike(term), Author.name.ilike(term)))
    tag_ids = [int(t) for t in (tags or "").split(",") if t.strip().isdigit()]
    for tag_id in tag_ids:
        q = q.filter(Episode.tags.any(Tag.id == tag_id))
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
            q = q.filter(Episode.id.in_(learned_ids) if learned_ids else Episode.id < 0)
    elif status == "unlearned":
        if not user:
            q = q.filter(Episode.id < 0)
        else:
            learned_ids = learned_episode_ids(db, user.id)
            if learned_ids:
                q = q.filter(~Episode.id.in_(learned_ids))
    elif status == "favorite":
        q = q.filter(Episode.video_id.in_(fav_ids) if fav_ids else Episode.id < 0)

    q = q.order_by(Episode.is_pinned.desc(), Episode.created_at.desc())
    episodes = q.all()

    grouped: dict[int, dict] = {}
    order: list[int] = []
    for ep in episodes:
        author = ep.author
        if author.id not in grouped:
            grouped[author.id] = {
                "id": author.id,
                "name": author.name,
                "gender": author.gender,
                "nationality": author.nationality or "",
                "accent": author.accent or "",
                "episode_count": 0,
                "covers": [],
            }
            order.append(author.id)
        row = grouped[author.id]
        row["episode_count"] += 1
        if len(row["covers"]) < 3 and ep.cover:
            row["covers"].append(ep.cover)

    results = [grouped[aid] for aid in order]
    results.sort(key=lambda r: (-r["episode_count"], r["name"].lower()))
    return {"count": len(results), "results": results}


@router.get("/authors/{author_id}/")
def author_detail(
    author_id: int,
    db: Session = Depends(get_db),
    user: User | None = Depends(get_current_user_optional),
):
    author = db.query(Author).filter(Author.id == author_id).first()
    if not author:
        raise HTTPException(status_code=404, detail="作者不存在")

    q = (
        db.query(Episode)
        .filter(
            Episode.author_id == author_id,
            Episode.status == "published",
            Episode.series_id.is_(None),
        )
        .filter(published_visibility_filter(user))
        .order_by(Episode.is_pinned.desc(), Episode.created_at.desc())
    )
    episodes = q.all()
    covers = [ep.cover for ep in episodes if ep.cover][:3]

    return {
        "id": author.id,
        "name": author.name,
        "gender": author.gender,
        "nationality": author.nationality or "",
        "accent": author.accent or "",
        "episode_count": len(episodes),
        "covers": covers,
    }
