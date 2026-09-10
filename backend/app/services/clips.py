"""用户字幕摘录：与生词本独立，不绑定词条。"""

from __future__ import annotations

import json
import logging
from datetime import datetime

from fastapi import HTTPException
from sqlalchemy import func
from sqlalchemy.orm import Session

from ..demo_access import can_access_episode
from ..dict.ai_learning import clip_examples
from ..models import Episode, Subtitle, User, UserSubtitleClip
from .ai_quota import check_and_consume, get_quota_status
from .learning import _fmt_dt

logger = logging.getLogger(__name__)

CLIP_TEXT_MAX = 500
NOTE_MAX = 500


def normalize_clip_text(text: str) -> str:
    return " ".join((text or "").split()).strip()


def _parse_examples(raw: str) -> list[dict]:
    try:
        data = json.loads(raw or "[]")
    except json.JSONDecodeError:
        return []
    if not isinstance(data, list):
        return []
    out: list[dict] = []
    for item in data[:3]:
        if not isinstance(item, dict):
            continue
        en = str(item.get("en") or "").strip()
        zh = str(item.get("zh") or "").strip()
        if en:
            out.append({"en": en, "zh": zh})
    return out


def clip_to_dict(row: UserSubtitleClip, *, already_saved: bool = False) -> dict:
    text = row.text or ""
    examples = _parse_examples(row.examples_json or "[]")
    examples_for = (row.examples_for or "").strip()
    return {
        "id": row.id,
        "text": text,
        "note": row.note or "",
        "video_id": row.video_id or "",
        "subtitle_id": row.subtitle_id,
        "episode_title": row.episode_title or "",
        "context_english": row.context_english or "",
        "context_chinese": row.context_chinese or "",
        "original_text": (row.original_text or "").strip() or text,
        "examples": examples,
        "examples_stale": bool(examples) and examples_for != normalize_clip_text(text),
        "created_at": _fmt_dt(row.created_at),
        "updated_at": _fmt_dt(row.updated_at),
        "already_saved": already_saved,
    }


def list_clips(db: Session, user: User) -> list[dict]:
    rows = (
        db.query(UserSubtitleClip)
        .filter(UserSubtitleClip.user_id == user.id)
        .order_by(UserSubtitleClip.created_at.desc())
        .all()
    )
    return [clip_to_dict(row) for row in rows]


def _owned_clip(db: Session, user: User, clip_id: int) -> UserSubtitleClip | None:
    return (
        db.query(UserSubtitleClip)
        .filter(UserSubtitleClip.id == clip_id, UserSubtitleClip.user_id == user.id)
        .first()
    )


def save_clip(db: Session, user: User, data: dict) -> tuple[UserSubtitleClip, bool]:
    text = normalize_clip_text(str(data.get("text") or ""))
    if not text:
        raise ValueError("请先划选一段文字")
    if len(text) > CLIP_TEXT_MAX:
        raise ValueError(f"摘录最多 {CLIP_TEXT_MAX} 字")
    note = str(data.get("note") or "").strip()[:NOTE_MAX]
    video_id = str(data.get("video_id") or "").strip()
    if not video_id:
        raise ValueError("缺少剧集")

    episode = db.query(Episode).filter(Episode.video_id == video_id).first()
    if not episode:
        raise LookupError("剧集不存在")
    if not can_access_episode(db, episode, user):
        raise PermissionError("无权访问该内容")

    subtitle_id = data.get("subtitle_id")
    sub: Subtitle | None = None
    if subtitle_id:
        sub = (
            db.query(Subtitle)
            .filter(Subtitle.id == int(subtitle_id), Subtitle.episode_id == episode.id)
            .first()
        )
        if not sub:
            raise LookupError("字幕不存在")

    existing_q = db.query(UserSubtitleClip).filter(
        UserSubtitleClip.user_id == user.id,
        func.lower(UserSubtitleClip.text) == text.lower(),
    )
    if sub:
        existing_q = existing_q.filter(UserSubtitleClip.subtitle_id == sub.id)
    else:
        existing_q = existing_q.filter(UserSubtitleClip.subtitle_id.is_(None))
    existing = existing_q.order_by(UserSubtitleClip.created_at.desc()).first()
    if existing:
        return existing, True

    now = datetime.utcnow()
    row = UserSubtitleClip(
        user_id=user.id,
        episode_id=episode.id,
        subtitle_id=sub.id if sub else None,
        video_id=episode.video_id,
        text=text,
        note=note,
        context_english=(sub.english if sub else "") or "",
        context_chinese=(sub.chinese if sub else "") or "",
        episode_title=episode.short_title or "",
        original_text=text,
        examples_json="[]",
        examples_for="",
        created_at=now,
        updated_at=now,
    )
    db.add(row)
    db.commit()
    db.refresh(row)
    return row, False


def update_clip(db: Session, user: User, clip_id: int, data: dict) -> UserSubtitleClip:
    row = _owned_clip(db, user, clip_id)
    if not row:
        raise LookupError("摘录不存在")

    if "text" in data and data["text"] is not None:
        text = normalize_clip_text(str(data["text"]))
        if not text:
            raise ValueError("摘录不能为空")
        if len(text) > CLIP_TEXT_MAX:
            raise ValueError(f"摘录最多 {CLIP_TEXT_MAX} 字")
        row.text = text
    if "note" in data and data["note"] is not None:
        row.note = str(data["note"]).strip()[:NOTE_MAX]
    row.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(row)
    return row


def remove_clip(db: Session, user: User, clip_id: int) -> bool:
    row = _owned_clip(db, user, clip_id)
    if not row:
        return False
    db.delete(row)
    db.commit()
    return True


def generate_examples(db: Session, user: User, clip_id: int, *, force: bool = False) -> dict:
    row = _owned_clip(db, user, clip_id)
    if not row:
        raise LookupError("摘录不存在")

    examples = _parse_examples(row.examples_json or "[]")
    if examples and not force:
        data = clip_to_dict(row)
        data["from_cache"] = True
        data["quota"] = get_quota_status(db, user)
        return data

    quota = check_and_consume(db, user, action="clip_examples")
    try:
        result = clip_examples(
            text=row.text or "",
            note=row.note or "",
            context_english=row.context_english or "",
            context_chinese=row.context_chinese or "",
        )
    except HTTPException:
        raise
    except RuntimeError as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc
    except Exception:
        logger.exception("clip examples generation failed clip=%s", clip_id)
        raise ValueError("生成失败，请稍后重试") from None

    generated = result.get("examples") or []
    if len(generated) < 2:
        raise ValueError("生成失败，请稍后重试")

    row.examples_json = json.dumps(generated, ensure_ascii=False)
    row.examples_for = normalize_clip_text(row.text or "")
    row.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(row)
    data = clip_to_dict(row)
    data["from_cache"] = False
    data["quota"] = quota
    return data
