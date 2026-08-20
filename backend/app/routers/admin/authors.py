from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import func
from sqlalchemy.orm import Session

from ...database import get_db
from ...deps import get_current_admin
from ...models import Author, Episode, Tag, User, UserAuthorSubscription, episode_tags
from ...schemas import (
    AdminAuthorCreateIn,
    AdminAuthorMergeIn,
    AdminAuthorOut,
    AdminAuthorUpdateIn,
)

router = APIRouter(prefix="/api/admin/authors", tags=["admin-authors"])


def _author_out(author: Author, episode_count: int) -> AdminAuthorOut:
    return AdminAuthorOut(
        id=author.id,
        name=author.name,
        gender=author.gender,
        nationality=author.nationality,
        accent=author.accent,
        episode_count=episode_count,
    )


def _episode_count(db: Session, author_id: int) -> int:
    return db.query(Episode).filter(Episode.author_id == author_id).count()


@router.get("/", response_model=list[AdminAuthorOut])
def list_authors(
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    counts = dict(
        db.query(Episode.author_id, func.count(Episode.id))
        .group_by(Episode.author_id)
        .all()
    )
    authors = db.query(Author).order_by(Author.name).all()
    return [_author_out(a, counts.get(a.id, 0)) for a in authors]


@router.post("/", response_model=AdminAuthorOut)
def create_author(
    body: AdminAuthorCreateIn,
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    name = body.name.strip()
    accent = body.accent.strip()
    existing = db.query(Author).filter(Author.name == name, Author.accent == accent).first()
    if existing:
        raise HTTPException(status_code=400, detail="相同姓名与口音的作者已存在")

    author = Author(
        name=name,
        gender=body.gender,
        nationality=body.nationality.strip(),
        accent=accent,
    )
    db.add(author)
    db.commit()
    db.refresh(author)
    return _author_out(author, 0)


@router.patch("/{author_id}/", response_model=AdminAuthorOut)
def update_author(
    author_id: int,
    body: AdminAuthorUpdateIn,
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    author = db.query(Author).filter(Author.id == author_id).first()
    if not author:
        raise HTTPException(status_code=404, detail="作者不存在")

    data = body.model_dump(exclude_unset=True)
    new_name = data.get("name", author.name).strip()
    new_accent = data.get("accent", author.accent).strip()
    conflict = (
        db.query(Author)
        .filter(Author.name == new_name, Author.accent == new_accent, Author.id != author_id)
        .first()
    )
    if conflict:
        raise HTTPException(status_code=400, detail="相同姓名与口音的作者已存在")

    if "name" in data:
        author.name = new_name
    if "gender" in data:
        author.gender = data["gender"]
    if "nationality" in data:
        author.nationality = data["nationality"].strip()
    if "accent" in data:
        author.accent = new_accent

    db.commit()
    db.refresh(author)
    return _author_out(author, _episode_count(db, author.id))


@router.delete("/{author_id}/")
def delete_author(
    author_id: int,
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    author = db.query(Author).filter(Author.id == author_id).first()
    if not author:
        raise HTTPException(status_code=404, detail="作者不存在")
    count = _episode_count(db, author_id)
    if count > 0:
        raise HTTPException(status_code=400, detail=f"该作者关联 {count} 个剧集，请先合并或修改剧集")

    db.query(UserAuthorSubscription).filter(UserAuthorSubscription.author_id == author_id).delete(
        synchronize_session=False
    )
    db.delete(author)
    db.commit()
    return {"success": True}


@router.post("/{author_id}/merge/", response_model=AdminAuthorOut)
def merge_author(
    author_id: int,
    body: AdminAuthorMergeIn,
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    if author_id == body.target_id:
        raise HTTPException(status_code=400, detail="不能合并到自身")

    source = db.query(Author).filter(Author.id == author_id).first()
    target = db.query(Author).filter(Author.id == body.target_id).first()
    if not source:
        raise HTTPException(status_code=404, detail="源作者不存在")
    if not target:
        raise HTTPException(status_code=404, detail="目标作者不存在")

    db.query(Episode).filter(Episode.author_id == source.id).update(
        {Episode.author_id: target.id},
        synchronize_session=False,
    )
    source_subs = (
        db.query(UserAuthorSubscription)
        .filter(UserAuthorSubscription.author_id == source.id)
        .all()
    )
    target_user_ids = {
        row[0]
        for row in db.query(UserAuthorSubscription.user_id)
        .filter(UserAuthorSubscription.author_id == target.id)
        .all()
    }
    for sub in source_subs:
        if sub.user_id in target_user_ids:
            db.delete(sub)
        else:
            sub.author_id = target.id
    db.delete(source)
    db.commit()
    db.refresh(target)
    return _author_out(target, _episode_count(db, target.id))
