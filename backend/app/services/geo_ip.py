from __future__ import annotations

import ipaddress
import logging
import threading
from dataclasses import dataclass
from pathlib import Path

logger = logging.getLogger(__name__)

_DATA_DIR = Path(__file__).resolve().parent.parent / "data"
_XDB_PATH = _DATA_DIR / "ip2region_v4.xdb"
_XDB_URL = "https://oss.sxakgs.com/file/ip2region_v4.xdb"

_searcher = None
_searcher_lock = threading.Lock()


@dataclass(frozen=True)
class GeoLocation:
    country: str | None = None
    region: str | None = None
    city: str | None = None


def _is_public_ip(ip: str) -> bool:
    try:
        addr = ipaddress.ip_address(ip)
    except ValueError:
        return False
    return not (addr.is_private or addr.is_loopback or addr.is_link_local or addr.is_reserved)


def _normalize_part(value: str | None) -> str | None:
    if not value:
        return None
    text = value.strip()
    if not text or text == "0":
        return None
    return text


def _parse_region_string(raw: str) -> GeoLocation:
    """解析 ip2region 定位串。

    当前免费库常见格式：`国家|省份|城市|ISP|ISO`
    旧格式偶发：`国家|区域|省份|城市|ISP`（区域常为 0）
    """
    parts = raw.split("|")

    def part(idx: int) -> str | None:
        return _normalize_part(parts[idx] if len(parts) > idx else None)

    country = part(0)
    mid = part(1)
    third = part(2)
    fourth = part(3)
    fifth = part(4)

    # 新格式：Country|Province|City|ISP|CN
    if fifth and len(fifth) == 2 and fifth.isalpha():
        return GeoLocation(country=country, region=mid, city=third)

    # 旧格式：Country|0|Province|City|ISP
    if mid is None and third:
        return GeoLocation(country=country, region=third, city=fourth)

    # 默认按新格式 Country|Province|City|ISP
    return GeoLocation(country=country, region=mid, city=third)


def ensure_ip2region_db() -> Path | None:
    _DATA_DIR.mkdir(parents=True, exist_ok=True)
    if _XDB_PATH.is_file() and _XDB_PATH.stat().st_size > 0:
        return _XDB_PATH
    try:
        import urllib.request

        logger.info("Downloading ip2region database to %s", _XDB_PATH)
        urllib.request.urlretrieve(_XDB_URL, _XDB_PATH)
        if _XDB_PATH.is_file() and _XDB_PATH.stat().st_size > 0:
            return _XDB_PATH
    except Exception as exc:
        logger.warning("Failed to download ip2region database: %s", exc)
    return None


def _get_searcher():
    global _searcher
    if _searcher is not None:
        return _searcher
    with _searcher_lock:
        if _searcher is not None:
            return _searcher
        db_path = ensure_ip2region_db()
        if not db_path:
            return None
        try:
            import ip2region.searcher as xdb
            import ip2region.util as util

            c_buffer = util.load_content_from_file(str(db_path))
            _searcher = xdb.new_with_buffer(util.IPv4, c_buffer)
        except Exception as exc:
            logger.warning("Failed to initialize ip2region searcher: %s", exc)
            _searcher = None
    return _searcher


def resolve_ip(ip: str | None) -> GeoLocation:
    if not ip or not _is_public_ip(ip):
        return GeoLocation()
    searcher = _get_searcher()
    if not searcher:
        return GeoLocation()
    try:
        raw = searcher.search(ip)
        if not raw:
            return GeoLocation()
        return _parse_region_string(str(raw))
    except Exception as exc:
        logger.debug("ip2region lookup failed for %s: %s", ip, exc)
        return GeoLocation()
