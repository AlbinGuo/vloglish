from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from ..database import get_db
from ..demo_access import get_visible_demo_episodes, user_is_member
from ..deps import get_current_user_optional, get_device_id
from ..favorites import favorite_video_ids
from ..models import DemoCode, User
from ..schemas import DemoVerifyIn, DemoVerifyOut
from ..services.episode_stats import learner_count_map_for_episodes
from ..serializers import episode_summary
from sqlalchemy.orm import joinedload

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
def get_demo_episodes_route(
    db: Session = Depends(get_db),
    device_id: str = Depends(get_device_id),
    user: User | None = Depends(get_current_user_optional),
):
    user_id = user.id if user else None
    fav_ids = favorite_video_ids(db, device_id, user_id)
    episodes = get_visible_demo_episodes(db, user)
    learner_map = learner_count_map_for_episodes(db, [ep.id for ep in episodes])
    return [
        episode_summary(
            ep,
            is_favorite=ep.video_id in fav_ids if user_is_member(user) else False,
            learner_count=learner_map.get(ep.id, 0),
        )
        for ep in episodes
    ]
