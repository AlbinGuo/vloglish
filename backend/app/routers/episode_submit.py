from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload

from ..database import get_db
from ..deps import get_current_member
from ..models import Episode, User
from ..schemas import (
    UserEpisodeSubmitIn,
    UserEpisodeSubmitOut,
    UserSubmissionItemOut,
    UserSubmissionListOut,
)
from ..services.episode_admin import apply_episode_fields, generate_video_id, get_or_create_author
from ..services.yt_dlp_fetch import is_supported_source_url

router = APIRouter(prefix="/api/episodes/submit", tags=["episode-submit"])

VALID_USER_ACCENTS = frozenset({"美国", "英国"})
ACCENT_NATIONALITY = {"美国": "🇺🇸", "英国": "🇬🇧"}


def _fmt_dt(dt) -> str:
    return dt.isoformat() + "Z" if dt else ""


def _placeholder_title(url: str) -> str:
    cleaned = url.strip()
    if len(cleaned) > 72:
        cleaned = cleaned[:69] + "..."
    return f"待补充 · {cleaned}"


@router.get("/", response_model=UserSubmissionListOut)
def list_my_submissions(
    user: User = Depends(get_current_member),
    db: Session = Depends(get_db),
):
    rows = (
        db.query(Episode)
        .options(joinedload(Episode.author))
        .filter(Episode.submitted_by_user_id == user.id)
        .order_by(Episode.created_at.desc(), Episode.id.desc())
        .all()
    )
    results = [
        UserSubmissionItemOut(
            video_id=ep.video_id,
            short_title=ep.short_title,
            original_video_url=ep.original_video_url or "",
            status=ep.status,
            rejection_reason=ep.rejection_reason or "",
            created_at=_fmt_dt(ep.created_at),
            has_media=bool((ep.video_url or "").strip()) and ep.subtitle_count > 0,
            accent=ep.author.accent if ep.author else "",
            cover=(ep.thumbnail_url or ep.cover or "").strip(),
        )
        for ep in rows
    ]
    return UserSubmissionListOut(count=len(results), results=results)


@router.post("/", response_model=UserEpisodeSubmitOut)
def submit_episode(
    body: UserEpisodeSubmitIn,
    user: User = Depends(get_current_member),
    db: Session = Depends(get_db),
):
    accent = (body.accent or "美国").strip()
    if accent not in VALID_USER_ACCENTS:
        raise HTTPException(status_code=400, detail="请选择美式或英式口音")

    url = body.original_video_url.strip()
    if not is_supported_source_url(url):
        raise HTTPException(status_code=400, detail="仅支持 YouTube 或 TikTok 链接")

    existing = db.query(Episode).filter(Episode.original_video_url == url).first()
    if existing:
        raise HTTPException(status_code=400, detail="该视频已收录或已在审核中，请勿重复提交")

    note = (body.note or "").strip()
    remark_parts = [f"用户投稿 (user #{user.id})", f"邮箱 {user.email}"]
    if note:
        remark_parts.append(f"用户备注：{note}")

    author = get_or_create_author(
        db,
        {
            "name": "待定",
            "gender": "m",
            "nationality": ACCENT_NATIONALITY.get(accent, ""),
            "accent": accent,
        },
    )

    video_id = generate_video_id()
    while db.query(Episode).filter(Episode.video_id == video_id).first():
        video_id = generate_video_id()

    payload = {
        "short_title": _placeholder_title(url),
        "summary": "",
        "remark": " | ".join(remark_parts),
        "stars": 3,
        "voca_size": 0,
        "cover": "",
        "video_url": "",
        "audio_url": "",
        "thumbnail_url": "",
        "original_video_url": url,
        "is_demo": False,
        "status": "draft",
    }

    ep = Episode(video_id=video_id, status="draft", submitted_by_user_id=user.id)
    apply_episode_fields(ep, payload, author=author, tags=[])
    db.add(ep)
    db.commit()
    db.refresh(ep)

    return UserEpisodeSubmitOut(
        video_id=ep.video_id,
        short_title=ep.short_title,
        status=ep.status,
        message="提交成功，视频将在管理员审核通过后上传语料，预计1-2个小时出审核结果~",
    )
