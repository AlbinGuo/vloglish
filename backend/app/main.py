from dotenv import load_dotenv
from pathlib import Path

load_dotenv(Path(__file__).resolve().parent.parent / ".env")

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from sqlalchemy import inspect, text

from .database import Base, SessionLocal, engine
from .models import ActivationCode
from .schemas import AuthTokensOut
from .routers import auth, demo, entries, episode_submit, episodes, learning, notifications
from .routers.admin import learning as admin_learning
from .routers.admin import activation_codes as admin_activation_codes
from .routers.admin import auth as admin_auth
from .routers.admin import authors as admin_authors
from .routers.admin import dashboard as admin_dashboard
from .routers.admin import demo_codes as admin_demo_codes
from .routers.admin import episode_import as admin_episode_import
from .routers.admin import episode_tools as admin_episode_tools
from .routers.admin import episodes as admin_episodes
from .routers.admin import notifications as admin_notifications
from .routers.admin import tags as admin_tags
from .routers.admin import users as admin_users
from .services.admin_bootstrap import ensure_admin_user

app = FastAPI(title="Vloglish API", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(demo.router)
app.include_router(episodes.router)
app.include_router(episode_submit.router)
app.include_router(notifications.router)
app.include_router(learning.router)
app.include_router(entries.router)
app.include_router(admin_auth.router)
app.include_router(admin_dashboard.router)
app.include_router(admin_activation_codes.router)
app.include_router(admin_users.router)
app.include_router(admin_episodes.router)
app.include_router(admin_episode_tools.router)
app.include_router(admin_episode_import.router)
app.include_router(admin_demo_codes.router)
app.include_router(admin_authors.router)
app.include_router(admin_tags.router)
app.include_router(admin_notifications.router)
app.include_router(admin_learning.router)
app.add_api_route(
    "/api/token/refresh/",
    auth.refresh_token,
    methods=["POST"],
    tags=["auth"],
    response_model=AuthTokensOut,
)


@app.exception_handler(Exception)
async def unhandled_exception(_request: Request, exc: Exception):
    return JSONResponse(
        status_code=500,
        content={"message": "Internal Server Error", "detail": str(exc)},
    )


@app.get("/api/health")
def health():
    return {"status": "ok"}


@app.on_event("startup")
def startup():
    Base.metadata.create_all(bind=engine)
    _migrate_schema()
    db = SessionLocal()
    try:
        if not db.query(ActivationCode).filter(ActivationCode.code == "DEV1").first():
            db.add(ActivationCode(code="DEV1"))
            db.commit()
        ensure_admin_user(db)
    finally:
        db.close()


def _migrate_schema():
    insp = inspect(engine)
    if "users" not in insp.get_table_names():
        return
    cols = {c["name"] for c in insp.get_columns("users")}
    if "is_staff" not in cols:
        with engine.begin() as conn:
            conn.execute(text("ALTER TABLE users ADD COLUMN is_staff BOOLEAN NOT NULL DEFAULT 0"))
    if "session_version" not in cols:
        with engine.begin() as conn:
            conn.execute(text("ALTER TABLE users ADD COLUMN session_version INTEGER NOT NULL DEFAULT 1"))
    if "episodes" in insp.get_table_names():
        ep_cols = {c["name"] for c in insp.get_columns("episodes")}
        if "status" not in ep_cols:
            with engine.begin() as conn:
                conn.execute(
                    text("ALTER TABLE episodes ADD COLUMN status VARCHAR(16) NOT NULL DEFAULT 'published'")
                )
        if "submitted_by_user_id" not in ep_cols:
            with engine.begin() as conn:
                conn.execute(text("ALTER TABLE episodes ADD COLUMN submitted_by_user_id INTEGER"))
        if "rejection_reason" not in ep_cols:
            with engine.begin() as conn:
                conn.execute(text("ALTER TABLE episodes ADD COLUMN rejection_reason TEXT"))
        if "published_at" not in ep_cols:
            with engine.begin() as conn:
                conn.execute(text("ALTER TABLE episodes ADD COLUMN published_at DATETIME"))
                conn.execute(
                    text(
                        "UPDATE episodes SET published_at = created_at "
                        "WHERE status = 'published' AND published_at IS NULL"
                    )
                )
    if "user_notifications" in insp.get_table_names():
        notif_cols = {c["name"] for c in insp.get_columns("user_notifications")}
        if "broadcast_id" not in notif_cols:
            with engine.begin() as conn:
                conn.execute(text("ALTER TABLE user_notifications ADD COLUMN broadcast_id INTEGER"))