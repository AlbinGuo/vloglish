"""用户自助导入：B 站链接 / 本地视频 + 用户自带的 SRT/VTT 字幕。

本地文件导入直接落到 ``DATA_DIR/media/<video_id>/``（复用现有
/api/episode/<video_id>/video|audio 本地媒体服务）；远程链接（YouTube/B 站）
下载后转存七牛云，成功即删除本地文件，避免占用服务器磁盘。
暂不做中文翻译 / 音标 / 难度词汇高亮。
"""
from __future__ import annotations

import logging
import os
import re
import shutil
import subprocess
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

from ..database import DATA_DIR
from ..qiniu_storage import QiniuConfig, upload_file
from .media_transcode import get_ffmpeg_dir, probe_video_codec
from .vtt_import import subtitle_text_to_dicts
from .yt_dlp_fetch import download_source_media

logger = logging.getLogger(__name__)

ALLOWED_VIDEO_SUFFIXES = {".mp4", ".mov", ".m4v", ".webm", ".mkv", ".avi", ".flv"}
ALLOWED_SUBTITLE_SUFFIXES = {".srt", ".vtt", ".txt"}

_H264_CODECS = frozenset({"h264", "avc1"})


def _ffmpeg_path() -> str:
    ffmpeg_dir = get_ffmpeg_dir()
    local = ffmpeg_dir / "ffmpeg.exe"
    if local.is_file():
        return str(local)
    found = shutil.which("ffmpeg")
    if found:
        return found
    raise RuntimeError(
        "服务器未配置 ffmpeg，无法处理上传视频。请在 backend/.env 配置 "
        "VLOGISH_TOOLS_DIR（目录内需含 ffmpeg.exe），然后重启后端。"
    )


def _ffmpeg_timeout() -> int:
    try:
        return max(60, int(os.getenv("FFMPEG_TRANSCODE_TIMEOUT", "14400")))
    except ValueError:
        return 14400


def _run_ffmpeg(cmd: list[str]) -> None:
    proc = subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        timeout=_ffmpeg_timeout(),
    )
    if proc.returncode != 0:
        detail = (proc.stderr or proc.stdout or "").strip()
        raise RuntimeError(detail[-1500:] if detail else "ffmpeg 处理失败")


def _prepare_video_mp4(src: Path, out: Path) -> None:
    """统一转成浏览器可播放的 video.mp4。"""
    ffmpeg = _ffmpeg_path()
    codec = probe_video_codec(src, get_ffmpeg_dir())
    if codec in _H264_CODECS:
        video_args = ["-c:v", "copy"]
    else:
        preset = os.getenv("FFMPEG_X264_PRESET", "veryfast").strip() or "veryfast"
        video_args = ["-c:v", "libx264", "-preset", preset, "-crf", "23"]
    _run_ffmpeg(
        [
            ffmpeg,
            "-y",
            "-i",
            str(src),
            *video_args,
            "-c:a",
            "aac",
            "-b:a",
            "128k",
            "-movflags",
            "+faststart",
            str(out),
        ]
    )
    if not out.is_file():
        raise RuntimeError("视频转码后未生成文件")


def _extract_audio_mp3(video: Path, out: Path) -> None:
    ffmpeg = _ffmpeg_path()
    _run_ffmpeg(
        [
            ffmpeg,
            "-y",
            "-i",
            str(video),
            "-vn",
            "-acodec",
            "libmp3lame",
            "-q:a",
            "4",
            str(out),
        ]
    )
    if not out.is_file():
        raise RuntimeError("音频提取失败")


def _image_to_jpg(src: Path, out: Path) -> bool:
    try:
        ffmpeg = _ffmpeg_path()
        _run_ffmpeg([ffmpeg, "-y", "-i", str(src), "-frames:v", "1", "-q:v", "3", str(out)])
    except Exception:
        return False
    return out.is_file()


def _extract_cover_from_video(video: Path, out: Path) -> bool:
    try:
        ffmpeg = _ffmpeg_path()
        _run_ffmpeg(
            [
                ffmpeg,
                "-y",
                "-ss",
                "0",
                "-i",
                str(video),
                "-frames:v",
                "1",
                "-vf",
                "scale=640:-2",
                "-q:v",
                "3",
                str(out),
            ]
        )
    except Exception:
        return False
    return out.is_file()


def _write_cover(target_dir: Path, video: Path, thumbnail_src: Path | None) -> None:
    """封面：优先用 B 站缩略图，其次用视频首帧（均尽力而为，失败不影响导入）。"""
    out = target_dir / "cover.jpg"
    if thumbnail_src is not None and thumbnail_src.is_file() and _image_to_jpg(thumbnail_src, out):
        return
    _extract_cover_from_video(video, out)


def _cover_url_if_exists(video_id: str) -> str:
    if (DATA_DIR / "media" / video_id / "cover.jpg").is_file():
        return f"/api/episode/{video_id}/cover/"
    return ""


def _finalize_video_dir(
    video_id: str, source_video: Path, *, thumbnail_src: Path | None = None
) -> Path:
    """把来源视频转成 video.mp4、抽 audio.mp3、生成 cover.jpg，落到 media/<video_id>/。"""
    target_dir = DATA_DIR / "media" / video_id
    target_dir.mkdir(parents=True, exist_ok=True)
    video_out = target_dir / "video.mp4"
    audio_out = target_dir / "audio.mp3"
    try:
        # 视频转封装/转码与音频抽取互不依赖，并行缩短总耗时
        with ThreadPoolExecutor(max_workers=2) as pool:
            fv = pool.submit(_prepare_video_mp4, source_video, video_out)
            fa = pool.submit(_extract_audio_mp3, source_video, audio_out)
            fv.result()
            fa.result()
    except Exception:
        shutil.rmtree(target_dir, ignore_errors=True)
        raise
    _write_cover(target_dir, video_out, thumbnail_src)
    return target_dir


def _parse_subtitles(subtitle_text: str | None) -> tuple[list[dict], bool, float]:
    text = (subtitle_text or "").strip()
    if not text:
        return [], False, 0.0
    subtitles = subtitle_text_to_dicts(text)
    if not subtitles:
        raise RuntimeError("未能从字幕文件中解析出任何字幕，请检查 SRT/VTT 内容")
    had_chinese = any((s.get("chinese") or "").strip() for s in subtitles)
    clip_length = float(max((s["end"] for s in subtitles), default=0.0))
    return subtitles, had_chinese, clip_length


def parse_subtitle_upload(subtitle_text: str) -> tuple[list[dict], float]:
    """给“先导视频、后补字幕”接口用：必须能解析出至少一条字幕。"""
    subtitles, _, clip_length = _parse_subtitles(subtitle_text)
    if not subtitles:
        raise RuntimeError("未能从字幕文件中解析出任何字幕，请检查 SRT/VTT 内容")
    return subtitles, clip_length


def _clean_title(text: str) -> str:
    stem = Path(text).stem if text else ""
    stem = re.sub(r"[_\-.]+", " ", stem).strip()
    stem = re.sub(r"\s+", " ", stem).strip()
    return (stem or "我的视频")[:80]


def _media_urls(video_id: str) -> dict:
    return {
        "video_url": f"/api/episode/{video_id}/video/",
        "audio_url": f"/api/episode/{video_id}/audio/",
    }


def _upload_media_to_qiniu(video_id: str, media_dir: Path) -> dict[str, str] | None:
    """把处理好的 video/audio/cover 上传七牛，返回可入库的 public 基址。

    七牛未配置时返回 None（调用方回退本地存储）；上传异常由调用方捕获。
    """
    try:
        cfg = QiniuConfig.from_env()
    except RuntimeError as exc:
        logger.warning("远程导入转存七牛跳过（七牛未配置）：%s", exc)
        return None

    jobs: dict[str, Path] = {}
    for field, pattern in (
        ("cover", "cover.*"),
        ("video_url", "video.*"),
        ("audio_url", "audio.*"),
    ):
        candidates = sorted(media_dir.glob(pattern))
        if candidates:
            jobs[field] = candidates[0]
    if "video_url" not in jobs:
        raise RuntimeError("七牛上传前未找到视频文件")

    uploads: dict[str, str] = {}
    # 三个文件并行上传，缩短等待
    with ThreadPoolExecutor(max_workers=len(jobs)) as pool:
        futures = {
            pool.submit(upload_file, cfg, path, cfg.object_key(video_id, path.name)): field
            for field, path in jobs.items()
        }
        for future, field in futures.items():
            uploads[field] = future.result()

    if not uploads.get("video_url"):
        raise RuntimeError("七牛上传后未得到视频地址")
    return uploads


def ingest_from_local_file(
    *,
    video_id: str,
    video_src: Path,
    video_suffix: str,
    subtitle_text: str | None,
    title_hint: str = "",
) -> dict:
    suffix = (video_suffix or "").lower()
    if suffix not in ALLOWED_VIDEO_SUFFIXES:
        raise RuntimeError("不支持的视频格式，请上传 mp4 / mov / webm / mkv 等常见格式")

    subtitles, had_chinese, clip_length = _parse_subtitles(subtitle_text)
    _finalize_video_dir(video_id, video_src)

    return {
        "short_title": _clean_title(title_hint),
        "summary": "",
        "author_name": "",
        "author_avatar": "",
        "original_video_url": "",
        "subtitles": subtitles,
        "had_chinese": had_chinese,
        "clip_length": clip_length,
        "cover_url": _cover_url_if_exists(video_id),
        **_media_urls(video_id),
    }


def ingest_from_remote_url(
    *,
    video_id: str,
    url: str,
    subtitle_text: str | None,
) -> dict:
    subtitles, had_chinese, clip_length = _parse_subtitles(subtitle_text)

    fetched = download_source_media(url, write_subtitles=False, quality="720")
    try:
        media_dir = _finalize_video_dir(
            video_id, fetched.video_path, thumbnail_src=fetched.thumbnail_path
        )

        # 后台异步转存七牛（不阻塞导入）；未配置/失败时保留本地，由 /api/episode 兜底播放
        media_payload = _media_urls(video_id)
        cover_url = _cover_url_if_exists(video_id)

        return {
            "short_title": _clean_title(fetched.title or ""),
            "summary": (fetched.summary or "")[:2000],
            "author_name": fetched.author_name or "",
            "author_avatar": fetched.author_avatar or "",
            "original_video_url": fetched.webpage_url or url,
            "subtitles": subtitles,
            "had_chinese": had_chinese,
            "clip_length": clip_length,
            "cover_url": cover_url,
            **media_payload,
        }
    finally:
        shutil.rmtree(fetched.work_dir, ignore_errors=True)
