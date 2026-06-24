from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import delete, func
from sqlalchemy.orm import Session

from ...database import get_db
from ...deps import get_current_admin
from ...models import Episode, Tag, User, episode_tags
from ...schemas import AdminTagCreateIn, AdminTagMergeIn, AdminTagOut, AdminTagUpdateIn

router = APIRouter(prefix="/api/admin/tags", tags=["admin-tags"])


def _tag_out(tag: Tag, episode_count: int) -> AdminTagOut:
    return AdminTagOut(id=tag.id, name=tag.name, episode_count=episode_count)


def _episode_count(db: Session, tag_id: int) -> int:
    return db.query(Episode).filter(Episode.tags.any(Tag.id == tag_id)).count()


def _next_tag_id(db: Session) -> int:
    max_id = db.query(func.max(Tag.id)).scalar()
    return (max_id or 0) + 1


@router.get("/", response_model=list[AdminTagOut])
def list_tags(
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    tag_ids_with_counts = dict(
        db.query(episode_tags.c.tag_id, func.count(episode_tags.c.episode_id))
        .group_by(episode_tags.c.tag_id)
        .all()
    )
    tags = db.query(Tag).order_by(Tag.name).all()
    return [_tag_out(t, tag_ids_with_counts.get(t.id, 0)) for t in tags]


@router.post("/", response_model=AdminTagOut)
def create_tag(
    body: AdminTagCreateIn,
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    name = body.name.strip()
    if not name:
        raise HTTPException(status_code=400, detail="标签名不能为空")
    if db.query(Tag).filter(Tag.name == name).first():
        raise HTTPException(status_code=400, detail="标签名已存在")

    tag = Tag(id=_next_tag_id(db), name=name)
    db.add(tag)
    db.commit()
    db.refresh(tag)
    return _tag_out(tag, 0)


@router.patch("/{tag_id}/", response_model=AdminTagOut)
def update_tag(
    tag_id: int,
    body: AdminTagUpdateIn,
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    tag = db.query(Tag).filter(Tag.id == tag_id).first()
    if not tag:
        raise HTTPException(status_code=404, detail="标签不存在")

    name = body.name.strip()
    conflict = db.query(Tag).filter(Tag.name == name, Tag.id != tag_id).first()
    if conflict:
        raise HTTPException(status_code=400, detail="标签名已存在")

    tag.name = name
    db.commit()
    db.refresh(tag)
    return _tag_out(tag, _episode_count(db, tag.id))


@router.delete("/{tag_id}/")
def delete_tag(
    tag_id: int,
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    tag = db.query(Tag).filter(Tag.id == tag_id).first()
    if not tag:
        raise HTTPException(status_code=404, detail="标签不存在")

    db.execute(delete(episode_tags).where(episode_tags.c.tag_id == tag_id))
    db.delete(tag)
    db.commit()
    return {"success": True}


@router.post("/{tag_id}/merge/", response_model=AdminTagOut)
def merge_tag(
    tag_id: int,
    body: AdminTagMergeIn,
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    if tag_id == body.target_id:
        raise HTTPException(status_code=400, detail="不能合并到自身")

    source = db.query(Tag).filter(Tag.id == tag_id).first()
    target = db.query(Tag).filter(Tag.id == body.target_id).first()
    if not source:
        raise HTTPException(status_code=404, detail="源标签不存在")
    if not target:
        raise HTTPException(status_code=404, detail="目标标签不存在")

    episodes = db.query(Episode).filter(Episode.tags.any(Tag.id == source.id)).all()
    for ep in episodes:
        tags = [t for t in ep.tags if t.id != source.id]
        if not any(t.id == target.id for t in tags):
            tags.append(target)
        ep.tags = tags

    db.execute(delete(episode_tags).where(episode_tags.c.tag_id == source.id))
    db.delete(source)
    db.commit()
    db.refresh(target)
    return _tag_out(target, _episode_count(db, target.id))
