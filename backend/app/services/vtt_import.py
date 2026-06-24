"""Parse WebVTT and merge cues into sentence-level subtitles."""
from __future__ import annotations

import re
from dataclasses import dataclass


@dataclass
class Cue:
    start: float
    end: float
    text: str


def parse_timestamp(value: str) -> float:
    parts = value.strip().split(":")
    if len(parts) == 3:
        h, m, s = parts
        return int(h) * 3600 + int(m) * 60 + float(s)
    if len(parts) == 2:
        m, s = parts
        return int(m) * 60 + float(s)
    return float(parts[0])


def parse_vtt(content: str) -> list[Cue]:
    cues: list[Cue] = []
    blocks = re.split(r"\n\s*\n", content.strip())
    for block in blocks:
        lines = [ln.strip() for ln in block.splitlines() if ln.strip()]
        if not lines or lines[0].upper() == "WEBVTT" or lines[0].startswith("Kind:") or lines[0].startswith("Language:"):
            continue
        if "-->" not in lines[0]:
            if len(lines) >= 2 and "-->" in lines[1]:
                timing, text_lines = lines[1], lines[2:]
            else:
                continue
        else:
            timing, text_lines = lines[0], lines[1:]
        start_s, end_s = [p.strip() for p in timing.split("-->")]
        text = " ".join(text_lines)
        text = re.sub(r"\s+", " ", text).strip()
        if not text:
            continue
        cues.append(Cue(start=parse_timestamp(start_s), end=parse_timestamp(end_s), text=text))
    return cues


def merge_into_sentences(cues: list[Cue], *, gap_threshold: float = 0.8) -> list[Cue]:
    if not cues:
        return []

    merged: list[Cue] = []
    buf_parts: list[str] = []
    buf_start: float | None = None
    buf_end = 0.0
    sentence_end = re.compile(r'[.!?…]["\')\]]*$')

    for i, cue in enumerate(cues):
        if buf_start is None:
            buf_start = cue.start
        buf_parts.append(cue.text)
        buf_end = cue.end
        text = " ".join(buf_parts).strip()
        next_gap = cues[i + 1].start - cue.end if i + 1 < len(cues) else gap_threshold

        if sentence_end.search(text) or next_gap >= gap_threshold or len(text) >= 100:
            merged.append(Cue(start=buf_start, end=buf_end, text=text))
            buf_parts = []
            buf_start = None

    return merged


def words_to_html(text: str) -> str:
    return " ".join(f"<span>{word}</span>" for word in re.findall(r"\S+", text))


def vtt_to_subtitle_dicts(vtt_text: str) -> list[dict]:
    cues = parse_vtt(vtt_text)
    sentences = merge_into_sentences(cues)
    subtitles: list[dict] = []
    for i, cue in enumerate(sentences):
        subtitles.append(
            {
                "index": i,
                "start": round(cue.start, 3),
                "end": round(cue.end, 3),
                "english": cue.text,
                "chinese": "",
                "ipa": "",
                "english_html": words_to_html(cue.text),
            }
        )
    return subtitles
