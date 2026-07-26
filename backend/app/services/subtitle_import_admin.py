from fastapi import HTTPException

from ..dict.deepseek import build_subtitle_translation_brief
from ..schemas import AdminSubtitleIn, AdminVttImportOut
from .episode_admin import subtitle_stats
from .subtitle_analyze import analyze_subtitles_with_deepseek
from .subtitle_translate import enrich_subtitles_with_deepseek
from .vtt_import import subtitles_have_chinese, subtitle_text_to_dicts


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
                "ipa": (s.ipa or "").strip(),
                "english_html": (s.english_html or "").strip(),
            }
        )
    # 重新编号
    for i, row in enumerate(rows):
        row["index"] = i
    return rows


def enrich_subtitle_rows_for_admin(
    rows: list[dict],
    *,
    title: str = "",
    summary: str = "",
    translate_chinese: bool = False,
) -> AdminVttImportOut:
    if not rows:
        raise HTTPException(status_code=400, detail="没有可增强的字幕")

    had_chinese = subtitles_have_chinese(rows)
    count, clip_length = subtitle_stats(rows)
    warnings: list[str] = []
    translated_count = 0
    ipa_count = 0
    translation_brief: dict = {}

    try:
        if translate_chinese:
            translated_count, ipa_count, translation_brief = enrich_subtitles_with_deepseek(
                rows,
                translate_chinese=True,
                overwrite_chinese=True,
                episode_title=title or "",
                episode_summary=summary or "",
            )
        else:
            try:
                translated_count, ipa_count, translation_brief = enrich_subtitles_with_deepseek(
                    rows,
                    translate_chinese=False,
                    overwrite_chinese=False,
                    episode_title=title or "",
                    episode_summary=summary or "",
                )
            except RuntimeError as exc:
                translated_count, ipa_count, translation_brief = 0, 0, {}
                warnings.append(f"音标生成失败：{exc}")
    except RuntimeError as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc

    if not translation_brief:
        try:
            english_lines = [(r.get("english") or "").strip() for r in rows if (r.get("english") or "").strip()]
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
        )
    except Exception as exc:
        warnings.append(f"字幕难度高亮分析失败（字幕已增强部分结果）：{exc}")

    highlight_count = int(analyze.get("highlight_count") or 0)
    annotate_failed = int(analyze.get("annotate_failed") or 0)
    if not any(w.startswith("字幕难度高亮分析失败") for w in warnings):
        if highlight_count == 0:
            warnings.append("未生成难词高亮：请确认 DeepSeek API 可用，或稍后重试")
        elif annotate_failed > 0:
            warnings.append(f"有 {annotate_failed} 条字幕高亮分析失败，已回退为普通分词")

    if ipa_count == 0 and not any(w.startswith("音标生成失败") for w in warnings):
        warnings.append("未生成音标：请确认 DeepSeek API 可用，或稍后重试")

    # 刷新统计（AI 可能改写了文本）
    count, clip_length = subtitle_stats(rows)
    subtitles = [AdminSubtitleIn(**row) for row in rows]
    return AdminVttImportOut(
        subtitles=subtitles,
        subtitle_count=count,
        clip_length=clip_length,
        had_chinese=had_chinese,
        translated_count=translated_count,
        ipa_count=ipa_count,
        stars=int(analyze.get("stars") or 3),
        voca_size=int(analyze.get("voca_size") or 0),
        highlight_count=highlight_count,
        warnings=warnings,
    )


def enrich_existing_subtitles_for_admin(
    subtitles: list[AdminSubtitleIn],
    *,
    title: str = "",
    summary: str = "",
    translate_chinese: bool = False,
) -> AdminVttImportOut:
    rows = _rows_from_subtitle_inputs(subtitles)
    return enrich_subtitle_rows_for_admin(
        rows,
        title=title,
        summary=summary,
        translate_chinese=translate_chinese,
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
            "未识别到时间轴（需含 00:00:00,000 --> 00:00:01,000）。"
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
        )

    return enrich_subtitle_rows_for_admin(
        rows,
        title=title,
        summary=summary,
        translate_chinese=translate_chinese,
    )
