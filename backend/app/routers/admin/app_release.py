"""管理端：App 发布（APK + 文案）。"""

from __future__ import annotations

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile
from sqlalchemy.orm import Session

from ...database import get_db
from ...deps import get_current_admin
from ...models import User
from ...qiniu_storage import QiniuConfig
from ...schemas import AppApkUploadOut, AppReleaseOut, AppReleasePatchIn
from ...services import app_release as app_release_svc
from ...services.app_apk import upload_app_apk

router = APIRouter(prefix="/api/admin/app-release", tags=["admin-app-release"])


@router.get("/", response_model=AppReleaseOut)
def get_app_release(_admin: User = Depends(get_current_admin), db: Session = Depends(get_db)):
    return AppReleaseOut(**app_release_svc.get_app_release(db))


@router.patch("/", response_model=AppReleaseOut)
def patch_app_release(
    body: AppReleasePatchIn,
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    patch = body.model_dump(exclude_unset=True)
    data = app_release_svc.save_app_release(db, patch)
    return AppReleaseOut(**data)


@router.post("/upload-apk/", response_model=AppApkUploadOut)
async def upload_apk(
    file: UploadFile = File(...),
    admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    data = await file.read()
    try:
        cfg = QiniuConfig.from_env()
        url = upload_app_apk(cfg, data, file.filename)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e)) from e
    except RuntimeError as e:
        raise HTTPException(status_code=502, detail=str(e)) from e
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"APK 上传失败: {e}") from e

    # 上传成功后写入当前发布配置
    saved = app_release_svc.save_app_release(db, {"android_apk_url": url, "enabled": True})
    _ = admin  # 鉴权用
    return AppApkUploadOut(android_apk_url=saved["android_apk_url"])
