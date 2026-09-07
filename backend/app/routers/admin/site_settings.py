from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from ...database import get_db
from ...deps import get_current_admin
from ...models import User
from ...schemas import AdminSiteSettingsOut, AdminSiteSettingsPatchIn
from ...services.site_settings import is_membership_gate_enabled, set_membership_gate_enabled

router = APIRouter(prefix="/api/admin/site-settings", tags=["admin-site-settings"])


@router.get("/", response_model=AdminSiteSettingsOut)
def get_site_settings(_admin: User = Depends(get_current_admin), db: Session = Depends(get_db)):
    return AdminSiteSettingsOut(membership_gate_enabled=is_membership_gate_enabled(db))


@router.patch("/", response_model=AdminSiteSettingsOut)
def patch_site_settings(
    body: AdminSiteSettingsPatchIn,
    _admin: User = Depends(get_current_admin),
    db: Session = Depends(get_db),
):
    enabled = (
        set_membership_gate_enabled(db, body.membership_gate_enabled)
        if body.membership_gate_enabled is not None
        else is_membership_gate_enabled(db)
    )
    return AdminSiteSettingsOut(membership_gate_enabled=enabled)
