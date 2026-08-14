"""Parse WebVTT / SRT. SRT keeps cue boundaries; VTT may merge into sentences."""
from __future__ import annotations

import html as html_lib
import re
from dataclasses import dataclass


@dataclass
class Cue:
    start: float
    end: float
    english: str
    chinese: str = ""


_CJK_RE = re.compile(r"[\u4e00-\u9fff\u3400-\u4dbf\uf900-\ufaff]")
# YouTube auto-caption inline timing: <00:00:07.109> and word markers <c> </c>
_YT_INLINE_TAG_RE = re.compile(
    r"<\d{1,2}:\d{2}:\d{2}\.\d{3}>|"
    r"<\d{1,2}:\d{2}\.\d{3}>|"
    r"</?c>"
)


def strip_youtube_inline_tags(text: str) -> str:
    if not text:
        return ""
    cleaned = _YT_INLINE_TAG_RE.sub("", text)
    return re.sub(r"\s+", " ", cleaned).strip()


def strip_speaker_markers(text: str) -> str:
    """Remove interview-style speaker markers like >> from plain subtitle text."""
    if not text:
        return ""
    cleaned = text.replace(">>", "")
    return re.sub(r"\s+", " ", cleaned).strip()


def strip_speaker_markers_html(html: str) -> str:
    """Remove >> markers from tokenized english_html."""
    if not html:
        return ""
    result = html.strip()
    result = re.sub(r"(?:<span>\s*>+\s*</span>\s*)+", "", result, flags=re.I)
    result = re.sub(r"^\s*>>+\s*", "", result)
    return result.strip()


def english_html_to_plain(html: str) -> str:
    """Strip highlight/token spans so we can compare with plain english."""
    if not html:
        return ""
    text = re.sub(r"<[^>]+>", " ", html)
    text = html_lib.unescape(text)
    return re.sub(r"\s+", " ", text).strip()


def _plain_text_key(text: str) -> str:
    """大小写不敏感、空白归一后的比对键。"""
    return re.sub(r"\s+", " ", (text or "").strip()).casefold()


def _html_has_vocab_markup(html: str) -> bool:
    h = html or ""
    return "highlight-" in h or "data-gloss=" in h or 'tid="' in h or 'pid="' in h


def normalize_subtitle_fields(
    english: str,
    chinese: str = "",
    english_html: str = "",
) -> tuple[str, str, str]:
    english = strip_speaker_markers(strip_youtube_inline_tags(english))
    chinese = strip_speaker_markers(chinese)
    html = strip_speaker_markers_html(english_html)

    if not english and not html:
        return "", chinese, ""
    if not english and html:
        return english_html_to_plain(html), chinese, html
    if not html:
        return english, chinese, words_to_html(english)

    plain_from_html = english_html_to_plain(html)
    # 明文与 html 抽文本一致（忽略大小写/多余空白）：保留高亮 html
    if _plain_text_key(plain_from_html) == _plain_text_key(english):
        # 以 html 抽文本为准，避免 I'm / i'm 这类差异再次触发重建
        return plain_from_html or english, chinese, html

    # 已有词汇高亮/标注时：以 html 为准同步 english，禁止用纯文本重建抹掉高亮
    # （外部 JSON 导入常见：english 全小写，english_html 含专有名词大小写）
    if _html_has_vocab_markup(html):
        return plain_from_html, chinese, html

    # 管理端只改了 english、旧 html 无高亮：按 english 重建 span
    return english, chinese, words_to_html(english)


def contains_cjk(text: str) -> bool:
    return bool(_CJK_RE.search(text))


def split_bilingual_lines(text_lines: list[str]) -> tuple[str, str]:
    english_parts: list[str] = []
    chinese_parts: list[str] = []
    for line in text_lines:
        line = re.sub(r"\s+", " ", line.strip())
        if not line:
            continue
        if contains_cjk(line):
            chinese_parts.append(line)
        else:
            english_parts.append(line)
    english = strip_speaker_markers(strip_youtube_inline_tags(" ".join(english_parts)))
    chinese = strip_speaker_markers(" ".join(chinese_parts).strip())
    return english, chinese


def parse_timestamp(value: str) -> float:
    # YouTube VTT often appends cue settings after the timestamp, e.g.
    # "00:00:11.509 align:start position:0%" — take the time token only.
    token = value.strip().split()[0]
    token = token.replace(",", ".")
    parts = token.split(":")
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
        english, chinese = split_bilingual_lines(text_lines)
        if not english and not chinese:
            continue
        if not english and chinese:
            english, chinese = chinese, ""
        cues.append(
            Cue(
                start=parse_timestamp(start_s),
                end=parse_timestamp(end_s),
                english=english,
                chinese=chinese,
            )
        )
    return cues


# 毫秒可选；兼容 00:00:01 / 00:00:01,0 / 00:00:01,000 / 00:00:01.000
_SRT_TIMING_RE = re.compile(
    r"^(\d{1,2}:\d{2}:\d{2}(?:[,\.]\d{1,3})?)\s*-->\s*(\d{1,2}:\d{2}:\d{2}(?:[,\.]\d{1,3})?).*(?:\n|$)",
    re.MULTILINE,
)


def _normalize_subtitle_newlines(content: str) -> str:
    text = content.lstrip("\ufeff")
    # UTF-16 误读为 UTF-8 时常见大量 NUL；去掉后时间轴才可能匹配
    if "\x00" in text:
        text = text.replace("\x00", "")
    # 全角冒号 / 特殊箭头 → 标准 SRT
    text = text.replace("：", ":").replace("→", "-->").replace("➜", "-->")
    return text.replace("\r\n", "\n").replace("\r", "\n").strip()


def _cue_from_timing_and_lines(start_s: str, end_s: str, text_lines: list[str]) -> Cue | None:
    english, chinese = split_bilingual_lines(text_lines)
    if not english and not chinese:
        return None
    if not english and chinese:
        english, chinese = chinese, ""
    try:
        start = parse_timestamp(start_s)
        end = parse_timestamp(end_s)
    except (ValueError, IndexError):
        return None
    if end < start:
        end = start
    return Cue(start=start, end=end, english=english, chinese=chinese)


def parse_srt(content: str) -> list[Cue]:
    """Parse SubRip (.srt) subtitles."""
    cues: list[Cue] = []
    normalized = _normalize_subtitle_newlines(content)
    if not normalized:
        return cues

    matches = list(_SRT_TIMING_RE.finditer(normalized))
    if matches:
        for i, match in enumerate(matches):
            start_s, end_s = match.group(1), match.group(2)
            text_start = match.end()
            text_end = matches[i + 1].start() if i + 1 < len(matches) else len(normalized)
            text_lines: list[str] = []
            for line in normalized[text_start:text_end].split("\n"):
                line = line.strip()
                if not line or re.fullmatch(r"\d+", line):
                    continue
                text_lines.append(line)
            cue = _cue_from_timing_and_lines(start_s, end_s, text_lines)
            if cue:
                cues.append(cue)
        return cues

    # Fallback for unusual exports that still use blank-line blocks.
    for block in re.split(r"\n\s*\n", normalized):
        lines = [ln.strip() for ln in block.splitlines() if ln.strip()]
        if len(lines) < 2:
            continue
        timing_idx = next((i for i, ln in enumerate(lines) if "-->" in ln), None)
        if timing_idx is None:
            continue
        timing = lines[timing_idx]
        text_lines = lines[timing_idx + 1 :]
        start_s, end_s = [p.strip() for p in timing.split("-->", 1)]
        cue = _cue_from_timing_and_lines(start_s, end_s, text_lines)
        if cue:
            cues.append(cue)
    return cues


def merge_into_sentences(cues: list[Cue], *, gap_threshold: float = 0.55) -> list[Cue]:
    if not cues:
        return []

    merged: list[Cue] = []
    buf_eng: list[str] = []
    buf_zh: list[str] = []
    buf_start: float | None = None
    buf_end = 0.0
    sentence_end = re.compile(r'[.!?…]["\')\]]*$')

    for i, cue in enumerate(cues):
        if buf_start is None:
            buf_start = cue.start
        if cue.english:
            buf_eng.append(cue.english)
        if cue.chinese:
            buf_zh.append(cue.chinese)
        buf_end = cue.end
        english = " ".join(buf_eng).strip()
        next_gap = cues[i + 1].start - cue.end if i + 1 < len(cues) else gap_threshold

        if sentence_end.search(english) or next_gap >= gap_threshold or len(english) >= 100:
            merged.append(
                Cue(
                    start=buf_start,
                    end=buf_end,
                    english=english,
                    chinese=" ".join(buf_zh).strip(),
                )
            )
            buf_eng = []
            buf_zh = []
            buf_start = None

    if buf_eng and buf_start is not None:
        merged.append(
            Cue(
                start=buf_start,
                end=buf_end,
                english=" ".join(buf_eng).strip(),
                chinese=" ".join(buf_zh).strip(),
            )
        )

    return merged


def words_to_html(text: str) -> str:
    cleaned = strip_youtube_inline_tags(text)
    return " ".join(f"<span>{word}</span>" for word in re.findall(r"\S+", cleaned))


def vtt_to_subtitle_dicts(vtt_text: str, *, merge_sentences: bool = True) -> list[dict]:
    cues = parse_vtt(vtt_text)
    return _cues_to_subtitle_dicts(cues, merge_sentences=merge_sentences)


def srt_to_subtitle_dicts(srt_text: str, *, merge_sentences: bool = False) -> list[dict]:
    """SRT 默认严格按文件条目分段，不合并多条 cue。"""
    cues = parse_srt(srt_text)
    return _cues_to_subtitle_dicts(cues, merge_sentences=merge_sentences)


_EMPTY_ZH = frozenset({"-", "—", "–", "n/a", "na", "none", "null"})


def parse_loose_start_time(value: str) -> float | None:
    """14s / 1:01 / 1:46:05 → 秒。"""
    token = (value or "").strip().lower()
    if not token:
        return None
    if token.endswith("s") and ":" not in token:
        try:
            return float(token[:-1].replace(",", "."))
        except ValueError:
            return None
    try:
        return parse_timestamp(token)
    except (ValueError, IndexError, TypeError):
        return None


def _split_tsv_row(line: str) -> list[str]:
    if "\t" in line:
        return line.split("\t")
    return []


def _is_timed_tsv_header(line: str) -> bool:
    cols = [c.strip().lower() for c in _split_tsv_row(line)]
    if not cols:
        return False
    joined = " ".join(cols)
    return cols[0] in {"time", "timestamp", "start", "timecode"} and (
        "subtitle" in joined or "translation" in joined or len(cols) >= 2
    )


def looks_like_timed_tsv(text: str) -> bool:
    lines = [ln for ln in _normalize_subtitle_newlines(text).split("\n") if ln.strip()]
    if not lines:
        return False
    if _is_timed_tsv_header(lines[0]):
        return True
    hits = 0
    for ln in lines[:40]:
        parts = _split_tsv_row(ln)
        if len(parts) >= 2 and parse_loose_start_time(parts[0]) is not None:
            hits += 1
    return hits >= 3


def parse_timed_tsv(content: str) -> list[Cue]:
    """YouTube / 工具导出：Time \\t Subtitle \\t Machine Translation。只有起点，终点取下一条。"""
    lines = [ln for ln in _normalize_subtitle_newlines(content).split("\n") if ln.strip()]
    if lines and _is_timed_tsv_header(lines[0]):
        lines = lines[1:]

    raw: list[tuple[float, str, str]] = []
    for ln in lines:
        parts = _split_tsv_row(ln)
        if len(parts) < 2:
            continue
        start = parse_loose_start_time(parts[0])
        if start is None:
            continue
        english = strip_speaker_markers(strip_youtube_inline_tags((parts[1] or "").strip()))
        chinese = (parts[2] or "").strip() if len(parts) >= 3 else ""
        if chinese.lower() in _EMPTY_ZH:
            chinese = ""
        chinese = strip_speaker_markers(chinese)
        if not english and not chinese:
            continue
        if not english and chinese:
            english, chinese = chinese, ""
        raw.append((start, english, chinese))

    cues: list[Cue] = []
    for i, (start, english, chinese) in enumerate(raw):
        end = raw[i + 1][0] if i + 1 < len(raw) else start + 3.0
        if end <= start:
            end = start + 1.0
        cues.append(Cue(start=start, end=end, english=english, chinese=chinese))
    return cues


def timed_tsv_to_subtitle_dicts(text: str, *, merge_sentences: bool = False) -> list[dict]:
    return _cues_to_subtitle_dicts(parse_timed_tsv(text), merge_sentences=merge_sentences)


def subtitle_text_to_dicts(text: str, *, merge_sentences: bool | None = None) -> list[dict]:
    stripped = text.lstrip("\ufeff").strip()
    if stripped.upper().startswith("WEBVTT"):
        # YouTube 等自动字幕仍默认按句合并；手动导入时可关掉
        return vtt_to_subtitle_dicts(
            text,
            merge_sentences=True if merge_sentences is None else merge_sentences,
        )
    if looks_like_timed_tsv(stripped):
        return timed_tsv_to_subtitle_dicts(
            text,
            merge_sentences=False if merge_sentences is None else merge_sentences,
        )
    srt_rows = srt_to_subtitle_dicts(
        text,
        merge_sentences=False if merge_sentences is None else merge_sentences,
    )
    if srt_rows:
        return srt_rows
    # Some tools export WebVTT without a WEBVTT header.
    return vtt_to_subtitle_dicts(
        text,
        merge_sentences=True if merge_sentences is None else merge_sentences,
    )


def _cues_to_subtitle_dicts(cues: list[Cue], *, merge_sentences: bool = True) -> list[dict]:
    rows = merge_into_sentences(cues) if merge_sentences else list(cues)
    subtitles: list[dict] = []
    for i, cue in enumerate(rows):
        english, chinese, english_html = normalize_subtitle_fields(
            cue.english,
            cue.chinese,
            words_to_html(cue.english) if cue.english else "",
        )
        if not english and not chinese:
            continue
        subtitles.append(
            {
                "index": len(subtitles),
                "start": round(cue.start, 3),
                "end": round(cue.end, 3),
                "english": english,
                "chinese": chinese,
                "ipa": "",
                "english_html": english_html,
            }
        )
    return subtitles


def subtitles_have_chinese(subtitles: list[dict]) -> bool:
    return any((s.get("chinese") or "").strip() for s in subtitles)
