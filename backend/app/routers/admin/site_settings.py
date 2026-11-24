from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from ...database import get_db
from ...deps import get_current_admin
from ...models import User
from ...schemas import AdminSiteSettingsOut, AdminSiteSettingsPatchIn
from ...services.site_settings import (
    get_available_target_languages,
    is_language_selection_enabled,
    is_membership_gate_enabled,
    set_available_target_languages,
    set_language_selection_enabled,
    set_membership_gate_enabled,
)

router = APIRouter(prefix="/api/admin/site-settings", tags=["admin-site-settings"])


def _out(db: Session) -> AdminSiteSettingsOut:
    return AdminSiteSettingsOut(
        membership_gate_enabled=is_membership_gate_enabled(db),
        language_selection_enabled=is_language_selection_enabled(db),
        available_target_languages=get_available_target_languages(db),
    )


@router.get("/", response_model=AdminSiteSettingsOut)
def get_site_settings(_admin: User = Depends(get_current_admin), db: Session = Depends(get_db)):
    return _out(db)


@router.patch("/", response_model=AdminSiteSettingsOut)
def patch_site_settings(
    body: AdminSiteSettingsPatchIn,
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    if body.membership_gate_enabled is not None:
        set_membership_gate_enabled(db, body.membership_gate_enabled)
    if body.language_selection_enabled is not None:
        set_language_selection_enabled(db, body.language_selection_enabled)
    if body.available_target_languages is not None:
        set_available_target_languages(db, body.available_target_languages)
    return _out(db)
