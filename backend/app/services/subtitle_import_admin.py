from fastapi import HTTPException

from ..schemas import AdminSubtitleIn, AdminVttImportOut
from .episode_admin import subtitle_stats
from .subtitle_analyze import analyze_subtitles_with_deepseek
from .subtitle_translate import enrich_subtitles_with_deepseek
from .vtt_import import subtitles_have_chinese, subtitle_text_to_dicts


def import_subtitle_text_for_admin(text: str) -> AdminVttImportOut:
    stripped = text.lstrip("\ufeff").strip()
    if not stripped:
        raise HTTPException(status_code=400, detail="字幕内容为空")

    rows = subtitle_text_to_dicts(stripped, merge_sentences=False)
    if not rows:
        raise HTTPException(
            status_code=400,
            detail="字幕解析失败：未能识别有效字幕条目，请检查 VTT/SRT 文件格式与时间轴",
        )

    had_chinese = subtitles_have_chinese(rows)
    translated_count = 0
    ipa_count = 0
    try:
        translated_count, ipa_count = enrich_subtitles_with_deepseek(
            rows,
            translate_chinese=not had_chinese,
        )
    except RuntimeError as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc

    count, clip_length = subtitle_stats(rows)
    try:
        analyze = analyze_subtitles_with_deepseek(rows, clip_length=clip_length)
    except Exception as exc:
        raise HTTPException(status_code=502, detail=f"字幕难度高亮分析失败：{exc}") from exc

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
        highlight_count=int(analyze.get("highlight_count") or 0),
    )
