import secrets

from sqlalchemy import delete
from sqlalchemy.orm import Session

from ..models import (
    Article,
    ArticleSegment,
    UserArticleFavorite,
    UserArticleOpen,
    UserArticleProgress,
    UserNotification,
    UserVocabularyItem,
    UserWordLookup,
)
from .article_split import count_words_in_segments
from .subtitle_analyze import analyze_subtitles_with_deepseek

VALID_STATUSES = {"draft", "published", "archived", "rejected"}


def generate_article_id() -> str:
    return secrets.token_urlsafe(11)[:15]


def revive_db_session(db: Session) -> None:
    """Long DeepSeek calls can leave a checked-out Postgres connection dead.

    pool_pre_ping only runs on checkout from the pool; a session that held the
    same connection idle for minutes still fails on the next SQL. Invalidate
    forces a fresh connection on the next use.
    """
    try:
        db.connection().invalidate()
    except Exception:
        pass
    try:
        db.rollback()
    except Exception:
        pass


def replace_segments(db: Session, article: Article, segments: list[dict]) -> None:
    db.execute(delete(ArticleSegment).where(ArticleSegment.article_id == article.id))
    for i, row in enumerate(segments):
        db.add(
            ArticleSegment(
                article_id=article.id,
                index=i,
                english=(row.get("english") or "").strip(),
                chinese=(row.get("chinese") or "").strip(),
                english_html=(row.get("english_html") or "").strip(),
            )
        )
    article.segment_count = len(segments)
    article.word_count = count_words_in_segments([s.get("english", "") for s in segments])
    article.tts_status = "none"
    db.commit()


def analyze_article_segments(segments: list[dict]) -> dict:
    return analyze_subtitles_with_deepseek(segments)


def _reload_article(db: Session, article_id: int) -> Article:
    article = db.query(Article).filter(Article.id == article_id).first()
    if not article:
        raise ValueError("文章不存在")
    return article


def import_text_to_segments(
    db: Session,
    article: Article,
    english_text: str,
    *,
    auto_translate: bool = False,
    auto_analyze: bool = False,
) -> dict:
    """Split English into segments and persist.

    Default is text-only (fast). Optional DeepSeek translate/analyze runs after
    the first save; the DB session is revived before writing AI results so a
    long API call cannot leave a dead Postgres connection.
    """
    from .article_split import split_into_segments
    from ..dict.deepseek import translate_lines_with_deepseek

    parts = split_into_segments(english_text)
    if not parts:
        raise ValueError("无法从文本中拆分出有效段落")

    article_id = article.id
    segments = [{"english": en, "chinese": "", "english_html": ""} for en in parts]

    # Always persist plain text first — keeps publishable state even if AI fails later.
    replace_segments(db, article, segments)
    article.word_count = count_words_in_segments(parts)
    db.commit()

    if not auto_translate and not auto_analyze:
        db.refresh(article)
        return {
            "segment_count": article.segment_count,
            "word_count": article.word_count,
            "stars": article.stars,
        }

    chinese_list: list[str] = [""] * len(parts)
    if auto_translate:
        try:
            chinese_list = translate_lines_with_deepseek(parts)
        except Exception:
            chinese_list = [""] * len(parts)

    segments = [
        {
            "english": en,
            "chinese": (chinese_list[i] if i < len(chinese_list) else ""),
            "english_html": "",
        }
        for i, en in enumerate(parts)
    ]

    stars = article.stars
    if auto_analyze:
        metrics = analyze_article_segments(segments)
        stars = metrics.get("stars") or article.stars or 3

    revive_db_session(db)
    article = _reload_article(db, article_id)
    replace_segments(db, article, segments)
    article.stars = stars
    article.word_count = count_words_in_segments(parts)
    db.commit()
    db.refresh(article)

    return {
        "segment_count": article.segment_count,
        "word_count": article.word_count,
        "stars": article.stars,
    }


def enrich_article_segments(
    db: Session,
    article: Article,
    *,
    translate: bool = True,
    analyze: bool = True,
    max_batches: int = 3,
    force_analyze: bool = False,
) -> dict:
    """Run DeepSeek on existing segments in small rounds; flush after each batch.

    Returns progress fields so the admin UI can loop until done=True.
    """
    from ..dict.deepseek import translate_lines_with_deepseek
    from .subtitle_analyze import (
        analyze_subtitles_with_deepseek,
        has_vocab_highlight_html,
        should_skip_annotate,
    )
    from .subtitle_translate import BATCH_SIZE as TRANSLATE_BATCH_SIZE

    article_id = article.id
    rows = (
        db.query(ArticleSegment)
        .filter(ArticleSegment.article_id == article_id)
        .order_by(ArticleSegment.index)
        .all()
    )
    if not rows:
        raise ValueError("无段落可增强")

    batches_budget = max(1, int(max_batches or 3))
    batches_used = 0
    translated_n = 0
    metrics: dict = {}
    metrics_applied = False

    db.commit()

    def _result(*, done: bool, phase: str, remaining: int, analyzed: bool) -> dict:
        art = _reload_article(db, article_id)
        return {
            "segment_count": art.segment_count,
            "word_count": art.word_count,
            "stars": art.stars,
            "translated": bool(translate),
            "analyzed": analyzed,
            "done": done,
            "phase": phase,
            "remaining": remaining,
            "translated_count": translated_n,
            "highlight_count": int(metrics.get("highlight_count") or 0),
            "annotate_failed": int(metrics.get("annotate_failed") or 0),
            "voca_size": int(metrics.get("voca_size") or 0),
        }

    if translate:
        while batches_used < batches_budget:
            rows = (
                db.query(ArticleSegment)
                .filter(ArticleSegment.article_id == article_id)
                .order_by(ArticleSegment.index)
                .all()
            )
            pending_zh = [
                r for r in rows if (r.english or "").strip() and not (r.chinese or "").strip()
            ]
            if not pending_zh:
                break

            chunk = pending_zh[:TRANSLATE_BATCH_SIZE]
            chunk_ids = [r.id for r in chunk]
            parts = [(r.english or "").strip() for r in chunk]
            try:
                translated = translate_lines_with_deepseek(parts)
            except Exception as e:
                raise RuntimeError(f"机翻失败：{e}") from e

            revive_db_session(db)
            for i, seg_id in enumerate(chunk_ids):
                seg = db.query(ArticleSegment).filter(ArticleSegment.id == seg_id).first()
                if not seg:
                    continue
                zh = (translated[i] if i < len(translated) else "") or ""
                if zh.strip():
                    seg.chinese = zh.strip()
                    translated_n += 1
            db.commit()
            batches_used += 1

        rows = (
            db.query(ArticleSegment)
            .filter(ArticleSegment.article_id == article_id)
            .order_by(ArticleSegment.index)
            .all()
        )
        pending_zh_left = sum(
            1 for r in rows if (r.english or "").strip() and not (r.chinese or "").strip()
        )
        if pending_zh_left:
            return _result(done=False, phase="translate", remaining=pending_zh_left, analyzed=False)

    if analyze:
        annotate_budget = batches_budget - batches_used
        if annotate_budget <= 0:
            rows = (
                db.query(ArticleSegment)
                .filter(ArticleSegment.article_id == article_id)
                .order_by(ArticleSegment.index)
                .all()
            )
            if force_analyze:
                remaining_hl = sum(1 for r in rows if (r.english or "").strip())
            else:
                remaining_hl = sum(
                    1
                    for r in rows
                    if (r.english or "").strip()
                    and not should_skip_annotate(r.english_html or "")
                )
            return _result(
                done=remaining_hl == 0,
                phase="done" if remaining_hl == 0 else "analyze",
                remaining=remaining_hl,
                analyzed=False,
            )

        if force_analyze:
            revive_db_session(db)
            rows = (
                db.query(ArticleSegment)
                .filter(ArticleSegment.article_id == article_id)
                .order_by(ArticleSegment.index)
                .all()
            )
            for r in rows:
                r.english_html = ""
            db.commit()
            force_analyze = False  # only clear once per job; subsequent rounds skip_highlighted
        while batches_used < batches_budget:
            revive_db_session(db)
            rows = (
                db.query(ArticleSegment)
                .filter(ArticleSegment.article_id == article_id)
                .order_by(ArticleSegment.index)
                .all()
            )
            segments = [
                {
                    "id": r.id,
                    "english": r.english or "",
                    "chinese": r.chinese or "",
                    "english_html": r.english_html or "",
                }
                for r in rows
            ]
            pending_before = sum(
                1
                for s in segments
                if (s["english"] or "").strip()
                and not should_skip_annotate(s.get("english_html") or "")
            )
            if pending_before == 0:
                break

            compute_metrics = not metrics_applied and not any(
                has_vocab_highlight_html(s.get("english_html") or "") for s in segments
            )
            metrics = analyze_subtitles_with_deepseek(
                segments,
                max_batches=1,
                skip_highlighted=True,
                compute_metrics=compute_metrics,
            )
            batches_used += max(1, int(metrics.get("batches_run") or 1))

            revive_db_session(db)
            for s in segments:
                seg = db.query(ArticleSegment).filter(ArticleSegment.id == s["id"]).first()
                if not seg:
                    continue
                html = (s.get("english_html") or "").strip()
                if html:
                    seg.english_html = html
            article = _reload_article(db, article_id)
            if compute_metrics:
                stars = int(metrics.get("stars") or 0)
                if 1 <= stars <= 5:
                    article.stars = stars
                metrics_applied = True
            db.commit()

            if int(metrics.get("annotate_remaining") or 0) == 0:
                break

        rows = (
            db.query(ArticleSegment)
            .filter(ArticleSegment.article_id == article_id)
            .order_by(ArticleSegment.index)
            .all()
        )
        remaining_hl = sum(
            1
            for r in rows
            if (r.english or "").strip()
            and not should_skip_annotate(r.english_html or "")
        )
        return _result(
            done=remaining_hl == 0,
            phase="done" if remaining_hl == 0 else "analyze",
            remaining=remaining_hl,
            analyzed=True,
        )

    return _result(done=True, phase="done", remaining=0, analyzed=False)


def delete_article_with_dependencies(db: Session, article_id: int) -> None:
    segment_ids = [
        r[0]
        for r in db.query(ArticleSegment.id).filter(ArticleSegment.article_id == article_id).all()
    ]
    if segment_ids:
        db.query(UserWordLookup).filter(UserWordLookup.segment_id.in_(segment_ids)).update(
            {UserWordLookup.segment_id: None, UserWordLookup.article_id: None},
            synchronize_session=False,
        )
        db.query(UserVocabularyItem).filter(UserVocabularyItem.source_segment_id.in_(segment_ids)).update(
            {
                UserVocabularyItem.source_segment_id: None,
                UserVocabularyItem.source_article_id: None,
            },
            synchronize_session=False,
        )
    db.query(UserWordLookup).filter(UserWordLookup.article_id == article_id).update(
        {UserWordLookup.article_id: None},
        synchronize_session=False,
    )
    db.query(UserVocabularyItem).filter(UserVocabularyItem.source_article_id == article_id).update(
        {
            UserVocabularyItem.source_article_id: None,
            UserVocabularyItem.source_segment_id: None,
        },
        synchronize_session=False,
    )
    db.query(UserArticleProgress).filter(UserArticleProgress.article_id == article_id).delete(
        synchronize_session=False
    )
    db.query(UserArticleFavorite).filter(UserArticleFavorite.article_id == article_id).delete(
        synchronize_session=False
    )
    db.query(UserArticleOpen).filter(UserArticleOpen.article_id == article_id).delete(
        synchronize_session=False
    )
    db.query(UserNotification).filter(UserNotification.article_id == article_id).update(
        {UserNotification.article_id: None},
        synchronize_session=False,
    )
    db.execute(delete(ArticleSegment).where(ArticleSegment.article_id == article_id))
    db.query(Article).filter(Article.id == article_id).delete(synchronize_session=False)
    db.commit()


def get_article_by_ref(db: Session, ref: str) -> Article | None:
    ref = ref.strip()
    if ref.isdigit():
        return db.query(Article).filter(Article.id == int(ref)).first()
    return db.query(Article).filter(Article.article_id == ref).first()
