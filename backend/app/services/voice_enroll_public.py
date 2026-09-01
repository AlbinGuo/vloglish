"""公网样本 URL，供 DashScope CosyVoice enrollment 拉取录音。

短链允许多次 GET/HEAD（TTL 内），避免阿里云先 HEAD 再 GET 导致 404。
"""

from __future__ import annotations

import json
import secrets
import threading
import time
from pathlib import Path

from ..database import DATA_DIR
from .membership_config import backend_public_url

TTL_SEC = 180
TOKEN_DIR = DATA_DIR / "voice_clone" / "_enroll_tokens"

_lock = threading.Lock()


def issue_enroll_url(path: Path, content_type: str) -> str:
    base = backend_public_url()
    if not base:
        raise RuntimeError(
            "未配置 BACKEND_PUBLIC_URL，CosyVoice 复刻需要可被阿里云访问的公网样本地址"
            "（本地可用 ngrok 等将后端映射为公网 HTTPS）"
        )
    token = secrets.token_urlsafe(24)
    ctype = (content_type or "audio/mpeg").split(";")[0].strip() or "audio/mpeg"
    TOKEN_DIR.mkdir(parents=True, exist_ok=True)
    payload = {
        "path": str(path.resolve()),
        "content_type": ctype,
        "expires_at": time.time() + TTL_SEC,
    }
    with _lock:
        _purge_locked()
        (TOKEN_DIR / f"{token}.json").write_text(json.dumps(payload), encoding="utf-8")
    return f"{base}/api/public/voice-enroll/{token}"


def read_enroll_token(token: str) -> tuple[bytes, str] | None:
    """TTL 内可重复读取，不一次性销毁。"""
    key = (token or "").strip()
    if not key or "/" in key or "\\" in key or ".." in key:
        return None
    rec_path = TOKEN_DIR / f"{key}.json"
    with _lock:
        _purge_locked()
        if not rec_path.is_file():
            return None
        try:
            rec = json.loads(rec_path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError):
            return None
        if float(rec.get("expires_at") or 0) < time.time():
            rec_path.unlink(missing_ok=True)
            return None
        audio_path = Path(str(rec.get("path") or ""))
        ctype = str(rec.get("content_type") or "audio/mpeg")
    if not audio_path.is_file():
        return None
    return audio_path.read_bytes(), ctype


def _purge_locked() -> None:
    if not TOKEN_DIR.is_dir():
        return
    now = time.time()
    for p in TOKEN_DIR.glob("*.json"):
        try:
            rec = json.loads(p.read_text(encoding="utf-8"))
            if float(rec.get("expires_at") or 0) < now:
                p.unlink(missing_ok=True)
        except (OSError, json.JSONDecodeError, TypeError, ValueError):
            p.unlink(missing_ok=True)
