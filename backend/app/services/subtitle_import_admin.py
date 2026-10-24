from fastapi import HTTPException

from ..dict.deepseek import build_subtitle_translation_brief
from ..schemas import AdminSubtitleIn, AdminVttImportOut
from .episode_admin import subtitle_stats
from .subtitle_analyze import (
    analyze_subtitles_with_deepseek,
    has_vocab_highlight_html,
    should_skip_annotate,
)
from .subtitle_translate import enrich_subtitles_with_deepseek
from .vtt_import import subtitles_have_chinese, subtitle_text_to_dicts

# 每轮 HTTP 最多跑几批 DeepSeek，避免逼近代理 900s 超时
DEFAULT_ENRICH_MAX_BATCHES = 3


def _rows_from_subtitle_inputs(subtitles: list[AdminSubtitleIn]) -> list[dict]:
    rows: list[dict] = []
    for i, s in enumerate(subtitles):
        english = (s.english or "").strip()
        chinese = (s.chinese or "").strip()
        if not english and not chinese:
            continue
        rows.append(
            {
                "index": i,
                "start": float(s.start),
                "end": float(s.end),
                "english": english or chinese,
                "chinese": "" if not english else chinese,
                "chinese_literal": (s.chinese_literal or "").strip(),
                "ipa": (s.ipa or "").strip(),
                "english_html": (s.english_html or "").strip(),
            }
        )
    for i, row in enumerate(rows):
        row["index"] = i
    return rows


def enrich_subtitle_rows_for_admin(
    rows: list[dict],
    *,
    title: str = "",
    summary: str = "",
    translate_chinese: bool = False,
    max_batches: int = DEFAULT_ENRICH_MAX_BATCHES,
) -> AdminVttImportOut:
    if not rows:
        raise HTTPException(status_code=400, detail="没有可增强的字幕")

    had_chinese = subtitles_have_chinese(rows)
    count, clip_length = subtitle_stats(rows)
    warnings: list[str] = []
    translated_count = 0
    ipa_count = 0
    translation_brief: dict = {}
    batches_budget = max(1, int(max_batches or DEFAULT_ENRICH_MAX_BATCHES))

    try:
        (
            translated_count,
            ipa_count,
            translation_brief,
            enrich_remaining,
            enrich_done,
            enrich_batches,
        ) = enrich_subtitles_with_deepseek(
            rows,
            translate_chinese=translate_chinese,
            overwrite_chinese=False,
            episode_title=title or "",
            episode_summary=summary or "",
            max_batches=batches_budget,
        )
    except RuntimeError as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc

    if not enrich_done:
        count, clip_length = subtitle_stats(rows)
        return AdminVttImportOut(
            subtitles=[AdminSubtitleIn(**row) for row in rows],
            subtitle_count=count,
            clip_length=clip_length,
            had_chinese=had_chinese,
            translated_count=translated_count,
            ipa_count=ipa_count,
            stars=3,
            voca_size=0,
            highlight_count=sum(
                1 for r in rows if has_vocab_highlight_html(r.get("english_html") or "")
            ),
            warnings=warnings,
            done=False,
            phase="enrich",
            remaining=enrich_remaining,
        )

    annotate_budget = max(0, batches_budget - enrich_batches)
    if annotate_budget <= 0:
        # enrich 刚好用尽预算；本轮先返回，下一轮做高亮
        count, clip_length = subtitle_stats(rows)
        pending_hl = sum(
            1
            for r in rows
            if (r.get("english") or "").strip()
            and not should_skip_annotate(r.get("english_html") or "")
        )
        return AdminVttImportOut(
            subtitles=[AdminSubtitleIn(**row) for row in rows],
            subtitle_count=count,
            clip_length=clip_length,
            had_chinese=had_chinese,
            translated_count=translated_count,
            ipa_count=ipa_count,
            stars=3,
            voca_size=0,
            highlight_count=sum(
                1 for r in rows if has_vocab_highlight_html(r.get("english_html") or "")
            ),
            warnings=warnings,
            done=pending_hl == 0,
            phase="done" if pending_hl == 0 else "analyze",
            remaining=pending_hl,
        )

    # 仅翻译模式需要剧情简报；保留中文时跳过，避免多一次 DeepSeek
    if translate_chinese and not translation_brief:
        try:
            english_lines = [
                (r.get("english") or "").strip() for r in rows if (r.get("english") or "").strip()
            ]
            translation_brief = build_subtitle_translation_brief(
                english_lines,
                episode_title=title or "",
                episode_summary=summary or "",
            )
        except Exception:
            translation_brief = {}

    analyze: dict = {}
    try:
        analyze = analyze_subtitles_with_deepseek(
            rows,
            clip_length=clip_length,
            translation_brief=translation_brief or None,
            max_batches=annotate_budget,
            skip_highlighted=True,
        )
    except Exception as exc:
        warnings.append(f"字幕难度高亮分析失败（字幕已增强部分结果）：{exc}")
        analyze = {
            "stars": 3,
            "voca_size": 0,
            "highlight_count": 0,
            "annotate_failed": 0,
            "annotate_remaining": 1,
            "annotate_done": 0,
        }

    highlight_count = int(analyze.get("highlight_count") or 0)
    annotate_failed = int(analyze.get("annotate_failed") or 0)
    annotate_remaining = int(analyze.get("annotate_remaining") or 0)
    annotate_done = bool(analyze.get("annotate_done"))

    if annotate_done:
        phase = "done"
        done = True
        remaining = 0
        if not any(w.startswith("字幕难度高亮分析失败") for w in warnings):
            if highlight_count == 0 and not any(
                has_vocab_highlight_html(r.get("english_html") or "") for r in rows
            ):
                warnings.append("未生成难词高亮：请确认 DeepSeek API 可用，或稍后重试")
            elif annotate_failed > 0:
                warnings.append(f"有 {annotate_failed} 条字幕高亮分析失败，已回退为普通分词")
        if ipa_count == 0 and not any((r.get("ipa") or "").strip() for r in rows):
            if not any("音标" in w for w in warnings):
                warnings.append("未生成音标：请确认 DeepSeek API 可用，或稍后重试")
    else:
        phase = "analyze"
        done = False
        remaining = annotate_remaining

    count, clip_length = subtitle_stats(rows)
    return AdminVttImportOut(
        subtitles=[AdminSubtitleIn(**row) for row in rows],
        subtitle_count=count,
        clip_length=clip_length,
        had_chinese=had_chinese,
        translated_count=translated_count,
        ipa_count=ipa_count,
        stars=int(analyze.get("stars") or 3),
        voca_size=int(analyze.get("voca_size") or 0),
        highlight_count=highlight_count,
        warnings=warnings,
        done=done,
        phase=phase,
        remaining=remaining,
    )


def enrich_existing_subtitles_for_admin(
    subtitles: list[AdminSubtitleIn],
    *,
    title: str = "",
    summary: str = "",
    translate_chinese: bool = False,
    max_batches: int = DEFAULT_ENRICH_MAX_BATCHES,
) -> AdminVttImportOut:
    rows = _rows_from_subtitle_inputs(subtitles)
    return enrich_subtitle_rows_for_admin(
        rows,
        title=title,
        summary=summary,
        translate_chinese=translate_chinese,
        max_batches=max_batches,
    )


def import_subtitle_text_for_admin(
    text: str,
    *,
    title: str = "",
    summary: str = "",
    translate_chinese: bool = False,
    enrich_ai: bool = False,
) -> AdminVttImportOut:
    stripped = text.lstrip("\ufeff").strip()
    if not stripped:
        raise HTTPException(status_code=400, detail="字幕内容为空")

    rows = subtitle_text_to_dicts(stripped, merge_sentences=False)
    if not rows:
        has_arrow = "-->" in stripped
        hint = (
            "未识别到时间轴。请使用 SRT/VTT（含 00:00:00,000 --> 00:00:01,000），"
            "或 Time / Subtitle / Machine Translation 的制表符文本（如 14s / 1:01 / 1:46:05）。"
            if not has_arrow
            else "已检测到 -->，但时间格式可能不兼容，或文件编码异常（请另存为 UTF-8）。"
        )
        raise HTTPException(
            status_code=400,
            detail=f"字幕解析失败：未能识别有效字幕条目。{hint}",
        )

    had_chinese = subtitles_have_chinese(rows)
    count, clip_length = subtitle_stats(rows)

    if not enrich_ai:
        subtitles = [AdminSubtitleIn(**row) for row in rows]
        return AdminVttImportOut(
            subtitles=subtitles,
            subtitle_count=count,
            clip_length=clip_length,
            had_chinese=had_chinese,
            translated_count=0,
            ipa_count=0,
            stars=3,
            voca_size=0,
            highlight_count=0,
            warnings=["已仅导入文本。保存后可点「AI 增强当前字幕」生成翻译/音标/高亮。"],
            done=True,
            phase="done",
            remaining=0,
        )

    return enrich_subtitle_rows_for_admin(
        rows,
        title=title,
        summary=summary,
        translate_chinese=translate_chinese,
    )
