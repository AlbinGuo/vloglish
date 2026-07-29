"""文章段落 TTS 生成并上传七牛。"""

from __future__ import annotations

import logging
import os
import tempfile
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

from sqlalchemy.orm import Session

from ..models import Article, ArticleSegment
from ..qiniu_storage import QiniuConfig, upload_file
from .tts_common import audio_file_suffix, estimate_duration_ms
from .tts_provider import synthesize_speech, tts_configured

logger = logging.getLogger(__name__)

# 每轮最多处理段数；线程池并行合成，避免单次 HTTP 过久
DEFAULT_MAX_SEGMENTS = 8
DEFAULT_WORKERS = 3


def article_segment_audio_key(cfg: QiniuConfig, article_id: str, index: int, suffix: str = ".mp3") -> str:
    ext = suffix if suffix.startswith(".") else f".{suffix}"
    return cfg.object_key("reading", article_id, f"seg_{index:04d}{ext}")


def _segment_needs_tts(segment: ArticleSegment, *, force: bool) -> bool:
    if force:
        return bool((segment.english or "").strip())
    return bool((segment.english or "").strip()) and not (segment.audio_url or "").strip()


def _synthesize_and_upload(
    *,
    english: str,
    article_public_id: str,
    index: int,
    qiniu: QiniuConfig,
    voice: str | None,
) -> tuple[str, int]:
    """Run TTS + Qiniu upload off the DB session (safe for worker threads)."""
    audio_bytes = synthesize_speech(english, voice=voice)
    suffix = audio_file_suffix(audio_bytes)
    with tempfile.NamedTemporaryFile(suffix=suffix, delete=False) as tmp:
        tmp.write(audio_bytes)
        tmp_path = Path(tmp.name)
    try:
        key = article_segment_audio_key(qiniu, article_public_id, index, suffix)
        url = upload_file(qiniu, tmp_path, key)
        duration_ms = estimate_duration_ms(english)
        return url, duration_ms
    finally:
        tmp_path.unlink(missing_ok=True)


def generate_segment_tts(
    db: Session,
    segment: ArticleSegment,
    article_public_id: str,
    *,
    qiniu: QiniuConfig,
    voice: str | None = None,
) -> tuple[bool, str | None]:
    try:
        url, duration_ms = _synthesize_and_upload(
            english=segment.english,
            article_public_id=article_public_id,
            index=segment.index,
            qiniu=qiniu,
            voice=voice,
        )
        segment.audio_url = url
        segment.duration_ms = duration_ms
        db.commit()
        return True, None
    except Exception as exc:
        logger.exception("segment TTS failed article=%s index=%s", article_public_id, segment.index)
        try:
            db.rollback()
        except Exception:
            pass
        return False, str(exc)


def generate_article_tts(
    db: Session,
    article: Article,
    *,
    voice: str | None = None,
    max_segments: int = DEFAULT_MAX_SEGMENTS,
    skip_existing: bool = True,
    force: bool = False,
    workers: int = DEFAULT_WORKERS,
) -> dict:
    """Generate TTS for a limited number of pending segments per request.

    Returns done/remaining so the admin UI can loop until finished.
    """
    if not tts_configured():
        provider = os.getenv("TTS_PROVIDER", "qwen").strip().lower() or "qwen"
        if provider == "azure":
            raise RuntimeError("未配置 AZURE_SPEECH_KEY，无法生成 TTS")
        raise RuntimeError("未配置 DASHSCOPE_API_KEY，无法生成 TTS")

    from .qwen_dashscope_tts import resolve_qwen_voice

    selected_voice = resolve_qwen_voice(voice)
    force_all = bool(force)

    segments = sorted(article.segments, key=lambda s: s.index)
    if not segments:
        raise ValueError("文章无段落")

    # 强制重生成：先清空已有音频，后续轮次用 skip_existing 续跑即可
    if force_all:
        changed = False
        for seg in segments:
            if (seg.english or "").strip() and (seg.audio_url or "").strip():
                seg.audio_url = ""
                seg.duration_ms = 0
                changed = True
        if changed:
            db.commit()

    pending = [s for s in segments if _segment_needs_tts(s, force=False)]
    total = len(segments)
    already_ready = total - len(pending)

    if not pending:
        article.tts_status = "ready"
        db.commit()
        return {
            "generated": 0,
            "failed": 0,
            "total": total,
            "tts_status": article.tts_status,
            "error_sample": "",
            "voice": selected_voice,
            "done": True,
            "remaining": 0,
            "skipped": already_ready,
            "processed": 0,
        }

    budget = max(1, int(max_segments or DEFAULT_MAX_SEGMENTS))
    chunk = pending[:budget]
    worker_n = max(1, min(int(workers or DEFAULT_WORKERS), len(chunk)))

    qiniu = QiniuConfig.from_env()
    article.tts_status = "pending"
    db.commit()

    # Capture plain fields for worker threads (no ORM objects across threads)
    jobs = [
        {
            "id": seg.id,
            "index": seg.index,
            "english": seg.english or "",
        }
        for seg in chunk
    ]

    ok = 0
    failed = 0
    error_sample = ""
    results: dict[int, tuple[str, int] | str] = {}

    def _job(item: dict) -> tuple[int, tuple[str, int] | str]:
        try:
            url, duration_ms = _synthesize_and_upload(
                english=item["english"],
                article_public_id=article.article_id,
                index=item["index"],
                qiniu=qiniu,
                voice=selected_voice,
            )
            return item["id"], (url, duration_ms)
        except Exception as exc:
            logger.exception(
                "segment TTS failed article=%s index=%s",
                article.article_id,
                item["index"],
            )
            return item["id"], str(exc)

    with ThreadPoolExecutor(max_workers=worker_n) as pool:
        futures = [pool.submit(_job, item) for item in jobs]
        for fut in as_completed(futures):
            seg_id, payload = fut.result()
            results[seg_id] = payload

    # Apply DB updates on the request thread
    for seg in chunk:
        payload = results.get(seg.id)
        if payload is None:
            failed += 1
            if not error_sample:
                error_sample = f"第 {seg.index + 1} 段: 未知错误"
            continue
        if isinstance(payload, str):
            failed += 1
            if not error_sample:
                error_sample = f"第 {seg.index + 1} 段: {payload}"
            continue
        url, duration_ms = payload
        seg.audio_url = url
        seg.duration_ms = duration_ms
        ok += 1

    db.commit()

    segments = (
        db.query(ArticleSegment)
        .filter(ArticleSegment.article_id == article.id)
        .order_by(ArticleSegment.index)
        .all()
    )
    missing = sum(1 for s in segments if (s.english or "").strip() and not (s.audio_url or "").strip())
    with_audio = sum(1 for s in segments if (s.audio_url or "").strip())

    if missing == 0 and with_audio > 0:
        article.tts_status = "ready"
    elif with_audio == 0:
        article.tts_status = "failed"
    else:
        article.tts_status = "partial"
    db.commit()

    return {
        "generated": ok,
        "failed": failed,
        "total": total,
        "tts_status": article.tts_status,
        "error_sample": error_sample,
        "voice": selected_voice,
        "done": missing == 0,
        "remaining": missing,
        "skipped": already_ready,
        "processed": len(chunk),
    }
