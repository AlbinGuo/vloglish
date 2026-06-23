"""Optional proxy to teco-lab.com for entry lookup when not cached locally."""
from __future__ import annotations

import json
import time
import uuid
import http.cookiejar
import urllib.error
import urllib.request

BASE_URL = "https://www.teco-lab.com"
DEMO_CODE = "ALICE"


class RemoteClient:
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
            with self.opener.open(req, timeout=30) as resp:
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
        return False


_client: RemoteClient | None = None


def get_client() -> RemoteClient:
    global _client
    if _client is None:
        _client = RemoteClient()
    return _client


def remote_lookup(token_id: int, token_type: int) -> dict | None:
    client = get_client()
    if not client.ensure_demo_session():
        return None
    status, data = client.request("GET", f"/api/lookup/?id={token_id}&type={token_type}")
    if status != 200 or not isinstance(data, dict) or not data.get("headword"):
        return None
    return data


def remote_entry_detail(entry_id: int) -> dict | None:
    client = get_client()
    if not client.ensure_demo_session():
        return None
    status, data = client.request("GET", f"/api/entry-detail/?entry_id={entry_id}")
    if status != 200 or not isinstance(data, dict) or not data.get("headword"):
        return None
    return data
