"""一次性公网样本 URL，供 DashScope CosyVoice enrollment 拉取录音。"""

from __future__ import annotations

import secrets
import threading
import time
from dataclasses import dataclass
from pathlib import Path

from .membership_config import backend_public_url

TTL_SEC = 180


@dataclass
class _Token:
    path: Path
    content_type: str
    expires_at: float


_lock = threading.Lock()
_tokens: dict[str, _Token] = {}


def issue_enroll_url(path: Path, content_type: str) -> str:
    base = backend_public_url()
    if not base:
        raise RuntimeError(
            "未配置 BACKEND_PUBLIC_URL，CosyVoice 复刻需要可被阿里云访问的公网样本地址"
            "（本地可用 ngrok 等将后端映射为公网 HTTPS）"
        )
    token = secrets.token_urlsafe(24)
    ctype = (content_type or "audio/mpeg").split(";")[0].strip() or "audio/mpeg"
    with _lock:
        _purge_locked()
        _tokens[token] = _Token(path=path, content_type=ctype, expires_at=time.time() + TTL_SEC)
    return f"{base}/api/public/voice-enroll/{token}"


def consume_enroll_token(token: str) -> tuple[bytes, str] | None:
    key = (token or "").strip()
    if not key:
        return None
    with _lock:
        _purge_locked()
        rec = _tokens.pop(key, None)
    if not rec:
        return None
    if not rec.path.is_file():
        return None
    return rec.path.read_bytes(), rec.content_type


def _purge_locked() -> None:
    now = time.time()
    dead = [k for k, v in _tokens.items() if v.expires_at < now]
    for k in dead:
        _tokens.pop(k, None)
