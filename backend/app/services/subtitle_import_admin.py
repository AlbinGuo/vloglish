from fastapi import HTTPException

from ..dict.deepseek import build_subtitle_translation_brief
from ..schemas import AdminSubtitleIn, AdminVttImportOut
from .episode_admin import subtitle_stats
from .subtitle_analyze import analyze_subtitles_with_deepseek
from .subtitle_translate import enrich_subtitles_with_deepseek
from .vtt_import import subtitles_have_chinese, subtitle_text_to_dicts


def import_subtitle_text_for_admin(
    text: str,
    *,
    title: str = "",
    summary: str = "",
    translate_chinese: bool = True,
) -> AdminVttImportOut:
    stripped = text.lstrip("\ufeff").strip()
    if not stripped:
        raise HTTPException(status_code=400, detail="字幕内容为空")

    # 按文件原始 cue 导入，不做碎句智能合并
    rows = subtitle_text_to_dicts(stripped, merge_sentences=False)
    if not rows:
        raise HTTPException(
            status_code=400,
            detail="字幕解析失败：未能识别有效字幕条目，请检查 VTT/SRT 文件格式与时间轴",
        )

    had_chinese = subtitles_have_chinese(rows)
    translated_count = 0
    ipa_count = 0
    translation_brief: dict = {}
    warnings: list[str] = []
    try:
        if translate_chinese:
            # AI 翻译：按剧情口语化改写中文（文件里已有中文也会重译）
            translated_count, ipa_count, translation_brief = enrich_subtitles_with_deepseek(
                rows,
                translate_chinese=True,
                overwrite_chinese=True,
                episode_title=title or "",
                episode_summary=summary or "",
            )
        else:
            # 直接使用文件：不翻译、不改写中文；仍生成 IPA（失败不阻断导入）
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

    # 即使不翻译，也尽量生成剧情简报，便于识别专业词汇高亮
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

    count, clip_length = subtitle_stats(rows)
    try:
        analyze = analyze_subtitles_with_deepseek(
            rows,
            clip_length=clip_length,
            translation_brief=translation_brief or None,
        )
    except Exception as exc:
        raise HTTPException(status_code=502, detail=f"字幕难度高亮分析失败：{exc}") from exc

    highlight_count = int(analyze.get("highlight_count") or 0)
    annotate_failed = int(analyze.get("annotate_failed") or 0)
    if highlight_count == 0:
        warnings.append("未生成难词高亮：请确认 DeepSeek API 可用，或稍后重试导入")
    elif annotate_failed > 0:
        warnings.append(f"有 {annotate_failed} 条字幕高亮分析失败，已回退为普通分词")

    if ipa_count == 0 and not any(w.startswith("音标生成失败") for w in warnings):
        warnings.append("未生成音标：请确认 DeepSeek API 可用，或稍后重试导入")

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
