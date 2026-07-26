from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session, joinedload, selectinload

from ...database import get_db
from ...deps import get_current_admin
from ...models import Episode, User
from ...schemas import (
    AdminEpisodeCreateIn,
    AdminEpisodeDetailOut,
    AdminEpisodeListItemOut,
    AdminEpisodeListOut,
    AdminFetchMediaIn,
    AdminFetchMediaOut,
    AdminNextEpisodeIndexOut,
    AdminEpisodeUpdateIn,
    AdminSubtitleIn,
    AdminVttImportIn,
    AdminVttImportOut,
)
from ...serializers import episode_detail
from ...services.episode_admin import (
    apply_episode_fields,
    delete_episode_with_dependencies,
    generate_video_id,
    get_or_create_author,
    next_episode_index,
    replace_subtitles,
    resolve_tags,
)
from ...services.episode_stats import admin_episode_list_query, row_stats_from_query
from ...services.subtitle_import_admin import import_subtitle_text_for_admin
from ...services.user_notifications import maybe_notify_submitter_on_status_change
from ...services.yt_dlp_fetch import fetch_and_upload_from_url
from ...services.episode_series import get_series_or_none

router = APIRouter(prefix="/api/admin", tags=["admin-meta"])


def _fmt_dt(value: datetime | None) -> str:
    if not value:
        return ""
    return value.strftime("%Y-%m-%d %H:%M:%S")


def _subtitle_out(s) -> AdminSubtitleIn:
    return AdminSubtitleIn(
        index=s.index,
        start=s.start,
        end=s.end,
        english=s.english,
        chinese=s.chinese or "",
        ipa=s.ipa or "",
        english_html=s.english_html or "",
    )


def _episode_detail(ep: Episode, submitter: User | None = None) -> AdminEpisodeDetailOut:
    series = ep.series
    return AdminEpisodeDetailOut(
        id=ep.id,
        video_id=ep.video_id,
        index=ep.index,
        short_title=ep.short_title,
        summary=ep.summary or "",
        remark=ep.remark or "",
        vocab_summary=getattr(ep, "vocab_summary", None) or "",
        stars=ep.stars,
        voca_size=ep.voca_size,
        subtitle_count=ep.subtitle_count,
        clip_length=ep.clip_length,
        cover=ep.cover or "",
        video_url=ep.video_url or "",
        audio_url=ep.audio_url or "",
        thumbnail_url=ep.thumbnail_url or "",
        original_video_url=ep.original_video_url or "",
        is_demo=ep.is_demo,
        is_pinned=bool(getattr(ep, "is_pinned", False)),
        status=ep.status,
        rejection_reason=ep.rejection_reason or "",
        is_user_submitted=ep.submitted_by_user_id is not None,
        is_catalog_public=bool(getattr(ep, "is_catalog_public", False)),
        submitted_by_user_id=ep.submitted_by_user_id,
        submitted_by_email=(submitter.email if submitter else ""),
        submitted_by_nickname=((submitter.nickname or "") if submitter else ""),
        series_id=ep.series_id,
        series_index=ep.series_index,
        series_title=series.title if series else "",
        author={
            "name": ep.author.name,
            "gender": ep.author.gender,
            "nationality": ep.author.nationality,
            "accent": ep.author.accent,
        },
        tag_names=[t.name for t in ep.tags],
        subtitles=[_subtitle_out(s) for s in sorted(ep.subtitles, key=lambda x: x.index)],
        created_at=_fmt_dt(ep.created_at),
    )


def _get_submitter(db: Session, user_id: int | None) -> User | None:
    if not user_id:
        return None
    return db.query(User).filter(User.id == user_id).first()


def _get_episode_or_404(db: Session, episode_id: int) -> Episode:
    # collections must use selectinload: joinedload(subtitles) is ~20s on remote PG
    ep = (
        db.query(Episode)
        .options(
            joinedload(Episode.author),
            selectinload(Episode.tags),
            selectinload(Episode.subtitles),
            joinedload(Episode.series),
        )
        .filter(Episode.id == episode_id)
        .first()
    )
    if not ep:
        raise HTTPException(status_code=404, detail="剧集不存在")
    return ep


@router.get("/episodes/", response_model=AdminEpisodeListOut)
def list_episodes(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    search: str | None = None,
    status: str | None = Query(None, pattern="^(draft|published|archived|rejected)$"),
    stars: int | None = Query(None, ge=1, le=5),
    series_id: int | None = Query(
        None,
        description="合集 ID；传 0 表示仅独立单集（无合集）",
    ),
    user_submitted: bool | None = Query(
        None,
        description="true=仅用户投稿；false=仅官方内容；不传=全部",
    ),
    sort_by: str = Query("index"),
    sort_dir: str = Query("desc", pattern="^(asc|desc)$"),
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    q = admin_episode_list_query(
        db,
        search=search,
        status=status,
        stars=stars,
        series_id=series_id,
        user_submitted=user_submitted,
        sort_by=sort_by,
        sort_dir=sort_dir,
    )
    total = q.count()
    rows = q.offset((page - 1) * page_size).limit(page_size).all()
    results = []
    for row in rows:
        ep = row[0]
        results.append(
            AdminEpisodeListItemOut(
                id=ep.id,
                index=ep.index,
                video_id=ep.video_id,
                short_title=ep.short_title,
                stars=ep.stars,
                status=ep.status,
                subtitle_count=ep.subtitle_count,
                clip_length=ep.clip_length,
                author_name=ep.author.name,
                cover=ep.thumbnail_url or ep.cover or "",
                is_demo=ep.is_demo,
                is_pinned=bool(getattr(ep, "is_pinned", False)),
                is_user_submitted=ep.submitted_by_user_id is not None,
                is_catalog_public=bool(getattr(ep, "is_catalog_public", False)),
                tag_names=[t.name for t in ep.tags],
                series_id=ep.series_id,
                series_title=ep.series.title if ep.series else "",
                series_index=ep.series_index,
                created_at=_fmt_dt(ep.created_at),
                **row_stats_from_query(row),
            )
        )
    return AdminEpisodeListOut(count=total, results=results)


@router.get("/episodes/next-index/", response_model=AdminNextEpisodeIndexOut)
def get_next_episode_index(
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    return AdminNextEpisodeIndexOut(next_index=next_episode_index(db))


@router.post("/episodes/import-vtt/", response_model=AdminVttImportOut)
@router.post("/episodes/import-subtitles/", response_model=AdminVttImportOut)
def import_subtitles(
    body: AdminVttImportIn,
    _admin: User = Depends(get_current_admin),
):
    return import_subtitle_text_for_admin(
        body.vtt_text,
        title=body.title or "",
        summary=body.summary or "",
        translate_chinese=body.translate_chinese,
    )


@router.post("/episodes/fetch-media/", response_model=AdminFetchMediaOut)
def fetch_media(
    body: AdminFetchMediaIn,
    _admin: User = Depends(get_current_admin),
):
    try:
        result = fetch_and_upload_from_url(
            body.url,
            slug=body.slug,
            enrich_subtitles=body.enrich_subtitles,
        )
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=502, detail=str(exc) or "抓取失败") from exc

    try:
        subtitles = [AdminSubtitleIn(**row) for row in result["subtitles"]]
        return AdminFetchMediaOut(
            title=result["title"],
            summary=result.get("summary", ""),
            author_name=result.get("author_name", ""),
            original_video_url=result["original_video_url"],
            cover=result["cover"],
            thumbnail_url=result["thumbnail_url"],
            video_url=result["video_url"],
            audio_url=result["audio_url"],
            subtitles=subtitles,
            subtitle_count=result["subtitle_count"],
            clip_length=result["clip_length"],
            had_chinese=result["had_chinese"],
            translated_count=result["translated_count"],
            ipa_count=result["ipa_count"],
            stars=result.get("stars", 3),
            voca_size=result.get("voca_size", 0),
            highlight_count=result.get("highlight_count", 0),
            source_id=result.get("source_id", ""),
            warnings=result.get("warnings", []),
        )
    except Exception as exc:
        raise HTTPException(
            status_code=502,
            detail=f"抓取结果组装失败：{exc}",
        ) from exc


@router.get("/episodes/preview/{video_id}/")
def preview_episode(
    video_id: str,
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    episode = (
        db.query(Episode)
        .options(
            joinedload(Episode.author),
            selectinload(Episode.tags),
            selectinload(Episode.subtitles),
            joinedload(Episode.series),
        )
        .filter(Episode.video_id == video_id)
        .first()
    )
    if not episode:
        raise HTTPException(status_code=404, detail="剧集不存在")
    total = db.query(Episode).filter(Episode.status == "published").count()
    from ...services.episode_series import series_nav_for_episode

    return episode_detail(episode, total, series_nav=series_nav_for_episode(db, episode))


@router.post("/episodes/", response_model=AdminEpisodeDetailOut)
def create_episode(
    body: AdminEpisodeCreateIn,
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    video_id = (body.video_id or generate_video_id()).strip()
    if db.query(Episode).filter(Episode.video_id == video_id).first():
        raise HTTPException(status_code=400, detail="video_id 已存在")

    short_title = body.short_title.strip()
    if not short_title:
        raise HTTPException(status_code=400, detail="请填写标题")
    if not body.author.name.strip():
        raise HTTPException(status_code=400, detail="请填写作者")
    if body.status == "rejected" and not body.rejection_reason.strip():
        raise HTTPException(status_code=400, detail="驳回时需填写原因")

    author = get_or_create_author(db, body.author.model_dump())
    tags = resolve_tags(db, body.tag_names)
    payload = body.model_dump()
    payload["subtitles"] = [s.model_dump() for s in body.subtitles]
    if payload.get("series_id") is not None and not get_series_or_none(db, payload["series_id"]):
        raise HTTPException(status_code=400, detail="合集不存在")
    if payload.get("series_id") is not None and payload.get("series_index") is None:
        raise HTTPException(status_code=400, detail="加入合集时请填写合集内集序号")

    ep = Episode(video_id=video_id, status=body.status)
    apply_episode_fields(ep, payload, author=author, tags=tags)
    db.add(ep)
    db.flush()

    if body.subtitles:
        replace_subtitles(db, ep.id, payload["subtitles"])

    db.commit()
    db.refresh(ep)
    ep = _get_episode_or_404(db, ep.id)
    return _episode_detail(ep, _get_submitter(db, ep.submitted_by_user_id))


@router.get("/episodes/{episode_id}/", response_model=AdminEpisodeDetailOut)
def get_episode(
    episode_id: int,
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    ep = _get_episode_or_404(db, episode_id)
    return _episode_detail(ep, _get_submitter(db, ep.submitted_by_user_id))


@router.patch("/episodes/{episode_id}/", response_model=AdminEpisodeDetailOut)
def update_episode(
    episode_id: int,
    body: AdminEpisodeUpdateIn,
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    ep = _get_episode_or_404(db, episode_id)
    old_status = ep.status
    data = body.model_dump(exclude_unset=True)

    next_status = data.get("status", ep.status)
    if next_status == "rejected":
        reason = data.get("rejection_reason")
        if reason is None:
            reason = ep.rejection_reason
        if not (reason and str(reason).strip()):
            raise HTTPException(status_code=400, detail="驳回时需填写原因")

    author = ep.author
    if body.author is not None:
        author = get_or_create_author(db, body.author.model_dump())

    tags = ep.tags
    if body.tag_names is not None:
        tags = resolve_tags(db, body.tag_names)

    if data.get("clear_series"):
        data["series_id"] = None
        data["series_index"] = None
    elif "series_id" in data and data["series_id"] is not None:
        if not get_series_or_none(db, data["series_id"]):
            raise HTTPException(status_code=400, detail="合集不存在")
        next_index = data.get("series_index", ep.series_index)
        if next_index is None:
            raise HTTPException(status_code=400, detail="加入合集时请填写合集内集序号")

    subtitles_payload = None
    if body.subtitles is not None:
        subtitles_payload = [s.model_dump() for s in body.subtitles]
        data["subtitles"] = subtitles_payload

    catalog_public = data.pop("is_catalog_public", None)

    apply_episode_fields(ep, data, author=author, tags=tags)
    if subtitles_payload is not None:
        replace_subtitles(db, ep.id, subtitles_payload)

    if ep.submitted_by_user_id and ep.status == "published":
        video_ok = bool((ep.video_url or "").strip())
        subtitle_ok = ep.subtitle_count > 0 or bool(subtitles_payload)
        if not video_ok or not subtitle_ok:
            raise HTTPException(
                status_code=400,
                detail="用户投稿发布前须手工上传视频直链与字幕",
            )

    maybe_notify_submitter_on_status_change(
        db,
        ep,
        old_status=old_status,
        new_status=ep.status,
        rejection_reason=ep.rejection_reason,
    )

    if catalog_public is not None and ep.submitted_by_user_id is not None:
        want_public = bool(catalog_public)
        if want_public and ep.status != "published":
            raise HTTPException(status_code=400, detail="请先发布后再设为全站可见")
        ep.is_catalog_public = want_public
    elif ep.submitted_by_user_id is None:
        # 官方内容始终按公共目录处理
        ep.is_catalog_public = False

    db.commit()
    ep = _get_episode_or_404(db, episode_id)
    return _episode_detail(ep, _get_submitter(db, ep.submitted_by_user_id))


@router.delete("/episodes/{episode_id}/")
def delete_episode(
    episode_id: int,
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    ep = _get_episode_or_404(db, episode_id)
    delete_episode_with_dependencies(db, ep)
    db.commit()
    return {"success": True}
