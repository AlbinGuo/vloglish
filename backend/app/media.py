from __future__ import annotations

import re
from pathlib import Path

from .database import DATA_DIR
from .qiniu_storage import qiniu_cover_expires, qiniu_media_expires, sign_url

YOUTUBE_ID_RE = re.compile(r"^[a-zA-Z0-9_-]{11}$")
YOUTUBE_URL_RE = re.compile(
    r"(?:youtu\.be/|youtube\.com/(?:embed/|watch\?v=)|[?&]v=)([a-zA-Z0-9_-]{11})"
)


def extract_youtube_id(value: str) -> str | None:
    if not value:
        return None
    match = YOUTUBE_URL_RE.search(value)
    if match:
        return match.group(1)
    if YOUTUBE_ID_RE.fullmatch(value):
        return value
    return None


def is_youtube_episode(*, video_id: str, video_url: str, original_video_url: str) -> bool:
    if extract_youtube_id(video_id):
        return True
    if "youtube.com" in video_url or "youtu.be" in video_url:
        return True
    if extract_youtube_id(original_video_url):
        return True
    return False


AUDIO_EXTENSIONS = (
    (".mp3", "audio/mpeg"),
    (".m4a", "audio/mp4"),
    (".webm", "audio/webm"),
    (".opus", "audio/ogg"),
)


def episode_audio_dir(video_id: str) -> Path:
    return DATA_DIR / "media" / video_id


def find_episode_audio_file(video_id: str) -> tuple[Path, str] | None:
    audio_dir = episode_audio_dir(video_id)
    if not audio_dir.is_dir():
        return None
    for ext, media_type in AUDIO_EXTENSIONS:
        path = audio_dir / f"audio{ext}"
        if path.is_file():
            return path, media_type
    return None


def episode_audio_path(video_id: str) -> Path:
    found = find_episode_audio_file(video_id)
    if found:
        return found[0]
    return episode_audio_dir(video_id) / "audio.mp3"


def episode_audio_api_url(video_id: str) -> str:
    return f"/api/episode/{video_id}/audio/"


VIDEO_EXTENSIONS = (
    (".mp4", "video/mp4"),
    (".webm", "video/webm"),
)


def find_episode_video_file(video_id: str) -> tuple[Path, str] | None:
    audio_dir = episode_audio_dir(video_id)
    if not audio_dir.is_dir():
        return None
    for ext, media_type in VIDEO_EXTENSIONS:
        path = audio_dir / f"video{ext}"
        if path.is_file():
            return path, media_type
    return None


def episode_video_api_url(video_id: str) -> str:
    return f"/api/episode/{video_id}/video/"


def is_remote_media_url(url: str) -> bool:
    return url.startswith("http://") or url.startswith("https://")


def resolve_video_url(*, video_id: str, video_url: str, original_video_url: str) -> str:
    if is_remote_media_url(video_url) and "youtube.com/embed" not in video_url:
        return sign_url(video_url, expires=qiniu_media_expires())
    if find_episode_video_file(video_id):
        return episode_video_api_url(video_id)
    return video_url


def resolve_audio_url(*, video_id: str, audio_url: str, video_url: str, original_video_url: str) -> str:
    if is_remote_media_url(audio_url):
        return sign_url(audio_url, expires=qiniu_media_expires())
    found = find_episode_audio_file(video_id)
    if found:
        return episode_audio_api_url(video_id)
    if audio_url:
        return sign_url(audio_url, expires=qiniu_media_expires()) if is_remote_media_url(audio_url) else audio_url
    if is_youtube_episode(
        video_id=video_id,
        video_url=video_url,
        original_video_url=original_video_url,
    ):
        return episode_audio_api_url(video_id)
    return ""


def resolve_cover_url(cover: str) -> str:
    """列表/详情封面：七牛资源签发短时 URL。"""
    raw = (cover or "").strip()
    if not raw:
        return ""
    if is_remote_media_url(raw):
        return sign_url(raw, expires=qiniu_cover_expires())
    return raw
