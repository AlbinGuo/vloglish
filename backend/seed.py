"""Import sample data from analysis/api-responses.json"""
from __future__ import annotations

import json
import re
import sys
import time
import uuid
import http.cookiejar
import urllib.error
import urllib.request
from pathlib import Path

from app.database import Base, DATA_DIR, SessionLocal, engine
from app.media import episode_audio_api_url, is_youtube_episode
from app.models import Author, DemoCode, Entry, Episode, Subtitle, Tag

ROOT = Path(__file__).resolve().parent.parent
SAMPLE = ROOT / "analysis" / "api-responses.json"
EXTRA = ROOT / "analysis" / "extra-episodes.json"
BASE_URL = "https://www.teco-lab.com"
DEMO_CODE = "ALICE"


class RemoteClient:
    """Fetch episode data from teco-lab.com (requires demo session)."""

    def __init__(self) -> None:
        self.device_id = str(uuid.uuid4())
        self.cj = http.cookiejar.CookieJar()
        self.opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(self.cj))
        self._verified = False

    def request(self, method: str, path: str, body: dict | None = None) -> tuple[int, dict | list | str]:
        ts = str(int(time.time()))
        nonce = str(uuid.uuid4())
        data = json.dumps(body).encode() if body else None
        req = urllib.request.Request(
            BASE_URL + path,
            data=data,
            headers={
                "Content-Type": "application/json",
                "X-Device-Id": self.device_id,
                "X-Timestamp": ts,
                "X-Nonce": nonce,
                "Accept": "application/json",
                "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
            },
            method=method,
        )
        try:
            with self.opener.open(req, timeout=60) as resp:
                raw = resp.read().decode()
                return resp.status, json.loads(raw)
        except urllib.error.HTTPError as e:
            raw = e.read().decode()
            try:
                return e.code, json.loads(raw)
            except json.JSONDecodeError:
                return e.code, raw

    def ensure_demo_session(self) -> bool:
        if self._verified:
            return True
        status, data = self.request(
            "POST",
            "/api/demo/verify-code/",
            {"code": DEMO_CODE, "device_id": self.device_id},
        )
        if status == 200 and isinstance(data, dict) and data.get("success"):
            self._verified = True
            return True
        print(f"Demo verify failed: status={status} data={data}")
        return False


def http_json(method: str, path: str, body: dict | None = None) -> tuple[int, dict | list | str]:
    client = RemoteClient()
    if not client.ensure_demo_session():
        return 403, {"message": "demo verify failed"}
    return client.request(method, path, body)


def get_or_create_tag(db, tag_id: int, name: str) -> Tag:
    tag = db.query(Tag).filter(Tag.id == tag_id).first()
    if tag:
        return tag
    tag = Tag(id=tag_id, name=name)
    db.add(tag)
    return tag


def get_or_create_author(db, data: dict) -> Author:
    author = (
        db.query(Author)
        .filter(Author.name == data["name"], Author.accent == data.get("accent", ""))
        .first()
    )
    if author:
        return author
    author = Author(
        name=data["name"],
        gender=data.get("gender", "m"),
        nationality=data.get("nationality", ""),
        accent=data.get("accent", ""),
    )
    db.add(author)
    db.flush()
    return author


def upsert_episode_from_summary(db, item: dict, is_demo: bool = True) -> Episode:
    author = get_or_create_author(db, item["author"])
    tags = [get_or_create_tag(db, t["id"], t["name"]) for t in item.get("tags", [])]

    ep = db.query(Episode).filter(Episode.video_id == item["video_id"]).first()
    if not ep:
        ep = Episode(video_id=item["video_id"])
        db.add(ep)

    ep.short_title = item["short_title"]
    ep.summary = item.get("summary", "")
    ep.remark = item.get("remark", "")
    ep.stars = item.get("stars", 3)
    ep.voca_size = item.get("voca_size", 0)
    ep.subtitle_count = item.get("subtitle_count", 0)
    ep.clip_length = item.get("clip_length", 0)
    ep.cover = item.get("cover", "")
    ep.author_id = author.id
    ep.is_demo = is_demo
    ep.tags = tags
    if item.get("index") is not None:
        ep.index = item["index"]
    else:
        m = re.search(r"clip(\d+)", item.get("cover", ""))
        if m:
            ep.index = int(m.group(1))
    db.flush()
    return ep


def apply_episode_detail(db, detail: dict) -> Episode:
    ep_data = detail["episode"]
    ep = db.query(Episode).filter(Episode.video_id == ep_data["video_id"]).first()
    if not ep:
        ep = Episode(video_id=ep_data["video_id"])
        db.add(ep)

    author = get_or_create_author(db, ep_data["author"])
    tags = [get_or_create_tag(db, t["id"], t["name"]) for t in ep_data.get("tags", [])]

    ep.index = ep_data.get("index", 0)
    ep.short_title = ep_data["short_title"]
    ep.summary = ep_data.get("summary", "")
    ep.remark = ep_data.get("remark", "")
    ep.stars = ep_data.get("stars", 3)
    ep.voca_size = ep_data.get("voca_size", 0)
    ep.subtitle_count = ep_data.get("subtitle_count", 0)
    ep.original_video_url = ep_data.get("original_video_url", "")
    ep.author_id = author.id
    ep.tags = tags
    ep.is_demo = True

    media = ep_data.get("media", {})
    ep.video_url = media.get("video_url", "")
    ep.audio_url = media.get("audio_url", "")
    ep.thumbnail_url = media.get("thumbnail_url", "")

    if not ep.audio_url and is_youtube_episode(
        video_id=ep.video_id,
        video_url=ep.video_url,
        original_video_url=ep.original_video_url,
    ):
        ep.audio_url = episode_audio_api_url(ep.video_id)

    db.query(Subtitle).filter(Subtitle.episode_id == ep.id).delete()
    db.flush()

    for s in ep_data.get("subtitles", []):
        db.add(
            Subtitle(
                id=s["id"],
                episode_id=ep.id,
                index=s["index"],
                start=s["start"],
                end=s["end"],
                english=s["english"],
                chinese=s.get("chinese", ""),
                ipa=s.get("ipa", ""),
                english_html=s.get("english_html", ""),
            )
        )

    db.flush()
    return ep


def fetch_remote_detail(client: RemoteClient, video_id: str) -> dict | None:
    status, data = client.request("GET", f"/api/episode/{video_id}/detail/")
    if status == 200 and isinstance(data, dict) and "episode" in data:
        return data
    print(f"  Fetch failed for {video_id}: HTTP {status}")
    return None


def episode_needs_detail(ep: Episode, force: bool) -> bool:
    if force:
        return True
    if not ep.video_url:
        return True
    if len(ep.subtitles) == 0 and ep.subtitle_count > 0:
        return True
    return False


def seed_entries(db, sample: dict):
    entry_data = sample.get("entry_detail_sample", {}).get("data")
    if entry_data:
        upsert_entry(db, entry_data)

    for item in sample.get("subtitle_entries", {}).get("sample", []) or []:
        if item["id"] == (entry_data or {}).get("id"):
            continue
        if db.query(Entry).filter(Entry.id == item["id"]).first():
            continue
        db.add(
            Entry(
                id=item["id"],
                headword=item["headword"],
                category=item.get("category", "单词"),
                forms=item.get("forms", ""),
                exam_tags_json=json.dumps(item.get("exam_tags", [])),
                data_json="{}",
            )
        )


def upsert_entry(db, data: dict):
    entry = db.query(Entry).filter(Entry.id == data["id"]).first()
    payload = {
        "pronunciations": data.get("pronunciations", []),
        "definitions": data.get("definitions", []),
    }
    if not entry:
        entry = Entry(id=data["id"])
        db.add(entry)
    entry.headword = data["headword"]
    entry.category = data.get("category", "单词")
    entry.exam_tags_json = json.dumps(data.get("exam_tags", []))
    entry.data_json = json.dumps(payload)


def load_media_subtitles(video_id: str) -> list[dict] | None:
    subs_file = DATA_DIR / "media" / video_id / "subtitles.json"
    if not subs_file.is_file():
        return None
    return json.loads(subs_file.read_text(encoding="utf-8"))


def main(fetch_remote: bool = False, force_fetch: bool = False):
    if not SAMPLE.exists():
        print(f"Missing {SAMPLE}")
        sys.exit(1)

    sample = json.loads(SAMPLE.read_text(encoding="utf-8"))
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()

    try:
        episodes_data = sample.get("episodes", {}).get("data", [])
        for item in episodes_data:
            upsert_episode_from_summary(db, item, is_demo=True)

        if "first_episode_detail" in sample:
            apply_episode_detail(db, sample["first_episode_detail"])

        if EXTRA.exists():
            extra = json.loads(EXTRA.read_text(encoding="utf-8"))
            for item in extra.get("episodes", []):
                upsert_episode_from_summary(db, item, is_demo=True)
            for detail in extra.get("details", []):
                vid = detail["episode"]["video_id"]
                subs = load_media_subtitles(vid)
                if subs:
                    detail["episode"]["subtitles"] = subs
                    detail["episode"]["subtitle_count"] = len(subs)
                apply_episode_detail(db, detail)
                if subs:
                    ep = db.query(Episode).filter(Episode.video_id == vid).first()
                    if ep:
                        ep.subtitle_count = len(subs)

        if fetch_remote:
            client = RemoteClient()
            if not client.ensure_demo_session():
                print("ERROR: cannot verify demo code ALICE — remote fetch skipped")
            else:
                print("Demo session OK, fetching episode details...")
                for item in episodes_data:
                    vid = item["video_id"]
                    ep = db.query(Episode).filter(Episode.video_id == vid).first()
                    if not ep or not episode_needs_detail(ep, force_fetch):
                        print(f"  Skip {vid} (already complete)")
                        continue
                    print(f"  Fetching {vid}...")
                    remote = fetch_remote_detail(client, vid)
                    if remote:
                        apply_episode_detail(db, remote)
                        print(f"  OK {vid}: {len(remote['episode'].get('subtitles', []))} subtitles")

        seed_entries(db, sample)

        demo = db.query(DemoCode).filter(DemoCode.code == "ALICE").first()
        if not demo:
            demo = DemoCode(code="ALICE", affiliate_code=None, active=True)
            db.add(demo)
            db.flush()

        all_eps = db.query(Episode).filter(Episode.is_demo.is_(True)).all()
        demo.episodes = all_eps

        db.commit()
        print(f"Seeded {len(all_eps)} demo episodes, {db.query(Entry).count()} entries")
    finally:
        db.close()


if __name__ == "__main__":
    fetch = "--fetch" in sys.argv
    force = "--force" in sys.argv
    main(fetch_remote=fetch, force_fetch=force)
