from datetime import datetime
import shutil
from pathlib import Path

from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile
from sqlalchemy.orm import Session, joinedload

from ..database import DATA_DIR, get_db
from ..deps import get_current_member
from ..media import resolve_cover_url
from ..models import Article, Episode, User, UserEpisodeFavorite
from ..schemas import (
    UserCorpusBadgeOut,
    UserEpisodeSubmitOut,
    UserSubmissionItemOut,
    UserSubmissionListOut,
)
from ..services.episode_admin import (
    apply_episode_fields,
    generate_video_id,
    get_or_create_author,
    replace_subtitles,
)
from ..services.local_submit import (
    ALLOWED_SUBTITLE_SUFFIXES,
    ALLOWED_VIDEO_SUFFIXES,
    ingest_from_local_file,
    ingest_from_remote_url,
    parse_subtitle_upload,
)
from ..services.yt_dlp_fetch import is_supported_source_url, resolve_bilibili_short_url

router = APIRouter(prefix="/api/episodes/submit", tags=["episode-submit"])

VALID_USER_ACCENTS = frozenset({"美国", "英国"})
ACCENT_NATIONALITY = {"美国": "🇺🇸", "英国": "🇬🇧"}


def _fmt_dt(dt) -> str:
    return dt.isoformat() + "Z" if dt else ""


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
            cover=resolve_cover_url((ep.thumbnail_url or ep.cover or "").strip()),
        )
        for ep in rows
    ]
    return UserSubmissionListOut(count=len(results), results=results)


@router.get("/badge/", response_model=UserCorpusBadgeOut)
def my_corpus_badge(
    user: User = Depends(get_current_member),
    db: Session = Depends(get_db),
):
    ep_count = (
        db.query(Episode)
        .filter(Episode.submitted_by_user_id == user.id)
        .count()
    )
    art_count = (
        db.query(Article)
        .filter(Article.submitted_by_user_id == user.id)
        .count()
    )
    seen_at = getattr(user, "my_corpus_seen_at", None)
    new_ep = db.query(Episode.id).filter(
        Episode.submitted_by_user_id == user.id,
        Episode.status == "published",
        Episode.published_at.isnot(None),
    )
    new_art = db.query(Article.id).filter(
        Article.submitted_by_user_id == user.id,
        Article.status == "published",
        Article.published_at.isnot(None),
    )
    if seen_at is not None:
        new_ep = new_ep.filter(Episode.published_at > seen_at)
        new_art = new_art.filter(Article.published_at > seen_at)
    fav_count = (
        db.query(UserEpisodeFavorite.user_id)
        .filter(UserEpisodeFavorite.user_id == user.id)
        .count()
    )
    has_new = new_ep.limit(1).first() is not None or new_art.limit(1).first() is not None
    return UserCorpusBadgeOut(count=ep_count + art_count + fav_count, has_new=has_new)


@router.post("/seen/")
def mark_my_corpus_seen(
    user: User = Depends(get_current_member),
    db: Session = Depends(get_db),
):
    user.my_corpus_seen_at = datetime.utcnow()
    db.commit()
    return {"success": True}


@router.post("/import/", response_model=UserEpisodeSubmitOut)
def import_self_episode(
    subtitle: UploadFile | None = File(None),
    url: str = Form(""),
    video: UploadFile | None = File(None),
    accent: str = Form("美国"),
    note: str = Form(""),
    user: User = Depends(get_current_member),
    db: Session = Depends(get_db),
):
    """用户自助导入：B 站链接或本地视频（字幕可选），导入即发布、仅本人可见。"""
    accent = (accent or "美国").strip()
    if accent not in VALID_USER_ACCENTS:
        raise HTTPException(status_code=400, detail="请选择美式或英式口音")

    url = (url or "").strip()
    has_video = video is not None and bool((video.filename or "").strip())
    if url and has_video:
        raise HTTPException(status_code=400, detail="B 站链接和本地视频只能二选一")
    if not url and not has_video:
        raise HTTPException(status_code=400, detail="请提供 B 站视频链接或本地视频文件")

    subtitle_text = ""
    if subtitle is not None and (subtitle.filename or "").strip():
        subtitle_suffix = Path(subtitle.filename or "").suffix.lower()
        if subtitle_suffix not in ALLOWED_SUBTITLE_SUFFIXES:
            raise HTTPException(status_code=400, detail="请上传 SRT 或 VTT 字幕文件")
        subtitle_text = subtitle.file.read().decode("utf-8", errors="replace")

    if url:
        # b23.tv 短链先解析成完整链接：既提升抓取成功率，也让去重更准确
        url = resolve_bilibili_short_url(url)
        if not is_supported_source_url(url):
            raise HTTPException(status_code=400, detail="请粘贴有效的 Bilibili 视频链接")
        existing = (
            db.query(Episode)
            .filter(
                Episode.original_video_url == url,
                Episode.submitted_by_user_id == user.id,
            )
            .first()
        )
        if existing:
            raise HTTPException(status_code=400, detail="你已经导入过这个视频了")

    video_id = generate_video_id()
    while db.query(Episode).filter(Episode.video_id == video_id).first():
        video_id = generate_video_id()

    try:
        if url:
            result = ingest_from_remote_url(
                video_id=video_id,
                url=url,
                subtitle_text=subtitle_text,
            )
        else:
            video_suffix = Path(video.filename or "").suffix.lower()  # type: ignore[union-attr]
            if video_suffix not in ALLOWED_VIDEO_SUFFIXES:
                raise RuntimeError("请上传 mp4 / mov / webm / mkv 等常见视频格式")
            uploads_dir = DATA_DIR / "uploads" / video_id
            uploads_dir.mkdir(parents=True, exist_ok=True)
            video_tmp = uploads_dir / f"upload{video_suffix}"
            try:
                with video_tmp.open("wb") as out:
                    shutil.copyfileobj(video.file, out)  # type: ignore[union-attr]
                result = ingest_from_local_file(
                    video_id=video_id,
                    video_src=video_tmp,
                    video_suffix=video_suffix,
                    subtitle_text=subtitle_text,
                    title_hint=Path(video.filename or "").stem,  # type: ignore[union-attr]
                )
            finally:
                shutil.rmtree(uploads_dir, ignore_errors=True)
    except HTTPException:
        shutil.rmtree(DATA_DIR / "media" / video_id, ignore_errors=True)
        raise
    except Exception as exc:
        shutil.rmtree(DATA_DIR / "media" / video_id, ignore_errors=True)
        raise HTTPException(status_code=400, detail=str(exc) or "视频导入失败") from exc

    note = (note or "").strip()
    remark_parts = [f"用户自助导入 (user #{user.id})", f"邮箱 {user.email}"]
    if note:
        remark_parts.append(f"备注：{note}")

    author_name = (result.get("author_name") or "").strip() or "我"
    author = get_or_create_author(
        db,
        {
            "name": author_name,
            "gender": "m",
            "nationality": ACCENT_NATIONALITY.get(accent, ""),
            "accent": accent,
        },
    )

    payload = {
        "short_title": result["short_title"],
        "summary": result.get("summary", ""),
        "remark": " | ".join(remark_parts),
        "stars": 3,
        "voca_size": 0,
        "cover": result.get("cover_url", ""),
        "video_url": result["video_url"],
        "audio_url": result["audio_url"],
        "thumbnail_url": "",
        "original_video_url": result.get("original_video_url", ""),
        "is_demo": False,
        "status": "published",
        "subtitles": result["subtitles"],
    }

    ep = Episode(
        video_id=video_id,
        status="published",
        submitted_by_user_id=user.id,
        is_catalog_public=False,
    )
    apply_episode_fields(ep, payload, author=author, tags=[])
    db.add(ep)
    db.flush()
    replace_subtitles(db, ep.id, result["subtitles"])
    db.commit()
    db.refresh(ep)

    if result["subtitles"]:
        message = "导入成功，已加入你的个人语料库（仅你可见）。"
    else:
        message = "视频导入成功！你还未上传字幕，可在视频详情页点击「导入字幕」补充。"

    return UserEpisodeSubmitOut(
        video_id=ep.video_id,
        short_title=ep.short_title,
        status=ep.status,
        message=message,
    )


@router.post("/{video_id}/subtitle/")
def add_episode_subtitle(
    video_id: str,
    subtitle: UploadFile = File(...),
    user: User = Depends(get_current_member),
    db: Session = Depends(get_db),
):
    """给已导入的视频补传 / 替换字幕（仅创建者本人可操作）。"""
    episode = (
        db.query(Episode)
        .filter(
            Episode.video_id == video_id,
            Episode.submitted_by_user_id == user.id,
        )
        .first()
    )
    if not episode:
        raise HTTPException(status_code=404, detail="视频不存在或不是你导入的")

    subtitle_suffix = Path(subtitle.filename or "").suffix.lower()
    if subtitle_suffix not in ALLOWED_SUBTITLE_SUFFIXES:
        raise HTTPException(status_code=400, detail="请上传 SRT 或 VTT 字幕文件")

    subtitle_text = subtitle.file.read().decode("utf-8", errors="replace")
    try:
        subtitles, clip_length = parse_subtitle_upload(subtitle_text)
    except RuntimeError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc

    replace_subtitles(db, episode.id, subtitles)
    episode.subtitle_count = len(subtitles)
    episode.clip_length = clip_length
    db.commit()
    db.refresh(episode)

    return {"success": True, "subtitle_count": episode.subtitle_count}
