"""单词拼写练习：抽词、结算、错词本。"""

from __future__ import annotations

import json
import random
import re
from datetime import datetime
from typing import Any

from sqlalchemy.orm import Session

from ..models import (
    ArticleSegment,
    Episode,
    Subtitle,
    UserVocabularyItem,
    WordPracticeSession,
    WordPracticeStat,
    WordPracticeWrong,
)
from .entry_lookup import entry_vocab_extras, lookup_result_by_entry_id
from .example_translation import lookup_cached_example_zh

WORD_RE = re.compile(r"^[A-Za-z][A-Za-z\-']{0,63}$")


def _norm_word(raw: str) -> str:
    return (raw or "").strip()


def _is_practiceable(word: str) -> bool:
    w = _norm_word(word)
    return bool(w) and bool(WORD_RE.match(w)) and " " not in w


def _resolve_video_ref(db: Session, row: UserVocabularyItem, cache: dict[int, str]) -> str:
    if row.source_type == "article":
        return ""
    if row.source_episode_id:
        if row.source_episode_id not in cache:
            ep = db.query(Episode.video_id).filter(Episode.id == row.source_episode_id).first()
            cache[row.source_episode_id] = ep[0] if ep else ""
        if cache[row.source_episode_id]:
            return cache[row.source_episode_id]
    return (row.source_video_id or "").strip()


def _example_from_entry(db: Session, entry_id: int) -> tuple[str, str]:
    """词条例句兜底：(英文, 中文)。"""
    cached = lookup_result_by_entry_id(db, entry_id) or {}
    examples = cached.get("examples") or []
    for ex in examples:
        if not isinstance(ex, dict):
            continue
        en = (ex.get("example_en") or ex.get("en") or "").strip()
        zh = (ex.get("example_cn") or ex.get("zh") or ex.get("cn") or "").strip()
        if en:
            return en[:280], zh[:280]
    return "", ""


def _context_for_item(db: Session, row: UserVocabularyItem) -> tuple[str, str]:
    """来源语境优先：字幕 → 文章段落 → 词条例句。返回 (英文, 中文)。"""
    if row.source_subtitle_id:
        sub = db.query(Subtitle).filter(Subtitle.id == row.source_subtitle_id).first()
        if sub and (sub.english or "").strip():
            return (sub.english or "").strip()[:280], (sub.chinese or "").strip()[:280]
    if row.source_segment_id:
        seg = db.query(ArticleSegment).filter(ArticleSegment.id == row.source_segment_id).first()
        if seg and (seg.english or "").strip():
            return (seg.english or "").strip()[:280], (seg.chinese or "").strip()[:280]
    return _example_from_entry(db, row.entry_id)


def _practice_priority(
    entry_id: int,
    *,
    stats: dict[int, WordPracticeStat],
    open_wrong_ids: set[int],
) -> int:
    """抽词优先级：数字越小越优先。错词/复习 > 未练 > 学习中 > 已掌握。"""
    if entry_id in open_wrong_ids:
        return 0
    stat = stats.get(entry_id)
    if not stat or int(stat.practice_count or 0) <= 0:
        return 1
    status = (stat.status or "new").strip().lower()
    if status == "review":
        return 0
    if status == "new":
        return 1
    if status == "known":
        return 3
    # learning / 其他
    return 2


_EPOCH = datetime(1970, 1, 1)


def _as_sort_ts(value: datetime | None, *, default: datetime | None = None) -> float:
    """转成可排序的 epoch 秒；避免 Windows 上 datetime.min.timestamp() 报错。"""
    dt = value or default or _EPOCH
    if dt < _EPOCH:
        dt = _EPOCH
    try:
        return dt.timestamp()
    except (OSError, OverflowError, ValueError):
        return 0.0


def _rank_key_for_item(
    row: UserVocabularyItem,
    *,
    stats: dict[int, WordPracticeStat],
    open_wrong_ids: set[int],
    wrong_recency: dict[int, datetime],
) -> tuple:
    """同优先级内：错词按最近错误，未练按收藏新近，其余按最久未练优先。"""
    pri = _practice_priority(row.entry_id, stats=stats, open_wrong_ids=open_wrong_ids)
    if pri == 0:
        # 最近错的优先（时间戳越大越前 → 用负值）
        return (
            pri,
            -_as_sort_ts(wrong_recency.get(row.entry_id)),
            -_as_sort_ts(row.created_at),
        )
    if pri == 1:
        return (pri, -_as_sort_ts(row.created_at), row.entry_id)
    stat = stats.get(row.entry_id)
    last = stat.last_practiced_at if stat else None
    # 最久未练优先
    return (pri, _as_sort_ts(last), row.entry_id)


def pick_vocab_items(
    db: Session,
    user_id: int,
    *,
    source: str,
    video_id: str = "",
    limit: int = 15,
) -> list[dict[str, Any]]:
    cap = max(1, min(int(limit or 15), 50))
    q = db.query(UserVocabularyItem).filter(UserVocabularyItem.user_id == user_id)
    rows = q.order_by(UserVocabularyItem.created_at.desc()).all()
    video_cache: dict[int, str] = {}
    picked: list[UserVocabularyItem] = []

    open_wrongs = (
        db.query(WordPracticeWrong)
        .filter(
            WordPracticeWrong.user_id == user_id,
            WordPracticeWrong.resolved_at.is_(None),
        )
        .order_by(WordPracticeWrong.last_wrong_at.desc())
        .all()
    )
    open_wrong_ids = {w.entry_id for w in open_wrongs}
    wrong_recency = {w.entry_id: w.last_wrong_at or datetime.min for w in open_wrongs}

    if source == "vocab_wrong":
        by_entry = {r.entry_id: r for r in rows}
        for w in open_wrongs:
            item = by_entry.get(w.entry_id)
            if item and _is_practiceable(item.word):
                picked.append(item)
            if len(picked) >= cap:
                break
    else:
        vid = (video_id or "").strip()
        candidates: list[UserVocabularyItem] = []
        for row in rows:
            if not _is_practiceable(row.word):
                continue
            if source == "episode_vocab":
                if not vid:
                    continue
                ref = _resolve_video_ref(db, row, video_cache)
                if ref != vid:
                    continue
            candidates.append(row)

        # 同 entry 去重，保留最近收藏
        seen: set[int] = set()
        unique: list[UserVocabularyItem] = []
        for row in candidates:
            if row.entry_id in seen:
                continue
            seen.add(row.entry_id)
            unique.append(row)

        entry_ids = [r.entry_id for r in unique]
        stats_rows = (
            db.query(WordPracticeStat)
            .filter(
                WordPracticeStat.user_id == user_id,
                WordPracticeStat.entry_id.in_(entry_ids),
            )
            .all()
            if entry_ids
            else []
        )
        stats = {s.entry_id: s for s in stats_rows}

        # 分桶：错词/复习 → 未练 → 学习中 → 已掌握；前两档稳定可预期，后两档轻量打乱
        buckets: dict[int, list[UserVocabularyItem]] = {0: [], 1: [], 2: [], 3: []}
        for row in unique:
            pri = _practice_priority(row.entry_id, stats=stats, open_wrong_ids=open_wrong_ids)
            buckets.setdefault(pri, []).append(row)

        ordered: list[UserVocabularyItem] = []
        for pri in (0, 1, 2, 3):
            bucket = buckets.get(pri) or []
            if not bucket:
                continue
            bucket.sort(
                key=lambda r: _rank_key_for_item(
                    r,
                    stats=stats,
                    open_wrong_ids=open_wrong_ids,
                    wrong_recency=wrong_recency,
                )
            )
            if pri >= 2 and len(bucket) > 1:
                random.shuffle(bucket)
            ordered.extend(bucket)

        picked = ordered[:cap]

    items: list[dict[str, Any]] = []
    for row in picked:
        _tags, ipa, definition_cn = entry_vocab_extras(db, row.entry_id)
        context_en, context_zh = _context_for_item(db, row)
        # 开局只读共享缓存补中文，不在此处调 AI（按需由 translate 接口触发）
        if context_en and not (context_zh or "").strip():
            context_zh = lookup_cached_example_zh(db, context_en)
        items.append(
            {
                "vocabulary_item_id": row.id,
                "entry_id": row.entry_id,
                "word": _norm_word(row.word),
                "ipa": ipa or "",
                "definition_cn": definition_cn or "",
                "source_video_id": _resolve_video_ref(db, row, video_cache),
                "source_subtitle_id": row.source_subtitle_id,
                "source_segment_id": row.source_segment_id,
                "context": context_en,
                "context_zh": context_zh or "",
            }
        )
    return items


def start_session(
    db: Session,
    user_id: int,
    *,
    source: str,
    video_id: str = "",
    limit: int = 15,
) -> WordPracticeSession:
    src = source if source in {"vocab", "episode_vocab", "vocab_wrong"} else "vocab"
    items = pick_vocab_items(db, user_id, source=src, video_id=video_id, limit=limit)
    if not items:
        raise ValueError("暂无可练习的单词（需为单个英文词，且已在生词本中）")
    row = WordPracticeSession(
        user_id=user_id,
        source=src,
        mode="type",
        video_id=(video_id or "").strip() if src == "episode_vocab" else "",
        total_count=len(items),
        items_json=json.dumps(items, ensure_ascii=False),
    )
    db.add(row)
    db.commit()
    db.refresh(row)
    return row


def session_to_start_dict(row: WordPracticeSession) -> dict[str, Any]:
    items = json.loads(row.items_json or "[]")
    return {
        "session_id": row.id,
        "source": row.source,
        "video_id": row.video_id,
        "total_count": row.total_count,
        "items": items,
    }


def _upsert_stat(
    db: Session,
    user_id: int,
    *,
    entry_id: int,
    vocabulary_item_id: int | None,
    had_wrong: bool,
) -> None:
    now = datetime.utcnow()
    stat = (
        db.query(WordPracticeStat)
        .filter(WordPracticeStat.user_id == user_id, WordPracticeStat.entry_id == entry_id)
        .first()
    )
    if not stat:
        stat = WordPracticeStat(
            user_id=user_id,
            entry_id=entry_id,
            vocabulary_item_id=vocabulary_item_id,
        )
        db.add(stat)
    stat.practice_count = int(stat.practice_count or 0) + 1
    stat.last_practiced_at = now
    if vocabulary_item_id:
        stat.vocabulary_item_id = vocabulary_item_id
    if had_wrong:
        stat.wrong_count_total = int(stat.wrong_count_total or 0) + 1
        stat.correct_streak = 0
        stat.status = "review"
    else:
        stat.correct_streak = int(stat.correct_streak or 0) + 1
        if stat.correct_streak >= 2 and int(stat.wrong_count_total or 0) == 0:
            stat.status = "known"
        elif stat.correct_streak >= 2:
            stat.status = "learning"
        else:
            stat.status = "learning"


def _touch_wrong(
    db: Session,
    user_id: int,
    *,
    entry_id: int,
    vocabulary_item_id: int | None,
    word: str,
    had_wrong: bool,
) -> None:
    now = datetime.utcnow()
    row = (
        db.query(WordPracticeWrong)
        .filter(WordPracticeWrong.user_id == user_id, WordPracticeWrong.entry_id == entry_id)
        .first()
    )
    if had_wrong:
        if not row:
            db.add(
                WordPracticeWrong(
                    user_id=user_id,
                    entry_id=entry_id,
                    vocabulary_item_id=vocabulary_item_id,
                    word=word,
                    wrong_count=1,
                    last_wrong_at=now,
                    resolved_at=None,
                )
            )
        else:
            row.wrong_count = int(row.wrong_count or 0) + 1
            row.last_wrong_at = now
            row.resolved_at = None
            row.word = word or row.word
            if vocabulary_item_id:
                row.vocabulary_item_id = vocabulary_item_id
    elif row and row.resolved_at is None:
        row.resolved_at = now


def finish_session(
    db: Session,
    user_id: int,
    session_id: int,
    *,
    results: list[dict[str, Any]],
    duration_ms: int = 0,
    chars_typed: int = 0,
) -> dict[str, Any]:
    row = (
        db.query(WordPracticeSession)
        .filter(WordPracticeSession.id == session_id, WordPracticeSession.user_id == user_id)
        .first()
    )
    if not row:
        raise ValueError("练习会话不存在")
    if row.finished_at:
        return {
            "session_id": row.id,
            "total_count": row.total_count,
            "correct_count": row.correct_count,
            "wrong_count": row.wrong_count,
            "duration_ms": row.duration_ms,
            "chars_typed": row.chars_typed,
        }

    items = {int(i["entry_id"]): i for i in json.loads(row.items_json or "[]") if i.get("entry_id")}
    clean_results: list[dict[str, Any]] = []
    wrong_n = 0
    for raw in results:
        try:
            entry_id = int(raw.get("entry_id") or 0)
        except (TypeError, ValueError):
            continue
        if entry_id not in items:
            continue
        try_count = max(1, int(raw.get("try_count") or 1))
        had_wrong = try_count > 1 or bool(raw.get("had_wrong"))
        if had_wrong:
            wrong_n += 1
        item = items[entry_id]
        clean_results.append(
            {
                "entry_id": entry_id,
                "vocabulary_item_id": item.get("vocabulary_item_id"),
                "word": item.get("word") or "",
                "try_count": try_count,
                "had_wrong": had_wrong,
                "latency_ms": max(0, int(raw.get("latency_ms") or 0)),
            }
        )
        _upsert_stat(
            db,
            user_id,
            entry_id=entry_id,
            vocabulary_item_id=item.get("vocabulary_item_id"),
            had_wrong=had_wrong,
        )
        _touch_wrong(
            db,
            user_id,
            entry_id=entry_id,
            vocabulary_item_id=item.get("vocabulary_item_id"),
            word=str(item.get("word") or ""),
            had_wrong=had_wrong,
        )

    row.results_json = json.dumps(clean_results, ensure_ascii=False)
    row.correct_count = max(0, len(clean_results) - wrong_n)
    row.wrong_count = wrong_n
    row.duration_ms = max(0, int(duration_ms or 0))
    row.chars_typed = max(0, int(chars_typed or 0))
    row.finished_at = datetime.utcnow()
    db.commit()
    db.refresh(row)
    return {
        "session_id": row.id,
        "total_count": row.total_count,
        "correct_count": row.correct_count,
        "wrong_count": row.wrong_count,
        "duration_ms": row.duration_ms,
        "chars_typed": row.chars_typed,
        "accuracy": round((row.correct_count / row.total_count) * 100) if row.total_count else 0,
    }


def list_wrongs(db: Session, user_id: int, *, limit: int = 100) -> list[dict[str, Any]]:
    rows = (
        db.query(WordPracticeWrong)
        .filter(WordPracticeWrong.user_id == user_id, WordPracticeWrong.resolved_at.is_(None))
        .order_by(WordPracticeWrong.last_wrong_at.desc())
        .limit(max(1, min(limit, 200)))
        .all()
    )
    out: list[dict[str, Any]] = []
    for row in rows:
        _tags, ipa, definition_cn = entry_vocab_extras(db, row.entry_id)
        out.append(
            {
                "id": row.id,
                "entry_id": row.entry_id,
                "vocabulary_item_id": row.vocabulary_item_id,
                "word": row.word,
                "wrong_count": row.wrong_count,
                "last_wrong_at": row.last_wrong_at.strftime("%Y-%m-%d %H:%M:%S") if row.last_wrong_at else "",
                "ipa": ipa or "",
                "definition_cn": definition_cn or "",
            }
        )
    return out


def wrong_count(db: Session, user_id: int) -> int:
    return (
        db.query(WordPracticeWrong)
        .filter(WordPracticeWrong.user_id == user_id, WordPracticeWrong.resolved_at.is_(None))
        .count()
    )
