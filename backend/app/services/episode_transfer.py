"""导入后把本地媒体转存七牛（后台执行，不阻塞导入请求）。

流程：DATA_DIR/media/<video_id> 下的 video/audio/cover 上传七牛，成功后回写
Episode 的 video_url/audio_url/cover/thumbnail_url，并删除本地大文件节省空间。
未配置七牛或失败时保持本地文件，播放继续走 /api/episode/<id>/video/ 兜底。
"""
from __future__ import annotations

import logging
import threading
from pathlib import Path

from ..database import DATA_DIR, SessionLocal
from ..models import Episode
from ..qiniu_storage import QiniuConfig, upload_file

logger = logging.getLogger(__name__)

_inflight: set[str] = set()
_lock = threading.Lock()


def schedule_qiniu_backfill(video_id: str) -> None:
    """排队把该视频的本地媒体转存七牛；同一视频并发去重。"""
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


def _find(media_dir: Path, stem: str) -> Path | None:
    candidates = sorted(p for p in media_dir.glob(f"{stem}.*") if p.is_file())
    return candidates[0] if candidates else None


def _backfill(video_id: str) -> None:
    try:
        media_dir = DATA_DIR / "media" / video_id
        if not media_dir.is_dir():
            return
        video = _find(media_dir, "video")
        if not video:
            return
        try:
            cfg = QiniuConfig.from_env()
        except RuntimeError as exc:
            logger.warning("七牛未配置，跳过转存 %s：%s", video_id, exc)
            return

        _set_status(video_id, "processing")
        video_url = upload_file(cfg, video, cfg.object_key(video_id, video.name))
        audio = _find(media_dir, "audio")
        audio_url = upload_file(cfg, audio, cfg.object_key(video_id, audio.name)) if audio else ""
        cover = _find(media_dir, "cover")
        cover_url = upload_file(cfg, cover, cfg.object_key(video_id, cover.name)) if cover else ""

        db = SessionLocal()
        try:
            ep = db.query(Episode).filter(Episode.video_id == video_id).first()
            if not ep:
                return
            ep.video_url = video_url
            if audio_url:
                ep.audio_url = audio_url
            if cover_url:
                ep.cover = cover_url
                ep.thumbnail_url = cover_url
            ep.media_transfer_status = "ready"
            ep.media_transfer_error = ""
            db.commit()
        finally:
            db.close()

        # 播放已切到七牛 CDN，删除本地大文件省空间（保留 cover 兜底）
        for p in list(media_dir.glob("video.*")) + list(media_dir.glob("audio.*")):
            try:
                p.unlink(missing_ok=True)
            except OSError:
                pass
        logger.info("转存七牛完成 %s -> %s", video_id, video_url)
    except Exception as exc:  # noqa: BLE001
        logger.warning("转存七牛失败 %s", video_id, exc_info=True)
        _set_status(video_id, "failed", str(exc))
    finally:
        with _lock:
            _inflight.discard(video_id)
