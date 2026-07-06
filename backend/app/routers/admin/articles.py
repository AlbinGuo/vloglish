from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session, joinedload

from ...database import get_db
from ...deps import get_current_admin
from ...models import Article, User
from ...schemas import (
    AdminArticleCreateIn,
    AdminArticleDetailOut,
    AdminArticleImportTextIn,
    AdminArticleImportTextOut,
    AdminArticleListOut,
    AdminArticleSegmentIn,
    AdminArticleTtsOut,
    AdminArticleUpdateIn,
    ArticleProgressUpdateIn,
)
from ...serializers import article_detail, article_segment_out
from ...services.article_admin import (
    VALID_STATUSES,
    delete_article_with_dependencies,
    generate_article_id,
    get_article_by_ref,
    import_text_to_segments,
    replace_segments,
)
from ...services.article_tts import generate_article_tts
from ...services.subtitle_analyze import analyze_subtitles_with_deepseek

router = APIRouter(prefix="/api/admin/articles", tags=["admin-articles"])


def _fmt_dt(value: datetime | None) -> str:
    if not value:
        return ""
    return value.strftime("%Y-%m-%d %H:%M:%S")


def _article_list_item(article: Article) -> dict:
    return {
        "id": article.id,
        "article_id": article.article_id,
        "title": article.title,
        "source": article.source or "",
        "topic": article.topic or "",
        "stars": article.stars,
        "word_count": article.word_count,
        "segment_count": article.segment_count,
        "status": article.status,
        "published_at": _fmt_dt(article.published_at),
        "created_at": _fmt_dt(article.created_at),
        "tts_status": article.tts_status or "none",
    }


def _require_article(db: Session, ref: str) -> Article:
    article = get_article_by_ref(db, ref)
    if not article:
        raise HTTPException(status_code=404, detail="文章不存在")
    return article


@router.get("/", response_model=AdminArticleListOut)
def admin_list_articles(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    status: str | None = None,
    q: str | None = None,
    db: Session = Depends(get_db),
    _admin: User = Depends(get_current_admin),
):
    query = db.query(Article)
    if status:
        query = query.filter(Article.status == status)
    if q and q.strip():
        term = f"%{q.strip()}%"
        query = query.filter(Article.title.ilike(term))
    query = query.order_by(Article.created_at.desc())
    total = query.count()
    rows = query.offset((page - 1) * page_size).limit(page_size).all()
    return AdminArticleListOut(
        count=total,
        results=[_article_list_item(a) for a in rows],
    )


@router.post("/", response_model=AdminArticleDetailOut)
def admin_create_article(
    body: AdminArticleCreateIn,
    db: Session = Depends(get_db),
    _admin: User = Depends(get_current_admin),
):
    article_id = (body.article_id or generate_article_id()).strip()
    if get_article_by_ref(db, article_id):
        raise HTTPException(status_code=400, detail="article_id 已存在")

    article = Article(
        article_id=article_id,
        title=body.title.strip() or "Untitled",
        summary=body.summary or "",
        source=body.source or "",
        source_url=body.source_url or "",
        topic=body.topic or "",
        cover=body.cover or "",
        stars=body.stars,
        status=body.status if body.status in VALID_STATUSES else "draft",
        published_at=body.published_at,
    )
    db.add(article)
    db.commit()
    db.refresh(article)
    data = article_detail(article, [])
    data["id"] = article.id
    data["status"] = article.status
    data["tts_status"] = article.tts_status or "none"
    return AdminArticleDetailOut(**data)


@router.get("/{ref}/", response_model=AdminArticleDetailOut)
def admin_get_article(
    ref: str,
    db: Session = Depends(get_db),
    _admin: User = Depends(get_current_admin),
):
    article = _require_article(db, ref)
    segments = (
        db.query(Article)
        .options(joinedload(Article.segments))
        .filter(Article.id == article.id)
        .first()
        .segments
    )
    data = article_detail(article, segments)
    data["id"] = article.id
    data["status"] = article.status
    data["tts_status"] = article.tts_status or "none"
    return AdminArticleDetailOut(**data)


@router.patch("/{ref}/", response_model=AdminArticleDetailOut)
def admin_update_article(
    ref: str,
    body: AdminArticleUpdateIn,
    db: Session = Depends(get_db),
    _admin: User = Depends(get_current_admin),
):
    article = _require_article(db, ref)
    for field in (
        "title",
        "summary",
        "source",
        "source_url",
        "topic",
        "cover",
        "stars",
        "status",
        "published_at",
    ):
        value = getattr(body, field, None)
        if value is not None:
            if field == "status" and value not in VALID_STATUSES:
                raise HTTPException(status_code=400, detail="无效状态")
            setattr(article, field, value)
    if body.status == "published" and not article.published_at:
        article.published_at = datetime.utcnow()
    db.commit()
    db.refresh(article)
    segments = (
        db.query(Article)
        .options(joinedload(Article.segments))
        .filter(Article.id == article.id)
        .first()
        .segments
    )
    data = article_detail(article, segments)
    data["id"] = article.id
    data["status"] = article.status
    data["tts_status"] = article.tts_status or "none"
    return AdminArticleDetailOut(**data)


@router.delete("/{ref}/")
def admin_delete_article(
    ref: str,
    db: Session = Depends(get_db),
    _admin: User = Depends(get_current_admin),
):
    article = _require_article(db, ref)
    delete_article_with_dependencies(db, article.id)
    return {"success": True}


@router.put("/{ref}/segments/")
def admin_replace_segments(
    ref: str,
    segments: list[AdminArticleSegmentIn],
    db: Session = Depends(get_db),
    _admin: User = Depends(get_current_admin),
):
    article = _require_article(db, ref)
    payload = [s.model_dump() for s in segments]
    replace_segments(db, article, payload)
    db.refresh(article)
    return {"segment_count": article.segment_count, "word_count": article.word_count}


@router.post("/{ref}/import-text/", response_model=AdminArticleImportTextOut)
def admin_import_text(
    ref: str,
    body: AdminArticleImportTextIn,
    db: Session = Depends(get_db),
    _admin: User = Depends(get_current_admin),
):
    article = _require_article(db, ref)
    if not body.english_text.strip():
        raise HTTPException(status_code=400, detail="english_text 不能为空")
    try:
        result = import_text_to_segments(
            db,
            article,
            body.english_text,
            auto_translate=body.auto_translate,
            auto_analyze=body.auto_analyze,
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e)) from e
    except RuntimeError as e:
        raise HTTPException(status_code=502, detail=str(e)) from e
    return AdminArticleImportTextOut(**result)


@router.post("/{ref}/analyze/")
def admin_analyze(
    ref: str,
    db: Session = Depends(get_db),
    _admin: User = Depends(get_current_admin),
):
    article = _require_article(db, ref)
    segments = (
        db.query(Article)
        .options(joinedload(Article.segments))
        .filter(Article.id == article.id)
        .first()
        .segments
    )
    if not segments:
        raise HTTPException(status_code=400, detail="无段落可分析")
    payload = [{"english": s.english, "chinese": s.chinese, "english_html": s.english_html} for s in segments]
    metrics = analyze_subtitles_with_deepseek(payload)
    replace_segments(db, article, payload)
    article.stars = metrics.get("stars") or article.stars
    db.commit()
    return metrics


@router.post("/{ref}/generate-tts/", response_model=AdminArticleTtsOut)
def admin_generate_tts(
    ref: str,
    db: Session = Depends(get_db),
    _admin: User = Depends(get_current_admin),
):
    article = _require_article(db, ref)
    segments = (
        db.query(Article)
        .options(joinedload(Article.segments))
        .filter(Article.id == article.id)
        .first()
        .segments
    )
    article.segments = segments
    try:
        result = generate_article_tts(db, article)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e)) from e
    except RuntimeError as e:
        raise HTTPException(status_code=502, detail=str(e)) from e
    return AdminArticleTtsOut(**result)


@router.post("/{ref}/publish/")
def admin_publish(
    ref: str,
    db: Session = Depends(get_db),
    _admin: User = Depends(get_current_admin),
):
    article = _require_article(db, ref)
    if article.segment_count <= 0:
        raise HTTPException(status_code=400, detail="请先导入段落再发布")
    article.status = "published"
    if not article.published_at:
        article.published_at = datetime.utcnow()
    db.commit()
    return {"success": True, "status": article.status}
