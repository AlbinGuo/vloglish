from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session, joinedload

from ...database import get_db
from ...deps import get_current_admin
from ...models import Article, User
from ...schemas import (
    AdminArticleCreateIn,
    AdminArticleDetailOut,
    AdminArticleEnrichIn,
    AdminArticleEnrichOut,
    AdminArticleImportTextIn,
    AdminArticleImportTextOut,
    AdminArticleListOut,
    AdminArticleSegmentIn,
    AdminArticleTtsIn,
    AdminArticleTtsOut,
    AdminArticleUpdateIn,
    AdminArticleUploadCoverIn,
    AdminArticleUploadCoverOut,
    ArticleProgressUpdateIn,
)
from ...qiniu_storage import QiniuConfig
from ...serializers import article_detail, article_segment_out
from ...services.article_admin import (
    VALID_STATUSES,
    delete_article_with_dependencies,
    enrich_article_segments,
    generate_article_id,
    get_article_by_ref,
    import_text_to_segments,
    replace_segments,
)
from ...services.article_cover import normalize_image_url, upload_article_cover_from_url
from ...services.article_tts import generate_article_tts
from ...services.user_notifications import (
    maybe_notify_article_release,
    maybe_notify_article_submitter_on_status_change,
)

router = APIRouter(prefix="/api/admin/articles", tags=["admin-articles"])


def _fmt_dt(value: datetime | None) -> str:
    if not value:
        return ""
    return value.strftime("%Y-%m-%d %H:%M:%S")


def _get_submitter(db: Session, user_id: int | None) -> User | None:
    if not user_id:
        return None
    return db.query(User).filter(User.id == user_id).first()


def _article_list_item(article: Article, submitter: User | None = None) -> dict:
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
        "is_user_submitted": article.submitted_by_user_id is not None,
        "is_catalog_public": bool(getattr(article, "is_catalog_public", False)),
        "submitted_by_email": (submitter.email if submitter else ""),
    }


def _require_article(db: Session, ref: str) -> Article:
    article = get_article_by_ref(db, ref)
    if not article:
        raise HTTPException(status_code=404, detail="文章不存在")
    return article


def _admin_article_detail(db: Session, article: Article) -> AdminArticleDetailOut:
    loaded = (
        db.query(Article)
        .options(joinedload(Article.segments))
        .filter(Article.id == article.id)
        .first()
    )
    segments = loaded.segments if loaded else []
    data = article_detail(article, segments)
    data["id"] = article.id
    data["status"] = article.status
    data["tts_status"] = article.tts_status or "none"
    submitter = _get_submitter(db, article.submitted_by_user_id)
    data["is_user_submitted"] = article.submitted_by_user_id is not None
    data["is_catalog_public"] = bool(getattr(article, "is_catalog_public", False))
    data["submitted_by_user_id"] = article.submitted_by_user_id
    data["submitted_by_email"] = submitter.email if submitter else ""
    data["submitted_by_nickname"] = (submitter.nickname or "") if submitter else ""
    data["rejection_reason"] = article.rejection_reason or ""
    data["submit_body"] = article.submit_body or ""
    data["remark"] = article.remark or ""
    return AdminArticleDetailOut(**data)


@router.get("/", response_model=AdminArticleListOut)
def admin_list_articles(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    status: str | None = None,
    q: str | None = None,
    user_submitted: bool | None = Query(
        None,
        description="True=仅用户投稿，False=仅官方，空=全部",
    ),
    db: Session = Depends(get_db),
    _admin: User = Depends(get_current_admin),
):
    query = db.query(Article)
    if status:
        query = query.filter(Article.status == status)
    if user_submitted is True:
        query = query.filter(Article.submitted_by_user_id.isnot(None))
    elif user_submitted is False:
        query = query.filter(Article.submitted_by_user_id.is_(None))
    if q and q.strip():
        term = f"%{q.strip()}%"
        query = query.filter(Article.title.ilike(term))
    query = query.order_by(Article.created_at.desc())
    total = query.count()
    rows = query.offset((page - 1) * page_size).limit(page_size).all()
    submitter_ids = {a.submitted_by_user_id for a in rows if a.submitted_by_user_id}
    submitters = {}
    if submitter_ids:
        submitters = {
            u.id: u
            for u in db.query(User).filter(User.id.in_(submitter_ids)).all()
        }
    return AdminArticleListOut(
        count=total,
        results=[
            _article_list_item(a, submitters.get(a.submitted_by_user_id))
            for a in rows
        ],
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
    return _admin_article_detail(db, article)


@router.get("/{ref}/", response_model=AdminArticleDetailOut)
def admin_get_article(
    ref: str,
    db: Session = Depends(get_db),
    _admin: User = Depends(get_current_admin),
):
    article = _require_article(db, ref)
    return _admin_article_detail(db, article)


@router.patch("/{ref}/", response_model=AdminArticleDetailOut)
def admin_update_article(
    ref: str,
    body: AdminArticleUpdateIn,
    db: Session = Depends(get_db),
    _admin: User = Depends(get_current_admin),
):
    article = _require_article(db, ref)
    old_status = article.status
    data = body.model_dump(exclude_unset=True)

    next_status = data.get("status", article.status)
    if next_status == "rejected":
        reason = data.get("rejection_reason")
        if reason is None:
            reason = article.rejection_reason
        if not (reason and str(reason).strip()):
            raise HTTPException(status_code=400, detail="驳回时需填写原因")

    catalog_public = data.pop("is_catalog_public", None)

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
        "rejection_reason",
    ):
        if field not in data:
            continue
        value = data[field]
        if field == "status" and value not in VALID_STATUSES:
            raise HTTPException(status_code=400, detail="无效状态")
        if field == "rejection_reason":
            article.rejection_reason = (value or "").strip()
            continue
        setattr(article, field, value)

    if "vocab_summary" in data:
        article.vocab_summary = data["vocab_summary"] or ""

    if article.status == "published":
        if article.segment_count <= 0:
            raise HTTPException(status_code=400, detail="请先导入段落再发布")
        if not article.published_at:
            article.published_at = datetime.utcnow()
        article.rejection_reason = ""

    maybe_notify_article_submitter_on_status_change(
        db,
        article,
        old_status=old_status,
        new_status=article.status,
        rejection_reason=article.rejection_reason,
    )

    if catalog_public is not None and article.submitted_by_user_id is not None:
        want_public = bool(catalog_public)
        if want_public and article.status != "published":
            raise HTTPException(status_code=400, detail="请先发布后再设为全站可见")
        article.is_catalog_public = want_public
    elif article.submitted_by_user_id is None:
        article.is_catalog_public = False

    if article.status in ("rejected", "archived", "draft"):
        article.is_catalog_public = False

    maybe_notify_article_release(db, article)
    db.commit()
    db.refresh(article)
    return _admin_article_detail(db, article)


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


@router.post("/{ref}/analyze/", response_model=AdminArticleEnrichOut)
def admin_analyze(
    ref: str,
    body: AdminArticleEnrichIn | None = None,
    db: Session = Depends(get_db),
    _admin: User = Depends(get_current_admin),
):
    """仅重新分析词汇高亮（分轮续跑，默认 force 清空后重跑）。"""
    article = _require_article(db, ref)
    opts = body or AdminArticleEnrichIn(translate=False, analyze=True, force_analyze=True)
    try:
        result = enrich_article_segments(
            db,
            article,
            translate=False,
            analyze=True,
            max_batches=opts.max_batches,
            force_analyze=opts.force_analyze if body is not None else True,
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e)) from e
    except RuntimeError as e:
        raise HTTPException(status_code=502, detail=str(e)) from e
    return AdminArticleEnrichOut(
        segment_count=result.get("segment_count", 0),
        word_count=result.get("word_count", 0),
        stars=result.get("stars", article.stars),
        translated=False,
        analyzed=bool(result.get("analyzed")),
        voca_size=int(result.get("voca_size") or 0),
        highlight_count=int(result.get("highlight_count") or 0),
        annotate_failed=int(result.get("annotate_failed") or 0),
        done=bool(result.get("done", True)),
        phase=str(result.get("phase") or "done"),
        remaining=int(result.get("remaining") or 0),
        translated_count=0,
    )


@router.post("/{ref}/enrich/", response_model=AdminArticleEnrichOut)
def admin_enrich_article(
    ref: str,
    body: AdminArticleEnrichIn | None = None,
    db: Session = Depends(get_db),
    _admin: User = Depends(get_current_admin),
):
    """机翻 + 词汇高亮（对已有段落）。导入请先用纯文本 import-text。"""
    article = _require_article(db, ref)
    opts = body or AdminArticleEnrichIn()
    if not opts.translate and not opts.analyze:
        raise HTTPException(status_code=400, detail="translate / analyze 至少选一项")
    try:
        result = enrich_article_segments(
            db,
            article,
            translate=opts.translate,
            analyze=opts.analyze,
            max_batches=opts.max_batches,
            force_analyze=opts.force_analyze,
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e)) from e
    except RuntimeError as e:
        raise HTTPException(status_code=502, detail=str(e)) from e
    return AdminArticleEnrichOut(
        segment_count=result.get("segment_count", 0),
        word_count=result.get("word_count", 0),
        stars=result.get("stars", article.stars),
        translated=bool(result.get("translated")),
        analyzed=bool(result.get("analyzed")),
        voca_size=int(result.get("voca_size") or 0),
        highlight_count=int(result.get("highlight_count") or 0),
        annotate_failed=int(result.get("annotate_failed") or 0),
        done=bool(result.get("done", True)),
        phase=str(result.get("phase") or "done"),
        remaining=int(result.get("remaining") or 0),
        translated_count=int(result.get("translated_count") or 0),
    )


@router.post("/{ref}/upload-cover/", response_model=AdminArticleUploadCoverOut)
def admin_upload_cover(
    ref: str,
    body: AdminArticleUploadCoverIn,
    db: Session = Depends(get_db),
    _admin: User = Depends(get_current_admin),
):
    article = _require_article(db, ref)
    source_url = body.source_url.strip()
    if not source_url:
        raise HTTPException(status_code=400, detail="source_url 不能为空")
    try:
        normalize_image_url(source_url)
        cover_url = upload_article_cover_from_url(
            QiniuConfig.from_env(),
            article.article_id,
            source_url,
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e)) from e
    except RuntimeError as e:
        raise HTTPException(status_code=502, detail=str(e)) from e
    article.cover = cover_url
    db.commit()
    return AdminArticleUploadCoverOut(cover=cover_url)


@router.post("/{ref}/generate-tts/", response_model=AdminArticleTtsOut)
def admin_generate_tts(
    ref: str,
    body: AdminArticleTtsIn | None = None,
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
    opts = body or AdminArticleTtsIn()
    try:
        result = generate_article_tts(
            db,
            article,
            voice=opts.voice,
            max_segments=opts.max_segments,
            skip_existing=opts.skip_existing,
            force=opts.force,
        )
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
    old_status = article.status
    article.status = "published"
    article.rejection_reason = ""
    if not article.published_at:
        article.published_at = datetime.utcnow()
    maybe_notify_article_submitter_on_status_change(
        db,
        article,
        old_status=old_status,
        new_status=article.status,
        rejection_reason=article.rejection_reason,
    )
    maybe_notify_article_release(db, article)
    db.commit()
    return {"success": True, "status": article.status}
