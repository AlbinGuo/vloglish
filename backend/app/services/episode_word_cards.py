"""整集词卡：抽取高亮 → 查词 → 按视频缓存，跨用户共享。"""

from __future__ import annotations

import hashlib
import json
import logging
import threading
from datetime import datetime

from sqlalchemy.orm import Session, joinedload

from ..models import Episode, EpisodeWordCardCache, Subtitle
from .highlight_tokens import extract_highlight_tokens
from .word_lookup import resolve_word_lookup

logger = logging.getLogger(__name__)

_build_locks: dict[int, threading.Lock] = {}
_locks_guard = threading.Lock()

HIGHLIGHT_TYPE_LABELS = {
    "a": "单词",
    "d": "短语动词",
    "i": "惯用表达",
    "c": "固定搭配",
    "l": "长难表达",
    "f": "话语标记",
}


def _lock_for(episode_id: int) -> threading.Lock:
    with _locks_guard:
        lock = _build_locks.get(episode_id)
        if lock is None:
            lock = threading.Lock()
            _build_locks[episode_id] = lock
        return lock


def compute_subtitles_content_hash(subtitles: list[Subtitle]) -> str:
    parts: list[str] = []
    for sub in sorted(subtitles, key=lambda s: s.index):
        parts.append(f"{sub.id}|{sub.index}|{sub.english}|{sub.english_html}")
    raw = "\n".join(parts)
    return hashlib.sha256(raw.encode("utf-8")).hexdigest()


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


def invalidate_episode_word_cards(db: Session, episode_id: int) -> None:
    db.query(EpisodeWordCardCache).filter(EpisodeWordCardCache.episode_id == episode_id).delete(
        synchronize_session=False
    )


def _load_cache_row(db: Session, episode_id: int) -> EpisodeWordCardCache | None:
    return db.query(EpisodeWordCardCache).filter(EpisodeWordCardCache.episode_id == episode_id).first()


def _save_cache(db: Session, episode_id: int, content_hash: str, cards: list[dict]) -> None:
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
        if not exam_tags:
            continue

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
    若 content_hash 匹配已有缓存，直接返回；否则查词构建并写入共享缓存。
    """
    subtitles = list(episode.subtitles or [])
    if not subtitles:
        # 确保 relationship 已加载
        subtitles = (
            db.query(Subtitle)
            .filter(Subtitle.episode_id == episode.id)
            .order_by(Subtitle.index)
            .all()
        )

    content_hash = compute_subtitles_content_hash(subtitles)
    row = _load_cache_row(db, episode.id)
    if row and row.content_hash == content_hash:
        try:
            cards = json.loads(row.cards_json or "[]")
        except json.JSONDecodeError:
            cards = []
        if isinstance(cards, list):
            return {
                "video_id": episode.video_id,
                "from_cache": True,
                "count": len(cards),
                "cards": cards,
            }

    lock = _lock_for(episode.id)
    with lock:
        # 双检：等待期间可能已被其他请求写好
        db.expire_all()
        row = _load_cache_row(db, episode.id)
        if row and row.content_hash == content_hash:
            try:
                cards = json.loads(row.cards_json or "[]")
            except json.JSONDecodeError:
                cards = []
            if isinstance(cards, list):
                return {
                    "video_id": episode.video_id,
                    "from_cache": True,
                    "count": len(cards),
                    "cards": cards,
                }

        tokens = collect_episode_tokens(subtitles)
        logger.info(
            "Building episode word cards video_id=%s tokens=%d",
            episode.video_id,
            len(tokens),
        )
        cards = _build_cards(db, episode, tokens)
        _save_cache(db, episode.id, content_hash, cards)
        return {
            "video_id": episode.video_id,
            "from_cache": False,
            "count": len(cards),
            "cards": cards,
        }


def load_episode_for_word_cards(db: Session, video_id: str) -> Episode | None:
    return (
        db.query(Episode)
        .options(joinedload(Episode.subtitles))
        .filter(Episode.video_id == video_id, Episode.status == "published")
        .first()
    )
