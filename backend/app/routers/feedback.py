"""用户意见反馈：提交与配图上传。"""

from __future__ import annotations

import json
from datetime import datetime

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile
from sqlalchemy.orm import Session

from ..database import get_db
from ..deps import get_current_user
from ..models import User, UserFeedback
from ..qiniu_storage import QiniuConfig
from ..schemas import FeedbackCreateIn, FeedbackCreateOut, FeedbackImageOut, FeedbackOut
from ..services.notification_image import upload_notification_image

router = APIRouter(prefix="/api/feedback", tags=["feedback"])


def _fmt_dt(value: datetime | None) -> str:
    if not value:
        return ""
    return value.strftime("%Y-%m-%d %H:%M:%S")


def _normalize_image_urls(urls: list[str]) -> list[str]:
    cleaned: list[str] = []
    for url in urls:
        u = (url or "").strip()
        if not u:
            continue
        if not (u.startswith("http://") or u.startswith("https://")):
            raise HTTPException(status_code=400, detail="图片地址无效")
        cleaned.append(u)
        if len(cleaned) >= 3:
            break
    return cleaned


@router.post("/upload-image/", response_model=FeedbackImageOut)
async def upload_feedback_image(
    file: UploadFile = File(...),
    _user: User = Depends(get_current_user),
):
    data = await file.read()
    try:
        cfg = QiniuConfig.from_env()
        image_url = upload_notification_image(cfg, data, file.filename, folder="feedback")
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e)) from e
    except RuntimeError as e:
        raise HTTPException(status_code=502, detail=str(e)) from e
    return FeedbackImageOut(image_url=image_url)


@router.post("/", response_model=FeedbackCreateOut)
def create_feedback(
    body: FeedbackCreateIn,
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    title = body.title.strip()
    content = body.body.strip()
    if not title:
        raise HTTPException(status_code=400, detail="请填写标题")
    if not content:
        raise HTTPException(status_code=400, detail="请填写反馈内容")

    image_urls = _normalize_image_urls(body.image_urls or [])
    row = UserFeedback(
        user_id=user.id,
        title=title[:120],
        body=content[:4000],
        image_urls_json=json.dumps(image_urls, ensure_ascii=False),
        status="pending",
    )
    db.add(row)
    db.commit()
    db.refresh(row)
    return FeedbackCreateOut(id=row.id)


@router.get("/mine/", response_model=list[FeedbackOut])
def list_my_feedback(
    user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    rows = (
        db.query(UserFeedback)
        .filter(UserFeedback.user_id == user.id)
        .order_by(UserFeedback.created_at.desc(), UserFeedback.id.desc())
        .limit(50)
        .all()
    )
    return [
        FeedbackOut(
            id=r.id,
            title=r.title,
            body=r.body,
            image_urls=r.image_urls,
            status=r.status,
            created_at=_fmt_dt(r.created_at),
        )
        for r in rows
    ]
