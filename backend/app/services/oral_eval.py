"""阿里云智能科教（SSECP）口语评测：服务端鉴权与结果归一化。"""

from __future__ import annotations

import json
import os
import time
import urllib.error
import urllib.request
from hashlib import md5
from typing import Any

DEFAULT_AUTH_URLS = (
    "https://api.cloud.ssapi.cn/auth/authorize",
    "https://gate-01.api.cloud.ssapi.cn/auth/authorize",
    "https://gate-02.api.cloud.ssapi.cn/auth/authorize",
    "https://gate-03.api.cloud.ssapi.cn/auth/authorize",
)


def oral_eval_configured() -> bool:
    app_id = (os.getenv("ORAL_EVAL_APP_ID") or "").strip()
    secret = (os.getenv("ORAL_EVAL_APP_SECRET") or "").strip()
    if not app_id or not secret:
        return False
    flag = (os.getenv("ORAL_EVAL_ENABLED") or "true").strip().lower()
    return flag in ("1", "true", "yes", "on")


def oral_eval_app_id() -> str:
    return (os.getenv("ORAL_EVAL_APP_ID") or "").strip()


def oral_eval_sdk_url() -> str:
    return (os.getenv("ORAL_EVAL_SDK_URL") or "/sdk/engine.js").strip() or "/sdk/engine.js"


def oral_eval_accent() -> str:
    raw = (os.getenv("ORAL_EVAL_ACCENT") or "am").strip().lower()
    return "en" if raw in ("en", "uk", "british") else "am"


def _auth_urls() -> list[str]:
    raw = (os.getenv("ORAL_EVAL_AUTH_URLS") or "").strip()
    if not raw:
        return list(DEFAULT_AUTH_URLS)
    return [u.strip() for u in raw.split(",") if u.strip()]


def _warrant_available() -> int:
    try:
        return max(300, int((os.getenv("ORAL_EVAL_WARRANT_SECONDS") or "7200").strip()))
    except ValueError:
        return 7200


def generate_signature(
    *,
    app_id: str,
    timestamp: str,
    user_id: str,
    user_client_ip: str,
    app_secret: str,
) -> str:
    params = {
        "appid": app_id,
        "timestamp": str(timestamp),
        "user_id": user_id,
        "user_client_ip": user_client_ip,
        "app_secret": app_secret,
    }
    query = "&".join(f"{k}={params[k]}" for k in sorted(params))
    return md5(query.encode("utf-8")).hexdigest()


def _multipart_body(fields: dict[str, str]) -> tuple[bytes, str]:
    boundary = f"----VloglishOral{int(time.time() * 1000)}"
    lines: list[bytes] = []
    for key, value in fields.items():
        lines.append(f"--{boundary}\r\n".encode())
        lines.append(f'Content-Disposition: form-data; name="{key}"\r\n\r\n'.encode())
        lines.append(str(value).encode("utf-8"))
        lines.append(b"\r\n")
    lines.append(f"--{boundary}--\r\n".encode())
    return b"".join(lines), f"multipart/form-data; boundary={boundary}"


def request_warrant(*, user_id: str, user_client_ip: str) -> dict[str, Any]:
    if not oral_eval_configured():
        raise RuntimeError("口语评测未配置（缺少 ORAL_EVAL_APP_ID / ORAL_EVAL_APP_SECRET）")

    app_id = oral_eval_app_id()
    app_secret = (os.getenv("ORAL_EVAL_APP_SECRET") or "").strip()
    timestamp = str(int(time.time()))
    ip = (user_client_ip or "127.0.0.1").strip()[:64] or "127.0.0.1"
    uid = (user_id or "anonymous").strip()[:128] or "anonymous"
    sign = generate_signature(
        app_id=app_id,
        timestamp=timestamp,
        user_id=uid,
        user_client_ip=ip,
        app_secret=app_secret,
    )
    fields = {
        "appid": app_id,
        "timestamp": timestamp,
        "user_id": uid,
        "user_client_ip": ip,
        "request_sign": sign,
        "warrant_available": str(_warrant_available()),
    }
    body, content_type = _multipart_body(fields)

    last_err = "授权失败"
    for url in _auth_urls():
        req = urllib.request.Request(
            url,
            data=body,
            headers={"Content-Type": content_type, "User-Agent": "vloglish-oral-eval/1.0"},
            method="POST",
        )
        try:
            with urllib.request.urlopen(req, timeout=12) as resp:
                raw = resp.read().decode("utf-8", errors="replace")
        except urllib.error.HTTPError as exc:
            try:
                last_err = exc.read().decode("utf-8", errors="replace")[:300]
            except Exception:
                last_err = str(exc)
            continue
        except Exception as exc:
            last_err = str(exc)
            continue

        try:
            data = json.loads(raw)
        except json.JSONDecodeError:
            last_err = "授权响应不是 JSON"
            continue

        code = data.get("code")
        if code is None and data.get("success") is True:
            payload = data.get("data") or {}
            warrant = payload.get("warrantId") or payload.get("warrant_id") or payload.get("AccessWarrantId")
            expire = payload.get("expireTime") or payload.get("expire_at") or payload.get("ExpireTime")
            if warrant:
                return {
                    "warrant_id": str(warrant),
                    "expire_at": int(expire) if str(expire).isdigit() else None,
                    "application_id": app_id,
                    "user_id": uid,
                    "sdk_url": oral_eval_sdk_url(),
                    "accent": oral_eval_accent(),
                }

        if int(code or -1) != 0:
            last_err = str(data.get("msg") or data.get("message") or f"code={code}")
            continue

        payload = data.get("data") or {}
        warrant = payload.get("warrant_id") or payload.get("warrantId")
        if not warrant:
            last_err = "授权成功但未返回 warrant_id"
            continue
        expire_at = payload.get("expire_at")
        try:
            expire_at_i = int(expire_at) if expire_at is not None else None
        except (TypeError, ValueError):
            expire_at_i = None
        return {
            "warrant_id": str(warrant),
            "expire_at": expire_at_i,
            "application_id": app_id,
            "user_id": uid,
            "sdk_url": oral_eval_sdk_url(),
            "accent": oral_eval_accent(),
        }

    raise RuntimeError(f"口语评测授权失败：{last_err}")


def _level_from_score(score: int) -> str:
    if score >= 85:
        return "优秀"
    if score >= 75:
        return "良好"
    if score >= 60:
        return "及格"
    return "需加强"


def _praise_from_score(score: int) -> str:
    if score >= 85:
        return "发音很棒，继续保持！"
    if score >= 75:
        return "整体不错，再打磨一下细节会更好。"
    if score >= 60:
        return "已经有进步，对照标红单词多练几遍。"
    return "别着急，先听清原句再慢一点跟读。"


def build_feedback_from_oral_result(payload: dict[str, Any], *, target: str) -> dict[str, Any]:
    """把引擎 JSON 归一化为与 LLM 跟读点评相近的结构。"""
    result = payload.get("result") if isinstance(payload.get("result"), dict) else payload
    if not isinstance(result, dict):
        result = {}

    try:
        overall = int(round(float(result.get("overall") or 0)))
    except (TypeError, ValueError):
        overall = 0
    overall = max(0, min(100, overall))

    try:
        accuracy = int(round(float(result.get("accuracy") or result.get("pron") or overall)))
    except (TypeError, ValueError):
        accuracy = overall

    fluency_obj = result.get("fluency") if isinstance(result.get("fluency"), dict) else {}
    try:
        fluency = int(round(float(fluency_obj.get("overall") or 0)))
    except (TypeError, ValueError):
        fluency = 0

    rhythm_obj = result.get("rhythm") if isinstance(result.get("rhythm"), dict) else {}
    try:
        rhythm = int(round(float(rhythm_obj.get("overall") or 0)))
    except (TypeError, ValueError):
        rhythm = 0

    words: list[dict[str, Any]] = []
    details = result.get("details") if isinstance(result.get("details"), list) else []
    for item in details:
        if not isinstance(item, dict):
            continue
        char = str(item.get("char") or "").strip()
        if not char:
            continue
        try:
            wscore = int(round(float(item.get("score") or 0)))
        except (TypeError, ValueError):
            wscore = 0
        words.append({"char": char, "score": max(0, min(100, wscore))})

    issues: list[str] = []
    tips: list[str] = []
    weak = [w for w in words if w["score"] < 60]
    if weak:
        shown = "、".join(f"「{w['char']}」" for w in weak[:4])
        issues.append(f"这些词发音偏弱：{shown}")
        tips.append("先单独慢读弱项单词，再整句连起来。")
    elif words and any(w["score"] < 75 for w in words):
        mid = [w for w in words if w["score"] < 75][:3]
        shown = "、".join(f"「{w['char']}」" for w in mid)
        tips.append(f"可再练：{shown}")

    speed = fluency_obj.get("speed")
    if speed == 0:
        issues.append("语速偏慢")
        tips.append("熟悉后稍微加快，保持单词完整即可。")
    elif speed == 2:
        issues.append("语速偏快")
        tips.append("放慢一点，注意词尾和连读。")

    pause = fluency_obj.get("pause")
    try:
        pause_n = int(pause or 0)
    except (TypeError, ValueError):
        pause_n = 0
    if pause_n >= 3:
        issues.append("句中停顿偏多")
        tips.append("按意群一口气读完，减少不必要停顿。")

    if not tips and overall >= 85:
        tips.append("可以挑战下一句，或用更快一点的语速再读一遍。")
    if not tips:
        tips.append("对照原句听一遍，再跟读一次。")

    audio_url = str(payload.get("audioUrl") or payload.get("audio_url") or "").strip()
    if not audio_url:
        app_id = str(payload.get("applicationId") or "").strip()
        record_id = str(payload.get("recordId") or "").strip()
        if app_id and record_id:
            audio_url = f"https://files.cloud.ssapi.cn/{app_id}/{record_id}.mp3"

    return {
        "score": overall,
        "level": _level_from_score(overall),
        "praise": _praise_from_score(overall),
        "issues": issues[:5],
        "tips": tips[:5],
        "engine": "oral",
        "accuracy": max(0, min(100, accuracy)),
        "fluency": max(0, min(100, fluency)),
        "rhythm": max(0, min(100, rhythm)),
        "words": words,
        "audio_url": audio_url,
        "target": target or "",
        "transcript": " ".join(w["char"] for w in words),
    }
