"""公开：App 扫码下载落地页数据。"""

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from ..database import get_db
from ..schemas import PublicAppDownloadOut
from ..services import app_release as app_release_svc

router = APIRouter(prefix="/api", tags=["app-download"])


@router.get("/app-download/", response_model=PublicAppDownloadOut)
def get_public_app_download(db: Session = Depends(get_db)):
    return PublicAppDownloadOut(**app_release_svc.public_app_download(db))
