"""用户练习记录：口语/单词/篇章评测结果落库，录音转存七牛。"""

from __future__ import annotations

import json
import logging
import os
import tempfile
import urllib.error
import urllib.request
from datetime import datetime
from pathlib import Path
from typing import Any

from sqlalchemy.exc import OperationalError, ProgrammingError
from sqlalchemy.orm import Session

from ..models import Article, Episode, User, UserPracticeRecord
from ..qiniu_storage import QiniuConfig, upload_file
from .oral_eval import is_allowed_oral_audio_url

logger = logging.getLogger(__name__)

MAX_RECORDS_PER_USER = int(os.getenv("PRACTICE_RECORD_MAX", "100") or "100")
MAX_AUDIO_RECORDS_PER_USER = int(os.getenv("PRACTICE_AUDIO_MAX", "50") or "50")
MAX_AUDIO_BYTES = int(os.getenv("PRACTICE_AUDIO_MAX_BYTES", str(3 * 1024 * 1024)) or str(3 * 1024 * 1024))


def _ensure_table(db: Session) -> None:
    """表不存在时补建（兼容未重启 / create_all 未跑到的环境）。"""
    try:
        bind = db.get_bind()
        UserPracticeRecord.__table__.create(bind=bind, checkfirst=True)
    except Exception:
        logger.exception("补建 user_practice_records 失败")


def _json_dumps(value: Any) -> str:
    try:
        return json.dumps(value if value is not None else [], ensure_ascii=False)
    except (TypeError, ValueError):
        return "[]"


def _as_int(value: Any) -> int | None:
    if value is None or value == "":
        return None
    try:
        return int(round(float(value)))
    except (TypeError, ValueError):
        return None


def mode_from_core_type(core_type: str | None) -> str:
    ct = (core_type or "").strip()
    if ct == "en.word.score":
        return "word"
    if ct == "en.pred.score":
        return "passage"
    return "sentence"


def record_to_dict(
    row: UserPracticeRecord,
    *,
    include_detail: bool = False,
    cover_url: str = "",
    source_title: str = "",
) -> dict[str, Any]:
    title = (row.title or "").strip() or (source_title or "").strip()
    out: dict[str, Any] = {
        "id": row.id,
        "mode": row.mode,
        "engine": row.engine,
        "source_type": row.source_type,
        "video_id": row.video_id or "",
        "subtitle_id": row.subtitle_id,
        "article_id": row.article_id or "",
        "segment_id": row.segment_id,
        "title": title,
        "cover_url": (cover_url or "").strip(),
        "ref_text": row.ref_text or "",
        "transcript": row.transcript or "",
        "score": int(row.score or 0),
        "level": row.level or "",
        "accuracy": row.accuracy,
        "fluency": row.fluency,
        "rhythm": row.rhythm,
        "integrity": row.integrity,
        "praise": row.praise or "",
        "audio_url": row.audio_url or "",
        "audio_source": row.audio_source or "",
        "has_audio": bool((row.audio_url or "").strip()),
        "created_at": row.created_at.isoformat() + "Z" if row.created_at else None,
    }
    if include_detail:
        try:
            out["issues"] = json.loads(row.issues_json or "[]")
        except json.JSONDecodeError:
            out["issues"] = []
        try:
            out["tips"] = json.loads(row.tips_json or "[]")
        except json.JSONDecodeError:
            out["tips"] = []
        try:
            out["words"] = json.loads(row.words_json or "[]")
        except json.JSONDecodeError:
            out["words"] = []
        try:
            out["result"] = json.loads(row.result_json or "{}")
        except json.JSONDecodeError:
            out["result"] = {}
    return out


def covers_for_records(db: Session, rows: list[UserPracticeRecord]) -> dict[int, tuple[str, str]]:
    """返回 {record_id: (cover_url, source_title)}。"""
    video_ids = sorted({(r.video_id or "").strip() for r in rows if (r.video_id or "").strip()})
    article_ids = sorted({(r.article_id or "").strip() for r in rows if (r.article_id or "").strip()})

    ep_map: dict[str, Episode] = {}
    if video_ids:
        for ep in db.query(Episode).filter(Episode.video_id.in_(video_ids)).all():
            ep_map[ep.video_id] = ep

    art_map: dict[str, Article] = {}
    if article_ids:
        for art in db.query(Article).filter(Article.article_id.in_(article_ids)).all():
            art_map[art.article_id] = art

    out: dict[int, tuple[str, str]] = {}
    for row in rows:
        cover = ""
        title = ""
        vid = (row.video_id or "").strip()
        aid = (row.article_id or "").strip()
        if vid and vid in ep_map:
            ep = ep_map[vid]
            cover = (ep.thumbnail_url or ep.cover or "").strip()
            title = (ep.short_title or ep.video_id or "").strip()
        elif aid and aid in art_map:
            art = art_map[aid]
            cover = (art.cover or "").strip()
            title = (art.title or art.article_id or "").strip()
        out[row.id] = (cover, title)
    return out


def _prune_records(db: Session, user_id: int) -> None:
    """超出条数时删除最旧记录。"""
    if MAX_RECORDS_PER_USER <= 0:
        return
    ids = [
        rid
        for (rid,) in (
            db.query(UserPracticeRecord.id)
            .filter(UserPracticeRecord.user_id == user_id)
            .order_by(UserPracticeRecord.created_at.desc(), UserPracticeRecord.id.desc())
            .all()
        )
    ]
    if len(ids) <= MAX_RECORDS_PER_USER:
        return
    drop_ids = ids[MAX_RECORDS_PER_USER:]
    db.query(UserPracticeRecord).filter(UserPracticeRecord.id.in_(drop_ids)).delete(synchronize_session=False)


def _prune_audio(db: Session, user_id: int) -> None:
    """超出有录音条数时，清空最旧记录的 audio_url（保留分数）。"""
    if MAX_AUDIO_RECORDS_PER_USER <= 0:
        return
    rows = (
        db.query(UserPracticeRecord)
        .filter(
            UserPracticeRecord.user_id == user_id,
            UserPracticeRecord.audio_url != "",
        )
        .order_by(UserPracticeRecord.created_at.desc(), UserPracticeRecord.id.desc())
        .all()
    )
    if len(rows) <= MAX_AUDIO_RECORDS_PER_USER:
        return
    for row in rows[MAX_AUDIO_RECORDS_PER_USER:]:
        row.audio_url = ""
        row.audio_source = ""


def _download_bytes(url: str, *, timeout: int = 30) -> tuple[bytes, str]:
    req = urllib.request.Request(
        url,
        headers={"User-Agent": "vloglish-practice-audio/1.0", "Accept": "*/*"},
        method="GET",
    )
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        data = resp.read()
        ctype = (resp.headers.get("Content-Type") or "").split(";")[0].strip()
    if not data:
        raise RuntimeError("录音文件为空")
    if len(data) > MAX_AUDIO_BYTES:
        raise RuntimeError("录音文件过大")
    return data, ctype or "audio/ogg"


def _suffix_for_content_type(ctype: str, url: str = "") -> str:
    c = (ctype or "").lower()
    u = (url or "").lower()
    if "mpeg" in c or "mp3" in c or u.endswith(".mp3"):
        return ".mp3"
    if "wav" in c or u.endswith(".wav"):
        return ".wav"
    if "webm" in c or u.endswith(".webm"):
        return ".webm"
    return ".ogg"


def archive_audio_bytes(
    db: Session,
    user: User,
    record: UserPracticeRecord,
    data: bytes,
    *,
    content_type: str = "audio/ogg",
    source: str = "upload",
) -> str:
    if not data:
        raise RuntimeError("录音为空")
    if len(data) > MAX_AUDIO_BYTES:
        raise RuntimeError("录音文件过大")

    cfg = QiniuConfig.from_env()
    suffix = _suffix_for_content_type(content_type)
    key = cfg.object_key("practice", str(user.id), f"{record.id}{suffix}")
    with tempfile.NamedTemporaryFile(suffix=suffix, delete=False) as tmp:
        tmp_path = Path(tmp.name)
        tmp.write(data)
    try:
        url = upload_file(cfg, tmp_path, key)
    finally:
        try:
            tmp_path.unlink(missing_ok=True)
        except OSError:
            pass

    record.audio_url = url
    record.audio_source = source
    db.add(record)
    _prune_audio(db, user.id)
    db.commit()
    db.refresh(record)
    return url


def archive_remote_audio(db: Session, user: User, record: UserPracticeRecord, remote_url: str) -> str | None:
    url = (remote_url or "").strip()
    if not url or not is_allowed_oral_audio_url(url):
        return None
    try:
        data, ctype = _download_bytes(url)
        return archive_audio_bytes(db, user, record, data, content_type=ctype, source="remote")
    except Exception:
        return None


def create_practice_record(
    db: Session,
    user: User,
    *,
    feedback: dict[str, Any],
    mode: str,
    engine: str = "oral",
    source_type: str = "other",
    video_id: str = "",
    subtitle_id: int | None = None,
    article_id: str = "",
    segment_id: int | None = None,
    title: str = "",
    ref_text: str = "",
    remote_audio_url: str = "",
) -> UserPracticeRecord:
    text = (ref_text or feedback.get("english") or feedback.get("ref_text") or feedback.get("target") or "").strip()

    def _build_row() -> UserPracticeRecord:
        return UserPracticeRecord(
            user_id=user.id,
            mode=(mode or "sentence").strip()[:16] or "sentence",
            engine=(engine or "oral").strip()[:16] or "oral",
            source_type=(source_type or "other").strip()[:16] or "other",
            video_id=(video_id or "").strip()[:32],
            subtitle_id=subtitle_id,
            article_id=(article_id or "").strip()[:32],
            segment_id=segment_id,
            title=(title or "").strip()[:256],
            ref_text=text[:8000],
            transcript=str(feedback.get("transcript") or "")[:8000],
            score=max(0, min(100, _as_int(feedback.get("score")) or 0)),
            level=str(feedback.get("level") or "")[:32],
            accuracy=_as_int(feedback.get("accuracy")),
            fluency=_as_int(feedback.get("fluency")),
            rhythm=_as_int(feedback.get("rhythm")),
            integrity=_as_int(feedback.get("integrity")),
            praise=str(feedback.get("praise") or "")[:2000],
            issues_json=_json_dumps(feedback.get("issues") or []),
            tips_json=_json_dumps(feedback.get("tips") or []),
            words_json=_json_dumps(feedback.get("words") or []),
            result_json=_json_dumps(
                {
                    k: feedback.get(k)
                    for k in (
                        "score",
                        "level",
                        "praise",
                        "issues",
                        "tips",
                        "words",
                        "accuracy",
                        "fluency",
                        "rhythm",
                        "integrity",
                        "engine",
                        "mode",
                        "core_type",
                        "audio_url",
                    )
                }
            ),
            audio_url="",
            audio_source="",
            created_at=datetime.utcnow(),
        )

    row = _build_row()
    db.add(row)
    try:
        db.commit()
    except (ProgrammingError, OperationalError) as exc:
        db.rollback()
        # 常见原因：表尚未创建
        if "user_practice_records" in str(exc).lower() or "does not exist" in str(exc).lower():
            logger.warning("user_practice_records 不存在，尝试补建后重试")
            _ensure_table(db)
            row = _build_row()
            db.add(row)
            db.commit()
        else:
            raise
    db.refresh(row)

    remote = (remote_audio_url or str(feedback.get("audio_url") or "")).strip()
    if remote and (engine or "").strip() == "oral":
        archive_remote_audio(db, user, row, remote)
        db.refresh(row)

    _prune_records(db, user.id)
    db.commit()
    db.refresh(row)
    return row


def list_practice_records(
    db: Session,
    user: User,
    *,
    mode: str | None = None,
    video_id: str | None = None,
    page: int = 1,
    page_size: int = 20,
) -> dict[str, Any]:
    page = max(1, page)
    page_size = max(1, min(100, page_size))
    allowed_modes = {"word", "sentence", "passage", "shadow"}
    try:
        q = db.query(UserPracticeRecord).filter(UserPracticeRecord.user_id == user.id)
        if mode and mode.strip() in allowed_modes:
            q = q.filter(UserPracticeRecord.mode == mode.strip())
        vid = (video_id or "").strip()
        if vid:
            q = q.filter(UserPracticeRecord.video_id == vid[:32])
        total = q.count()
        rows = (
            q.order_by(UserPracticeRecord.created_at.desc(), UserPracticeRecord.id.desc())
            .offset((page - 1) * page_size)
            .limit(page_size)
            .all()
        )
    except (ProgrammingError, OperationalError) as exc:
        db.rollback()
        if "user_practice_records" in str(exc).lower() or "does not exist" in str(exc).lower():
            _ensure_table(db)
            return {"count": 0, "page": page, "page_size": page_size, "results": []}
        raise
    covers = covers_for_records(db, rows)
    results = []
    for r in rows:
        cover, source_title = covers.get(r.id, ("", ""))
        results.append(record_to_dict(r, cover_url=cover, source_title=source_title))
    return {
        "count": total,
        "page": page,
        "page_size": page_size,
        "results": results,
    }


def list_shadow_tracks_for_video(
    db: Session,
    user: User,
    video_id: str,
) -> dict[str, Any]:
    """某集影子跟读音轨：每个 subtitle_id 只返回最新一条有录音的记录。"""
    vid = (video_id or "").strip()
    if not vid:
        return {"video_id": "", "results": []}
    try:
        rows = (
            db.query(UserPracticeRecord)
            .filter(
                UserPracticeRecord.user_id == user.id,
                UserPracticeRecord.mode == "shadow",
                UserPracticeRecord.video_id == vid[:32],
                UserPracticeRecord.audio_url != "",
                UserPracticeRecord.subtitle_id.isnot(None),
            )
            .order_by(UserPracticeRecord.created_at.desc(), UserPracticeRecord.id.desc())
            .all()
        )
    except (ProgrammingError, OperationalError) as exc:
        db.rollback()
        if "user_practice_records" in str(exc).lower() or "does not exist" in str(exc).lower():
            _ensure_table(db)
            return {"video_id": vid, "results": []}
        raise

    seen: set[int] = set()
    results: list[dict[str, Any]] = []
    for row in rows:
        sid = row.subtitle_id
        if sid is None or sid in seen:
            continue
        seen.add(sid)
        results.append(record_to_dict(row))
    return {"video_id": vid, "results": results}


def upsert_shadow_record(
    db: Session,
    user: User,
    *,
    video_id: str,
    subtitle_id: int,
    title: str = "",
    ref_text: str = "",
) -> UserPracticeRecord:
    """同一用户同一字幕只保留一条影子记录（重录覆盖）。"""
    vid = (video_id or "").strip()[:32]
    existing = (
        db.query(UserPracticeRecord)
        .filter(
            UserPracticeRecord.user_id == user.id,
            UserPracticeRecord.mode == "shadow",
            UserPracticeRecord.video_id == vid,
            UserPracticeRecord.subtitle_id == subtitle_id,
        )
        .order_by(UserPracticeRecord.created_at.desc(), UserPracticeRecord.id.desc())
        .first()
    )
    text = (ref_text or "").strip()[:8000]
    if existing:
        # 删掉同字幕多余旧记录，只留这一条
        extras = (
            db.query(UserPracticeRecord)
            .filter(
                UserPracticeRecord.user_id == user.id,
                UserPracticeRecord.mode == "shadow",
                UserPracticeRecord.video_id == vid,
                UserPracticeRecord.subtitle_id == subtitle_id,
                UserPracticeRecord.id != existing.id,
            )
            .all()
        )
        for extra in extras:
            db.delete(extra)
        existing.title = (title or existing.title or "").strip()[:256]
        if text:
            existing.ref_text = text
        existing.engine = "shadow"
        existing.source_type = "video"
        existing.audio_url = ""
        existing.audio_source = ""
        existing.created_at = datetime.utcnow()
        db.add(existing)
        db.commit()
        db.refresh(existing)
        return existing

    return create_practice_record(
        db,
        user,
        feedback={},
        mode="shadow",
        engine="shadow",
        source_type="video",
        video_id=vid,
        subtitle_id=subtitle_id,
        title=title,
        ref_text=text,
    )


def get_practice_record(db: Session, user: User, record_id: int) -> UserPracticeRecord | None:
    return (
        db.query(UserPracticeRecord)
        .filter(UserPracticeRecord.user_id == user.id, UserPracticeRecord.id == record_id)
        .first()
    )


def delete_practice_record(db: Session, user: User, record_id: int) -> bool:
    row = get_practice_record(db, user, record_id)
    if not row:
        return False
    db.delete(row)
    db.commit()
    return True
