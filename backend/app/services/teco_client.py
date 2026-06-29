"""Authenticated HTTP client for www.teco-lab.com (member catalog)."""
from __future__ import annotations

import hashlib
import hmac
import http.cookiejar
import json
import os
import time
import urllib.error
import urllib.parse
import urllib.request
import uuid
from pathlib import Path

from ..database import DATA_DIR

BASE_URL = "https://www.teco-lab.com"
SESSION_FILE = DATA_DIR / "teco_session.json"


class TecoAuthClient:
    def __init__(self, *, device_id: str | None = None) -> None:
        self.device_id = device_id or str(uuid.uuid4())
        self.cj = http.cookiejar.CookieJar()
        self.opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(self.cj))
        self.access_token: str | None = None
        self.refresh_token: str | None = None

    @classmethod
    def from_env(cls) -> TecoAuthClient:
        client = cls()
        token = os.getenv("TECO_ACCESS_TOKEN", "").strip()
        if token:
            client.access_token = token
            env_device = os.getenv("TECO_DEVICE_ID", "").strip()
            if env_device:
                client.device_id = env_device
            return client
        if SESSION_FILE.is_file():
            return cls.from_session_file(SESSION_FILE)
        return client

    @classmethod
    def from_session_file(cls, path: Path) -> TecoAuthClient:
        data = json.loads(path.read_text(encoding="utf-8"))
        access = (data.get("access") or data.get("access_token") or "").strip()
        if not access:
            raise RuntimeError(f"Missing access token in {path}")
        client = cls(device_id=(data.get("device_id") or data.get("deviceId") or "").strip() or None)
        client.access_token = access
        client.refresh_token = (data.get("refresh") or data.get("refresh_token") or "").strip() or None
        return client

    @staticmethod
    def _credentials() -> tuple[str, str]:
        email = os.getenv("TECO_EMAIL", os.getenv("TECO_USERNAME", "")).strip()
        password = os.getenv("TECO_PASSWORD", "").strip()
        if not email or not password:
            raise RuntimeError(
                "请配置 teco-lab 会员认证：backend/data/teco_session.json，"
                "或 .env 中的 TECO_ACCESS_TOKEN / TECO_EMAIL+TECO_PASSWORD"
            )
        return email, password

    @staticmethod
    def _nonce() -> str:
        return os.urandom(12).hex()

    def _signature(self, method: str, path: str, timestamp: str, body: str) -> str:
        if not self.access_token:
            return ""
        message = f"{method.upper()}\n{path}\n{timestamp}\n{body}"
        return hmac.new(
            self.access_token.encode("utf-8"),
            message.encode("utf-8"),
            hashlib.sha256,
        ).hexdigest()

    def request(
        self,
        method: str,
        path: str,
        body: dict | None = None,
        *,
        auth: bool = True,
    ) -> tuple[int, dict | list | str]:
        ts = str(int(time.time()))
        nonce = self._nonce()
        body_str = json.dumps(body, separators=(",", ":"), ensure_ascii=False) if body else ""
        canonical_path = path if path.startswith("/") else urllib.parse.urlparse(path).path
        headers = {
            "Content-Type": "application/json",
            "X-Device-Id": self.device_id,
            "X-Timestamp": ts,
            "X-Nonce": nonce,
            "Accept": "application/json",
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
        }
        if auth and self.access_token:
            headers["Authorization"] = f"Bearer {self.access_token}"
            sig = self._signature(method, canonical_path, ts, body_str)
            if sig:
                headers["X-Signature"] = sig

        data = body_str.encode("utf-8") if body else None
        url = path if path.startswith("http") else BASE_URL + path
        req = urllib.request.Request(url, data=data, headers=headers, method=method)
        try:
            with self.opener.open(req, timeout=120) as resp:
                raw = resp.read().decode()
                if not raw:
                    return resp.status, {}
                return resp.status, json.loads(raw)
        except urllib.error.HTTPError as e:
            raw = e.read().decode()
            try:
                return e.code, json.loads(raw)
            except json.JSONDecodeError:
                return e.code, raw

    def login(self) -> None:
        if self.access_token:
            return
        email, password = self._credentials()
        body = {"username": email, "password": password}
        status, data = self.request("POST", "/api/login/", body, auth=False)
        if status == 200 and isinstance(data, dict) and data.get("access"):
            self.access_token = data["access"]
            self.refresh_token = data.get("refresh")
            return
        detail = data if isinstance(data, dict) else {"raw": data}
        raise RuntimeError(f"teco-lab 登录失败 ({status}): {detail}")

    def ensure_auth(self) -> None:
        if not self.access_token:
            self.login()

    def get_json(self, path: str, *, auth: bool = True) -> dict | list:
        status, data = self.request("GET", path, auth=auth)
        if status != 200:
            raise RuntimeError(f"GET {path} failed ({status}): {data}")
        return data

    def episode_list(self, *, page: int = 1, page_size: int = 50) -> list[dict]:
        data = self.get_json(
            f"/api/episode-list/?page={page}&page_size={page_size}&ordering=index",
            auth=False,
        )
        if isinstance(data, dict) and "results" in data:
            return data["results"]
        if isinstance(data, list):
            return data
        raise RuntimeError(f"Unexpected episode-list response: {type(data)}")

    def episode_detail(self, video_id: str) -> dict:
        data = self.get_json(f"/api/episode/{video_id}/detail/")
        if isinstance(data, dict) and "episode" in data:
            return data
        raise RuntimeError(f"Unexpected detail response for {video_id}")

    def auth_status(self) -> dict:
        has_session = SESSION_FILE.is_file()
        has_token = bool(os.getenv("TECO_ACCESS_TOKEN", "").strip())
        has_login = bool(
            os.getenv("TECO_EMAIL", os.getenv("TECO_USERNAME", "")).strip()
            and os.getenv("TECO_PASSWORD", "").strip()
        )
        return {
            "configured": has_session or has_token or has_login,
            "session_file": str(SESSION_FILE),
            "has_session_file": has_session,
            "has_access_token": has_token,
            "has_email_password": has_login,
        }
