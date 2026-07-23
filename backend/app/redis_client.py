"""Redis 连接（词卡等跨进程共享缓存）。REDIS_URL 未配置或不可用时返回 None，业务自行降级。"""

from __future__ import annotations

import logging
import os
import threading
import time

logger = logging.getLogger(__name__)

REDIS_URL = os.getenv("REDIS_URL", "").strip()

_client = None
_client_lock = threading.Lock()
_last_fail_at = 0.0
_RETRY_AFTER_SEC = 15.0


def get_redis():
    """返回 redis.Redis 客户端；不可用时返回 None（会周期性重试连接）。"""
    global _client, _last_fail_at

    if not REDIS_URL:
        return None

    if _client is not None:
        return _client

    now = time.time()
    if _last_fail_at and now - _last_fail_at < _RETRY_AFTER_SEC:
        return None

    with _client_lock:
        if _client is not None:
            return _client
        if _last_fail_at and time.time() - _last_fail_at < _RETRY_AFTER_SEC:
            return None
        try:
            import redis

            client = redis.Redis.from_url(
                REDIS_URL,
                decode_responses=True,
                socket_connect_timeout=1.5,
                socket_timeout=3.0,
                health_check_interval=30,
            )
            client.ping()
            _client = client
            _last_fail_at = 0.0
            logger.info("Redis connected → %s", _safe_url_label(REDIS_URL))
            return _client
        except Exception:
            _last_fail_at = time.time()
            logger.warning(
                "Redis unavailable (url=%s), word-card cache will fall back to DB",
                _safe_url_label(REDIS_URL),
                exc_info=True,
            )
            return None


def redis_ping() -> bool:
    client = get_redis()
    if client is None:
        return False
    try:
        return bool(client.ping())
    except Exception:
        return False


def _safe_url_label(url: str) -> str:
    if "@" in url:
        scheme, rest = url.split("://", 1) if "://" in url else ("redis", url)
        host_part = rest.split("@", 1)[-1]
        return f"{scheme}://{host_part}"
    return url


def redis_url_label() -> str:
    return _safe_url_label(REDIS_URL) if REDIS_URL else ""
