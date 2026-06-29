"""Resolve DATABASE_URL: db_switch.py (local dev) > env DATABASE_URL > sqlite."""
from __future__ import annotations

import os
import sys
from pathlib import Path

BACKEND_DIR = Path(__file__).resolve().parent.parent


def resolve_database_url(default_sqlite: str) -> str:
    if str(BACKEND_DIR) not in sys.path:
        sys.path.insert(0, str(BACKEND_DIR))
    try:
        import db_switch

        url = db_switch.DATABASE_URLS[db_switch.ACTIVE_DB]
        if not url:
            raise RuntimeError(f"db_switch.DATABASE_URLS[{db_switch.ACTIVE_DB!r}] is empty")
        return url
    except ImportError:
        pass
    except KeyError as exc:
        import db_switch

        raise RuntimeError(
            f"db_switch.ACTIVE_DB={db_switch.ACTIVE_DB!r} 不在 DATABASE_URLS 中，"
            f"可选：{list(db_switch.DATABASE_URLS)}"
        ) from exc

    return os.getenv("DATABASE_URL") or default_sqlite


def database_host_label(url: str) -> str:
    if url.startswith("sqlite"):
        return "sqlite(default)"
    if "@" not in url:
        return "unknown"
    host_part = url.split("@", 1)[1].split("/", 1)[0]
    if host_part.startswith("db:") or host_part in ("localhost:5432", "127.0.0.1:5432"):
        return f"local ({host_part})"
    if "8.137.196.234" in host_part or ":15432" in host_part:
        return f"remote/production ({host_part})"
    return host_part
