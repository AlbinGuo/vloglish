from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload

from ...database import get_db
from ...deps import get_current_admin
from ...models import DemoCode, Episode, User
from ...schemas import (
    AdminDemoCodeCreateIn,
    AdminDemoCodeDetailOut,
    AdminDemoCodeListOut,
    AdminDemoCodeOut,
    AdminDemoCodeUpdateIn,
)

router = APIRouter(prefix="/api/admin/demo-codes", tags=["admin-demo-codes"])


def _episode_brief(ep: Episode) -> dict:
    return {
        "id": ep.id,
        "video_id": ep.video_id,
        "short_title": ep.short_title,
        "status": ep.status,
    }


def _demo_out(demo: DemoCode) -> AdminDemoCodeOut:
    return AdminDemoCodeOut(
        id=demo.id,
        code=demo.code,
        affiliate_code=demo.affiliate_code,
        active=demo.active,
        episode_count=len(demo.episodes),
    )


@router.get("/", response_model=AdminDemoCodeListOut)
def list_demo_codes(
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    demos = (
        db.query(DemoCode)
        .options(joinedload(DemoCode.episodes))
        .order_by(DemoCode.id)
        .all()
    )
    return AdminDemoCodeListOut(results=[_demo_out(d) for d in demos])


@router.post("/", response_model=AdminDemoCodeDetailOut)
def create_demo_code(
    body: AdminDemoCodeCreateIn,
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    code = body.code.strip().upper()
    if not code:
        raise HTTPException(status_code=400, detail="体验码不能为空")
    if db.query(DemoCode).filter(DemoCode.code == code).first():
        raise HTTPException(status_code=400, detail="体验码已存在")

    episodes = _load_episodes(db, body.episode_ids)
    demo = DemoCode(code=code, affiliate_code=body.affiliate_code, active=body.active)
    demo.episodes = episodes
    db.add(demo)
    db.commit()
    db.refresh(demo)
    return _demo_detail(db, demo.id)


@router.get("/{demo_id}/", response_model=AdminDemoCodeDetailOut)
def get_demo_code(
    demo_id: int,
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    return _demo_detail(db, demo_id)


@router.patch("/{demo_id}/", response_model=AdminDemoCodeDetailOut)
def update_demo_code(
    demo_id: int,
    body: AdminDemoCodeUpdateIn,
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    demo = (
        db.query(DemoCode)
        .options(joinedload(DemoCode.episodes))
        .filter(DemoCode.id == demo_id)
        .first()
    )
    if not demo:
        raise HTTPException(status_code=404, detail="体验码不存在")

    if body.active is not None:
        demo.active = body.active
    if body.affiliate_code is not None:
        demo.affiliate_code = body.affiliate_code or None
    if body.episode_ids is not None:
        demo.episodes = _load_episodes(db, body.episode_ids)

    db.commit()
    return _demo_detail(db, demo_id)


@router.delete("/{demo_id}/")
def delete_demo_code(
    demo_id: int,
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    demo = db.query(DemoCode).filter(DemoCode.id == demo_id).first()
    if not demo:
        raise HTTPException(status_code=404, detail="体验码不存在")
    if demo.code == "ALICE":
        raise HTTPException(status_code=400, detail="不能删除默认体验码 ALICE")
    db.delete(demo)
    db.commit()
    return {"success": True}


def _load_episodes(db: Session, episode_ids: list[int]) -> list[Episode]:
    if not episode_ids:
        return []
    episodes = db.query(Episode).filter(Episode.id.in_(episode_ids)).all()
    found = {e.id for e in episodes}
    missing = set(episode_ids) - found
    if missing:
        raise HTTPException(status_code=400, detail=f"剧集不存在: {sorted(missing)}")
    return episodes


def _demo_detail(db: Session, demo_id: int) -> AdminDemoCodeDetailOut:
    demo = (
        db.query(DemoCode)
        .options(joinedload(DemoCode.episodes))
        .filter(DemoCode.id == demo_id)
        .first()
    )
    if not demo:
        raise HTTPException(status_code=404, detail="体验码不存在")
    episodes = sorted(demo.episodes, key=lambda e: e.index, reverse=True)
    return AdminDemoCodeDetailOut(
        id=demo.id,
        code=demo.code,
        affiliate_code=demo.affiliate_code,
        active=demo.active,
        episode_count=len(episodes),
        episodes=[_episode_brief(ep) for ep in episodes],
        episode_ids=[ep.id for ep in episodes],
    )
