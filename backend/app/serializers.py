from .models import Author, Episode, Entry, Tag
from .media import resolve_audio_url, resolve_video_url


def author_dict(author: Author) -> dict:
    return {
        "name": author.name,
        "gender": author.gender,
        "nationality": author.nationality,
        "accent": author.accent,
    }


def tags_list(episode: Episode) -> list[dict]:
    return [{"id": t.id, "name": t.name} for t in episode.tags]


def episode_summary(episode: Episode, *, is_favorite: bool = False, is_learned: bool = False) -> dict:
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
    }


def episode_detail(episode: Episode, total: int) -> dict:
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
                "thumbnail_url": episode.thumbnail_url,
            },
            "subtitles": [
                {
                    "id": s.id,
                    "index": s.index,
                    "start": s.start,
                    "end": s.end,
                    "english": s.english,
                    "chinese": s.chinese,
                    "ipa": s.ipa,
                    "english_html": s.english_html,
                }
                for s in sorted(episode.subtitles, key=lambda x: x.index)
            ],
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
