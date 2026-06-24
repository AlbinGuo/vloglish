from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session, joinedload

from ..database import get_db
from ..deps import get_device_id
from ..favorites import favorite_video_ids
from ..models import DemoCode, Episode, Entry
from ..schemas import DemoVerifyIn, DemoVerifyOut
from ..serializers import episode_summary, entry_detail

router = APIRouter(prefix="/api/demo", tags=["demo"])


@router.post("/verify-code/", response_model=DemoVerifyOut)
def verify_code(body: DemoVerifyIn, db: Session = Depends(get_db)):
    demo = (
        db.query(DemoCode)
        .options(joinedload(DemoCode.episodes))
        .filter(DemoCode.code == body.code.strip(), DemoCode.active.is_(True))
        .first()
    )
    if not demo:
        return DemoVerifyOut(success=False, message="无效体验码", affiliate_code=None)
    return DemoVerifyOut(
        success=True,
        message="体验码验证成功",
        affiliate_code=demo.affiliate_code,
    )


@router.get("/get-episodes/")
def get_demo_episodes(db: Session = Depends(get_db), device_id: str = Depends(get_device_id)):
    fav_ids = favorite_video_ids(db, device_id)
    demo = (
        db.query(DemoCode)
        .options(
            joinedload(DemoCode.episodes).joinedload(Episode.author),
            joinedload(DemoCode.episodes).joinedload(Episode.tags),
        )
        .filter(DemoCode.code == "ALICE")
        .first()
    )
    if demo and demo.episodes:
        episodes = sorted(demo.episodes, key=lambda e: e.index, reverse=True)
    else:
        episodes = (
            db.query(Episode)
            .options(joinedload(Episode.author), joinedload(Episode.tags))
            .filter(Episode.is_demo.is_(True))
            .order_by(Episode.index.desc())
            .all()
        )
    return [episode_summary(ep, is_favorite=ep.video_id in fav_ids) for ep in episodes]
