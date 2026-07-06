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
    db.commit()


def analyze_article_segments(segments: list[dict]) -> dict:
    return analyze_subtitles_with_deepseek(segments)


def import_text_to_segments(
    db: Session,
    article: Article,
    english_text: str,
    *,
    auto_translate: bool = True,
    auto_analyze: bool = True,
) -> dict:
    from .article_split import split_into_segments
    from ..dict.deepseek import translate_lines_with_deepseek

    parts = split_into_segments(english_text)
    if not parts:
        raise ValueError("无法从文本中拆分出有效段落")

    chinese_list: list[str] = [""] * len(parts)
    if auto_translate:
        try:
            chinese_list = translate_lines_with_deepseek(parts)
        except Exception:
            chinese_list = [""] * len(parts)

    segments = [
        {"english": en, "chinese": (chinese_list[i] if i < len(chinese_list) else ""), "english_html": ""}
        for i, en in enumerate(parts)
    ]

    stars = article.stars
    if auto_analyze:
        metrics = analyze_article_segments(segments)
        stars = metrics.get("stars") or article.stars or 3

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
