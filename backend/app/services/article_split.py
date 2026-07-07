from __future__ import annotations

import re

_SENTENCE_END = re.compile(r"(?<=[.!?])\s+")
_SECONDARY_SPLIT = re.compile(r"(?<=[,;—–-])\s+")
_WORDS = re.compile(r"\b[\w'-]+\b")


def _word_count(text: str) -> int:
    return len(_WORDS.findall(text))


def split_into_segments(text: str, *, max_words: int = 25, max_chars: int = 180) -> list[str]:
    text = re.sub(r"\r\n?", "\n", text.strip())
    text = re.sub(r"\n{2,}", "\n\n", text)
    if not text:
        return []

    paragraphs = [p.strip() for p in text.split("\n\n") if p.strip()]
    raw_parts: list[str] = []
    for para in paragraphs:
        raw_parts.extend(_SENTENCE_END.split(para))

    segments: list[str] = []
    for part in raw_parts:
        part = part.strip()
        if not part:
            continue
        if _word_count(part) > max_words or len(part) > max_chars:
            segments.extend(_split_long_part(part, max_words=max_words, max_chars=max_chars))
        else:
            segments.append(part)

    return _merge_short_segments(segments)


def _split_long_part(part: str, *, max_words: int, max_chars: int) -> list[str]:
    chunks = _SECONDARY_SPLIT.split(part)
    if len(chunks) == 1:
        return [part]
    out: list[str] = []
    buf = ""
    for chunk in chunks:
        chunk = chunk.strip()
        if not chunk:
            continue
        candidate = f"{buf} {chunk}".strip() if buf else chunk
        if _word_count(candidate) > max_words or len(candidate) > max_chars:
            if buf:
                out.append(buf)
            buf = chunk
        else:
            buf = candidate
    if buf:
        out.append(buf)
    return out or [part]


def _merge_short_segments(segments: list[str], min_chars: int = 20) -> list[str]:
    if not segments:
        return []
    out: list[str] = []
    buf = ""
    for seg in segments:
        if not buf:
            buf = seg
            continue
        if len(buf) < min_chars:
            buf = f"{buf} {seg}".strip()
        else:
            out.append(buf)
            buf = seg
    if buf:
        if out and len(buf) < min_chars:
            out[-1] = f"{out[-1]} {buf}".strip()
        else:
            out.append(buf)
    return out


def count_words_in_segments(segments: list[str]) -> int:
    return sum(_word_count(s) for s in segments)
