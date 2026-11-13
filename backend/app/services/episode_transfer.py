"""导入后把媒体转存七牛（后台执行，不阻塞导入）。

- B 站直链视频：边下边传（分片直传七牛），不落整片磁盘；
- B 站音频：下 DASH 小音频转 mp3，本地保留一份（供 ASR/听力用）并上传；
- 本地导入：直接上传本地文件；
- 旧数据若已有本地 video.mp4：直接上传本地（避免重复下载）。
成功后回写 Episode 的 video_url/audio_url 并删除本地大视频文件；失败保留本地兜底。
"""
from __future__ import annotations

import logging
import shutil
import subprocess
import tempfile
import threading
from pathlib import Path
from urllib.parse import parse_qs, urlparse

from ..database import DATA_DIR, SessionLocal
from ..models import Episode
from ..qiniu_storage import QiniuConfig, upload_file
from ..qiniu_stream_upload import stream_to_qiniu
from .bilibili_meta import download_audio, iter_durl_chunks

logger = logging.getLogger(__name__)

_inflight: set[str] = set()
_lock = threading.Lock()


def schedule_qiniu_backfill(video_id: str) -> None:
    """排队把该视频的媒体转存七牛；同一视频并发去重。"""
    vid = (video_id or "").strip()
    if not vid:
        return
    with _lock:
        if vid in _inflight:
            return
        _inflight.add(vid)
    threading.Thread(target=_backfill, args=(vid,), daemon=True).start()


def _set_status(video_id: str, status: str, error: str = "") -> None:
    db = SessionLocal()
    try:
        ep = db.query(Episode).filter(Episode.video_id == video_id).first()
        if not ep:
            return
        ep.media_transfer_status = status
        ep.media_transfer_error = (error or "")[:500]
        db.commit()
    except Exception:  # noqa: BLE001
        db.rollback()
    finally:
        db.close()


def _load_source_url(video_id: str) -> str | None:
    db = SessionLocal()
    try:
        ep = db.query(Episode).filter(Episode.video_id == video_id).first()
        return (ep.video_url or "").strip() if ep else None
    finally:
        db.close()


def _parse_bili_stream(url: str) -> tuple[str, int] | None:
    if "/api/bilibili/stream/" not in url:
        return None
    parsed = urlparse(url)
    bvid = parsed.path.rstrip("/").rsplit("/", 1)[-1]
    if not bvid:
        return None
    try:
        page = int((parse_qs(parsed.query).get("p") or ["1"])[0] or 1)
    except (TypeError, ValueError):
        page = 1
    return bvid, max(1, page)


def _find(media_dir: Path, stem: str) -> Path | None:
    candidates = sorted(p for p in media_dir.glob(f"{stem}.*") if p.is_file())
    return candidates[0] if candidates else None


def _ffmpeg_to_mp3(src: Path, dest: Path) -> None:
    subprocess.run(
        ["ffmpeg", "-y", "-i", str(src), "-vn", "-acodec", "libmp3lame", "-q:a", "5", str(dest)],
        check=True,
        capture_output=True,
        timeout=600,
    )


def _transfer_bilibili_audio(cfg: QiniuConfig, video_id: str, bvid: str, page: int) -> str:
    media_dir = DATA_DIR / "media" / video_id
    media_dir.mkdir(parents=True, exist_ok=True)
    dest_local = media_dir / "audio.mp3"
    work = Path(tempfile.mkdtemp(prefix="vloglish-audio-"))
    try:
        src = work / "audio.src"
        download_audio(bvid, page, src)
        try:
            _ffmpeg_to_mp3(src, dest_local)
        except Exception:  # noqa: BLE001
            shutil.copyfile(src, dest_local)
        if dest_local.is_file() and dest_local.stat().st_size > 0:
            return upload_file(cfg, dest_local, cfg.object_key(video_id, "audio.mp3"))
    except Exception:  # noqa: BLE001
        logger.warning("B站音频转存失败 %s", video_id, exc_info=True)
    finally:
        shutil.rmtree(work, ignore_errors=True)
    return ""


def _transfer_bilibili(cfg: QiniuConfig, video_id: str, bvid: str, page: int) -> tuple[str, str]:
    # 视频：边下边传（不落整片）
    video_key = cfg.object_key(video_id, "video.mp4")
    video_url = stream_to_qiniu(cfg, video_key, iter_durl_chunks(bvid, page), mime="video/mp4")
    audio_url = _transfer_bilibili_audio(cfg, video_id, bvid, page)
    return video_url, audio_url


def _transfer_local(cfg: QiniuConfig, video_id: str) -> tuple[str, str]:
    media_dir = DATA_DIR / "media" / video_id
    if not media_dir.is_dir():
        return "", ""
    video = _find(media_dir, "video")
    if not video:
        return "", ""
    video_url = upload_file(cfg, video, cfg.object_key(video_id, video.name))
    audio = _find(media_dir, "audio")
    audio_url = upload_file(cfg, audio, cfg.object_key(video_id, audio.name)) if audio else ""
    return video_url, audio_url


def _finalize(video_id: str, video_url: str, audio_url: str) -> None:
    db = SessionLocal()
    try:
        ep = db.query(Episode).filter(Episode.video_id == video_id).first()
        if not ep:
            return
        ep.video_url = video_url
        if audio_url:
            ep.audio_url = audio_url
        ep.media_transfer_status = "ready"
        ep.media_transfer_error = ""
        db.commit()
    finally:
        db.close()

    # 播放已走七牛 CDN，删除本地大视频；保留小音频供 ASR/听力兜底
    media_dir = DATA_DIR / "media" / video_id
    if media_dir.is_dir():
        for p in media_dir.glob("video.*"):
            try:
                p.unlink(missing_ok=True)
            except OSError:
                pass


def _backfill(video_id: str) -> None:
    try:
        src_url = _load_source_url(video_id)
        if src_url is None:
            return
        try:
            cfg = QiniuConfig.from_env()
        except RuntimeError as exc:
            logger.warning("七牛未配置，跳过转存 %s：%s", video_id, exc)
            _set_status(video_id, "local", "七牛未配置，暂走本地播放")
            return

        _set_status(video_id, "processing")

        video_url = ""
        audio_url = ""
        bili = _parse_bili_stream(src_url)
        if bili:
            # 旧数据若已下载本地视频，直接上传本地（更快、避免重复下载）
            if _find(DATA_DIR / "media" / video_id, "video"):
                video_url, audio_url = _transfer_local(cfg, video_id)
            else:
                try:
                    video_url, audio_url = _transfer_bilibili(cfg, video_id, bili[0], bili[1])
                except Exception:  # noqa: BLE001
                    logger.warning("B站流式转存失败，尝试本地回退 %s", video_id, exc_info=True)
                    video_url, audio_url = _transfer_local(cfg, video_id)
        else:
            video_url, audio_url = _transfer_local(cfg, video_id)

        if not video_url:
            _set_status(video_id, "failed", "未找到可转存的视频源")
            return
        _finalize(video_id, video_url, audio_url)
        logger.info("转存七牛完成 %s -> %s", video_id, video_url)
    except Exception as exc:  # noqa: BLE001
        logger.warning("转存七牛失败 %s", video_id, exc_info=True)
        _set_status(video_id, "failed", str(exc))
    finally:
        with _lock:
            _inflight.discard(video_id)
