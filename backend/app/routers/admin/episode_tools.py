from fastapi import APIRouter, Depends

from ...deps import get_current_admin
from ...models import User
from ...schemas import AdminSubtitleIn, AdminVttImportIn, AdminVttImportOut
from ...services.episode_admin import subtitle_stats
from ...services.vtt_import import vtt_to_subtitle_dicts

router = APIRouter(prefix="/api/admin/episodes", tags=["admin-episodes"])


@router.post("/import-vtt/", response_model=AdminVttImportOut)
def import_vtt(
    body: AdminVttImportIn,
    _admin: User = Depends(get_current_admin),
):
    rows = vtt_to_subtitle_dicts(body.vtt_text)
    subtitles = [AdminSubtitleIn(**row) for row in rows]
    count, clip_length = subtitle_stats(rows)
    return AdminVttImportOut(subtitles=subtitles, subtitle_count=count, clip_length=clip_length)
