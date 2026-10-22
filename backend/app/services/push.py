"""App 系统推送（Android→FCM，iOS→APNs 直发）。

设计要点：
- 配置缺失时 `is_configured()` 返回 False，整条链路自动 no-op，不影响主流程；
- 发布剧集/群发只写一条 `push_outbox`，由后台 worker 异步发送，避免阻塞请求；
- worker 用原子 UPDATE 认领任务，多进程部署也不会重复发送；
- 失效 token（APNs 410/400、FCM 404/410）自动置 `is_active=False`。
"""

from __future__ import annotations

import json
import os
import threading
import time
from datetime import datetime
from pathlib import Path

from jose import jwt
from sqlalchemy.orm import Session

from ..database import SessionLocal
from ..models import PushDevice, PushOutbox

try:  # httpx 仅在真正发送时才需要；缺失时退化为 no-op
    import httpx
except Exception:  # pragma: no cover
    httpx = None  # type: ignore[assignment]

try:  # APNs 走 HTTP/2，需要 httpx[http2] 提供的 h2 包
    import h2  # noqa: F401

    _H2_AVAILABLE = True
except Exception:  # pragma: no cover
    _H2_AVAILABLE = False

_FCM_SCOPE = "https://www.googleapis.com/auth/firebase.messaging"
_FCM_TOKEN_URL = "https://oauth2.googleapis.com/token"
_FCM_SEND_URL = "https://fcm.googleapis.com/v1/projects/{pid}/messages:send"
_ANDROID_CHANNEL_ID = "vloglish_default"

_fcm_sa: dict | None = None
_fcm_tok = {"value": "", "exp": 0.0}


def _read_secret(env_json: str, env_file: str) -> str:
    raw = (os.getenv(env_json) or "").strip()
    path = (os.getenv(env_file) or "").strip()
    if raw:
        return raw
    if path and Path(path).is_file():
        try:
            return Path(path).read_text(encoding="utf-8")
        except OSError:
            return ""
    return ""


def _fcm_account() -> dict | None:
    global _fcm_sa
    if _fcm_sa is None:
        raw = _read_secret("FCM_SERVICE_ACCOUNT_JSON", "FCM_SERVICE_ACCOUNT_FILE")
        try:
            _fcm_sa = json.loads(raw) if raw else {}
        except Exception:
            _fcm_sa = {}
    return _fcm_sa or None


def _fcm_access_token() -> str | None:
    now = time.time()
    if _fcm_tok["value"] and now < _fcm_tok["exp"] - 60:
        return _fcm_tok["value"]
    sa = _fcm_account()
    if not sa or httpx is None:
        return None
    claims = {
        "iss": sa.get("client_email", ""),
        "scope": _FCM_SCOPE,
        "aud": _FCM_TOKEN_URL,
        "iat": int(now),
        "exp": int(now) + 3600,
    }
    assertion = jwt.encode(
        claims, sa.get("private_key", ""), algorithm="RS256",
        headers={"kid": sa.get("private_key_id", "")},
    )
    try:
        resp = httpx.post(
            _FCM_TOKEN_URL,
            data={"grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer", "assertion": assertion},
            timeout=10,
        )
        data = resp.json()
    except Exception:
        return None
    _fcm_tok["value"] = data.get("access_token", "")
    _fcm_tok["exp"] = now + int(data.get("expires_in", 3600))
    return _fcm_tok["value"] or None


def _send_fcm(token: str, title: str, body: str, data: dict) -> str:
    """返回 ok / invalid / error。"""
    sa, at = _fcm_account(), _fcm_access_token()
    if not sa or not at or httpx is None:
        return "error"
    message = {
        "message": {
            "token": token,
            "notification": {"title": title, "body": body},
            "data": {k: str(v) for k, v in data.items()},
            "android": {
                "priority": "high",
                "notification": {"channel_id": _ANDROID_CHANNEL_ID, "sound": "default"},
            },
        }
    }
    try:
        resp = httpx.post(
            _FCM_SEND_URL.format(pid=sa.get("project_id", "")),
            headers={"Authorization": f"Bearer {at}"},
            json=message,
            timeout=10,
        )
    except Exception as exc:
        print("[push] FCM 请求异常:", repr(exc))
        return "error"
    if resp.status_code == 200:
        return "ok"
    try:
        err = resp.json().get("error", {})
        status = err.get("status", "")
        detail = err.get("message", "")
    except Exception:
        status, detail = "", resp.text[:200]
    print(f"[push] FCM 失败 {resp.status_code} {status} {detail}")
    return "invalid" if status in ("UNREGISTERED", "NOT_FOUND") else "error"


def _apns_jwt() -> str | None:
    key = _read_secret("APNS_AUTH_KEY_JSON", "APNS_AUTH_KEY_FILE")
    key_id = (os.getenv("APNS_KEY_ID") or "").strip()
    team_id = (os.getenv("APNS_TEAM_ID") or "").strip()
    if not key or not key_id or not team_id:
        return None
    try:
        return jwt.encode(
            {"iss": team_id, "iat": int(time.time())},
            key,
            algorithm="ES256",
            headers={"kid": key_id},
        )
    except Exception:
        return None


def _send_apns(token: str, title: str, body: str, data: dict, env: str) -> str:
    """返回 ok / invalid / error。"""
    jwtok = _apns_jwt()
    if not jwtok or httpx is None:
        return "error"
    topic = (os.getenv("APNS_TOPIC") or "").strip()
    host = "api.sandbox.push.apple.com" if env == "sandbox" else "api.push.apple.com"
    payload = {
        "aps": {"alert": {"title": title, "body": body}, "sound": "default", "badge": 1},
        **{k: str(v) for k, v in data.items()},
    }
    try:
        resp = httpx.post(
            f"https://{host}/3/device/{token}",
            http2=True,
            headers={
                "authorization": f"bearer {jwtok}",
                "apns-topic": topic,
                "apns-push-type": "alert",
                "apns-priority": "10",
            },
            json=payload,
            timeout=10,
        )
    except Exception as exc:
        # 常见：未安装 h2（httpx[http2]）导致 http2=True 报错；或网络不通
        print("[push] APNs 请求异常:", repr(exc))
        return "error"
    if resp.status_code == 200:
        return "ok"
    reason = ""
    try:
        reason = str(resp.json().get("reason", ""))
    except Exception:
        reason = resp.text[:200]
    print(f"[push] APNs 失败 {resp.status_code} {reason} (env={env or 'production'} topic={topic})")
    # 仅当明确是设备 token 失效时才停用，其余（BadTopic/鉴权等）视为 error 保留设备
    if resp.status_code == 410 or reason in ("BadDeviceToken", "Unregistered", "DeviceTokenNotForTopic"):
        return "invalid"
    return "error"


def is_configured() -> bool:
    if httpx is None:
        return False
    return bool(_fcm_account() or _apns_jwt())


def enqueue_push(db: Session, *, title: str, body: str, data: dict) -> None:
    """写一条待发送任务（不 commit，跟调用方同事务）。"""
    if not is_configured():
        return
    db.add(
        PushOutbox(
            title=(title or "")[:256],
            body=body or "",
            data_json=json.dumps(data or {}, ensure_ascii=False),
        )
    )


def _dispatch(devices: list[PushDevice], title: str, body: str, data: dict) -> int:
    ok = 0
    for d in devices:
        if d.platform == "ios":
            res = _send_apns(d.token, title, body, data, d.env)
        else:
            res = _send_fcm(d.token, title, body, data)
        if res == "ok":
            ok += 1
        elif res == "invalid":
            d.is_active = False
    return ok


def _process_once() -> None:
    if not is_configured():
        return
    db = SessionLocal()
    try:
        job = (
            db.query(PushOutbox)
            .filter(PushOutbox.status == "pending")
            .order_by(PushOutbox.id.asc())
            .first()
        )
        if not job:
            return
        # 原子认领：多 worker/多进程下只有一个能把 pending 改成 processing
        claimed = (
            db.query(PushOutbox)
            .filter(PushOutbox.id == job.id, PushOutbox.status == "pending")
            .update({PushOutbox.status: "processing"}, synchronize_session=False)
        )
        db.commit()
        if not claimed:
            return

        data = json.loads(job.data_json or "{}")
        devices = db.query(PushDevice).filter(PushDevice.is_active.is_(True)).all()
        job.recipient_count = _dispatch(devices, job.title, job.body, data)
        job.status = "done"
        job.processed_at = datetime.utcnow()
        db.commit()
        print(f"[push] outbox#{job.id} 已发送 → 设备 {len(devices)}，成功 {job.recipient_count}")
    except Exception as exc:  # pragma: no cover
        db.rollback()
        print("[push] worker error", exc)
    finally:
        db.close()


def start_push_worker(interval: int = 15) -> None:
    if not is_configured():
        print("[push] 未配置 FCM/APNs，跳过推送 worker")
        return
    if _apns_jwt() and not _H2_AVAILABLE:
        print("[push] ⚠️ 已配置 APNs 但缺少 h2：请 `pip install 'httpx[http2]'`，否则 iOS 推送会一直失败")
    if _apns_jwt() and not (os.getenv("APNS_TOPIC") or "").strip():
        print("[push] ⚠️ APNS_TOPIC 未设置（应填 bundle id，如 cc.vloglish.app），iOS 推送会返回 BadTopic")

    def _loop() -> None:
        while True:
            try:
                _process_once()
            except Exception as exc:  # pragma: no cover
                print("[push] loop error", exc)
            time.sleep(interval)

    threading.Thread(target=_loop, name="push-worker", daemon=True).start()
    print("[push] 推送 worker 已启动")
