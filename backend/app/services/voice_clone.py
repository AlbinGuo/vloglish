"""用户声音复刻业务：每用户一条音色，样本落盘保留。"""

from __future__ import annotations

import hashlib
import shutil
import subprocess
import tempfile
from pathlib import Path

from fastapi import HTTPException
from sqlalchemy.orm import Session

from ..database import DATA_DIR
from ..models import User, UserClonedVoice
from .media_transcode import _ffmpeg_bin, get_ffmpeg_dir
from . import cosyvoice_clone as cvc
from . import qwen_voice_clone as qvc
from . import tts_ssml
from . import voice_enroll_public as enroll_pub
from .tts_common import normalize_tts_text

SAMPLE_DIR = DATA_DIR / "voice_clone"
CACHE_DIR = DATA_DIR / "tts_cache" / "cloned"
MAX_SAMPLE_BYTES = 10 * 1024 * 1024
MIN_DURATION_MS = 10_000
MAX_DURATION_MS = 60_000
RECOMMENDED_MAX_MS = 20_000

DEFAULT_ENROLL_TEXT = (
    "Hello, this is my voice for English learning. "
    "I watch videos every day and practice speaking clearly. "
    "Please clone my voice so I can hear the subtitles in my own voice."
)


def voice_clone_ready() -> bool:
    return cvc.voice_clone_configured()


def needs_reenroll(row: UserClonedVoice | None) -> bool:
    if not row or not (row.voice or "").strip():
        return False
    return not cvc.is_cosyvoice_model(row.tts_model)


def get_row(db: Session, user: User) -> UserClonedVoice | None:
    return db.query(UserClonedVoice).filter(UserClonedVoice.user_id == user.id).one_or_none()


def row_to_dict(row: UserClonedVoice | None) -> dict | None:
    if not row or not (row.voice or "").strip():
        return None
    return {
        "voice": row.voice,
        "ttsModel": row.tts_model or cvc.VOICE_CLONE_TTS_MODEL,
        "needsReenroll": needs_reenroll(row),
        "name": "我的声音",
        "preferredName": row.preferred_name,
        "fallbackMode": bool(row.fallback_mode),
        "preferPlayback": bool(getattr(row, "prefer_playback", True)),
        "hasSample": bool(row.sample_relpath) and _sample_path(row).is_file(),
        "sampleText": row.sample_text or "",
        "language": row.language or "en",
        "createdAt": row.created_at.isoformat() + "Z" if row.created_at else None,
        "updatedAt": row.updated_at.isoformat() + "Z" if row.updated_at else None,
    }


def _user_dir(user_id: int) -> Path:
    path = SAMPLE_DIR / str(user_id)
    path.mkdir(parents=True, exist_ok=True)
    return path


def _sample_path(row: UserClonedVoice) -> Path:
    rel = (row.sample_relpath or "").strip().replace("\\", "/")
    if not rel or ".." in rel.split("/"):
        return _user_dir(row.user_id) / "sample.mp3"
    return DATA_DIR / rel


def _suffix_for_content_type(ctype: str) -> str:
    c = (ctype or "").lower()
    if "wav" in c:
        return ".wav"
    if "mpeg" in c or "mp3" in c:
        return ".mp3"
    if "mp4" in c or "m4a" in c or "aac" in c:
        return ".m4a"
    if "webm" in c:
        return ".webm"
    if "ogg" in c or "opus" in c:
        return ".ogg"
    return ".bin"


def convert_enrollment_audio(data: bytes, content_type: str) -> tuple[bytes, str]:
    """将浏览器常见格式转为 DashScope 接受的 mp3/wav/mp4。"""
    if not data:
        raise HTTPException(status_code=400, detail="录音为空")
    if len(data) > MAX_SAMPLE_BYTES:
        raise HTTPException(status_code=400, detail="录音超过 10MB")

    ctype = (content_type or "application/octet-stream").split(";")[0].strip().lower()
    if ctype in ("audio/mpeg", "audio/mp3"):
        return data, "audio/mpeg"
    if ctype in ("audio/wav", "audio/x-wav"):
        return data, "audio/wav"
    if ctype in ("audio/mp4", "audio/m4a", "audio/x-m4a", "audio/aac"):
        return data, "audio/mp4"

    # webm/ogg 等 → mp3
    ffmpeg_dir = get_ffmpeg_dir()
    try:
        ffmpeg = _ffmpeg_bin(ffmpeg_dir, "ffmpeg")
    except RuntimeError as exc:
        raise HTTPException(
            status_code=503,
            detail=f"录音格式需转码但未找到 ffmpeg：{exc}",
        ) from exc

    suffix = _suffix_for_content_type(ctype)
    with tempfile.NamedTemporaryFile(suffix=suffix, delete=False) as src:
        src.write(data)
        src_path = Path(src.name)
    out_path = src_path.with_suffix(".mp3")
    try:
        proc = subprocess.run(
            [
                ffmpeg,
                "-y",
                "-i",
                str(src_path),
                "-ac",
                "1",
                "-ar",
                "44100",
                "-codec:a",
                "libmp3lame",
                "-qscale:a",
                "4",
                str(out_path),
            ],
            capture_output=True,
            text=True,
            check=False,
            timeout=120,
        )
        if proc.returncode != 0 or not out_path.is_file():
            detail = (proc.stderr or proc.stdout or "").strip()
            raise HTTPException(
                status_code=400,
                detail=f"录音转码失败：{(detail[-300:] if detail else '未知错误')}",
            )
        return out_path.read_bytes(), "audio/mpeg"
    finally:
        src_path.unlink(missing_ok=True)
        out_path.unlink(missing_ok=True)


def _save_sample(user_id: int, data: bytes, content_type: str) -> tuple[str, str]:
    """保存已转码样本到 DATA_DIR/voice_clone/{uid}/sample.*，返回 (relpath, content_type)。"""
    out_ctype = (content_type or "audio/mpeg").split(";")[0].strip().lower()
    if out_ctype == "audio/mp3":
        out_ctype = "audio/mpeg"
    suffix = ".mp3" if out_ctype == "audio/mpeg" else (
        ".wav" if out_ctype == "audio/wav" else ".m4a"
    )
    dest = _user_dir(user_id) / f"sample{suffix}"
    for old in _user_dir(user_id).glob("sample.*"):
        if old != dest:
            old.unlink(missing_ok=True)
    dest.write_bytes(data)
    rel = f"voice_clone/{user_id}/sample{suffix}"
    return rel, out_ctype


def _delete_local_samples(user_id: int) -> None:
    d = SAMPLE_DIR / str(user_id)
    if d.is_dir():
        shutil.rmtree(d, ignore_errors=True)


def create_or_replace(
    db: Session,
    user: User,
    *,
    audio_data: bytes,
    content_type: str,
    text: str | None = None,
    language: str = "en",
    duration_ms: int | None = None,
) -> UserClonedVoice:
    if not voice_clone_ready():
        raise HTTPException(status_code=503, detail="声音复刻未配置（缺少 DASHSCOPE_API_KEY）")

    if duration_ms is not None and duration_ms < MIN_DURATION_MS:
        raise HTTPException(status_code=400, detail="请至少录满 10 秒")
    if duration_ms is not None and duration_ms > MAX_DURATION_MS:
        raise HTTPException(status_code=400, detail="录音最长 60 秒")

    enroll_text = (text or "").strip() or DEFAULT_ENROLL_TEXT
    try:
        enroll_text = normalize_tts_text(enroll_text)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc

    converted, out_ctype = convert_enrollment_audio(audio_data, content_type)
    preferred = cvc.sanitize_prefix(f"u{user.id}", fallback="vloglish")
    lang = cvc.normalize_clone_language(language)

    existing = get_row(db, user)
    if existing and (existing.voice or "").strip():
        _delete_remote_voice(existing.voice, existing.tts_model)

    rel, saved_ctype = _save_sample(user.id, converted, out_ctype)
    sample_path = DATA_DIR / rel
    try:
        audio_url = enroll_pub.issue_enroll_url(sample_path, saved_ctype)
        result = cvc.create_cloned_voice(audio_url=audio_url, language=lang, prefix=preferred)
    except RuntimeError as exc:
        msg = str(exc)
        status = 503 if "BACKEND_PUBLIC_URL" in msg else 502
        raise HTTPException(status_code=status, detail=msg) from exc

    voice = result["voice"]
    tts_model = result.get("target_model") or cvc.VOICE_CLONE_TTS_MODEL
    fallback = bool(result.get("fallback_mode"))

    if existing:
        existing.voice = voice
        existing.tts_model = tts_model
        existing.preferred_name = preferred
        existing.sample_text = enroll_text
        existing.language = lang
        existing.fallback_mode = fallback
        existing.sample_relpath = rel
        existing.sample_content_type = saved_ctype
        existing.prefer_playback = True
        db.add(existing)
        db.commit()
        db.refresh(existing)
        return existing

    row = UserClonedVoice(
        user_id=user.id,
        voice=voice,
        tts_model=tts_model,
        preferred_name=preferred,
        sample_text=enroll_text,
        language=lang,
        fallback_mode=fallback,
        sample_relpath=rel,
        sample_content_type=saved_ctype,
        prefer_playback=True,
    )
    db.add(row)
    db.commit()
    db.refresh(row)
    return row


def set_prefer_playback(db: Session, user: User, prefer: bool) -> UserClonedVoice:
    row = get_row(db, user)
    if not row or not (row.voice or "").strip():
        raise HTTPException(status_code=404, detail="尚未复刻声音")
    row.prefer_playback = bool(prefer)
    db.add(row)
    db.commit()
    db.refresh(row)
    return row


def delete_for_user(db: Session, user: User) -> bool:
    row = get_row(db, user)
    if not row:
        return False
    if (row.voice or "").strip():
        _delete_remote_voice(row.voice, row.tts_model)
    _delete_local_samples(user.id)
    # 清该用户相关合成缓存前缀
    db.delete(row)
    db.commit()
    return True


def read_sample(row: UserClonedVoice) -> tuple[bytes, str]:
    path = _sample_path(row)
    if not path.is_file():
        raise HTTPException(status_code=404, detail="样本录音不存在")
    return path.read_bytes(), row.sample_content_type or "audio/mpeg"


def _delete_remote_voice(voice: str, tts_model: str | None) -> None:
    model = (tts_model or "").strip()
    try:
        if cvc.is_cosyvoice_model(model):
            cvc.delete_cloned_voice(voice)
        else:
            qvc.delete_cloned_voice(voice)
    except RuntimeError:
        try:
            if cvc.is_cosyvoice_model(model):
                qvc.delete_cloned_voice(voice)
            else:
                cvc.delete_cloned_voice(voice)
        except RuntimeError:
            pass


def _cache_path(voice: str, text: str, model: str) -> Path:
    key = hashlib.sha1(f"{model}\n{voice}\n{text}".encode("utf-8")).hexdigest()
    return CACHE_DIR / f"{key}.mp3"


def synthesize_for_user(
    db: Session,
    user: User,
    text: str,
    *,
    duration_ms: int | None = None,
) -> tuple[bytes, bool]:
    if not voice_clone_ready():
        raise HTTPException(status_code=503, detail="声音复刻未配置")
    row = get_row(db, user)
    if not row or not (row.voice or "").strip():
        raise HTTPException(status_code=404, detail="尚未复刻声音，请先录音创建")
    if needs_reenroll(row):
        raise HTTPException(status_code=409, detail="当前音色需重新录制后才能用于语速对齐朗读")

    try:
        cleaned = normalize_tts_text(text)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    if len(cleaned) > 500:
        raise HTTPException(status_code=400, detail="文本过长（最多 500 字）")

    model = row.tts_model or cvc.VOICE_CLONE_TTS_MODEL
    lang = row.language or "en"
    use_ssml = duration_ms is not None and duration_ms > 0
    synth_text = tts_ssml.build_subtitle_ssml(cleaned, duration_ms) if use_ssml else cleaned
    cache_payload = synth_text if use_ssml else cleaned

    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    path = _cache_path(row.voice, cache_payload, model)
    if path.is_file() and path.stat().st_size > 0:
        return path.read_bytes(), True

    try:
        audio = cvc.synthesize_with_cloned_voice(
            synth_text,
            voice=row.voice,
            tts_model=model,
            language=lang,
            enable_ssml=use_ssml,
        )
    except RuntimeError as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc

    if not audio:
        raise HTTPException(status_code=502, detail="TTS 返回空音频")

    tmp = path.with_suffix(".tmp")
    tmp.write_bytes(audio)
    tmp.replace(path)
    return audio, False
