"""Legacy router — routes moved to routers.admin.episodes."""

from fastapi import APIRouter

router = APIRouter(prefix="/api/admin/episodes", tags=["admin-episodes"])
