"""整句字幕收藏接口。"""
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from ..database import get_db
from ..deps import get_current_user
from ..models import User
from ..schemas import SubtitleFavoriteOut, SubtitleFavoriteSaveIn
from ..services import subtitle_favorites as svc

router = APIRouter(prefix="/api/subtitle-favorites", tags=["subtitle-favorites"])


@router.get("/", response_model=list[SubtitleFavoriteOut])
def list_favorites(
    video_id: str | None = Query(None),
    limit: int = Query(200, ge=1, le=500),
    offset: int = Query(0, ge=0),
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    rows = svc.list_favorites(db, user, video_id=video_id, limit=limit, offset=offset)
    return [SubtitleFavoriteOut(**d) for d in rows]


@router.post("/", response_model=SubtitleFavoriteOut)
def add_favorite(
    body: SubtitleFavoriteSaveIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    try:
        row, already = svc.save_favorite(db, user, body.subtitle_id)
    except LookupError as e:
        raise HTTPException(status_code=404, detail=str(e)) from e
    except PermissionError as e:
        raise HTTPException(status_code=403, detail=str(e)) from e
    return SubtitleFavoriteOut(**svc.favorite_to_dict(row, already_saved=already))


@router.delete("/by-subtitle/{subtitle_id}/")
def delete_by_subtitle(
    subtitle_id: int,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if not svc.remove_by_subtitle(db, user, subtitle_id):
        raise HTTPException(status_code=404, detail="未收藏该字幕")
    return {"success": True}


@router.delete("/{favorite_id}/")
def delete_favorite(
    favorite_id: int,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if not svc.remove_favorite(db, user, favorite_id):
        raise HTTPException(status_code=404, detail="收藏不存在")
    return {"success": True}
