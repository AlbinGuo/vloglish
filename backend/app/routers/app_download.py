"""公开：App 扫码下载落地页 + 版本检查。"""

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from ..database import get_db
from ..schemas import AppVersionCheckOut, PublicAppDownloadOut
from ..services import app_release as app_release_svc

router = APIRouter(prefix="/api", tags=["app-download"])


@router.get("/app-download/", response_model=PublicAppDownloadOut)
def get_public_app_download(db: Session = Depends(get_db)):
    return PublicAppDownloadOut(**app_release_svc.public_app_download(db))


@router.get("/app/version-check/", response_model=AppVersionCheckOut)
def check_app_version(
    version_code: int = Query(0, ge=0, description="当前 App 的 versionCode"),
    db: Session = Depends(get_db),
):
    return AppVersionCheckOut(
        **app_release_svc.check_app_version(db, current_version_code=version_code)
    )
