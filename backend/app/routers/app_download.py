"""公开：App 扫码下载落地页 + 版本检查。"""

from fastapi import APIRouter, Depends, HTTPException, Query
from fastapi.responses import RedirectResponse
from sqlalchemy.orm import Session

from ..database import get_db
from ..schemas import AppVersionCheckOut, PublicAppDownloadOut
from ..services import app_release as app_release_svc

router = APIRouter(prefix="/api", tags=["app-download"])


@router.get("/app-download/", response_model=PublicAppDownloadOut)
def get_public_app_download(db: Session = Depends(get_db)):
    return PublicAppDownloadOut(**app_release_svc.public_app_download(db))


@router.get("/app-download/android/")
def download_android_apk(db: Session = Depends(get_db)):
    """中转下载：计数后 302 到 APK 直链。"""
    url = app_release_svc.increment_android_download(db)
    if not url:
        raise HTTPException(status_code=404, detail="Android 安装包暂未开放下载")
    return RedirectResponse(url=url, status_code=302)


@router.get("/app/version-check/", response_model=AppVersionCheckOut)
def check_app_version(
    version_code: int = Query(0, ge=0, description="当前 App 的 versionCode"),
    db: Session = Depends(get_db),
):
    return AppVersionCheckOut(
        **app_release_svc.check_app_version(db, current_version_code=version_code)
    )
