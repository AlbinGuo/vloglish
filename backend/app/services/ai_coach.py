"""AI 教练业务：讲解、挖空、跟读、每日路径、读报问答、错词复习。"""

from __future__ import annotations

import hashlib
import logging
from collections.abc import Iterator
from datetime import datetime
from typing import Any

from fastapi import HTTPException
from sqlalchemy.orm import Session

logger = logging.getLogger(__name__)

from ..demo_access import can_access_episode
from ..dict.ai_learning import (
    explain_subtitle_sentence,
    explain_subtitle_sentence_stream,
    generate_cloze,
    reading_qa,
    shadowing_feedback,
    vocab_review_cards,
)
from ..models import Article, ArticleSegment, Episode, Subtitle, User, UserEpisodeProgress, UserVocabularyItem
from ..services.article_access import can_access_article
from .ai_quota import check_and_consume
from .ai_result_cache import content_hash, get_ai_result, set_ai_result
from .daily_visits import visit_date_now
from .oral_eval import (
    CORE_PASSAGE,
    CORE_SENT,
    CORE_WORD,
    build_feedback_from_oral_result,
    oral_eval_accent,
    oral_eval_app_id,
    oral_eval_configured,
    oral_eval_sdk_url,
    request_warrant,
)
from .practice_records import create_practice_record, mode_from_core_type

# 当日错词复习卡缓存（进程内；多 worker 不共享）。键：user_id:YYYY-MM-DD:fingerprint
_VOCAB_REVIEW_CACHE: dict[str, dict] = {}


def _subtitle_neighbors(db: Session, episode_id: int, subtitle_id: int) -> tuple[str, str]:
    neighbors = (
        db.query(Subtitle)
        .filter(Subtitle.episode_id == episode_id)
        .order_by(Subtitle.index.asc())
        .all()
    )
    before = after = ""
    for i, row in enumerate(neighbors):
        if row.id == subtitle_id:
            if i > 0:
                before = neighbors[i - 1].english or ""
            if i + 1 < len(neighbors):
                after = neighbors[i + 1].english or ""
            break
    return before, after


def explain_subtitle(
    db: Session,
    user: User,
    *,
    video_id: str,
    subtitle_id: int,
    force: bool = False,
) -> dict:
    episode = db.query(Episode).filter(Episode.video_id == video_id).first()
    if not episode:
        raise HTTPException(status_code=404, detail="剧集不存在")
    if not can_access_episode(db, episode, user):
        raise HTTPException(status_code=403, detail="当前无权学习该内容，请开通会员或选择免费内容")

    sub = (
        db.query(Subtitle)
        .filter(Subtitle.id == subtitle_id, Subtitle.episode_id == episode.id)
        .first()
    )
    if not sub:
        raise HTTPException(status_code=404, detail="字幕不存在")

    before, after = _subtitle_neighbors(db, episode.id, sub.id)
    digest = content_hash(
        sub.english or "",
        sub.chinese or "",
        before,
        after,
        episode.short_title or "",
    )

    if not force:
        cached = get_ai_result("explain", subtitle_id, digest)
        if cached:
            return {
                "video_id": video_id,
                "subtitle_id": subtitle_id,
                "english": sub.english or "",
                "chinese": sub.chinese or "",
                **cached,
                "quota": None,
                "from_cache": True,
            }

    quota = check_and_consume(db, user, action="ai")
    try:
        result = explain_subtitle_sentence(
            english=sub.english or "",
            chinese=sub.chinese or "",
            context_before=before,
            context_after=after,
            episode_title=episode.short_title or "",
        )
    except RuntimeError as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc

    set_ai_result("explain", subtitle_id, digest, result)
    return {
        "video_id": video_id,
        "subtitle_id": subtitle_id,
        "english": sub.english or "",
        "chinese": sub.chinese or "",
        **result,
        "quota": quota,
        "from_cache": False,
    }


def explain_subtitle_stream(
    db: Session,
    user: User,
    *,
    video_id: str,
    subtitle_id: int,
    force: bool = False,
) -> Iterator[dict[str, Any]]:
    """SSE 事件流：meta → field* → done；错误时 yield error。"""
    episode = db.query(Episode).filter(Episode.video_id == video_id).first()
    if not episode:
        yield {"type": "error", "detail": "剧集不存在"}
        return
    if not can_access_episode(db, episode, user):
        yield {"type": "error", "detail": "当前无权学习该内容，请开通会员或选择免费内容"}
        return

    sub = (
        db.query(Subtitle)
        .filter(Subtitle.id == subtitle_id, Subtitle.episode_id == episode.id)
        .first()
    )
    if not sub:
        yield {"type": "error", "detail": "字幕不存在"}
        return

    before, after = _subtitle_neighbors(db, episode.id, sub.id)
    digest = content_hash(
        sub.english or "",
        sub.chinese or "",
        before,
        after,
        episode.short_title or "",
    )
    base = {
        "video_id": video_id,
        "subtitle_id": subtitle_id,
        "english": sub.english or "",
        "chinese": sub.chinese or "",
    }

    if not force:
        cached = get_ai_result("explain", subtitle_id, digest)
        if cached:
            yield {
                "type": "meta",
                **base,
                "from_cache": True,
                "quota": None,
            }
            for key in ("plain_chinese", "structure", "expressions", "paraphrase", "tip"):
                if key in cached:
                    yield {"type": "field", "key": key, "value": cached[key]}
            yield {
                "type": "done",
                "result": {**base, **cached, "quota": None, "from_cache": True},
            }
            return

    try:
        quota = check_and_consume(db, user, action="ai")
    except HTTPException as exc:
        detail = exc.detail if isinstance(exc.detail, str) else "今日 AI 次数已用完"
        yield {"type": "error", "detail": detail}
        return

    yield {
        "type": "meta",
        **base,
        "from_cache": False,
        "quota": quota,
    }

    result: dict[str, Any] = {
        "plain_chinese": "",
        "structure": "",
        "expressions": [],
        "paraphrase": "",
        "tip": "",
    }
    try:
        for event in explain_subtitle_sentence_stream(
            english=sub.english or "",
            chinese=sub.chinese or "",
            context_before=before,
            context_after=after,
            episode_title=episode.short_title or "",
        ):
            if event.get("type") == "field":
                key = str(event.get("key") or "")
                if key in result:
                    result[key] = event.get("value")
                yield event
            elif event.get("type") == "done":
                done_result = event.get("result")
                if isinstance(done_result, dict):
                    result = {
                        "plain_chinese": str(done_result.get("plain_chinese") or "").strip(),
                        "structure": str(done_result.get("structure") or "").strip(),
                        "expressions": done_result.get("expressions")
                        if isinstance(done_result.get("expressions"), list)
                        else [],
                        "paraphrase": str(done_result.get("paraphrase") or "").strip(),
                        "tip": str(done_result.get("tip") or "").strip(),
                    }
    except RuntimeError as exc:
        yield {"type": "error", "detail": str(exc)}
        return

    set_ai_result("explain", subtitle_id, digest, result)
    yield {
        "type": "done",
        "result": {**base, **result, "quota": quota, "from_cache": False},
    }


def cloze_for_subtitle(
    db: Session,
    user: User,
    *,
    video_id: str,
    subtitle_id: int,
    force: bool = False,
) -> dict:
    episode = db.query(Episode).filter(Episode.video_id == video_id).first()
    if not episode:
        raise HTTPException(status_code=404, detail="剧集不存在")
    if not can_access_episode(db, episode, user):
        raise HTTPException(status_code=403, detail="当前无权学习该内容")
    sub = (
        db.query(Subtitle)
        .filter(Subtitle.id == subtitle_id, Subtitle.episode_id == episode.id)
        .first()
    )
    if not sub or not (sub.english or "").strip():
        raise HTTPException(status_code=404, detail="字幕不存在")

    english = sub.english or ""
    digest = content_hash(english)

    if not force:
        cached = get_ai_result("cloze", subtitle_id, digest)
        if cached:
            return {
                "video_id": video_id,
                "subtitle_id": subtitle_id,
                "english": english,
                "chinese": sub.chinese or "",
                **cached,
                "quota": None,
                "from_cache": True,
            }

    quota = check_and_consume(db, user, action="ai")
    try:
        cloze = generate_cloze(english)
    except RuntimeError as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc

    set_ai_result("cloze", subtitle_id, digest, cloze)
    return {
        "video_id": video_id,
        "subtitle_id": subtitle_id,
        "english": english,
        "chinese": sub.chinese or "",
        **cloze,
        "quota": quota,
        "from_cache": False,
    }


def _load_subtitle_for_user(
    db: Session,
    user: User,
    *,
    video_id: str,
    subtitle_id: int,
) -> tuple[Episode, Subtitle]:
    episode = db.query(Episode).filter(Episode.video_id == video_id).first()
    if not episode:
        raise HTTPException(status_code=404, detail="剧集不存在")
    if not can_access_episode(db, episode, user):
        raise HTTPException(status_code=403, detail="当前无权学习该内容")
    sub = (
        db.query(Subtitle)
        .filter(Subtitle.id == subtitle_id, Subtitle.episode_id == episode.id)
        .first()
    )
    if not sub:
        raise HTTPException(status_code=404, detail="字幕不存在")
    return episode, sub


def shadowing_for_subtitle(
    db: Session,
    user: User,
    *,
    video_id: str,
    subtitle_id: int,
    transcript: str,
) -> dict:
    _, sub = _load_subtitle_for_user(db, user, video_id=video_id, subtitle_id=subtitle_id)

    quota = check_and_consume(db, user, action="ai")
    try:
        feedback = shadowing_feedback(target=sub.english or "", said=transcript or "")
    except RuntimeError as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc
    payload = {
        "video_id": video_id,
        "subtitle_id": subtitle_id,
        "english": sub.english or "",
        "transcript": transcript or "",
        "engine": "llm",
        "mode": "sentence",
        **feedback,
        "quota": quota,
    }
    try:
        record = create_practice_record(
            db,
            user,
            feedback=payload,
            mode="sentence",
            engine="llm",
            source_type="video",
            video_id=video_id,
            subtitle_id=subtitle_id,
            ref_text=sub.english or "",
        )
        payload["practice_record_id"] = record.id
        payload["practice_audio_url"] = record.audio_url or ""
    except Exception:
        logger.exception("保存练习记录失败 (shadowing_for_subtitle user=%s)", user.id)
        try:
            db.rollback()
        except Exception:
            pass
    return payload


def oral_eval_status() -> dict:
    enabled = oral_eval_configured()
    return {
        "enabled": enabled,
        "application_id": oral_eval_app_id() if enabled else "",
        "sdk_url": oral_eval_sdk_url() if enabled else "",
        "accent": oral_eval_accent() if enabled else "am",
        "core_type": "en.sent.score",
    }


def oral_eval_warrant_for_user(user: User, *, client_ip: str | None) -> dict:
    if not oral_eval_configured():
        raise HTTPException(status_code=503, detail="口语评测未启用")
    try:
        return request_warrant(user_id=f"u{user.id}", user_client_ip=client_ip or "127.0.0.1")
    except RuntimeError as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc


def shadowing_from_oral_result(
    db: Session,
    user: User,
    *,
    video_id: str,
    subtitle_id: int,
    oral_payload: dict[str, Any],
    title: str = "",
) -> dict:
    """口语评测成功后：消耗 AI 额度并返回统一点评结构（规则生成建议）。"""
    _, sub = _load_subtitle_for_user(db, user, video_id=video_id, subtitle_id=subtitle_id)
    quota = check_and_consume(db, user, action="ai")
    feedback = build_feedback_from_oral_result(
        oral_payload or {},
        target=sub.english or "",
        core_type=CORE_SENT,
    )
    payload = {
        "video_id": video_id,
        "subtitle_id": subtitle_id,
        "english": sub.english or "",
        "transcript": feedback.get("transcript") or "",
        **feedback,
        "quota": quota,
    }
    try:
        record = create_practice_record(
            db,
            user,
            feedback=payload,
            mode="sentence",
            engine="oral",
            source_type="video",
            video_id=video_id,
            subtitle_id=subtitle_id,
            title=title,
            ref_text=sub.english or "",
        )
        payload["practice_record_id"] = record.id
        payload["practice_audio_url"] = record.audio_url or ""
        if record.audio_url:
            payload["audio_url"] = record.audio_url
    except Exception:
        logger.exception("保存练习记录失败 (shadowing_from_oral_result user=%s)", user.id)
        try:
            db.rollback()
        except Exception:
            pass
    return payload


def oral_eval_feedback(
    db: Session,
    user: User,
    *,
    ref_text: str,
    oral_payload: dict[str, Any],
    core_type: str = CORE_SENT,
    source_type: str = "other",
    video_id: str = "",
    subtitle_id: int | None = None,
    article_id: str = "",
    segment_id: int | None = None,
    title: str = "",
) -> dict:
    """通用口语评测结果（单词 / 句子 / 篇章），不绑定字幕。"""
    text = (ref_text or "").strip()
    if not text:
        raise HTTPException(status_code=400, detail="评测文本为空")
    ct = (core_type or CORE_SENT).strip()
    if ct not in (CORE_WORD, CORE_SENT, CORE_PASSAGE):
        ct = CORE_SENT
    mode = mode_from_core_type(ct)
    quota = check_and_consume(db, user, action="ai")
    feedback = build_feedback_from_oral_result(oral_payload or {}, target=text, core_type=ct)
    src = (source_type or "other").strip() or "other"
    if article_id:
        src = "article"
    elif video_id:
        src = "video"
    elif mode == "word" and src == "other":
        src = "vocab"
    payload = {
        "english": text,
        "ref_text": text,
        "transcript": feedback.get("transcript") or "",
        **feedback,
        "quota": quota,
    }
    try:
        record = create_practice_record(
            db,
            user,
            feedback=payload,
            mode=mode,
            engine="oral",
            source_type=src,
            video_id=video_id,
            subtitle_id=subtitle_id,
            article_id=article_id,
            segment_id=segment_id,
            title=title,
            ref_text=text,
        )
        payload["practice_record_id"] = record.id
        payload["practice_audio_url"] = record.audio_url or ""
        if record.audio_url:
            payload["audio_url"] = record.audio_url
    except Exception:
        logger.exception("保存练习记录失败 (oral_eval_feedback user=%s)", user.id)
        try:
            db.rollback()
        except Exception:
            pass
    return payload


def shadowing_for_text(
    db: Session,
    user: User,
    *,
    target: str,
    transcript: str,
    mode: str = "sentence",
    source_type: str = "other",
    video_id: str = "",
    subtitle_id: int | None = None,
    article_id: str = "",
    segment_id: int | None = None,
    title: str = "",
) -> dict:
    """无字幕场景的 ASR+LLM 跟读点评（单词/篇章回退）。"""
    text = (target or "").strip()
    if not text:
        raise HTTPException(status_code=400, detail="目标文本为空")
    practice_mode = (mode or "sentence").strip()
    if practice_mode not in ("word", "sentence", "passage"):
        practice_mode = "sentence"
    quota = check_and_consume(db, user, action="ai")
    try:
        feedback = shadowing_feedback(target=text, said=transcript or "")
    except RuntimeError as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc
    src = (source_type or "other").strip() or "other"
    if article_id:
        src = "article"
    elif video_id:
        src = "video"
    elif practice_mode == "word" and src == "other":
        src = "vocab"
    payload = {
        "english": text,
        "ref_text": text,
        "transcript": transcript or "",
        "engine": "llm",
        "mode": practice_mode,
        **feedback,
        "quota": quota,
    }
    try:
        record = create_practice_record(
            db,
            user,
            feedback=payload,
            mode=practice_mode,
            engine="llm",
            source_type=src,
            video_id=video_id,
            subtitle_id=subtitle_id,
            article_id=article_id,
            segment_id=segment_id,
            title=title,
            ref_text=text,
        )
        payload["practice_record_id"] = record.id
        payload["practice_audio_url"] = record.audio_url or ""
    except Exception:
        logger.exception("保存练习记录失败 (shadowing_for_text user=%s)", user.id)
        try:
            db.rollback()
        except Exception:
            pass
    return payload


def daily_learning_path(db: Session, user: User) -> dict:
    """规则版每日路径（不消耗 AI 额度）：继续学 + 推荐未完成 + 生词复习入口。"""
    continue_item = None
    prog = (
        db.query(UserEpisodeProgress, Episode)
        .join(Episode, Episode.id == UserEpisodeProgress.episode_id)
        .filter(
            UserEpisodeProgress.user_id == user.id,
            UserEpisodeProgress.is_completed.is_(False),
            UserEpisodeProgress.max_reached_index > 0,
            Episode.status == "published",
        )
        .order_by(UserEpisodeProgress.last_watched_at.desc())
        .first()
    )
    if prog:
        p, ep = prog
        if can_access_episode(db, ep, user):
            continue_item = {
                "kind": "continue",
                "video_id": ep.video_id,
                "title": ep.short_title or ep.video_id,
                "cover": ep.thumbnail_url or ep.cover or "",
                "completion_percent": float(p.completion_percent or 0),
                "reason": "接着上次学",
            }

    recommend = []
    seen = {continue_item["video_id"]} if continue_item else set()
    rows = (
        db.query(Episode)
        .filter(Episode.status == "published", Episode.series_id.is_(None))
        .order_by(Episode.created_at.desc())
        .limit(40)
        .all()
    )
    learned_ids = {
        r[0]
        for r in db.query(UserEpisodeProgress.episode_id)
        .filter(
            UserEpisodeProgress.user_id == user.id,
            UserEpisodeProgress.is_completed.is_(True),
        )
        .all()
    }
    for ep in rows:
        if ep.video_id in seen or ep.id in learned_ids:
            continue
        if not can_access_episode(db, ep, user):
            continue
        recommend.append(
            {
                "kind": "recommend",
                "video_id": ep.video_id,
                "title": ep.short_title or ep.video_id,
                "cover": ep.thumbnail_url or ep.cover or "",
                "reason": "今日推荐精听",
            }
        )
        seen.add(ep.video_id)
        if len(recommend) >= 3:
            break

    vocab_count = (
        db.query(UserVocabularyItem).filter(UserVocabularyItem.user_id == user.id).count()
    )

    return {
        "continue_item": continue_item,
        "recommend": recommend,
        "vocab_review": {
            "available": vocab_count > 0,
            "count": vocab_count,
            "path": "/english/vocabulary?review=1",
            "reason": "去生词本复习（不会自动消耗 AI）" if vocab_count else "生词本为空，学视频时点词可收藏",
        },
        "tips": [
            "先用「讲解」吃透难句，再用「跟读」开口",
            "听写 / AI 挖空巩固听力细节",
        ],
    }


def article_qa(
    db: Session,
    user: User,
    *,
    article_id: str,
    segment_id: int | None,
    question: str,
    device_id: str = "",
) -> dict:
    article = db.query(Article).filter(Article.article_id == article_id).first()
    if not article:
        raise HTTPException(status_code=404, detail="文章不存在")
    if not can_access_article(db, article, user, device_id):
        raise HTTPException(status_code=403, detail="今日阅读额度已用完或无权访问")

    english = ""
    chinese = ""
    sid = segment_id
    if segment_id:
        seg = (
            db.query(ArticleSegment)
            .filter(ArticleSegment.id == segment_id, ArticleSegment.article_id == article.id)
            .first()
        )
        if not seg:
            raise HTTPException(status_code=404, detail="段落不存在")
        english = seg.english or ""
        chinese = seg.chinese or ""
    else:
        segs = (
            db.query(ArticleSegment)
            .filter(ArticleSegment.article_id == article.id)
            .order_by(ArticleSegment.index.asc())
            .limit(6)
            .all()
        )
        english = "\n".join(s.english or "" for s in segs)
        chinese = "\n".join(s.chinese or "" for s in segs)

    quota = check_and_consume(db, user, action="ai")
    try:
        result = reading_qa(
            english=english,
            chinese=chinese,
            question=question,
            title=article.title or "",
        )
    except RuntimeError as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc

    return {
        "article_id": article_id,
        "segment_id": sid,
        **result,
        "quota": quota,
    }


def _vocab_words_for_review(db: Session, user: User) -> list[str]:
    rows = (
        db.query(UserVocabularyItem)
        .filter(UserVocabularyItem.user_id == user.id)
        .order_by(UserVocabularyItem.created_at.desc())
        .limit(12)
        .all()
    )
    return [r.word.strip() for r in rows if r.word and r.word.strip()]


def _vocab_review_fingerprint(words: list[str]) -> str:
    # 与 AI 实际使用的前 8 个词对齐，词集不变则复用缓存
    normalized = [w.lower() for w in words[:8]]
    raw = "\n".join(normalized)
    return hashlib.sha1(raw.encode("utf-8")).hexdigest()[:16]


def _vocab_review_cache_key(user_id: int, fingerprint: str) -> str:
    return f"{user_id}:{visit_date_now().isoformat()}:{fingerprint}"


def _get_vocab_review_cache(user_id: int, words: list[str]) -> dict | None:
    if not words:
        return None
    key = _vocab_review_cache_key(user_id, _vocab_review_fingerprint(words))
    cached = _VOCAB_REVIEW_CACHE.get(key)
    if not cached or not isinstance(cached.get("cards"), list):
        return None
    return cached


def _set_vocab_review_cache(user_id: int, words: list[str], cards: list) -> dict:
    key = _vocab_review_cache_key(user_id, _vocab_review_fingerprint(words))
    payload = {
        "cards": cards,
        "words": words[:8],
        "cached_at": datetime.utcnow().isoformat() + "Z",
    }
    _VOCAB_REVIEW_CACHE[key] = payload
    # 简单清理：只保留最近 200 条，避免进程内存无限涨
    if len(_VOCAB_REVIEW_CACHE) > 200:
        for old_key in list(_VOCAB_REVIEW_CACHE.keys())[:50]:
            _VOCAB_REVIEW_CACHE.pop(old_key, None)
    return payload


def peek_vocab_review(db: Session, user: User) -> dict:
    """不消耗额度：返回是否有词、以及当日缓存卡片（如有）。"""
    words = _vocab_words_for_review(db, user)
    n = (
        db.query(UserVocabularyItem)
        .filter(UserVocabularyItem.user_id == user.id)
        .count()
    )
    if not words:
        return {
            "available": False,
            "count": 0,
            "cards": [],
            "from_cache": False,
            "cache_hit": False,
            "message": "生词本为空",
        }
    cached = _get_vocab_review_cache(user.id, words)
    cards = list(cached["cards"]) if cached else []
    return {
        "available": True,
        "count": n,
        "cards": cards,
        "from_cache": bool(cards),
        "cache_hit": bool(cards),
        "cached_at": cached.get("cached_at") if cached else None,
        "message": "今日已有复习卡，可继续复习；重新生成会消耗 AI 额度" if cards else "点击开始复习时才会调用 AI（当日缓存可复用）",
    }


def build_vocab_review(db: Session, user: User, *, force: bool = False) -> dict:
    """获取或生成错词复习卡。默认复用当日缓存；force=True 时强制重新生成并扣额度。"""
    words = _vocab_words_for_review(db, user)
    if not words:
        return {
            "available": False,
            "count": 0,
            "cards": [],
            "from_cache": False,
            "cache_hit": False,
            "quota": None,
            "message": "生词本还没有词，去视频里点词收藏吧",
        }

    n = (
        db.query(UserVocabularyItem)
        .filter(UserVocabularyItem.user_id == user.id)
        .count()
    )
    if not force:
        cached = _get_vocab_review_cache(user.id, words)
        if cached:
            return {
                "available": True,
                "count": n,
                "cards": list(cached["cards"]),
                "from_cache": True,
                "cache_hit": True,
                "cached_at": cached.get("cached_at"),
                "quota": None,
                "message": "已复用今日复习卡（未消耗 AI 额度）",
            }

    quota = check_and_consume(db, user, action="ai")
    try:
        result = vocab_review_cards(words)
    except RuntimeError as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc

    cards = list(result.get("cards") or [])
    cached = _set_vocab_review_cache(user.id, words, cards)
    return {
        "available": True,
        "count": n,
        "cards": cards,
        "from_cache": False,
        "cache_hit": False,
        "cached_at": cached.get("cached_at"),
        "quota": quota,
        "message": "已生成今日复习卡" if cards else "未能生成复习卡，请稍后重试",
    }
