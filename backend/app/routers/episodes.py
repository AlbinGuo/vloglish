from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Query
from fastapi.responses import FileResponse
from sqlalchemy import distinct, func, or_
from sqlalchemy.orm import Session, joinedload, selectinload

from ..episode_visibility import catalog_visibility_filter, published_visibility_filter
from ..database import get_db
from ..demo_access import (
    can_access_episode,
    get_episode_limit,
    user_is_member,
)
from ..deps import (
    get_current_user,
    get_current_user_optional,
    get_device_id,
    get_optional_user_from_token,
)
from ..favorites import favorite_video_ids
from ..services.author_subscribe import (
    attach_author_subscribe_fields,
    set_author_subscribed,
)
from ..services.episode_stats import learner_count_map_for_episodes
from ..services.learning import learned_episode_ids, progress_map_for_episodes
from ..media import find_episode_audio_file, find_episode_cover_file, find_episode_video_file, resolve_cover_url
from ..models import (
    Author,
    Episode,
    EpisodeFavorite,
    EpisodeSeries,
    Tag,
    User,
    UserAuthorSubscription,
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
        "published_at",
        pattern="^(index|-index|stars|-stars|created_at|-created_at|published_at|-published_at|series_index|-series_index)$",
    ),
    search: str | None = None,
    video_ids: str | None = Query(
        None,
        description="逗号分隔的 video_id，用于指定卡片；含合集内视频",
    ),
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
    if author_id is not None:
        # 作者主页：目录可见内容 + 投稿者本人可见自己的个人投稿（未转全站的私密投稿）
        q = q.filter(
            or_(catalog_visibility_filter(), Episode.submitted_by_user_id == user.id)
        )
    else:
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
    video_id_list = [v.strip() for v in (video_ids or "").split(",") if v.strip()][:20]
    if series_id is not None or (series_slug and series_slug.strip()):
        if series_id is not None:
            q = q.filter(Episode.series_id == series_id)
        else:
            q = q.join(EpisodeSeries).filter(EpisodeSeries.slug == series_slug.strip())
    elif video_id_list:
        q = q.filter(Episode.video_id.in_(video_id_list))
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

    publish_time = func.coalesce(Episode.published_at, Episode.created_at)
    order_map = {
        "index": Episode.index.desc(),
        "-index": Episode.index.asc(),
        "stars": Episode.stars.desc(),
        "-stars": Episode.stars.asc(),
        "created_at": Episode.created_at.desc(),
        "-created_at": Episode.created_at.asc(),
        "published_at": publish_time.desc(),
        "-published_at": publish_time.asc(),
        "series_index": Episode.series_index.asc().nulls_last(),
        "-series_index": Episode.series_index.desc().nulls_last(),
    }
    # 置顶最先，其次对普通用户开放，再按发布时间（空则回退创建时间）
    q = q.order_by(
        Episode.is_pinned.desc(),
        Episode.open_to_free_users.desc(),
        order_map.get(ordering, publish_time.desc()),
    )

    # 普通用户也返回完整目录；不可播放项与 can_access_episode 对齐，标记 requires_membership
    start = offset if offset is not None else (page - 1) * page_size
    total = q.count()
    items = q.offset(start).limit(page_size).all()
    prog_map = progress_map_for_episodes(db, user.id, [ep.id for ep in items]) if user else {}
    learner_map = learner_count_map_for_episodes(db, [ep.id for ep in items])

    def _requires_membership(ep: Episode) -> bool:
        return not can_access_episode(db, ep, user)

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

    # 顶栏「视频」数量：独立视频 + 合集内视频（全站已发布总量）
    videos = (
        db.query(Episode)
        .filter(Episode.status == "published")
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
    """合集列表：登录用户可见；点进合集可看目录，未开放剧集再引导开通。"""
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
                "requires_membership": not any(can_access_episode(db, ep, user) for ep in episodes),
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

    fav_ids = favorite_video_ids(db, device_id, user.id)
    prog_map = progress_map_for_episodes(db, user.id, [ep.id for ep in episodes])
    learner_map = learner_count_map_for_episodes(db, [ep.id for ep in episodes])

    series_cover = series.cover or next((ep.cover for ep in episodes if ep.cover), "")
    return {
        "id": series.id,
        "slug": series.slug,
        "title": series.title,
        "summary": series.summary or "",
        "cover": resolve_cover_url(series_cover),
        "episode_count": len(episodes),
        "episodes": [
            episode_summary(
                ep,
                is_favorite=ep.video_id in fav_ids if user_is_member(user) else False,
                is_learned=prog_map.get(ep.id).is_completed if prog_map.get(ep.id) else False,
                progress_percent=prog_map.get(ep.id).completion_percent if prog_map.get(ep.id) else 0,
                learner_count=learner_map.get(ep.id, 0),
                requires_membership=not can_access_episode(db, ep, user),
            )
            for ep in episodes
        ],
    }


def _prewarm_bilibili_video(payload: dict) -> None:
    """打开详情时后台预热 B 站直链，缩短点击播放的等待（best-effort，失败不影响响应）。"""
    try:
        media = (payload.get("episode") or {}).get("media") or {}
        video_url = str(media.get("video_url") or "")
    except Exception:  # noqa: BLE001
        return
    if "/api/bilibili/stream/" not in video_url:
        return
    bvid = video_url.rsplit("/", 1)[-1].split("?")[0]
    if not bvid:
        return

    def _run() -> None:
        try:
            from ..services.bilibili_meta import resolve_durl

            resolve_durl(bvid, 1)
        except Exception:  # noqa: BLE001
            pass

    import threading

    threading.Thread(target=_run, daemon=True).start()


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
            selectinload(Episode.audience_notes),
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
    is_favorite = False
    if user and user_is_member(user):
        is_favorite = (
            db.query(UserEpisodeFavorite.user_id)
            .filter(
                UserEpisodeFavorite.user_id == user.id,
                UserEpisodeFavorite.episode_id == episode.id,
            )
            .first()
            is not None
        )
    payload = episode_detail(
        episode,
        total,
        series_nav=series_nav_for_episode(db, episode),
        is_favorite=is_favorite,
    )
    payload["episode"]["author"] = attach_author_subscribe_fields(
        db,
        payload["episode"]["author"],
        episode.author_id,
        user.id if user else None,
    )
    payload["episode"]["is_owner"] = bool(
        user is not None and episode.submitted_by_user_id == user.id
    )
    if (episode.video_url or "").startswith(("/api/episode/", "/api/bilibili/")):
        # 本地/代理兜底的视频：打开时后台补转七牛，完成后播放自动切到 CDN
        from ..services.episode_transfer import schedule_qiniu_backfill

        schedule_qiniu_backfill(episode.video_id)
    _prewarm_bilibili_video(payload)
    return payload


@router.post("/episode/{video_id}/subtitles/{subtitle_id}/literal/")
def generate_subtitle_literal(
    video_id: str,
    subtitle_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """为当前句生成对照直译，并合并本集专名。结果写入字幕，后续用户共用。"""
    episode = (
        db.query(Episode)
        .options(selectinload(Episode.subtitles))
        .filter(Episode.video_id == video_id, Episode.status == "published")
        .first()
    )
    if not episode:
        raise HTTPException(status_code=404, detail="Episode not found")
    if not can_access_episode(db, episode, user):
        raise HTTPException(status_code=403, detail="无权访问该内容")

    sub = next((s for s in episode.subtitles if s.id == subtitle_id), None)
    if not sub:
        raise HTTPException(status_code=404, detail="字幕不存在")

    existing = (getattr(sub, "chinese_literal", None) or "").strip()
    from ..services.episode_glossary import glossary_hits, merge_episode_glossary, parse_glossary

    glossary = parse_glossary(getattr(episode, "glossary_json", None))
    if existing:
        return {
            "chinese_literal": existing,
            "glossary": glossary,
            "hits": glossary_hits(sub.english or "", glossary),
        }

    from ..dict.deepseek import translate_literal_chinese_with_deepseek

    try:
        result = translate_literal_chinese_with_deepseek(
            sub.english or "",
            sense_chinese=sub.chinese or "",
            glossary=glossary,
        )
    except Exception as exc:
        raise HTTPException(status_code=502, detail="直译生成失败，请稍后重试") from exc

    literal = str(result.get("chinese_literal") or "").strip()
    if not literal:
        raise HTTPException(status_code=502, detail="直译生成为空")
    sub.chinese_literal = literal
    glossary = merge_episode_glossary(episode, result.get("glossary_hits") or [])
    db.commit()
    db.refresh(sub)
    return {
        "chinese_literal": literal,
        "glossary": glossary,
        "hits": glossary_hits(sub.english or "", glossary),
    }


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
    token: str | None = Query(default=None),
    db: Session = Depends(get_db),
    user: User | None = Depends(get_current_user_optional),
):
    episode = db.query(Episode).filter(Episode.video_id == video_id, Episode.status == "published").first()
    if not episode:
        raise HTTPException(status_code=404, detail="Episode not found")
    # <audio>/<video> 标签无法带 Authorization 头，允许用 ?token= 鉴权
    if user is None and token:
        user = get_optional_user_from_token(db, token)
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
    token: str | None = Query(default=None),
    db: Session = Depends(get_db),
    user: User | None = Depends(get_current_user_optional),
):
    episode = db.query(Episode).filter(Episode.video_id == video_id, Episode.status == "published").first()
    if not episode:
        raise HTTPException(status_code=404, detail="Episode not found")
    # <video> 标签无法带 Authorization 头，允许用 ?token= 鉴权
    if user is None and token:
        user = get_optional_user_from_token(db, token)
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


@router.get("/episode/{video_id}/hls/index.m3u8")
def get_episode_hls(
    video_id: str,
    token: str | None = Query(default=None),
    db: Session = Depends(get_db),
    user: User | None = Depends(get_current_user_optional),
):
    """B 站视频 HLS 边转边播：返回当前可用的 m3u8（分片地址带 token）。"""
    episode = db.query(Episode).filter(Episode.video_id == video_id, Episode.status == "published").first()
    if not episode:
        raise HTTPException(status_code=404, detail="Episode not found")
    if user is None and token:
        user = get_optional_user_from_token(db, token)
    if not can_access_episode(db, episode, user):
        raise HTTPException(status_code=403, detail="无权访问该内容")

    from urllib.parse import quote

    from fastapi.responses import PlainTextResponse

    from ..media import find_episode_video_file
    from ..services.episode_hls import (
        build_qiniu_m3u8,
        ensure_hls,
        m3u8_path,
        wait_first_segment,
    )

    local = find_episode_video_file(video_id)
    ensure_hls(video_id, episode.video_url or "", local[0] if local else None)
    qiniu_m3u8 = build_qiniu_m3u8(video_id)
    if qiniu_m3u8:
        return PlainTextResponse(qiniu_m3u8, media_type="application/vnd.apple.mpegurl")
    wait_first_segment(video_id, timeout=6)

    m3u8 = m3u8_path(video_id)
    text = m3u8.read_text("utf-8", "ignore") if m3u8.is_file() else ""
    if not [ln for ln in text.splitlines() if ln.strip().endswith(".ts")]:
        # 首片还没切出来：返回占位 EVENT 播放列表，让播放器先拿到清单、稍后 reload 拿分片，
        # 避免“点开”在服务端阻塞几十秒。
        placeholder = (
            "#EXTM3U\n#EXT-X-VERSION:3\n#EXT-X-TARGETDURATION:6\n"
            "#EXT-X-MEDIA-SEQUENCE:0\n#EXT-X-PLAYLIST-TYPE:EVENT\n"
        )
        return PlainTextResponse(placeholder, media_type="application/vnd.apple.mpegurl")
    token_q = f"?token={quote(token)}" if token else ""
    out_lines: list[str] = []
    for line in text.splitlines():
        seg = line.strip()
        if seg.endswith(".ts"):
            out_lines.append(f"/api/episode/{video_id}/hls/{seg}{token_q}")
        else:
            out_lines.append(line)
    body = "\n".join(out_lines) + "\n"
    if "#EXT-X-ENDLIST" not in body and "#EXT-X-PLAYLIST-TYPE" not in body:
        body = body.replace("#EXTM3U", "#EXTM3U\n#EXT-X-PLAYLIST-TYPE:EVENT", 1)
    return PlainTextResponse(body, media_type="application/vnd.apple.mpegurl")


@router.get("/episode/{video_id}/hls/{name}")
def get_episode_hls_segment(
    video_id: str,
    name: str,
    token: str | None = Query(default=None),
    db: Session = Depends(get_db),
    user: User | None = Depends(get_current_user_optional),
):
    episode = db.query(Episode).filter(Episode.video_id == video_id, Episode.status == "published").first()
    if not episode:
        raise HTTPException(status_code=404, detail="Episode not found")
    if user is None and token:
        user = get_optional_user_from_token(db, token)
    if not can_access_episode(db, episode, user):
        raise HTTPException(status_code=403, detail="无权访问该内容")

    from ..services.episode_hls import segment_path

    path = segment_path(video_id, name)
    if not path:
        raise HTTPException(status_code=404, detail="Segment not found")
    return FileResponse(path, media_type="video/mp2t")


@router.get("/episode/{video_id}/cover/")
def get_episode_cover(
    video_id: str,
    db: Session = Depends(get_db),
):
    """本地封面（B 站导入用缩略图、本地视频用首帧）。封面非敏感内容，公开可取。"""
    episode = db.query(Episode).filter(Episode.video_id == video_id, Episode.status == "published").first()
    if not episode:
        raise HTTPException(status_code=404, detail="Episode not found")
    found = find_episode_cover_file(video_id)
    if found:
        cover_path, media_type = found
        return FileResponse(cover_path, media_type=media_type)
    raise HTTPException(status_code=404, detail="Cover not found")


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

    q = q.order_by(
        Episode.is_pinned.desc(),
        Episode.open_to_free_users.desc(),
        func.coalesce(Episode.published_at, Episode.created_at).desc(),
    )
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
                "avatar": resolve_cover_url(author.avatar_url or ""),
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
        .filter(
            or_(
                catalog_visibility_filter(),
                Episode.submitted_by_user_id == (user.id if user else -1),
            )
        )
        .order_by(
            Episode.is_pinned.desc(),
            Episode.open_to_free_users.desc(),
            func.coalesce(Episode.published_at, Episode.created_at).desc(),
        )
    )
    episodes = q.all()
    covers = [ep.cover for ep in episodes if ep.cover][:3]

    return attach_author_subscribe_fields(
        db,
        {
            "id": author.id,
            "name": author.name,
            "gender": author.gender,
            "nationality": author.nationality or "",
            "accent": author.accent or "",
            "avatar": resolve_cover_url(author.avatar_url or ""),
            "episode_count": len(episodes),
            "covers": covers,
        },
        author.id,
        user.id if user else None,
    )


@router.post("/authors/{author_id}/subscribe/")
def subscribe_author(
    author_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    try:
        return set_author_subscribed(db, user.id, author_id, True)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e)) from e


@router.delete("/authors/{author_id}/subscribe/")
def unsubscribe_author(
    author_id: int,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    try:
        return set_author_subscribed(db, user.id, author_id, False)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e)) from e


@router.get("/me/author-subscriptions/")
def my_author_subscriptions(
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    """我的关注：关注的作者列表，附未观看作品数（按作者主页可见的独立单集统计）。"""
    sub_rows = (
        db.query(UserAuthorSubscription.author_id, UserAuthorSubscription.created_at)
        .filter(UserAuthorSubscription.user_id == user.id)
        .order_by(UserAuthorSubscription.created_at.desc())
        .all()
    )
    if not sub_rows:
        return {"count": 0, "results": []}

    author_ids = [row[0] for row in sub_rows]
    authors = db.query(Author).filter(Author.id.in_(author_ids)).all()
    by_id = {a.id: a for a in authors}

    total_rows = (
        db.query(Episode.author_id, func.count(Episode.id))
        .filter(
            Episode.author_id.in_(author_ids),
            Episode.status == "published",
            Episode.series_id.is_(None),
        )
        .filter(published_visibility_filter(user))
        .group_by(Episode.author_id)
        .all()
    )
    totals = {aid: int(cnt) for aid, cnt in total_rows}

    opened_rows = (
        db.query(Episode.author_id, func.count(distinct(UserEpisodeProgress.episode_id)))
        .join(Episode, Episode.id == UserEpisodeProgress.episode_id)
        .filter(
            UserEpisodeProgress.user_id == user.id,
            Episode.author_id.in_(author_ids),
            Episode.status == "published",
            Episode.series_id.is_(None),
        )
        .filter(published_visibility_filter(user))
        .group_by(Episode.author_id)
        .all()
    )
    opened = {aid: int(cnt) for aid, cnt in opened_rows}

    results = []
    for author_id, _created_at in sub_rows:
        author = by_id.get(author_id)
        if not author:
            continue
        total = totals.get(author_id, 0)
        seen = opened.get(author_id, 0)
        results.append(
            {
                "id": author.id,
                "name": author.name,
                "gender": author.gender,
                "nationality": author.nationality or "",
                "accent": author.accent or "",
                "avatar": resolve_cover_url(author.avatar_url or ""),
                "episode_count": total,
                "unwatched_count": max(0, total - seen),
                "is_subscribed": True,
            }
        )
    return {"count": len(results), "results": results}
