from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from ..database import get_db
from ..deps import get_current_member
from ..models import Episode, User
from ..schemas import (
    AdminFetchMediaIn,
    AdminFetchMediaOut,
    AdminSubtitleIn,
    UserEpisodeSubmitIn,
    UserEpisodeSubmitOut,
)
from ..services.episode_admin import (
    apply_episode_fields,
    generate_video_id,
    get_or_create_author,
    replace_subtitles,
)
from ..services.yt_dlp_fetch import fetch_and_upload_from_url, is_supported_source_url

router = APIRouter(prefix="/api/episodes/submit", tags=["episode-submit"])

VALID_USER_ACCENTS = frozenset({"美国", "英国"})
ACCENT_NATIONALITY = {"美国": "🇺🇸", "英国": "🇬🇧"}


def _fetch_media_out(result: dict) -> AdminFetchMediaOut:
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


@router.post("/fetch-media/", response_model=AdminFetchMediaOut)
def user_fetch_media(
    body: AdminFetchMediaIn,
    _user: User = Depends(get_current_member),
):
    if not is_supported_source_url(body.url):
        raise HTTPException(status_code=400, detail="仅支持 YouTube 或 TikTok 链接")
    try:
        result = fetch_and_upload_from_url(
            body.url,
            slug=body.slug,
            enrich_subtitles=body.enrich_subtitles,
        )
    except RuntimeError as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc
    return _fetch_media_out(result)


@router.post("/", response_model=UserEpisodeSubmitOut)
def submit_episode(
    body: UserEpisodeSubmitIn,
    user: User = Depends(get_current_member),
    db: Session = Depends(get_db),
):
    if body.accent not in VALID_USER_ACCENTS:
        raise HTTPException(status_code=400, detail="请选择美式或英式口音")
    if not is_supported_source_url(body.original_video_url):
        raise HTTPException(status_code=400, detail="仅支持 YouTube 或 TikTok 链接")
    if not body.subtitles:
        raise HTTPException(status_code=400, detail="请先抓取视频并生成字幕")

    existing = (
        db.query(Episode)
        .filter(Episode.original_video_url == body.original_video_url.strip())
        .first()
    )
    if existing:
        raise HTTPException(status_code=400, detail="该视频已收录，请勿重复提交")

    author_name = (body.author_name or "未知").strip() or "未知"
    author = get_or_create_author(
        db,
        {
            "name": author_name,
            "gender": "m",
            "nationality": ACCENT_NATIONALITY.get(body.accent, ""),
            "accent": body.accent,
        },
    )

    video_id = generate_video_id()
    while db.query(Episode).filter(Episode.video_id == video_id).first():
        video_id = generate_video_id()

    payload = {
        "short_title": body.title.strip(),
        "summary": body.summary,
        "remark": f"用户投稿 (user #{user.id})",
        "stars": body.stars,
        "voca_size": body.voca_size,
        "cover": body.cover,
        "video_url": body.video_url,
        "audio_url": body.audio_url,
        "thumbnail_url": body.thumbnail_url,
        "original_video_url": body.original_video_url.strip(),
        "is_demo": False,
        "status": "draft",
        "subtitles": [s.model_dump() for s in body.subtitles],
    }

    ep = Episode(video_id=video_id, status="draft", submitted_by_user_id=user.id)
    apply_episode_fields(ep, payload, author=author, tags=[])
    db.add(ep)
    db.flush()
    replace_subtitles(db, ep.id, payload["subtitles"])
    db.commit()

    return UserEpisodeSubmitOut(
        video_id=ep.video_id,
        short_title=ep.short_title,
        status=ep.status,
        message="提交成功，审核结果将通过通知告知您",
    )
