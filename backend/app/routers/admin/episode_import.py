from fastapi import APIRouter, Depends
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session

from ...database import get_db
from ...deps import get_current_admin
from ...models import User
from ...schemas import AdminEpisodeImportIn, AdminEpisodeImportOut
from ...services.episode_json_import import export_episodes_json, import_episodes_json

router = APIRouter(prefix="/api/admin", tags=["admin-episode-import"])


@router.post("/episodes/import-json/", response_model=AdminEpisodeImportOut)
def import_json(
    body: AdminEpisodeImportIn,
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    result = import_episodes_json(
        db,
        {"episodes": body.episodes, "details": body.details},
        default_status=body.default_status,
        mark_demo=body.mark_demo,
    )
    return AdminEpisodeImportOut(**result)


@router.get("/episodes/export-json/")
def export_json(
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    data = export_episodes_json(db)
    return JSONResponse(content=data)
