import secrets

from sqlalchemy import delete
from sqlalchemy.orm import Session

from ..models import (
    Article,
    ArticleSegment,
    UserArticleFavorite,
    UserArticleOpen,
    UserArticleProgress,
    UserVocabularyItem,
    UserWordLookup,
)
from .article_split import count_words_in_segments
from .subtitle_analyze import analyze_subtitles_with_deepseek

VALID_STATUSES = {"draft", "published", "archived"}


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
) -> dict:
    """Run DeepSeek on existing segments (translate / vocab highlight), then write back."""
    from ..dict.deepseek import translate_lines_with_deepseek

    article_id = article.id
    rows = (
        db.query(ArticleSegment)
        .filter(ArticleSegment.article_id == article_id)
        .order_by(ArticleSegment.index)
        .all()
    )
    if not rows:
        raise ValueError("无段落可增强")

    parts = [r.english or "" for r in rows]
    chinese_list = [r.chinese or "" for r in rows]
    html_list = [r.english_html or "" for r in rows]

    # Release transaction before long AI work
    db.commit()

    if translate:
        try:
            translated = translate_lines_with_deepseek(parts)
            chinese_list = [
                (translated[i] if i < len(translated) and translated[i] else chinese_list[i])
                for i in range(len(parts))
            ]
        except Exception as e:
            raise RuntimeError(f"机翻失败：{e}") from e

    segments = [
        {"english": parts[i], "chinese": chinese_list[i], "english_html": html_list[i]}
        for i in range(len(parts))
    ]

    stars = article.stars
    if analyze:
        metrics = analyze_article_segments(segments)
        stars = metrics.get("stars") or article.stars or 3
        # analyze mutates english_html on segment dicts in place via subtitle_analyze
    else:
        metrics = {}

    revive_db_session(db)
    article = _reload_article(db, article_id)
    replace_segments(db, article, segments)
    article.stars = stars
    db.commit()
    db.refresh(article)

    return {
        "segment_count": article.segment_count,
        "word_count": article.word_count,
        "stars": article.stars,
        "translated": bool(translate),
        "analyzed": bool(analyze),
        **({k: v for k, v in metrics.items() if k != "stars"} if isinstance(metrics, dict) else {}),
    }


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
    db.execute(delete(ArticleSegment).where(ArticleSegment.article_id == article_id))
    db.query(Article).filter(Article.id == article_id).delete(synchronize_session=False)
    db.commit()


def get_article_by_ref(db: Session, ref: str) -> Article | None:
    ref = ref.strip()
    if ref.isdigit():
        return db.query(Article).filter(Article.id == int(ref)).first()
    return db.query(Article).filter(Article.article_id == ref).first()
