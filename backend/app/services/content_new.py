"""User-facing “new / unread” helpers for series & articles (2-day window)."""
from __future__ import annotations

from datetime import datetime, timedelta

from ..services.episode_admin import NEW_EPISODE_DAYS


def parse_iso_dt(value: str | None) -> datetime | None:
    if not value or not str(value).strip():
        return None
    text = str(value).strip()
    if text.endswith("Z"):
        text = text[:-1]
    if "+" in text[10:]:
        text = text[: text.index("+", 10)]
    if "." in text:
        text = text.split(".", 1)[0]
    try:
        return datetime.fromisoformat(text)
    except ValueError:
        try:
            return datetime.strptime(text[:10], "%Y-%m-%d")
        except ValueError:
            return None


def content_is_new(ref: datetime | None, *, now: datetime | None = None) -> bool:
    if not ref:
        return False
    current = now or datetime.utcnow()
    return current - ref < timedelta(days=NEW_EPISODE_DAYS)


def is_unread(
    ref: datetime | None,
    seen_at: datetime | None,
    *,
    now: datetime | None = None,
) -> bool:
    """Unread = within new window AND newer than last list visit (if any)."""
    if not content_is_new(ref, now=now):
        return False
    if seen_at is None:
        return True
    return ref > seen_at


def latest_dt(*values: datetime | None) -> datetime | None:
    present = [v for v in values if v is not None]
    if not present:
        return None
    return max(present)


def fmt_dt(value: datetime | None) -> str:
    if not value:
        return ""
    return value.isoformat() + "Z"
