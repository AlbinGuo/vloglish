from .db_url import database_host_label
from .env import load_app_env

load_app_env()

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from sqlalchemy import inspect, text

from .database import DATABASE_URL, Base, SessionLocal, engine, is_postgresql
from .models import ActivationCode
from .schemas import AuthTokensOut
from .routers import auth, demo, entries, episode_submit, episodes, learning, notifications, presence, articles
from .routers.admin import learning as admin_learning
from .routers.admin import activation_codes as admin_activation_codes
from .routers.admin import auth as admin_auth
from .routers.admin import authors as admin_authors
from .routers.admin import articles as admin_articles
from .routers.admin import dashboard as admin_dashboard
from .routers.admin import demo_codes as admin_demo_codes
from .routers.admin import episode_import as admin_episode_import
from .routers.admin import episodes as admin_episodes
from .routers.admin import notifications as admin_notifications
from .routers.admin import presence as admin_presence
from .routers.admin import tags as admin_tags
from .routers.admin import series as admin_series
from .routers.admin import teco_import as admin_teco_import
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
app.include_router(articles.router)
app.include_router(presence.router)
app.include_router(admin_auth.router)
app.include_router(admin_dashboard.router)
app.include_router(admin_activation_codes.router)
app.include_router(admin_users.router)
app.include_router(admin_teco_import.router)
app.include_router(admin_episode_import.router)
app.include_router(admin_episodes.router)
app.include_router(admin_articles.router)
app.include_router(admin_demo_codes.router)
app.include_router(admin_authors.router)
app.include_router(admin_tags.router)
app.include_router(admin_series.router)
app.include_router(admin_notifications.router)
app.include_router(admin_learning.router)
app.include_router(admin_presence.router)
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
    from .redis_client import REDIS_URL, redis_ping

    redis_ok = redis_ping() if REDIS_URL else None
    return {
        "status": "ok",
        "redis": "ok" if redis_ok else ("disabled" if not REDIS_URL else "down"),
    }


@app.on_event("startup")
def startup():
    from .redis_client import REDIS_URL, get_redis, redis_url_label

    print(f"[vloglish] database → {database_host_label(DATABASE_URL)}")
    if REDIS_URL:
        client = get_redis()
        print(
            f"[vloglish] redis → {redis_url_label()} "
            f"({'ok' if client else 'unavailable, falling back to DB'})"
        )
    else:
        print("[vloglish] redis → disabled (set REDIS_URL to enable word-card hot cache)")
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

    bool_default = "false" if is_postgresql() else "0"
    datetime_type = "TIMESTAMP" if is_postgresql() else "DATETIME"

    cols = {c["name"] for c in insp.get_columns("users")}
    if "is_staff" not in cols:
        with engine.begin() as conn:
            conn.execute(
                text(f"ALTER TABLE users ADD COLUMN is_staff BOOLEAN NOT NULL DEFAULT {bool_default}")
            )
    if "session_version" not in cols:
        with engine.begin() as conn:
            conn.execute(
                text("ALTER TABLE users ADD COLUMN session_version INTEGER NOT NULL DEFAULT 1")
            )
    if "refresh_tokens" in insp.get_table_names():
        rt_cols = {c["name"] for c in insp.get_columns("refresh_tokens")}
        if "session_key" not in rt_cols:
            with engine.begin() as conn:
                conn.execute(
                    text(
                        "ALTER TABLE refresh_tokens ADD COLUMN session_key VARCHAR(64) NOT NULL DEFAULT ''"
                    )
                )
        if "device_id" in rt_cols:
            # device_id 已有；确保可用索引便于按设备替换会话（无则跳过）
            pass
    if "last_seen_at" not in cols:
        with engine.begin() as conn:
            conn.execute(text(f"ALTER TABLE users ADD COLUMN last_seen_at {datetime_type}"))
    for col, col_type in (
        ("signup_country", "VARCHAR(64)"),
        ("signup_region", "VARCHAR(64)"),
        ("signup_city", "VARCHAR(64)"),
    ):
        if col not in cols:
            with engine.begin() as conn:
                conn.execute(text(f"ALTER TABLE users ADD COLUMN {col} {col_type}"))
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
                conn.execute(
                    text(f"ALTER TABLE episodes ADD COLUMN published_at {datetime_type}")
                )
                conn.execute(
                    text(
                        "UPDATE episodes SET published_at = created_at "
                        "WHERE status = 'published' AND published_at IS NULL"
                    )
                )
        if "series_id" not in ep_cols:
            with engine.begin() as conn:
                conn.execute(text("ALTER TABLE episodes ADD COLUMN series_id INTEGER"))
        if "series_index" not in ep_cols:
            with engine.begin() as conn:
                conn.execute(text("ALTER TABLE episodes ADD COLUMN series_index INTEGER"))
        if "is_pinned" not in ep_cols:
            with engine.begin() as conn:
                conn.execute(
                    text(f"ALTER TABLE episodes ADD COLUMN is_pinned BOOLEAN NOT NULL DEFAULT {bool_default}")
                )
    if "user_notifications" in insp.get_table_names():
        notif_cols = {c["name"] for c in insp.get_columns("user_notifications")}
        if "broadcast_id" not in notif_cols:
            with engine.begin() as conn:
                conn.execute(text("ALTER TABLE user_notifications ADD COLUMN broadcast_id INTEGER"))
        if "image_url" not in notif_cols:
            with engine.begin() as conn:
                conn.execute(text("ALTER TABLE user_notifications ADD COLUMN image_url TEXT NOT NULL DEFAULT ''"))
    if "admin_broadcasts" in insp.get_table_names():
        bc_cols = {c["name"] for c in insp.get_columns("admin_broadcasts")}
        if "image_url" not in bc_cols:
            with engine.begin() as conn:
                conn.execute(text("ALTER TABLE admin_broadcasts ADD COLUMN image_url TEXT NOT NULL DEFAULT ''"))
    if "user_word_lookups" in insp.get_table_names():
        lookup_cols = {c["name"] for c in insp.get_columns("user_word_lookups")}
        if "article_id" not in lookup_cols:
            with engine.begin() as conn:
                conn.execute(text("ALTER TABLE user_word_lookups ADD COLUMN article_id INTEGER"))
        if "segment_id" not in lookup_cols:
            with engine.begin() as conn:
                conn.execute(text("ALTER TABLE user_word_lookups ADD COLUMN segment_id INTEGER"))
    if "user_vocabulary_items" in insp.get_table_names():
        vocab_cols = {c["name"] for c in insp.get_columns("user_vocabulary_items")}
        if "source_article_id" not in vocab_cols:
            with engine.begin() as conn:
                conn.execute(text("ALTER TABLE user_vocabulary_items ADD COLUMN source_article_id INTEGER"))
        if "source_segment_id" not in vocab_cols:
            with engine.begin() as conn:
                conn.execute(text("ALTER TABLE user_vocabulary_items ADD COLUMN source_segment_id INTEGER"))
        if "source_type" not in vocab_cols:
            with engine.begin() as conn:
                conn.execute(
                    text("ALTER TABLE user_vocabulary_items ADD COLUMN source_type VARCHAR(16) NOT NULL DEFAULT 'video'")
                )
    if "articles" in insp.get_table_names():
        art_cols = {c["name"] for c in insp.get_columns("articles")}
        if "tts_status" not in art_cols:
            with engine.begin() as conn:
                conn.execute(
                    text("ALTER TABLE articles ADD COLUMN tts_status VARCHAR(16) NOT NULL DEFAULT 'none'")
                )
    if "article_segments" in insp.get_table_names():
        seg_cols = {c["name"] for c in insp.get_columns("article_segments")}
        if "audio_url" not in seg_cols:
            with engine.begin() as conn:
                conn.execute(text("ALTER TABLE article_segments ADD COLUMN audio_url TEXT NOT NULL DEFAULT ''"))
        if "duration_ms" not in seg_cols:
            with engine.begin() as conn:
                conn.execute(
                    text("ALTER TABLE article_segments ADD COLUMN duration_ms INTEGER NOT NULL DEFAULT 0")
                )