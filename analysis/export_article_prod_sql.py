"""将 add-article.sql（含 DDL）转为生产库可用的纯数据导入脚本。"""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SRC = ROOT / "add-article.sql"
DST = ROOT / "add-article-prod.sql"

ARTICLE_PUBLIC_ID = "RMVm_F-btmyczxo"


def main() -> None:
    text = SRC.read_text(encoding="utf-8")

    article_m = re.search(
        r'INSERT INTO "articles".*?VALUES \(1,\'([^\']+)\',(.*?)\);',
        text,
        re.DOTALL,
    )
    if not article_m:
        raise SystemExit("未找到 articles INSERT")

    public_id = article_m.group(1)
    article_values = article_m.group(2).strip()

    seg_m = re.search(
        r'INSERT INTO "article_segments".*?VALUES (.*?);\s*-- user_article_progress',
        text,
        re.DOTALL,
    )
    if not seg_m:
        raise SystemExit("未找到 article_segments INSERT")

    raw_rows = seg_m.group(1).strip()
    row_re = re.compile(
        r"\((\d+),1,(\d+),'((?:''|[^'])*)','((?:''|[^'])*)','((?:''|[^'])*)','((?:''|[^'])*)',(\d+)\)"
    )
    rows = row_re.findall(raw_rows)
    if not rows:
        raise SystemExit("未能解析 article_segments 行")

    rows.sort(key=lambda r: int(r[1]))

    lines = [
        "-- News Reading 文章生产导入（仅数据，不含建表）",
        f"-- generated from {SRC.name}",
        f"-- article_id: {public_id}",
        "-- 用法：在生产 PostgreSQL 执行本文件",
        "",
        "BEGIN;",
        "",
        "-- 若生产库是旧版后端启动的，补 TTS 相关字段",
        "ALTER TABLE articles ADD COLUMN IF NOT EXISTS tts_status varchar(16) NOT NULL DEFAULT 'none';",
        "ALTER TABLE article_segments ADD COLUMN IF NOT EXISTS audio_url text NOT NULL DEFAULT '';",
        "ALTER TABLE article_segments ADD COLUMN IF NOT EXISTS duration_ms integer NOT NULL DEFAULT 0;",
        "",
        f"-- 文章：{public_id}",
        "INSERT INTO articles (",
        "  article_id, title, summary, source, source_url, topic, cover,",
        "  stars, word_count, segment_count, status, is_free_preview,",
        "  published_at, created_at, updated_at, tts_status",
        ")",
        f"SELECT '{public_id}', {article_values}",
        f"WHERE NOT EXISTS (SELECT 1 FROM articles WHERE article_id = '{public_id}');",
        "",
        "-- 若已存在则先删旧段落，再导入（避免重复 index）",
        "DELETE FROM article_segments",
        f"WHERE article_id = (SELECT id FROM articles WHERE article_id = '{public_id}');",
        "",
    ]

    for _id, index, english, chinese, english_html, audio_url, duration_ms in rows:
        lines.append(
            "INSERT INTO article_segments (article_id, index, english, chinese, english_html, audio_url, duration_ms)"
        )
        lines.append(
            f"SELECT a.id, {index}, '{english}', '{chinese}', '{english_html}', '{audio_url}', {duration_ms}"
        )
        lines.append(
            f"FROM articles a WHERE a.article_id = '{public_id}';"
        )
        lines.append("")

    lines.extend(
        [
            "COMMIT;",
            "",
            f"-- imported segments: {len(rows)}",
        ]
    )

    DST.write_text("\n".join(lines), encoding="utf-8")
    print(f"Wrote {DST} ({len(rows)} segments)")


if __name__ == "__main__":
    main()
