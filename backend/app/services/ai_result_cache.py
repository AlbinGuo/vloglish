"""AI 讲解 / 挖空共享结果缓存：优先 Redis，不可用时进程内降级。

同一字幕文案对所有用户复用，命中时不调模型、不扣额度。
"""

from __future__ import annotations

import hashlib
import json
import logging
import os
import time
from typing import Any

from ..redis_client import get_redis

logger = logging.getLogger(__name__)

# 默认 30 天；字幕变更靠 content_hash 失效
_TTL_SEC = int(os.getenv("AI_RESULT_CACHE_TTL_SECONDS", str(30 * 24 * 3600)) or "0")
_MEM: dict[str, tuple[float, str]] = {}
_MEM_MAX = 500


def content_hash(*parts: str) -> str:
    raw = "\n".join((p or "").strip() for p in parts)
    return hashlib.sha1(raw.encode("utf-8")).hexdigest()[:20]


def _key(kind: str, subtitle_id: int, digest: str) -> str:
    return f"ai:{kind}:{subtitle_id}:{digest}"


def get_ai_result(kind: str, subtitle_id: int, digest: str) -> dict[str, Any] | None:
    key = _key(kind, subtitle_id, digest)
    client = get_redis()
    if client is not None:
        try:
            raw = client.get(key)
            if raw:
                data = json.loads(raw)
                if isinstance(data, dict):
                    return data
        except Exception:
            logger.debug("ai result redis get failed kind=%s", kind, exc_info=True)

    hit = _MEM.get(key)
    if not hit:
        return None
    expires_at, blob = hit
    if _TTL_SEC > 0 and time.time() > expires_at:
        _MEM.pop(key, None)
        return None
    try:
        data = json.loads(blob)
        return data if isinstance(data, dict) else None
    except Exception:
        return None


def set_ai_result(kind: str, subtitle_id: int, digest: str, payload: dict[str, Any]) -> None:
    key = _key(kind, subtitle_id, digest)
    # 不缓存额度字段，避免串用户
    clean = {k: v for k, v in payload.items() if k != "quota"}
    blob = json.dumps(clean, ensure_ascii=False)
    client = get_redis()
    if client is not None:
        try:
            if _TTL_SEC > 0:
                client.setex(key, _TTL_SEC, blob)
            else:
                client.set(key, blob)
            return
        except Exception:
            logger.debug("ai result redis set failed kind=%s", kind, exc_info=True)

    expires = time.time() + (_TTL_SEC if _TTL_SEC > 0 else 30 * 24 * 3600)
    _MEM[key] = (expires, blob)
    if len(_MEM) > _MEM_MAX:
        for old in list(_MEM.keys())[:80]:
            _MEM.pop(old, None)
