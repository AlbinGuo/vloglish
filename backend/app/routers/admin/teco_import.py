from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from ...database import get_db
from ...deps import get_current_admin
from ...models import User
from ...qiniu_storage import QiniuConfig
from ...schemas import (
    AdminTecoAuthStatusOut,
    AdminTecoCatalogItemOut,
    AdminTecoCatalogOut,
    AdminTecoImportEpisodeIn,
    AdminTecoImportEpisodeOut,
    AdminTecoImportRangeIn,
    AdminTecoImportRangeOut,
    AdminTecoSyncDbFromQiniuIn,
)
from ...services.media_transcode import ffmpeg_tools_status
from ...services.teco_client import TecoAuthClient
from ...services.teco_fetch import (
    catalog_with_db_flags,
    fetch_catalog_in_index_range,
    get_teco_client,
    import_teco_episode,
    sync_db_from_qiniu_range,
)

router = APIRouter(prefix="/api/admin/teco", tags=["admin-teco-import"])


@router.get("/auth-status/", response_model=AdminTecoAuthStatusOut)
def teco_auth_status(_admin: User = Depends(get_current_admin)):
    client = TecoAuthClient.from_env()
    auth = client.auth_status()
    tools = ffmpeg_tools_status()
    return AdminTecoAuthStatusOut(
        **auth,
        ffmpeg_configured=tools["configured"],
        ffmpeg_dir=tools["ffmpeg_dir"],
        has_ffmpeg=tools["has_ffmpeg"],
        has_ffprobe=tools["has_ffprobe"],
    )


@router.get("/catalog/", response_model=AdminTecoCatalogOut)
def teco_catalog(
    index_from: int = Query(191, ge=1),
    index_to: int = Query(199, ge=1),
    check_qiniu: bool = Query(False),
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    try:
        client = get_teco_client()
        items = fetch_catalog_in_index_range(client, index_from=index_from, index_to=index_to)
        cfg = QiniuConfig.from_env() if check_qiniu else None
        rows = catalog_with_db_flags(db, items, cfg=cfg)
    except RuntimeError as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc
    return AdminTecoCatalogOut(
        index_from=min(index_from, index_to),
        index_to=max(index_from, index_to),
        count=len(rows),
        results=[AdminTecoCatalogItemOut(**row) for row in rows],
    )


@router.post("/import-episode/", response_model=AdminTecoImportEpisodeOut)
def teco_import_episode(
    body: AdminTecoImportEpisodeIn,
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    try:
        client = get_teco_client()
        cfg = QiniuConfig.from_env()
    except RuntimeError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc

    summary: dict = {"video_id": body.video_id}
    if body.short_title:
        summary["short_title"] = body.short_title
    if body.index is not None:
        summary["index"] = body.index

    if "short_title" not in summary:
        try:
            if body.index is not None:
                lo = hi = body.index
            else:
                lo, hi = 1, 9999
            catalog = fetch_catalog_in_index_range(client, index_from=lo, index_to=hi)
            match = next((x for x in catalog if x["video_id"] == body.video_id), None)
            if match:
                summary = dict(match)
        except RuntimeError:
            pass
    summary.setdefault("short_title", body.video_id)

    try:
        result = import_teco_episode(
            db,
            client,
            cfg,
            summary,
            status=body.status,
            skip_existing=body.skip_existing,
            apply_branding=body.apply_branding,
            media_mode=body.media_mode,
        )
    except RuntimeError as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc

    return AdminTecoImportEpisodeOut(**result)


@router.post("/import-range/", response_model=AdminTecoImportRangeOut)
def teco_import_range(
    body: AdminTecoImportRangeIn,
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    try:
        client = get_teco_client()
        cfg = QiniuConfig.from_env()
        catalog = fetch_catalog_in_index_range(
            client,
            index_from=body.index_from,
            index_to=body.index_to,
        )
    except RuntimeError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc

    results: list[AdminTecoImportEpisodeOut] = []
    errors: list[str] = []
    created = 0
    updated = 0
    skipped = 0

    for summary in catalog:
        try:
            row = import_teco_episode(
                db,
                client,
                cfg,
                summary,
                status=body.status,
                skip_existing=body.skip_existing,
                apply_branding=body.apply_branding,
                media_mode=body.media_mode,
            )
            item = AdminTecoImportEpisodeOut(**row)
            results.append(item)
            if item.skipped:
                skipped += 1
            elif item.created:
                created += 1
            else:
                updated += 1
        except RuntimeError as exc:
            vid = summary.get("video_id", "?")
            errors.append(f"{vid}: {exc}")

    return AdminTecoImportRangeOut(
        index_from=min(body.index_from, body.index_to),
        index_to=max(body.index_from, body.index_to),
        total=len(catalog),
        created=created,
        updated=updated,
        skipped=skipped,
        failed=len(errors),
        results=results,
        errors=errors,
    )


@router.post("/sync-db-from-qiniu/", response_model=AdminTecoImportRangeOut)
def teco_sync_db_from_qiniu(
    body: AdminTecoSyncDbFromQiniuIn,
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    try:
        client = get_teco_client()
        cfg = QiniuConfig.from_env()
        result = sync_db_from_qiniu_range(
            db,
            client,
            cfg,
            index_from=body.index_from,
            index_to=body.index_to,
            status=body.status,
            skip_existing=body.skip_existing,
            force_update=body.force_update,
        )
    except RuntimeError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc

    return AdminTecoImportRangeOut(
        index_from=result["index_from"],
        index_to=result["index_to"],
        total=result["total"],
        created=result["created"],
        updated=result["updated"],
        skipped=result["skipped"],
        failed=result["failed"],
        results=[AdminTecoImportEpisodeOut(**row) for row in result["results"]],
        errors=result["errors"],
    )
