"""整集词卡：抽取高亮 → 查词 → Redis（主）+ DB（兜底）跨用户共享缓存。"""

from __future__ import annotations

import hashlib
import json
import logging
import os
import threading
from datetime import datetime

from sqlalchemy.orm import Session, load_only

from ..models import Episode, EpisodeWordCardCache, Subtitle
from ..redis_client import get_redis
from .highlight_tokens import extract_highlight_tokens
from .word_lookup import resolve_word_lookup

logger = logging.getLogger(__name__)

_build_locks: dict[int, threading.Lock] = {}
_locks_guard = threading.Lock()

# Redis key：整集词卡 JSON；字幕变更时 DELETE
_REDIS_KEY_PREFIX = "vloglish:wordcards:v1:episode:"
# 0 = 不过期（直到 invalidate）；需要时可设 WORD_CARDS_REDIS_TTL_SECONDS
_REDIS_TTL_SEC = int(os.getenv("WORD_CARDS_REDIS_TTL_SECONDS", "0") or "0")

HIGHLIGHT_TYPE_LABELS = {
    "a": "核心词汇",
    "d": "短语动词",
    "i": "惯用表达",
    "c": "固定搭配",
    "l": "长难表达",
    "p": "专业词汇",
    "f": "话语标记",
}


def _lock_for(episode_id: int) -> threading.Lock:
    with _locks_guard:
        lock = _build_locks.get(episode_id)
        if lock is None:
            lock = threading.Lock()
            _build_locks[episode_id] = lock
        return lock


def _redis_key(episode_id: int) -> str:
    return f"{_REDIS_KEY_PREFIX}{episode_id}"


def compute_subtitles_content_hash(subtitles: list[Subtitle]) -> str:
    parts: list[str] = []
    for sub in sorted(subtitles, key=lambda s: s.index):
        parts.append(f"{sub.id}|{sub.index}|{sub.english}|{sub.english_html}")
    raw = "\n".join(parts)
    return hashlib.sha256(raw.encode("utf-8")).hexdigest()


def _load_subtitles_for_hash(db: Session, episode_id: int) -> list[Subtitle]:
    """只取算 hash / 抽词所需列，避免拖入无关字段。"""
    return (
        db.query(Subtitle)
        .options(
            load_only(
                Subtitle.id,
                Subtitle.episode_id,
                Subtitle.index,
                Subtitle.english,
                Subtitle.english_html,
            )
        )
        .filter(Subtitle.episode_id == episode_id)
        .order_by(Subtitle.index)
        .all()
    )


def collect_episode_tokens(subtitles: list[Subtitle]) -> list[dict]:
    """整集按词面去重，保留首次出现的字幕上下文。"""
    seen: set[str] = set()
    tokens: list[dict] = []
    for sub in sorted(subtitles, key=lambda s: s.index):
        for token in extract_highlight_tokens(sub.english_html or ""):
            key = token.word.lower()
            if key in seen:
                continue
            seen.add(key)
            tokens.append(
                {
                    "word": token.word,
                    "type": token.type,
                    "highlight": token.highlight,
                    "context": sub.english or "",
                    "subtitle_id": sub.id,
                }
            )
    return tokens


def _type_label(highlight: str | None, is_phrase: bool, category: str = "") -> str:
    if highlight and highlight in HIGHLIGHT_TYPE_LABELS:
        return HIGHLIGHT_TYPE_LABELS[highlight]
    cat = (category or "").strip()
    if cat in ("短语", "phrase", "Phrase"):
        return "短语"
    if cat in ("单词", "word", "Word"):
        return "单词"
    return "短语" if is_phrase else "单词"


def _primary_ipa(entry: dict) -> str:
    prons = entry.get("pronunciations") or []
    ipa = ""
    for p in prons:
        if not isinstance(p, dict):
            continue
        candidate = (p.get("ipa") or "").strip()
        if not candidate:
            continue
        if candidate.startswith("/") or candidate.startswith("["):
            formatted = candidate
        else:
            formatted = f"/{candidate}/"
        if p.get("is_primary"):
            return formatted
        if not ipa:
            ipa = formatted
    return ipa


def _first_meaning_cn(entry: dict) -> str:
    defs = entry.get("definitions") or []
    if not defs or not isinstance(defs[0], dict):
        return ""
    return (defs[0].get("definition_cn") or "").strip()


def _parse_cards_json(raw: str | None) -> list | None:
    try:
        cards = json.loads(raw or "[]")
    except json.JSONDecodeError:
        return None
    return cards if isinstance(cards, list) else None


def _payload(video_id: str, cards: list, *, from_cache: bool) -> dict:
    return {
        "video_id": video_id,
        "from_cache": from_cache,
        "count": len(cards),
        "cards": cards,
    }


def _redis_get_cards(episode_id: int) -> list | None:
    client = get_redis()
    if client is None:
        return None
    try:
        raw = client.get(_redis_key(episode_id))
        if not raw:
            return None
        data = json.loads(raw)
        if isinstance(data, dict):
            cards = data.get("cards")
            return cards if isinstance(cards, list) else None
        if isinstance(data, list):
            return data
        return None
    except Exception:
        logger.warning("Redis word-cards GET failed episode_id=%s", episode_id, exc_info=True)
        return None


def _redis_set_cards(episode_id: int, content_hash: str, cards: list[dict]) -> None:
    client = get_redis()
    if client is None:
        return
    try:
        blob = json.dumps(
            {
                "content_hash": content_hash,
                "cards": cards,
                "updated_at": datetime.utcnow().isoformat() + "Z",
            },
            ensure_ascii=False,
        )
        key = _redis_key(episode_id)
        if _REDIS_TTL_SEC > 0:
            client.setex(key, _REDIS_TTL_SEC, blob)
        else:
            client.set(key, blob)
    except Exception:
        logger.warning("Redis word-cards SET failed episode_id=%s", episode_id, exc_info=True)


def _redis_delete(episode_id: int) -> None:
    client = get_redis()
    if client is None:
        return
    try:
        client.delete(_redis_key(episode_id))
    except Exception:
        logger.warning("Redis word-cards DEL failed episode_id=%s", episode_id, exc_info=True)


def invalidate_episode_word_cards(db: Session, episode_id: int) -> None:
    _redis_delete(episode_id)
    db.query(EpisodeWordCardCache).filter(EpisodeWordCardCache.episode_id == episode_id).delete(
        synchronize_session=False
    )


def _load_cache_row(db: Session, episode_id: int) -> EpisodeWordCardCache | None:
    return db.query(EpisodeWordCardCache).filter(EpisodeWordCardCache.episode_id == episode_id).first()


def _save_db_cache(db: Session, episode_id: int, content_hash: str, cards: list[dict]) -> None:
    payload = json.dumps(cards, ensure_ascii=False)
    now = datetime.utcnow()
    row = _load_cache_row(db, episode_id)
    if row:
        row.content_hash = content_hash
        row.cards_json = payload
        row.updated_at = now
    else:
        db.add(
            EpisodeWordCardCache(
                episode_id=episode_id,
                content_hash=content_hash,
                cards_json=payload,
                updated_at=now,
            )
        )
    db.commit()


def _save_cache(db: Session, episode_id: int, content_hash: str, cards: list[dict]) -> None:
    """同时写入 Redis（热）与 DB（冷备份）。"""
    _redis_set_cards(episode_id, content_hash, cards)
    _save_db_cache(db, episode_id, content_hash, cards)


def _build_cards(db: Session, episode: Episode, tokens: list[dict]) -> list[dict]:
    cards: list[dict] = []
    for token in tokens:
        try:
            entry = resolve_word_lookup(db, token["word"], token["type"], token["context"])
        except Exception:
            logger.exception(
                "word card lookup failed episode=%s word=%r",
                episode.video_id,
                token["word"],
            )
            continue

        exam_tags = entry.get("exam_tags") or []
        # 凡 AI 高亮的重点词都进词卡；考试标签有则展示，无则不强制
        highlight = token.get("highlight")
        type_label = _type_label(highlight, token["type"] == 2, entry.get("category") or "")
        cards.append(
            {
                "word": token["word"],
                "type": token["type"],
                "context": token["context"],
                "highlight": highlight,
                "subtitle_id": token.get("subtitle_id"),
                "type_label": type_label,
                "exam_tags": exam_tags,
                "ipa": _primary_ipa(entry),
                "meaning": _first_meaning_cn(entry) or "暂无释义",
                "entry": entry,
            }
        )
    return cards


def get_or_build_episode_word_cards(db: Session, episode: Episode) -> dict:
    """
    返回整集词卡。

    命中顺序：Redis → DB（并回填 Redis）→ 现查现建。
    字幕变更经 invalidate 同时删 Redis + DB。
    """
    # 1) Redis 热缓存（跨 worker / 跨用户）
    redis_cards = _redis_get_cards(episode.id)
    if redis_cards is not None:
        return _payload(episode.video_id, redis_cards, from_cache=True)

    # 2) DB 冷备份：命中后回填 Redis
    row = _load_cache_row(db, episode.id)
    if row:
        cards = _parse_cards_json(row.cards_json)
        if cards is not None:
            _redis_set_cards(episode.id, row.content_hash or "", cards)
            return _payload(episode.video_id, cards, from_cache=True)

    lock = _lock_for(episode.id)
    with lock:
        redis_cards = _redis_get_cards(episode.id)
        if redis_cards is not None:
            return _payload(episode.video_id, redis_cards, from_cache=True)

        db.expire_all()
        row = _load_cache_row(db, episode.id)
        if row:
            cards = _parse_cards_json(row.cards_json)
            if cards is not None:
                _redis_set_cards(episode.id, row.content_hash or "", cards)
                return _payload(episode.video_id, cards, from_cache=True)

        subtitles = _load_subtitles_for_hash(db, episode.id)
        content_hash = compute_subtitles_content_hash(subtitles)
        tokens = collect_episode_tokens(subtitles)
        logger.info(
            "Building episode word cards video_id=%s tokens=%d",
            episode.video_id,
            len(tokens),
        )
        cards = _build_cards(db, episode, tokens)
        _save_cache(db, episode.id, content_hash, cards)
        return _payload(episode.video_id, cards, from_cache=False)


def load_episode_for_word_cards(db: Session, video_id: str) -> Episode | None:
    """只加载剧集本身；字幕按需在 get_or_build 里轻量查询。"""
    return (
        db.query(Episode)
        .filter(Episode.video_id == video_id, Episode.status == "published")
        .first()
    )
