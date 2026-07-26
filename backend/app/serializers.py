from datetime import datetime

from .models import Article, ArticleSegment, Author, Episode, Entry, Tag, UserArticleProgress
from .media import resolve_audio_url, resolve_video_url
from .services.episode_admin import episode_is_new
from .services.vocab_summary import parse_vocab_summary


def author_dict(author: Author) -> dict:
    return {
        "id": author.id,
        "name": author.name,
        "gender": author.gender,
        "nationality": author.nationality,
        "accent": author.accent,
    }


def tags_list(episode: Episode) -> list[dict]:
    return [{"id": t.id, "name": t.name} for t in episode.tags]


def _series_brief(episode: Episode) -> dict:
    series = getattr(episode, "series", None)
    return {
        "series_id": episode.series_id,
        "series_slug": series.slug if series else "",
        "series_title": series.title if series else "",
        "series_index": episode.series_index,
    }


def episode_summary(
    episode: Episode,
    *,
    is_favorite: bool = False,
    is_learned: bool = False,
    progress_percent: float = 0,
) -> dict:
    created_at = episode.created_at.isoformat() + "Z" if episode.created_at else ""
    return {
        "index": episode.index,
        "video_id": episode.video_id,
        "short_title": episode.short_title,
        "summary": episode.summary,
        "remark": episode.remark or "",
        "stars": episode.stars,
        "voca_size": episode.voca_size,
        "subtitle_count": episode.subtitle_count,
        "clip_length": episode.clip_length,
        "cover": episode.cover,
        "author": author_dict(episode.author),
        "tags": tags_list(episode),
        "created_at": created_at,
        "is_learned": is_learned,
        "is_favorite": is_favorite,
        "progress_percent": progress_percent,
        "is_new": episode_is_new(episode),
        "is_pinned": bool(getattr(episode, "is_pinned", False)),
        **_series_brief(episode),
    }


def episode_detail(episode: Episode, total: int, *, series_nav: dict | None = None) -> dict:
    return {
        "episode": {
            "index": episode.index,
            "video_id": episode.video_id,
            "short_title": episode.short_title,
            "summary": episode.summary,
            "remark": episode.remark or "",
            "stars": episode.stars,
            "voca_size": episode.voca_size,
            "subtitle_count": episode.subtitle_count,
            "original_video_url": episode.original_video_url,
            "author": author_dict(episode.author),
            "tags": tags_list(episode),
            "media": {
                "video_url": resolve_video_url(
                    video_id=episode.video_id,
                    video_url=episode.video_url,
                    original_video_url=episode.original_video_url,
                ),
                "audio_url": resolve_audio_url(
                    video_id=episode.video_id,
                    audio_url=episode.audio_url,
                    video_url=episode.video_url,
                    original_video_url=episode.original_video_url,
                ),
                "thumbnail_url": episode.thumbnail_url or episode.cover,
            },
            "subtitles": [
                {
                    "id": s.id,
                    "index": s.index,
                    "start": s.start,
                    "end": s.end,
                    "english": s.english or "",
                    "chinese": s.chinese or "",
                    "ipa": s.ipa or "",
                    "english_html": s.english_html or "",
                }
                for s in sorted(episode.subtitles, key=lambda x: x.index)
            ],
            "series": series_nav,
            "vocab_summary": parse_vocab_summary(getattr(episode, "vocab_summary", None) or ""),
            "vocab_summary_text": getattr(episode, "vocab_summary", None) or "",
        },
        "total_episodes": total,
    }


def entry_detail(entry: Entry) -> dict:
    data = entry.detail
    return {
        "id": entry.id,
        "headword": entry.headword,
        "category": entry.category,
        "pronunciations": data.get("pronunciations", []),
        "definitions": data.get("definitions", []),
        "exam_tags": entry.exam_tags,
        "favorite": None,
    }


def entry_brief(entry: Entry) -> dict:
    return {
        "id": entry.id,
        "headword": entry.headword,
        "forms": entry.forms,
        "category": entry.category,
        "exam_tags": entry.exam_tags,
    }


def _article_fmt_dt(value: datetime | None) -> str:
    if not value:
        return ""
    return value.isoformat()


def article_segment_out(seg: ArticleSegment) -> dict:
    return {
        "id": seg.id,
        "index": seg.index,
        "english": seg.english,
        "chinese": seg.chinese or "",
        "english_html": seg.english_html or "",
        "audio_url": seg.audio_url or "",
        "duration_ms": seg.duration_ms or 0,
    }


def article_progress_out(row: UserArticleProgress | None) -> dict | None:
    if not row:
        return None
    return {
        "last_segment_index": row.last_segment_index,
        "max_reached_index": row.max_reached_index,
        "completion_percent": round(row.completion_percent, 1),
        "is_completed": row.is_completed,
        "last_read_at": _article_fmt_dt(row.last_read_at),
    }


def article_list_item(
    article: Article,
    *,
    progress: UserArticleProgress | None = None,
    accessible: bool = True,
) -> dict:
    return {
        "article_id": article.article_id,
        "title": article.title,
        "summary": article.summary or "",
        "source": article.source or "",
        "topic": article.topic or "",
        "stars": article.stars,
        "word_count": article.word_count,
        "segment_count": article.segment_count,
        "cover": article.cover or "",
        "published_at": _article_fmt_dt(article.published_at),
        "progress": article_progress_out(progress),
        "accessible": accessible,
    }


def article_detail(
    article: Article,
    segments: list[ArticleSegment],
    *,
    progress: UserArticleProgress | None = None,
) -> dict:
    return {
        "article_id": article.article_id,
        "title": article.title,
        "summary": article.summary or "",
        "source": article.source or "",
        "source_url": article.source_url or "",
        "topic": article.topic or "",
        "stars": article.stars,
        "word_count": article.word_count,
        "segment_count": article.segment_count,
        "cover": article.cover or "",
        "published_at": _article_fmt_dt(article.published_at),
        "tts_status": article.tts_status or "none",
        "segments": [article_segment_out(s) for s in segments],
        "progress": article_progress_out(progress),
    }
