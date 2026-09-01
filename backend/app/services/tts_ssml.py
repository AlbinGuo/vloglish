"""按字幕时间窗生成 CosyVoice SSML（语速 + 标点停顿）。"""

from __future__ import annotations

import re
import xml.sax.saxutils as xml

from .tts_common import normalize_tts_text

_PUNCT_SPLIT = re.compile(r"([,.;:?!，。；：？！…]+)")
_WORD_RE = re.compile(r"[A-Za-z0-9']+")
# 英文约 2.8 词/秒
_WPS = 2.8


def _word_count(text: str) -> int:
    words = _WORD_RE.findall(text)
    if words:
        return len(words)
    stripped = re.sub(r"\s+", "", text)
    return max(len(stripped) // 2, 1)


def _natural_sec(text: str) -> float:
    return max(_word_count(text) / _WPS, 0.35)


def build_subtitle_ssml(text: str, duration_ms: int | None) -> str:
    cleaned = normalize_tts_text(text)
    if duration_ms is None or duration_ms <= 0:
        return f"<speak>{xml.escape(cleaned)}</speak>"

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

    n_breaks = sum(1 for idx, (body, punct) in enumerate(phrases) if punct and idx < len(phrases) - 1)
    target_sec = max(duration_ms / 1000.0, 0.2)
    natural = _natural_sec(cleaned)

    break_budget = min(target_sec * 0.28, n_breaks * 0.18) if n_breaks else 0.0
    per_break_ms = int(round(break_budget / n_breaks * 1000)) if n_breaks else 0
    per_break_ms = max(50, min(280, per_break_ms)) if n_breaks else 0

    speech_target = max(target_sec - (per_break_ms * n_breaks / 1000.0), 0.2)
    rate = max(0.5, min(2.0, natural / speech_target))
    rate_s = f"{rate:.2f}"

    parts: list[str] = []
    for idx, (body, punct) in enumerate(phrases):
        if body:
            parts.append(xml.escape(body))
        if punct:
            parts.append(xml.escape(punct))
            if idx < len(phrases) - 1 and per_break_ms:
                parts.append(f'<break time="{per_break_ms}ms"/>')

    return f'<speak rate="{rate_s}">{"".join(parts)}</speak>'
