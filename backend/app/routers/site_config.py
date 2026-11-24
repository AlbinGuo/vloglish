from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from ..database import get_db
from ..schemas import SiteConfigOut
from ..services.site_settings import (
    get_available_target_languages,
    is_language_selection_enabled,
    is_membership_gate_enabled,
)

router = APIRouter(prefix="/api", tags=["site-config"])


@router.get("/site-config/", response_model=SiteConfigOut)
def get_site_config(db: Session = Depends(get_db)):
    return SiteConfigOut(
        membership_gate_enabled=is_membership_gate_enabled(db),
        language_selection_enabled=is_language_selection_enabled(db),
        available_target_languages=get_available_target_languages(db),
    )
