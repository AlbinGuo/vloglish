from .db_url import database_host_label
from .env import load_app_env

load_app_env()

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from sqlalchemy import inspect, text

from .database import DATABASE_URL, Base, SessionLocal, engine, is_postgresql
from .models import (
    ActivationCode,
    AiUsageEvent,
    ExampleTranslationCache,
    UserAuthorSubscription,
    UserPageDwell,
    UserPracticeRecord,
    WishRequest,
    WishRequestLike,
    WordPracticeSession,
    WordPracticeStat,
    WordPracticeWrong,
)
from .schemas import AuthTokensOut
from .routers import ai_coach, app_download, article_submit, auth, demo, entries, episode_submit, episodes, feedback, learning, membership, notifications, presence, articles, site_config, wish_wall, word_practice
from .routers.admin import learning as admin_learning
from .routers.admin import activation_codes as admin_activation_codes
from .routers.admin import ai_usage as admin_ai_usage
from .routers.admin import app_release as admin_app_release
from .routers.admin import auth as admin_auth
from .routers.admin import authors as admin_authors
from .routers.admin import articles as admin_articles
from .routers.admin import dashboard as admin_dashboard
from .routers.admin import demo_codes as admin_demo_codes
from .routers.admin import episode_import as admin_episode_import
from .routers.admin import episodes as admin_episodes
from .routers.admin import feedback as admin_feedback
from .routers.admin import wish_wall as admin_wish_wall
from .routers.admin import membership_orders as admin_membership_orders
from .routers.admin import notifications as admin_notifications
from .routers.admin import presence as admin_presence
from .routers.admin import site_settings as admin_site_settings
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
app.include_router(site_config.router)
app.include_router(app_download.router)
app.include_router(demo.router)
app.include_router(episodes.router)
app.include_router(episode_submit.router)
app.include_router(notifications.router)
app.include_router(feedback.router)
app.include_router(wish_wall.router)
app.include_router(learning.router)
app.include_router(word_practice.router)
app.include_router(entries.router)
app.include_router(article_submit.router)
app.include_router(articles.router)
app.include_router(presence.router)
app.include_router(membership.router)
app.include_router(ai_coach.router)
app.include_router(admin_auth.router)
app.include_router(admin_dashboard.router)
app.include_router(admin_site_settings.router)
app.include_router(admin_app_release.router)
app.include_router(admin_activation_codes.router)
app.include_router(admin_membership_orders.router)
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
app.include_router(admin_feedback.router)
app.include_router(admin_wish_wall.router)
app.include_router(admin_learning.router)
app.include_router(admin_ai_usage.router)
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

    # 练习记录表：create_all 偶发未建时补建（旧进程未重启也会在下次启动补齐）
    if "user_practice_records" not in insp.get_table_names():
        UserPracticeRecord.__table__.create(bind=engine, checkfirst=True)
        print("[vloglish] created table user_practice_records")
        insp = inspect(engine)

    if "ai_usage_events" not in insp.get_table_names():
        AiUsageEvent.__table__.create(bind=engine, checkfirst=True)
        print("[vloglish] created table ai_usage_events")
        insp = inspect(engine)

    if "user_page_dwells" not in insp.get_table_names():
        UserPageDwell.__table__.create(bind=engine, checkfirst=True)
        print("[vloglish] created table user_page_dwells")
        insp = inspect(engine)

    if "word_practice_sessions" not in insp.get_table_names():
        WordPracticeSession.__table__.create(bind=engine, checkfirst=True)
        print("[vloglish] created table word_practice_sessions")
        insp = inspect(engine)
    if "word_practice_wrongs" not in insp.get_table_names():
        WordPracticeWrong.__table__.create(bind=engine, checkfirst=True)
        print("[vloglish] created table word_practice_wrongs")
        insp = inspect(engine)
    if "word_practice_stats" not in insp.get_table_names():
        WordPracticeStat.__table__.create(bind=engine, checkfirst=True)
        print("[vloglish] created table word_practice_stats")
        insp = inspect(engine)
    if "example_translation_cache" not in insp.get_table_names():
        ExampleTranslationCache.__table__.create(bind=engine, checkfirst=True)
        print("[vloglish] created table example_translation_cache")
        insp = inspect(engine)

    if "user_author_subscriptions" not in insp.get_table_names():
        UserAuthorSubscription.__table__.create(bind=engine, checkfirst=True)
        print("[vloglish] created table user_author_subscriptions")
        insp = inspect(engine)

    if "wish_requests" not in insp.get_table_names():
        WishRequest.__table__.create(bind=engine, checkfirst=True)
        print("[vloglish] created table wish_requests")
        insp = inspect(engine)
    if "wish_request_likes" not in insp.get_table_names():
        WishRequestLike.__table__.create(bind=engine, checkfirst=True)
        print("[vloglish] created table wish_request_likes")
        insp = inspect(engine)

    # 早期版本 article_id 为 INTEGER，需改为文章对外 ID（VARCHAR）
    if "user_practice_records" in insp.get_table_names():
        upr_cols = {c["name"]: c for c in insp.get_columns("user_practice_records")}
        article_col = upr_cols.get("article_id")
        if article_col is not None:
            col_type = str(article_col.get("type") or "").lower()
            if "int" in col_type and "varchar" not in col_type and "char" not in col_type:
                with engine.begin() as conn:
                    if is_postgresql():
                        conn.execute(
                            text(
                                "ALTER TABLE user_practice_records "
                                "ALTER COLUMN article_id TYPE VARCHAR(32) "
                                "USING CASE WHEN article_id IS NULL THEN '' ELSE article_id::text END"
                            )
                        )
                        conn.execute(
                            text(
                                "ALTER TABLE user_practice_records "
                                "ALTER COLUMN article_id SET DEFAULT ''"
                            )
                        )
                    else:
                        conn.execute(
                            text(
                                "ALTER TABLE user_practice_records "
                                "ALTER COLUMN article_id TYPE VARCHAR(32)"
                            )
                        )
                print("[vloglish] migrated user_practice_records.article_id → VARCHAR(32)")
                insp = inspect(engine)

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
    if "last_client" not in cols:
        with engine.begin() as conn:
            conn.execute(text("ALTER TABLE users ADD COLUMN last_client VARCHAR(16)"))
    if "avatar_key" not in cols:
        with engine.begin() as conn:
            conn.execute(text("ALTER TABLE users ADD COLUMN avatar_key VARCHAR(32)"))
    if "my_corpus_seen_at" not in cols:
        with engine.begin() as conn:
            conn.execute(text(f"ALTER TABLE users ADD COLUMN my_corpus_seen_at {datetime_type}"))
            # 已有用户视为已看过，避免历史上已通过的投稿全部冒「新」
            now_sql = "NOW()" if is_postgresql() else "CURRENT_TIMESTAMP"
            conn.execute(
                text(f"UPDATE users SET my_corpus_seen_at = {now_sql} WHERE my_corpus_seen_at IS NULL")
            )
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
        if "is_catalog_public" not in ep_cols:
            with engine.begin() as conn:
                conn.execute(
                    text(
                        f"ALTER TABLE episodes ADD COLUMN is_catalog_public BOOLEAN NOT NULL DEFAULT {bool_default}"
                    )
                )
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
        if "vocab_summary" not in ep_cols:
            with engine.begin() as conn:
                conn.execute(text("ALTER TABLE episodes ADD COLUMN vocab_summary TEXT NOT NULL DEFAULT ''"))
        if "video_context" not in ep_cols:
            with engine.begin() as conn:
                conn.execute(text("ALTER TABLE episodes ADD COLUMN video_context TEXT NOT NULL DEFAULT ''"))
        if "release_notified_at" not in ep_cols:
            with engine.begin() as conn:
                conn.execute(
                    text(f"ALTER TABLE episodes ADD COLUMN release_notified_at {datetime_type}")
                )
    if "user_notifications" in insp.get_table_names():
        notif_cols = {c["name"] for c in insp.get_columns("user_notifications")}
        if "broadcast_id" not in notif_cols:
            with engine.begin() as conn:
                conn.execute(text("ALTER TABLE user_notifications ADD COLUMN broadcast_id INTEGER"))
        if "image_url" not in notif_cols:
            with engine.begin() as conn:
                conn.execute(text("ALTER TABLE user_notifications ADD COLUMN image_url TEXT NOT NULL DEFAULT ''"))
        if "popup_acked_at" not in notif_cols:
            with engine.begin() as conn:
                conn.execute(
                    text(f"ALTER TABLE user_notifications ADD COLUMN popup_acked_at {datetime_type}")
                )
        if "article_id" not in notif_cols:
            with engine.begin() as conn:
                conn.execute(text("ALTER TABLE user_notifications ADD COLUMN article_id INTEGER"))
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
        if "vocab_summary" not in art_cols:
            with engine.begin() as conn:
                conn.execute(
                    text("ALTER TABLE articles ADD COLUMN vocab_summary TEXT NOT NULL DEFAULT ''")
                )
        if "release_notified_at" not in art_cols:
            with engine.begin() as conn:
                conn.execute(
                    text(f"ALTER TABLE articles ADD COLUMN release_notified_at {datetime_type}")
                )
        if "submitted_by_user_id" not in art_cols:
            with engine.begin() as conn:
                conn.execute(text("ALTER TABLE articles ADD COLUMN submitted_by_user_id INTEGER"))
        if "is_catalog_public" not in art_cols:
            with engine.begin() as conn:
                conn.execute(
                    text(
                        f"ALTER TABLE articles ADD COLUMN is_catalog_public BOOLEAN NOT NULL DEFAULT {bool_default}"
                    )
                )
        if "rejection_reason" not in art_cols:
            with engine.begin() as conn:
                conn.execute(text("ALTER TABLE articles ADD COLUMN rejection_reason TEXT NOT NULL DEFAULT ''"))
        if "submit_body" not in art_cols:
            with engine.begin() as conn:
                conn.execute(text("ALTER TABLE articles ADD COLUMN submit_body TEXT NOT NULL DEFAULT ''"))
        if "remark" not in art_cols:
            with engine.begin() as conn:
                conn.execute(text("ALTER TABLE articles ADD COLUMN remark TEXT NOT NULL DEFAULT ''"))
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
    if "membership_orders" in insp.get_table_names():
        mo_cols = {c["name"] for c in insp.get_columns("membership_orders")}
        if "user_id" not in mo_cols:
            with engine.begin() as conn:
                conn.execute(text("ALTER TABLE membership_orders ADD COLUMN user_id INTEGER"))
    if "user_daily_visits" in insp.get_table_names():
        visit_cols = {c["name"] for c in insp.get_columns("user_daily_visits")}
        if "session_count" not in visit_cols:
            with engine.begin() as conn:
                conn.execute(
                    text(
                        "ALTER TABLE user_daily_visits "
                        "ADD COLUMN session_count INTEGER NOT NULL DEFAULT 1"
                    )
                )
