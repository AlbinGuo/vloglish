"""按字幕生成 CosyVoice SSML：保留标点停顿，不按时间窗强行变速。"""

from __future__ import annotations

import re
import xml.sax.saxutils as xml

from .tts_common import normalize_tts_text

_PUNCT_SPLIT = re.compile(r"([,.;:?!，。；：？！…]+)")

# CosyVoice 克隆音色 instruction 上限约 100 字
_INSTR_NATURAL = "Narrate in a natural and friendly chat style with emotion and pauses."
_INSTR_QUESTION = "Speak naturally with a questioning tone, pitch variation, and pauses."
_INSTR_EXCLAIM = "Speak naturally with energy, emotion, pitch variation, and pauses."


def speak_instruction(text: str) -> str:
    """给克隆音色的自然语言指令（情感 / 停顿），不冒充原片表演。"""
    stripped = (text or "").strip()
    if stripped.endswith("?") or stripped.endswith("？"):
        return _INSTR_QUESTION
    if stripped.endswith("!") or stripped.endswith("！"):
        return _INSTR_EXCLAIM
    return _INSTR_NATURAL


def _break_ms(punct: str) -> int:
    if re.search(r"[.?!。？！…]", punct):
        return 280
    if re.search(r"[:;：；]", punct):
        return 200
    return 160


def build_natural_ssml(text: str) -> str:
    """标点处插入短停顿，语速保持默认，避免把韵律拉成匀速。"""
    cleaned = normalize_tts_text(text)
    chunks = _PUNCT_SPLIT.split(cleaned)
    phrases: list[tuple[str, str]] = []
    i = 0
    while i < len(chunks):
        body = chunks[i].strip()
        punct = chunks[i + 1] if i + 1 < len(chunks) else ""
        if body or punct:
            phrases.append((body, punct))
        i += 2
    if not phrases:
        phrases = [(cleaned, "")]

    parts: list[str] = []
    for idx, (body, punct) in enumerate(phrases):
        if body:
            if parts:
                parts.append(" ")
            parts.append(xml.escape(body))
        if punct:
            parts.append(xml.escape(punct))
            if idx < len(phrases) - 1:
                parts.append(f'<break time="{_break_ms(punct)}ms"/>')

    return f"<speak>{''.join(parts)}</speak>"


def build_subtitle_ssml(text: str, duration_ms: int | None = None) -> str:
    """兼容旧调用；duration_ms 不再用于整段变速。"""
    del duration_ms
    return build_natural_ssml(text)
