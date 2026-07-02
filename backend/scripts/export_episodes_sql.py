"""Export episodes (140-190 etc.) from local DB to PostgreSQL SQL for server import."""
from __future__ import annotations

import argparse
import sys
from datetime import datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

from dotenv import load_dotenv

load_dotenv(ROOT / ".env")

from sqlalchemy.orm import joinedload

from app.database import SessionLocal
from app.db_url import database_host_label, resolve_database_url
from app.models import Episode

DEFAULT_OUT = ROOT.parent / "analysis" / "episodes-140-190.sql"


def sql_literal(value) -> str:
    if value is None:
        return "NULL"
    if isinstance(value, bool):
        return "TRUE" if value else "FALSE"
    if isinstance(value, (int, float)):
        return str(value)
    if isinstance(value, datetime):
        return f"'{value.strftime('%Y-%m-%d %H:%M:%S')}'::timestamp"
    s = str(value).replace("'", "''")
    return f"'{s}'"


def export_sql(
    *,
    index_from: int | None,
    index_to: int | None,
    status: str,
) -> str:
    db = SessionLocal()
    try:
        query = (
            db.query(Episode)
            .options(
                joinedload(Episode.author),
                joinedload(Episode.tags),
                joinedload(Episode.subtitles),
            )
            .order_by(Episode.index.asc(), Episode.id.asc())
        )
        if index_from is not None and index_to is not None:
            lo, hi = min(index_from, index_to), max(index_from, index_to)
            query = query.filter(Episode.index >= lo, Episode.index <= hi)
        episodes = query.all()
    finally:
        db.close()

    if not episodes:
        raise SystemExit("No episodes matched the filter.")

    lines: list[str] = [
        "-- vlogish episode import SQL",
        f"-- generated: {datetime.utcnow().isoformat()}Z",
        f"-- episodes: {len(episodes)} (index {episodes[0].index}..{episodes[-1].index})",
        "-- Run on production PostgreSQL inside transaction.",
        "",
        "BEGIN;",
        "",
    ]

    # --- authors (by name + accent) ---
    seen_authors: set[tuple[str, str, str, str]] = set()
    for ep in episodes:
        a = ep.author
        key = (a.name, a.gender or "m", a.nationality or "", a.accent or "")
        if key in seen_authors:
            continue
        seen_authors.add(key)
        lines.append(
            "INSERT INTO authors (name, gender, nationality, accent)\n"
            f"SELECT {sql_literal(a.name)}, {sql_literal(a.gender or 'm')}, "
            f"{sql_literal(a.nationality or '')}, {sql_literal(a.accent or '')}\n"
            "WHERE NOT EXISTS (\n"
            "  SELECT 1 FROM authors x\n"
            f"  WHERE x.name = {sql_literal(a.name)} AND x.accent = {sql_literal(a.accent or '')}\n"
            ");"
        )
    lines.append("")

    # --- tags (id 无自增序列时须用 MAX(id)+1，避免 tags_pkey 冲突) ---
    seen_tags: set[str] = set()
    for ep in episodes:
        for tag in ep.tags:
            name = tag.name.strip()
            if not name or name in seen_tags:
                continue
            seen_tags.add(name)
            lit = sql_literal(name)
            lines.append(
                "INSERT INTO tags (id, name)\n"
                f"SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM tags), {lit}\n"
                f"WHERE NOT EXISTS (SELECT 1 FROM tags WHERE name = {lit});"
            )
    lines.append("")

    video_ids: list[str] = []

    for ep in episodes:
        vid = ep.video_id
        video_ids.append(vid)
        author = ep.author
        pub = ep.published_at or ep.created_at

        lines.extend(
            [
                f"-- episode {ep.index}: {vid}",
                "INSERT INTO episodes (",
                "  index, video_id, short_title, summary, remark, stars, voca_size,",
                "  subtitle_count, clip_length, cover, video_url, audio_url, thumbnail_url,",
                "  original_video_url, author_id, submitted_by_user_id, rejection_reason,",
                "  created_at, is_demo, status, published_at",
                ") VALUES (",
                f"  {ep.index}, {sql_literal(vid)}, {sql_literal(ep.short_title)},",
                f"  {sql_literal(ep.summary or '')}, {sql_literal(ep.remark or '')},",
                f"  {ep.stars or 3}, {ep.voca_size or 0}, {ep.subtitle_count or 0},",
                f"  {float(ep.clip_length or 0)}, {sql_literal(ep.cover or '')},",
                f"  {sql_literal(ep.video_url or '')}, {sql_literal(ep.audio_url or '')},",
                f"  {sql_literal(ep.thumbnail_url or '')}, {sql_literal(ep.original_video_url or '')},",
                "  (SELECT id FROM authors WHERE name = "
                f"{sql_literal(author.name)} AND accent = {sql_literal(author.accent or '')} LIMIT 1),",
                "  NULL, NULL,",
                f"  {sql_literal(ep.created_at or datetime.utcnow())},",
                f"  {sql_literal(bool(ep.is_demo))}, {sql_literal(status)},",
                f"  {sql_literal(pub)}",
                ")",
                "ON CONFLICT (video_id) DO UPDATE SET",
                "  index = EXCLUDED.index,",
                "  short_title = EXCLUDED.short_title,",
                "  summary = EXCLUDED.summary,",
                "  remark = EXCLUDED.remark,",
                "  stars = EXCLUDED.stars,",
                "  voca_size = EXCLUDED.voca_size,",
                "  subtitle_count = EXCLUDED.subtitle_count,",
                "  clip_length = EXCLUDED.clip_length,",
                "  cover = EXCLUDED.cover,",
                "  video_url = EXCLUDED.video_url,",
                "  audio_url = EXCLUDED.audio_url,",
                "  thumbnail_url = EXCLUDED.thumbnail_url,",
                "  original_video_url = EXCLUDED.original_video_url,",
                "  author_id = EXCLUDED.author_id,",
                "  is_demo = EXCLUDED.is_demo,",
                "  status = EXCLUDED.status,",
                "  published_at = EXCLUDED.published_at;",
                "",
                f"DELETE FROM user_subtitle_progress WHERE subtitle_id IN (",
                f"  SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = {sql_literal(vid)}",
                ");",
                f"DELETE FROM subtitles WHERE episode_id = (SELECT id FROM episodes WHERE video_id = {sql_literal(vid)});",
                f"DELETE FROM episode_tags WHERE episode_id = (SELECT id FROM episodes WHERE video_id = {sql_literal(vid)});",
                "",
            ]
        )

        for tag in ep.tags:
            name = tag.name.strip()
            if not name:
                continue
            lines.append(
                "INSERT INTO episode_tags (episode_id, tag_id)\n"
                f"SELECT e.id, t.id FROM episodes e, tags t\n"
                f"WHERE e.video_id = {sql_literal(vid)} AND t.name = {sql_literal(name)}\n"
                "ON CONFLICT DO NOTHING;"
            )

        for sub in sorted(ep.subtitles, key=lambda s: s.index):
            # subtitles.id 由应用侧 MAX(id)+1 分配，无自增序列时须显式取新 id，避免 subtitles_pkey 冲突
            lines.append(
                "INSERT INTO subtitles (id, episode_id, index, start, \"end\", english, chinese, ipa, english_html)\n"
                f"SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, {sub.index}, "
                f"{float(sub.start)}, {float(sub.end)}, "
                f"{sql_literal(sub.english)}, {sql_literal(sub.chinese or '')}, "
                f"{sql_literal(sub.ipa or '')}, {sql_literal(sub.english_html or '')}\n"
                f"FROM episodes e WHERE e.video_id = {sql_literal(vid)};"
            )
        lines.append("")

    lines.extend(
        [
            "-- sync id sequences if present",
            "SELECT setval(",
            "  pg_get_serial_sequence('tags', 'id'),",
            "  GREATEST(COALESCE((SELECT MAX(id) FROM tags), 1), 1)",
            ") WHERE pg_get_serial_sequence('tags', 'id') IS NOT NULL;",
            "SELECT setval(",
            "  pg_get_serial_sequence('subtitles', 'id'),",
            "  GREATEST(COALESCE((SELECT MAX(id) FROM subtitles), 1), 1)",
            ") WHERE pg_get_serial_sequence('subtitles', 'id') IS NOT NULL;",
            "",
            "COMMIT;",
            "",
            f"-- imported video_ids: {', '.join(video_ids)}",
        ]
    )
    return "\n".join(lines) + "\n"


def main() -> None:
    parser = argparse.ArgumentParser(description="Export episodes to PostgreSQL SQL file")
    parser.add_argument("--index-from", type=int, default=140)
    parser.add_argument("--index-to", type=int, default=190)
    parser.add_argument("--status", default="published", choices=["published", "draft", "archived"])
    parser.add_argument("-o", "--output", type=Path, default=DEFAULT_OUT)
    args = parser.parse_args()

    db_url = resolve_database_url("sqlite")
    print(f"[export-sql] database → {database_host_label(db_url)}")

    sql = export_sql(index_from=args.index_from, index_to=args.index_to, status=args.status)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(sql, encoding="utf-8")
    size_mb = args.output.stat().st_size / (1024 * 1024)
    print(f"Wrote {args.output} ({size_mb:.2f} MB)")


if __name__ == "__main__":
    main()
