"""跟读/单词打分示范音：Qwen TTS + 本地磁盘缓存。"""

from __future__ import annotations

import hashlib
from pathlib import Path

from fastapi import HTTPException

from ..database import DATA_DIR
from .qwen_dashscope_tts import QWEN_ARTICLE_VOICES, resolve_qwen_voice
from .tts_common import normalize_tts_text
from .tts_provider import synthesize_speech, tts_configured

CACHE_DIR = DATA_DIR / "tts_cache"
MAX_WORD_CHARS = 80
MAX_SENTENCE_CHARS = 500
# 与读报篇章评测前端拼接上限对齐
MAX_PASSAGE_CHARS = 1200


def practice_tts_ready() -> bool:
    return tts_configured()


def _max_chars(mode: str) -> int:
    m = (mode or "").strip().lower()
    if m == "word":
        return MAX_WORD_CHARS
    if m == "passage":
        return MAX_PASSAGE_CHARS
    return MAX_SENTENCE_CHARS


def _cache_path(voice: str, text: str) -> Path:
    key = hashlib.sha1(f"{voice}\n{text}".encode("utf-8")).hexdigest()
    return CACHE_DIR / f"{key}.mp3"


def synthesize_practice_tts(*, text: str, voice: str, mode: str = "sentence") -> tuple[bytes, bool]:
    """返回 (audio_bytes, cache_hit)。cache_hit=True 时未调用百炼。"""
    if not practice_tts_ready():
        raise HTTPException(status_code=503, detail="示范 TTS 未配置")

    raw = (text or "").strip()
    if not raw:
        raise HTTPException(status_code=400, detail="示范文本为空")
    limit = _max_chars(mode)
    if len(raw) > limit:
        raise HTTPException(status_code=400, detail=f"示范文本过长（最多 {limit} 字）")

    try:
        cleaned = normalize_tts_text(raw)
        voice_name = resolve_qwen_voice(voice)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc

    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    path = _cache_path(voice_name, cleaned)
    if path.is_file() and path.stat().st_size > 0:
        return path.read_bytes(), True

    try:
        audio = synthesize_speech(cleaned, voice=voice_name)
    except RuntimeError as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc

    if not audio:
        raise HTTPException(status_code=502, detail="TTS 返回空音频")

    tmp = path.with_suffix(".tmp")
    tmp.write_bytes(audio)
    tmp.replace(path)
    return audio, False


def list_practice_voices() -> list[str]:
    return list(QWEN_ARTICLE_VOICES)
