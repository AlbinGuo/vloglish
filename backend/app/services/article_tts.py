"""文章段落 TTS 生成并上传七牛。"""

from __future__ import annotations

import logging
import os
import tempfile
from pathlib import Path

from sqlalchemy.orm import Session

from ..models import Article, ArticleSegment
from ..qiniu_storage import QiniuConfig, upload_file
from .tts_common import audio_file_suffix, estimate_duration_ms
from .tts_provider import synthesize_speech, tts_configured

logger = logging.getLogger(__name__)


def article_segment_audio_key(cfg: QiniuConfig, article_id: str, index: int, suffix: str = ".mp3") -> str:
    ext = suffix if suffix.startswith(".") else f".{suffix}"
    return cfg.object_key("reading", article_id, f"seg_{index:04d}{ext}")


def generate_segment_tts(
    db: Session,
    segment: ArticleSegment,
    article_public_id: str,
    *,
    qiniu: QiniuConfig,
) -> tuple[bool, str | None]:
    try:
        audio_bytes = synthesize_speech(segment.english)
        suffix = audio_file_suffix(audio_bytes)
        with tempfile.NamedTemporaryFile(suffix=suffix, delete=False) as tmp:
            tmp.write(audio_bytes)
            tmp_path = Path(tmp.name)
        try:
            key = article_segment_audio_key(qiniu, article_public_id, segment.index, suffix)
            url = upload_file(qiniu, tmp_path, key)
            segment.audio_url = url
            segment.duration_ms = estimate_duration_ms(segment.english)
            db.commit()
            return True, None
        finally:
            tmp_path.unlink(missing_ok=True)
    except Exception as exc:
        logger.exception("segment TTS failed article=%s index=%s", article_public_id, segment.index)
        return False, str(exc)


def generate_article_tts(db: Session, article: Article) -> dict:
    if not tts_configured():
        provider = os.getenv("TTS_PROVIDER", "qwen").strip().lower() or "qwen"
        if provider == "azure":
            raise RuntimeError("未配置 AZURE_SPEECH_KEY，无法生成 TTS")
        raise RuntimeError("未配置 DASHSCOPE_API_KEY，无法生成 TTS")

    segments = sorted(article.segments, key=lambda s: s.index)
    if not segments:
        raise ValueError("文章无段落")

    qiniu = QiniuConfig.from_env()
    article.tts_status = "pending"
    db.commit()

    ok = 0
    failed = 0
    error_sample = ""
    for seg in segments:
        success, err = generate_segment_tts(db, seg, article.article_id, qiniu=qiniu)
        if success:
            ok += 1
        else:
            failed += 1
            if err and not error_sample:
                error_sample = f"第 {seg.index + 1} 段: {err}"

    total = len(segments)
    if ok == 0:
        article.tts_status = "failed"
    elif failed > 0:
        article.tts_status = "partial"
    else:
        article.tts_status = "ready"
    db.commit()

    return {
        "generated": ok,
        "failed": failed,
        "total": total,
        "tts_status": article.tts_status,
        "error_sample": error_sample,
    }
