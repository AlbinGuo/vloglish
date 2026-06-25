from fastapi import APIRouter, Depends, HTTPException

from ...deps import get_current_admin
from ...models import User
from ...schemas import (
    AdminFetchMediaIn,
    AdminFetchMediaOut,
    AdminSubtitleIn,
    AdminVttImportIn,
    AdminVttImportOut,
)
from ...services.episode_admin import subtitle_stats
from ...services.subtitle_translate import enrich_subtitles_with_deepseek
from ...services.vtt_import import subtitles_have_chinese, vtt_to_subtitle_dicts
from ...services.yt_dlp_fetch import fetch_and_upload_from_url

router = APIRouter(prefix="/api/admin/episodes", tags=["admin-episodes"])


@router.post("/fetch-media/", response_model=AdminFetchMediaOut)
def fetch_media(
    body: AdminFetchMediaIn,
    _admin: User = Depends(get_current_admin),
):
    try:
        result = fetch_and_upload_from_url(
            body.url,
            slug=body.slug,
            enrich_subtitles=body.enrich_subtitles,
        )
    except RuntimeError as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc

    subtitles = [AdminSubtitleIn(**row) for row in result["subtitles"]]
    return AdminFetchMediaOut(
        title=result["title"],
        summary=result.get("summary", ""),
        author_name=result.get("author_name", ""),
        original_video_url=result["original_video_url"],
        cover=result["cover"],
        thumbnail_url=result["thumbnail_url"],
        video_url=result["video_url"],
        audio_url=result["audio_url"],
        subtitles=subtitles,
        subtitle_count=result["subtitle_count"],
        clip_length=result["clip_length"],
        had_chinese=result["had_chinese"],
        translated_count=result["translated_count"],
        ipa_count=result["ipa_count"],
        stars=result.get("stars", 3),
        voca_size=result.get("voca_size", 0),
        highlight_count=result.get("highlight_count", 0),
        source_id=result.get("source_id", ""),
        warnings=result.get("warnings", []),
    )


@router.post("/import-vtt/", response_model=AdminVttImportOut)
def import_vtt(
    body: AdminVttImportIn,
    _admin: User = Depends(get_current_admin),
):
    rows = vtt_to_subtitle_dicts(body.vtt_text)
    had_chinese = subtitles_have_chinese(rows)
    translated_count = 0
    ipa_count = 0
    if rows:
        try:
            translated_count, ipa_count = enrich_subtitles_with_deepseek(
                rows,
                translate_chinese=not had_chinese,
            )
        except RuntimeError as exc:
            raise HTTPException(status_code=502, detail=str(exc)) from exc

    subtitles = [AdminSubtitleIn(**row) for row in rows]
    count, clip_length = subtitle_stats(rows)
    return AdminVttImportOut(
        subtitles=subtitles,
        subtitle_count=count,
        clip_length=clip_length,
        had_chinese=had_chinese,
        translated_count=translated_count,
        ipa_count=ipa_count,
    )
