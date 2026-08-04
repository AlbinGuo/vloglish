"""生词本列表缓存：优先 Redis，不可用时进程内降级。"""

from __future__ import annotations

import json
import logging
import os
from typing import Any

from ..redis_client import get_redis

logger = logging.getLogger(__name__)

_TTL_SEC = int(os.getenv("VOCAB_LIST_REDIS_TTL_SECONDS", "300") or "300")
_MEM: dict[str, tuple[float, str]] = {}


def _key(user_id: int, article_ref: str | None) -> str:
    ref = (article_ref or "").strip() or "_"
    return f"vocab:list:{user_id}:{ref}"


def get_vocab_list_cache(user_id: int, article_ref: str | None = None) -> list[dict[str, Any]] | None:
    key = _key(user_id, article_ref)
    client = get_redis()
    if client is not None:
        try:
            raw = client.get(key)
            if raw:
                data = json.loads(raw)
                if isinstance(data, list):
                    return data
        except Exception:
            logger.debug("vocab list redis get failed", exc_info=True)

    import time

    hit = _MEM.get(key)
    if not hit:
        return None
    expires_at, blob = hit
    if time.time() > expires_at:
        _MEM.pop(key, None)
        return None
    try:
        data = json.loads(blob)
        return data if isinstance(data, list) else None
    except Exception:
        return None


def set_vocab_list_cache(
    user_id: int,
    items: list[dict[str, Any]],
    article_ref: str | None = None,
) -> None:
    key = _key(user_id, article_ref)
    blob = json.dumps(items, ensure_ascii=False)
    client = get_redis()
    if client is not None:
        try:
            if _TTL_SEC > 0:
                client.setex(key, _TTL_SEC, blob)
            else:
                client.set(key, blob)
            return
        except Exception:
            logger.debug("vocab list redis set failed", exc_info=True)

    import time

    _MEM[key] = (time.time() + max(_TTL_SEC, 60), blob)
    if len(_MEM) > 300:
        for old in list(_MEM.keys())[:50]:
            _MEM.pop(old, None)


def invalidate_vocab_list_cache(user_id: int) -> None:
    """增删生词后清掉该用户全部列表缓存。"""
    prefix = f"vocab:list:{user_id}:"
    client = get_redis()
    if client is not None:
        try:
            # 常见只有全局列表与少量 article_ref；用 scan 避免 KEYS
            cursor = 0
            while True:
                cursor, keys = client.scan(cursor=cursor, match=f"{prefix}*", count=50)
                if keys:
                    client.delete(*keys)
                if cursor == 0:
                    break
        except Exception:
            logger.debug("vocab list redis invalidate failed", exc_info=True)

    for key in list(_MEM.keys()):
        if key.startswith(prefix):
            _MEM.pop(key, None)
