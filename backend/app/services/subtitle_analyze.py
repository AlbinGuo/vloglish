"""Analyze subtitles for difficulty, vocabulary size, and highlight HTML via DeepSeek."""
from __future__ import annotations

import re

from ..dict.deepseek import analyze_episode_metrics_with_deepseek, annotate_subtitle_lines_with_deepseek
from .vtt_import import words_to_html

VALID_HIGHLIGHTS = frozenset({"a", "d", "i", "c", "l", "f"})
ANNOTATE_BATCH_SIZE = 8


class _HighlightIdGen:
    def __init__(self) -> None:
        self._tid = 50_000
        self._pid = 500

    def next_tid(self) -> int:
        self._tid += 1
        return self._tid

    def next_pid(self) -> int:
        self._pid += 1
        return self._pid


def _normalize_highlight(value: object) -> str | None:
    if value is None:
        return None
    text = str(value).strip().lower()
    if not text or text == "null":
        return None
    return text if text in VALID_HIGHLIGHTS else "a"


def tokens_to_english_html(tokens: list[dict], ids: _HighlightIdGen) -> str:
    parts: list[str] = []
    for token in tokens:
        if not isinstance(token, dict):
            continue
        text = str(token.get("text", "")).strip()
        if not text:
            continue
        highlight = _normalize_highlight(token.get("highlight"))
        is_phrase = bool(token.get("phrase"))
        if highlight and is_phrase:
            parts.append(f'<span pid="{ids.next_pid()}" class="highlight highlight-{highlight}">{text}</span>')
        elif highlight:
            parts.append(f'<span tid="{ids.next_tid()}" class="highlight highlight-{highlight}">{text}</span>')
        else:
            parts.append(f"<span>{text}</span>")
    return "".join(parts)


def _token_texts(tokens: list[dict]) -> str:
    return " ".join(str(t.get("text", "")).strip() for t in tokens if isinstance(t, dict) and str(t.get("text", "")).strip())


def _tokens_usable(tokens: list[dict], english: str) -> bool:
    if not tokens:
        return False
    joined = _token_texts(tokens)
    if not joined:
        return False
    normalized_english = re.sub(r"\s+", " ", english.strip())
    if joined == normalized_english:
        return True
    return joined.replace(" ", "") == normalized_english.replace(" ", "")


def analyze_subtitles_with_deepseek(
    subtitles: list[dict],
    *,
    clip_length: float | None = None,
    batch_size: int = ANNOTATE_BATCH_SIZE,
) -> dict[str, int]:
    """Fill english_html highlights; return episode stars, voca_size, highlight_count."""
    pending: list[tuple[int, str]] = []
    for i, row in enumerate(subtitles):
        english = (row.get("english") or "").strip()
        if english:
            pending.append((i, english))

    if not pending:
        return {"stars": 3, "voca_size": 0, "highlight_count": 0}

    english_lines = [text for _, text in pending]
    metrics = analyze_episode_metrics_with_deepseek(english_lines, clip_length=clip_length)

    id_gen = _HighlightIdGen()
    highlight_count = 0

    for offset in range(0, len(pending), batch_size):
        chunk = pending[offset : offset + batch_size]
        chunk_lines = [text for _, text in chunk]
        items = annotate_subtitle_lines_with_deepseek(chunk_lines)
        for (idx, english), item in zip(chunk, items):
            tokens = item.get("tokens") or []
            if not isinstance(tokens, list):
                continue
            if _tokens_usable(tokens, english):
                html = tokens_to_english_html(tokens, id_gen)
            else:
                html = words_to_html(english).replace(" ", "")
            if html:
                subtitles[idx]["english_html"] = html
            highlight_count += sum(
                1 for t in tokens if isinstance(t, dict) and _normalize_highlight(t.get("highlight"))
            )

    return {
        "stars": metrics["stars"],
        "voca_size": metrics["voca_size"],
        "highlight_count": highlight_count,
    }
