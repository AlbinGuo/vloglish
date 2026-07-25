"""Analyze subtitles for difficulty, vocabulary size, and highlight HTML via DeepSeek."""
from __future__ import annotations

import re

from ..dict.deepseek import analyze_episode_metrics_with_deepseek, annotate_subtitle_lines_with_deepseek
from .vtt_import import words_to_html

VALID_HIGHLIGHTS = frozenset({"a", "d", "i", "c", "l", "f", "p"})
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
    return " ".join(
        str(t.get("text", "")).strip() for t in tokens if isinstance(t, dict) and str(t.get("text", "")).strip()
    )


def _alnum_key(text: str) -> str:
    return re.sub(r"[^a-z0-9]+", "", (text or "").lower())


def _tokens_usable(tokens: list[dict], english: str) -> bool:
    if not tokens:
        return False
    joined = _token_texts(tokens)
    if not joined:
        return False
    normalized_english = re.sub(r"\s+", " ", english.strip())
    if joined == normalized_english:
        return True
    if joined.replace(" ", "") == normalized_english.replace(" ", ""):
        return True
    # 标点/弯引号等轻微差异时仍采用 AI token，避免丢掉高亮
    ka, kb = _alnum_key(joined), _alnum_key(normalized_english)
    if not ka or not kb:
        return False
    if ka == kb:
        return True
    longer = max(len(ka), len(kb))
    shorter = min(len(ka), len(kb))
    if longer == 0:
        return False
    return shorter / longer >= 0.9 and (ka in kb or kb in ka)


def _count_token_highlights(tokens: list[dict]) -> int:
    return sum(1 for t in tokens if isinstance(t, dict) and _normalize_highlight(t.get("highlight")))


def analyze_subtitles_with_deepseek(
    subtitles: list[dict],
    *,
    clip_length: float | None = None,
    batch_size: int = ANNOTATE_BATCH_SIZE,
    translation_brief: dict | None = None,
) -> dict[str, int]:
    """Fill english_html highlights; return episode stars, voca_size, highlight_count."""
    pending: list[tuple[int, str]] = []
    for i, row in enumerate(subtitles):
        english = (row.get("english") or "").strip()
        if english:
            pending.append((i, english))

    if not pending:
        return {"stars": 3, "voca_size": 0, "highlight_count": 0, "annotate_failed": 0}

    english_lines = [text for _, text in pending]
    try:
        metrics = analyze_episode_metrics_with_deepseek(english_lines, clip_length=clip_length)
    except Exception:
        metrics = {"stars": 3, "voca_size": 0}

    id_gen = _HighlightIdGen()
    highlight_count = 0
    annotate_failed = 0

    for offset in range(0, len(pending), batch_size):
        chunk = pending[offset : offset + batch_size]
        chunk_lines = [text for _, text in chunk]
        try:
            items = annotate_subtitle_lines_with_deepseek(
                chunk_lines,
                translation_brief=translation_brief,
            )
        except Exception:
            annotate_failed += len(chunk)
            for idx, english in chunk:
                if not (subtitles[idx].get("english_html") or "").strip():
                    subtitles[idx]["english_html"] = words_to_html(english).replace(" ", "")
            continue

        for (idx, english), item in zip(chunk, items):
            tokens = item.get("tokens") or []
            if not isinstance(tokens, list):
                tokens = []
            hl_n = _count_token_highlights(tokens)
            if _tokens_usable(tokens, english):
                html = tokens_to_english_html(tokens, id_gen)
                highlight_count += hl_n
            else:
                # token 对不齐时仍尽量保留已有高亮；完全不可用才回退
                if hl_n > 0 and _token_texts(tokens):
                    html = tokens_to_english_html(tokens, id_gen)
                    highlight_count += hl_n
                else:
                    html = words_to_html(english).replace(" ", "")
                    annotate_failed += 1
            if html:
                subtitles[idx]["english_html"] = html

    return {
        "stars": metrics["stars"],
        "voca_size": metrics["voca_size"],
        "highlight_count": highlight_count,
        "annotate_failed": annotate_failed,
    }
