"""TTS Provider 路由：qwen（DashScope，默认）/ azure。"""

from __future__ import annotations

import os

from . import azure_tts, qwen_dashscope_tts
from .tts_common import estimate_duration_ms, normalize_tts_text

__all__ = ["tts_configured", "synthesize_speech", "estimate_duration_ms", "normalize_tts_text"]


def _provider() -> str:
    return os.getenv("TTS_PROVIDER", "qwen").strip().lower() or "qwen"


def tts_configured() -> bool:
    provider = _provider()
    if provider == "azure":
        return azure_tts.azure_tts_configured()
    return qwen_dashscope_tts.qwen_tts_configured()


def synthesize_speech(text: str, *, voice: str | None = None) -> bytes:
    provider = _provider()
    if provider == "azure":
        return azure_tts.synthesize_speech(text)
    if provider == "qwen":
        return qwen_dashscope_tts.synthesize_speech(text, voice=voice)
    raise RuntimeError(f"未知 TTS_PROVIDER: {provider}")
