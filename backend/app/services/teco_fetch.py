"""Import episodes from teco-lab.com with vloglish branding."""
from __future__ import annotations

import re
import shutil
import tempfile
import urllib.request
from pathlib import Path

from sqlalchemy.orm import Session

from ..database import DATA_DIR
from ..models import Episode
from ..qiniu_storage import QiniuConfig, episode_media_urls, qiniu_object_exists, upload_file
from .episode_json_import import apply_episode_detail_json, upsert_episode_summary
from .media_branding import generate_episode_cover, process_imported_video
from .teco_client import TecoAuthClient


def guess_ext(url: str, default: str) -> str:
    path = url.split("?", 1)[0]
    ext = Path(path).suffix.lower()
    if ext in {".mp4", ".webm", ".mp3", ".m4a", ".webp", ".jpg", ".jpeg", ".png"}:
        return ext
    return default


def download_file(url: str, dest: Path) -> Path:
    dest.parent.mkdir(parents=True, exist_ok=True)
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req, timeout=600) as resp:
        dest.write_bytes(resp.read())
    return dest


def extract_index(item: dict) -> int | None:
    if item.get("index") is not None:
        return int(item["index"])
    cover = item.get("cover", "")
    m = re.search(r"clip(\d+)", cover)
    if m:
        return int(m.group(1))
    return None


def fetch_catalog_in_index_range(
    client: TecoAuthClient,
    *,
    index_from: int,
    index_to: int,
    page_size: int = 50,
) -> list[dict]:
    if index_from > index_to:
        index_from, index_to = index_to, index_from

    collected: dict[str, dict] = {}
    page = 1
    while page <= 20:
        batch = client.episode_list(page=page, page_size=page_size)
        if not batch:
            break
        lowest_idx = None
        for item in batch:
            idx = extract_index(item)
            if idx is None:
                continue
            lowest_idx = idx if lowest_idx is None else min(lowest_idx, idx)
            if index_from <= idx <= index_to:
                collected[item["video_id"]] = item
        if lowest_idx is not None and lowest_idx < index_from:
            break
        if len(batch) < page_size:
            break
        page += 1

    return sorted(collected.values(), key=lambda x: extract_index(x) or 0)


def catalog_with_db_flags(
    db: Session,
    items: list[dict],
    *,
    cfg: QiniuConfig | None = None,
) -> list[dict]:
    if not items:
        return []
    ids = [item["video_id"] for item in items]
    existing = {
        row.video_id: row.id
        for row in db.query(Episode).filter(Episode.video_id.in_(ids)).all()
    }
    out: list[dict] = []
    for item in items:
        vid = item["video_id"]
        qiniu_has = False
        if cfg is not None:
            qiniu_has = qiniu_object_exists(cfg, vid, "video.mp4")
        out.append(
            {
                "video_id": vid,
                "index": extract_index(item),
                "short_title": item.get("short_title", ""),
                "stars": item.get("stars", 3),
                "clip_length": item.get("clip_length", 0),
                "subtitle_count": item.get("subtitle_count", 0),
                "cover_preview": item.get("cover", ""),
                "exists_in_db": vid in existing,
                "episode_db_id": existing.get(vid),
                "qiniu_has_video": qiniu_has,
            }
        )
    return out


def upload_episode_media(cfg: QiniuConfig, video_id: str, media_dir: Path) -> dict[str, str]:
    uploads: dict[str, str] = {}

    cover_candidates = sorted(media_dir.glob("cover.*"))
    if cover_candidates:
        cover_local = cover_candidates[0]
        key = cfg.object_key(video_id, cover_local.name)
        uploads["cover"] = upload_file(cfg, cover_local, key)
        uploads["thumbnail_url"] = uploads["cover"]

    video_local = None
    for p in sorted(media_dir.glob("video.*")):
        video_local = p
        break
    if video_local and video_local.is_file():
        key = cfg.object_key(video_id, video_local.name)
        uploads["video_url"] = upload_file(cfg, video_local, key)

    audio_local = None
    for p in sorted(media_dir.glob("audio.*")):
        audio_local = p
        break
    if audio_local and audio_local.is_file():
        key = cfg.object_key(video_id, audio_local.name)
        uploads["audio_url"] = upload_file(cfg, audio_local, key)

    return uploads


def apply_manifest_to_detail(detail: dict, manifest: dict, summary: dict) -> None:
    ep = detail["episode"]
    media = ep.setdefault("media", {})
    if manifest.get("video_url"):
        media["video_url"] = manifest["video_url"]
    if manifest.get("audio_url"):
        media["audio_url"] = manifest["audio_url"]
    if manifest.get("thumbnail_url"):
        media["thumbnail_url"] = manifest["thumbnail_url"]
    if manifest.get("cover"):
        ep["cover"] = manifest["cover"]
        summary["cover"] = manifest["cover"]


def import_teco_episode(
    db: Session,
    client: TecoAuthClient,
    cfg: QiniuConfig,
    summary: dict,
    *,
    status: str = "published",
    skip_existing: bool = False,
    apply_branding: bool = True,
    media_mode: str = "full",
) -> dict:
    video_id = summary["video_id"]
    if skip_existing and db.query(Episode).filter(Episode.video_id == video_id).first():
        return {
            "video_id": video_id,
            "skipped": True,
            "created": False,
            "subtitle_count": 0,
            "message": "已存在，已跳过",
        }

    client.ensure_auth()
    detail = client.episode_detail(video_id)
    ep = detail["episode"]
    media = ep.get("media") or {}

    for key in ("short_title", "summary", "remark", "stars", "voca_size", "subtitle_count", "clip_length", "tags"):
        if key not in summary or summary.get(key) in (None, "", []):
            if ep.get(key) is not None:
                summary[key] = ep[key]
    if "author" not in summary and ep.get("author"):
        summary["author"] = ep["author"]
    idx = extract_index(summary) or extract_index(ep)
    if idx is not None:
        summary["index"] = idx

    warnings: list[str] = []
    work_dir: Path | None = None

    try:
        if media_mode == "qiniu_only":
            if not qiniu_object_exists(cfg, video_id, "video.mp4"):
                raise RuntimeError(
                    f"七牛上未找到 {video_id}/video.mp4，请先完整导入或确认路径 {cfg.object_key(video_id, 'video.mp4')}"
                )
            manifest = episode_media_urls(cfg, video_id)
            if not qiniu_object_exists(cfg, video_id, "audio.mp3"):
                warnings.append("七牛上无 audio.mp3，音频字段留空")
                manifest["audio_url"] = ""
            if not qiniu_object_exists(cfg, video_id, "cover.webp"):
                warnings.append("七牛上无 cover.webp")
                manifest["cover"] = ""
                manifest["thumbnail_url"] = ""
        else:
            work_dir = Path(tempfile.mkdtemp(prefix=f"teco-{video_id}-"))
            media_dir = work_dir / "media"
            media_dir.mkdir(parents=True, exist_ok=True)

            video_url = media.get("video_url") or ""
            if not video_url:
                raise RuntimeError(f"{video_id} 详情中无 video_url")

            ext = guess_ext(video_url, ".mp4")
            video_local = media_dir / f"video{ext}"
            download_file(video_url, video_local)

            if apply_branding:
                process_imported_video(video_local)
                idx = extract_index(summary) or extract_index(ep) or 0
                title = summary.get("short_title") or ep.get("short_title") or video_id
                clip_len = float(summary.get("clip_length") or ep.get("clip_length") or 0)
                try:
                    generate_episode_cover(
                        video_local,
                        video_id=video_id,
                        episode_index=idx,
                        short_title=title,
                        clip_length_hint=clip_len,
                        dest_path=media_dir / "cover.webp",
                    )
                except RuntimeError as exc:
                    warnings.append(f"封面生成失败: {exc}")
            else:
                warnings.append("已跳过视频处理")

            audio_url = media.get("audio_url") or ""
            if audio_url:
                aext = guess_ext(audio_url, ".mp3")
                download_file(audio_url, media_dir / f"audio{aext}")

            manifest = upload_episode_media(cfg, video_id, media_dir)
            if not manifest.get("cover"):
                warnings.append("未生成封面，列表可能无图")

        apply_manifest_to_detail(detail, manifest, summary)

        idx = extract_index(summary) or extract_index(ep)
        if idx is not None:
            summary["index"] = idx
            ep["index"] = idx

        _, created = upsert_episode_summary(db, summary, is_demo=False, status=status)
        apply_episode_detail_json(db, detail, is_demo=False, status=status)
        db.commit()

        sub_count = len(ep.get("subtitles") or [])
        return {
            "video_id": video_id,
            "skipped": False,
            "created": created,
            "subtitle_count": sub_count,
            "cover_url": manifest.get("cover", ""),
            "video_url": manifest.get("video_url", ""),
            "warnings": warnings,
            "message": "数据库同步成功" if media_mode == "qiniu_only" else "导入成功",
        }
    except Exception:
        db.rollback()
        raise
    finally:
        if work_dir is not None:
            shutil.rmtree(work_dir, ignore_errors=True)


def sync_db_from_qiniu_range(
    db: Session,
    client: TecoAuthClient,
    cfg: QiniuConfig,
    *,
    index_from: int,
    index_to: int,
    status: str = "published",
    skip_existing: bool = True,
    force_update: bool = False,
) -> dict:
    catalog = fetch_catalog_in_index_range(client, index_from=index_from, index_to=index_to)
    results: list[dict] = []
    errors: list[str] = []
    created = updated = skipped = 0

    for summary in catalog:
        video_id = summary["video_id"]
        in_db = db.query(Episode).filter(Episode.video_id == video_id).first()
        if in_db and skip_existing and not force_update:
            results.append({"video_id": video_id, "skipped": True, "message": "数据库已有"})
            skipped += 1
            continue
        if not qiniu_object_exists(cfg, video_id, "video.mp4"):
            errors.append(f"{video_id}（第{summary.get('index')}期）：七牛无 video.mp4，跳过")
            continue
        try:
            row = import_teco_episode(
                db,
                client,
                cfg,
                summary,
                status=status,
                skip_existing=False if force_update else skip_existing,
                apply_branding=False,
                media_mode="qiniu_only",
            )
            results.append(row)
            if row.get("skipped"):
                skipped += 1
            elif row.get("created"):
                created += 1
            else:
                updated += 1
        except Exception as exc:
            errors.append(f"{video_id}: {exc}")

    return {
        "index_from": min(index_from, index_to),
        "index_to": max(index_from, index_to),
        "total": len(catalog),
        "created": created,
        "updated": updated,
        "skipped": skipped,
        "failed": len(errors),
        "results": results,
        "errors": errors,
    }


def get_teco_client() -> TecoAuthClient:
    return TecoAuthClient.from_env()
