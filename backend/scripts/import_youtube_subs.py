"""Parse WebVTT and merge cues into sentence-level subtitles."""
from __future__ import annotations

import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DATA_MEDIA = ROOT / "data" / "media"


@dataclass
class Cue:
    start: float
    end: float
    text: str


def parse_timestamp(value: str) -> float:
    token = value.strip().split()[0]
    parts = token.split(":")
    if len(parts) == 3:
        h, m, s = parts
        return int(h) * 3600 + int(m) * 60 + float(s)
    if len(parts) == 2:
        m, s = parts
        return int(m) * 60 + float(s)
    return float(parts[0])


def parse_vtt(path: Path) -> list[Cue]:
    content = path.read_text(encoding="utf-8")
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

    if buf_parts and buf_start is not None:
        merged.append(Cue(start=buf_start, end=buf_end, text=" ".join(buf_parts).strip()))

    return merged


def words_to_html(text: str) -> str:
    return " ".join(f"<span>{word}</span>" for word in re.findall(r"\S+", text))


def cues_to_subtitles(cues: list[Cue], *, start_id: int = 90001) -> list[dict]:
    subtitles: list[dict] = []
    for i, cue in enumerate(cues):
        subtitles.append(
            {
                "id": start_id + i,
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


def main() -> None:
    if len(sys.argv) < 2:
        print("Usage: python scripts/import_youtube_subs.py <video_id> [vtt_path]")
        sys.exit(1)

    video_id = sys.argv[1]
    media_dir = DATA_MEDIA / video_id
    vtt_path = Path(sys.argv[2]) if len(sys.argv) > 2 else media_dir / "subs.en-GB.vtt"
    if not vtt_path.is_file():
        raise SystemExit(f"VTT not found: {vtt_path}")

    cues = parse_vtt(vtt_path)
    sentences = merge_into_sentences(cues)
    subtitles = cues_to_subtitles(sentences)

    out = media_dir / "subtitles.json"
    out.write_text(json.dumps(subtitles, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"Parsed {len(cues)} cues -> {len(sentences)} sentences")
    print(f"Saved: {out}")
    if sentences:
        print(f"Duration: {sentences[0].start:.2f}s - {sentences[-1].end:.2f}s")


if __name__ == "__main__":
    main()
