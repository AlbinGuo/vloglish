"""用户文章投稿：链接 + 可选英文正文；审核通过后进个人语料库。"""

from __future__ import annotations

from urllib.parse import urlparse

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from ..database import get_db
from ..deps import get_current_member
from ..models import Article, User
from ..schemas import (
    UserArticleSubmitIn,
    UserArticleSubmitOut,
    UserArticleSubmissionItemOut,
    UserArticleSubmissionListOut,
)
from ..services.article_admin import generate_article_id
from ..services.user_notifications import notify_staff_article_submitted

router = APIRouter(prefix="/api/articles/submit", tags=["article-submit"])

MAX_BODY_CHARS = 50000


def _fmt_dt(dt) -> str:
    return dt.isoformat() + "Z" if dt else ""


def _is_http_url(url: str) -> bool:
    try:
        parsed = urlparse(url.strip())
    except Exception:
        return False
    return parsed.scheme in ("http", "https") and bool(parsed.netloc)


def _placeholder_title(*, source_url: str, body: str) -> str:
    if source_url:
        cleaned = source_url.strip()
        if len(cleaned) > 72:
            cleaned = cleaned[:69] + "..."
        return f"待补充 · {cleaned}"
    line = (body or "").strip().splitlines()[0].strip() if body.strip() else ""
    if not line:
        return "待补充 · 用户投稿文章"
    if len(line) > 72:
        line = line[:69] + "..."
    return f"待补充 · {line}"


@router.get("/", response_model=UserArticleSubmissionListOut)
def list_my_article_submissions(
    user: User = Depends(get_current_member),
    db: Session = Depends(get_db),
):
    rows = (
        db.query(Article)
        .filter(Article.submitted_by_user_id == user.id)
        .order_by(Article.created_at.desc(), Article.id.desc())
        .all()
    )
    results = [
        UserArticleSubmissionItemOut(
            article_id=a.article_id,
            title=a.title or "",
            source_url=a.source_url or "",
            has_submit_body=bool((a.submit_body or "").strip()),
            status=a.status,
            rejection_reason=a.rejection_reason or "",
            created_at=_fmt_dt(a.created_at),
            has_content=int(a.segment_count or 0) > 0,
            cover=(a.cover or "").strip(),
            source=a.source or "",
        )
        for a in rows
    ]
    return UserArticleSubmissionListOut(count=len(results), results=results)


@router.post("/", response_model=UserArticleSubmitOut)
def submit_article(
    body: UserArticleSubmitIn,
    user: User = Depends(get_current_member),
    db: Session = Depends(get_db),
):
    source_url = (body.source_url or "").strip()
    submit_body = (body.body or "").strip()
    note = (body.note or "").strip()

    if not source_url and not submit_body:
        raise HTTPException(status_code=400, detail="请填写文章链接或粘贴英文正文（至少一项）")
    if source_url and not _is_http_url(source_url):
        raise HTTPException(status_code=400, detail="请填写有效的 http(s) 文章链接")
    if len(submit_body) > MAX_BODY_CHARS:
        raise HTTPException(status_code=400, detail=f"正文过长（最多 {MAX_BODY_CHARS} 字）")

    if source_url:
        existing = (
            db.query(Article)
            .filter(Article.source_url == source_url, Article.submitted_by_user_id.isnot(None))
            .first()
        )
        if existing:
            raise HTTPException(status_code=400, detail="该链接已投稿或已在审核中，请勿重复提交")

    remark_parts = [f"用户投稿 (user #{user.id})", f"邮箱 {user.email}"]
    if note:
        remark_parts.append(f"用户备注：{note}")

    article_id = generate_article_id()
    while db.query(Article).filter(Article.article_id == article_id).first():
        article_id = generate_article_id()

    article = Article(
        article_id=article_id,
        title=_placeholder_title(source_url=source_url, body=submit_body),
        summary="",
        source="用户投稿",
        source_url=source_url,
        topic="",
        cover="",
        stars=3,
        status="draft",
        submitted_by_user_id=user.id,
        is_catalog_public=False,
        rejection_reason="",
        submit_body=submit_body,
        remark=" | ".join(remark_parts),
    )
    db.add(article)
    db.flush()
    notify_staff_article_submitted(db, article, user)
    db.commit()
    db.refresh(article)

    return UserArticleSubmitOut(
        article_id=article.article_id,
        title=article.title,
        status=article.status,
        message="提交成功，文章将在管理员审核通过后入库，预计1-2个小时出审核结果~",
    )
