from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import or_
from sqlalchemy.orm import Session, joinedload

from ...database import get_db
from ...deps import get_current_admin
from ...models import Author, Episode, User
from ...schemas import (
    AdminEpisodeCreateIn,
    AdminEpisodeDetailOut,
    AdminEpisodeListItemOut,
    AdminEpisodeListOut,
    AdminEpisodeUpdateIn,
    AdminSubtitleIn,
)
from ...serializers import episode_detail
from ...services.episode_admin import (
    apply_episode_fields,
    generate_video_id,
    get_or_create_author,
    replace_subtitles,
    resolve_tags,
)
from ...services.user_notifications import maybe_notify_submitter_on_status_change

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


def _episode_detail(ep: Episode) -> AdminEpisodeDetailOut:
    return AdminEpisodeDetailOut(
        id=ep.id,
        video_id=ep.video_id,
        index=ep.index,
        short_title=ep.short_title,
        summary=ep.summary or "",
        remark=ep.remark or "",
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
        status=ep.status,
        rejection_reason=ep.rejection_reason or "",
        is_user_submitted=ep.submitted_by_user_id is not None,
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


def _get_episode_or_404(db: Session, episode_id: int) -> Episode:
    ep = (
        db.query(Episode)
        .options(
            joinedload(Episode.author),
            joinedload(Episode.tags),
            joinedload(Episode.subtitles),
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
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    q = db.query(Episode).options(joinedload(Episode.author), joinedload(Episode.tags)).join(Author)
    if search and search.strip():
        term = f"%{search.strip()}%"
        q = q.filter(or_(Episode.short_title.ilike(term), Episode.video_id.ilike(term), Author.name.ilike(term)))
    if status:
        q = q.filter(Episode.status == status)
    if stars is not None:
        q = q.filter(Episode.stars == stars)
    q = q.order_by(Episode.id.desc())
    total = q.count()
    items = q.offset((page - 1) * page_size).limit(page_size).all()
    return AdminEpisodeListOut(
        count=total,
        results=[
            AdminEpisodeListItemOut(
                id=ep.id,
                video_id=ep.video_id,
                short_title=ep.short_title,
                stars=ep.stars,
                status=ep.status,
                subtitle_count=ep.subtitle_count,
                clip_length=ep.clip_length,
                author_name=ep.author.name,
                cover=ep.thumbnail_url or ep.cover or "",
                is_demo=ep.is_demo,
                is_user_submitted=ep.submitted_by_user_id is not None,
                tag_names=[t.name for t in ep.tags],
                created_at=_fmt_dt(ep.created_at),
            )
            for ep in items
        ],
    )


@router.get("/episodes/preview/{video_id}/")
def preview_episode(
    video_id: str,
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    episode = (
        db.query(Episode)
        .options(joinedload(Episode.author), joinedload(Episode.tags), joinedload(Episode.subtitles))
        .filter(Episode.video_id == video_id)
        .first()
    )
    if not episode:
        raise HTTPException(status_code=404, detail="剧集不存在")
    total = db.query(Episode).filter(Episode.status == "published").count()
    return episode_detail(episode, total)


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

    ep = Episode(video_id=video_id, status=body.status)
    apply_episode_fields(ep, payload, author=author, tags=tags)
    db.add(ep)
    db.flush()

    if body.subtitles:
        replace_subtitles(db, ep.id, payload["subtitles"])

    db.commit()
    db.refresh(ep)
    return _episode_detail(_get_episode_or_404(db, ep.id))


@router.get("/episodes/{episode_id}/", response_model=AdminEpisodeDetailOut)
def get_episode(
    episode_id: int,
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    return _episode_detail(_get_episode_or_404(db, episode_id))


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

    subtitles_payload = None
    if body.subtitles is not None:
        subtitles_payload = [s.model_dump() for s in body.subtitles]
        data["subtitles"] = subtitles_payload

    apply_episode_fields(ep, data, author=author, tags=tags)
    if subtitles_payload is not None:
        replace_subtitles(db, ep.id, subtitles_payload)

    maybe_notify_submitter_on_status_change(
        db,
        ep,
        old_status=old_status,
        new_status=ep.status,
        rejection_reason=ep.rejection_reason,
    )

    db.commit()
    return _episode_detail(_get_episode_or_404(db, episode_id))


@router.delete("/episodes/{episode_id}/")
def delete_episode(
    episode_id: int,
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    ep = _get_episode_or_404(db, episode_id)
    db.delete(ep)
    db.commit()
    return {"success": True}
