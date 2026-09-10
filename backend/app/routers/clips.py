from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from ..database import get_db
from ..deps import get_current_user
from ..models import User
from ..schemas import SubtitleClipExamplesOut, SubtitleClipOut, SubtitleClipSaveIn, SubtitleClipUpdateIn
from ..services import clips as svc

router = APIRouter(prefix="/api/learning/clips", tags=["clips"])


def _http_from_service(exc: Exception) -> HTTPException:
    if isinstance(exc, ValueError):
        return HTTPException(status_code=400, detail=str(exc))
    if isinstance(exc, PermissionError):
        return HTTPException(status_code=403, detail=str(exc))
    if isinstance(exc, LookupError):
        return HTTPException(status_code=404, detail=str(exc))
    return HTTPException(status_code=500, detail="摘录操作失败")


@router.get("/", response_model=list[SubtitleClipOut])
def list_clips(
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return [SubtitleClipOut(**item) for item in svc.list_clips(db, user)]


@router.post("/", response_model=SubtitleClipOut)
def add_clip(
    body: SubtitleClipSaveIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    try:
        row, already = svc.save_clip(
            db,
            user,
            {
                "text": body.text,
                "video_id": body.video_id,
                "subtitle_id": body.subtitle_id,
                "note": body.note,
            },
        )
    except (ValueError, PermissionError, LookupError) as e:
        raise _http_from_service(e) from e
    return SubtitleClipOut(**svc.clip_to_dict(row, already_saved=already))


@router.patch("/{clip_id}/", response_model=SubtitleClipOut)
def patch_clip(
    clip_id: int,
    body: SubtitleClipUpdateIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    payload = body.model_dump(exclude_unset=True)
    if not payload:
        raise HTTPException(status_code=400, detail="没有要更新的内容")
    try:
        row = svc.update_clip(db, user, clip_id, payload)
    except (ValueError, LookupError) as e:
        raise _http_from_service(e) from e
    return SubtitleClipOut(**svc.clip_to_dict(row))


@router.delete("/{clip_id}/")
def delete_clip(
    clip_id: int,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if not svc.remove_clip(db, user, clip_id):
        raise HTTPException(status_code=404, detail="摘录不存在")
    return {"success": True}


@router.post("/{clip_id}/examples/", response_model=SubtitleClipExamplesOut)
def generate_clip_examples(
    clip_id: int,
    force: bool = Query(False),
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    try:
        data = svc.generate_examples(db, user, clip_id, force=force)
    except HTTPException:
        raise
    except LookupError as e:
        raise HTTPException(status_code=404, detail=str(e)) from e
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e)) from e
    return SubtitleClipExamplesOut(**data)
