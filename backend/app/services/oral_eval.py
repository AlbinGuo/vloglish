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

CORE_WORD = "en.word.score"
CORE_SENT = "en.sent.score"
CORE_PASSAGE = "en.pred.score"


def _clean_env(value: str | None) -> str:
    """去掉首尾空白与成对引号，避免 .env 误写导致签名失败。"""
    text = (value or "").strip()
    if len(text) >= 2 and text[0] == text[-1] and text[0] in {'"', "'"}:
        text = text[1:-1].strip()
    return text


def oral_eval_configured() -> bool:
    app_id = _clean_env(os.getenv("ORAL_EVAL_APP_ID"))
    secret = _clean_env(os.getenv("ORAL_EVAL_APP_SECRET"))
    if not app_id or not secret:
        return False
    flag = (os.getenv("ORAL_EVAL_ENABLED") or "true").strip().lower()
    return flag in ("1", "true", "yes", "on")


def oral_eval_app_id() -> str:
    return _clean_env(os.getenv("ORAL_EVAL_APP_ID"))


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


def _normalize_client_ip(raw: str | None) -> str:
    ip = (raw or "").strip()
    # X-Forwarded-For 已在上游取首个；此处再去掉端口 / IPv6 括号
    if ip.startswith("[") and "]" in ip:
        ip = ip[1 : ip.index("]")]
    if ip.count(":") == 1 and "." in ip:
        # 形如 1.2.3.4:12345
        ip = ip.split(":", 1)[0]
    # 本地调试时用公网占位，避免部分网关对 127.0.0.1 / ::1 校验异常
    if ip in {"", "127.0.0.1", "::1", "localhost"}:
        ip = "8.8.8.8"
    return ip[:64] or "8.8.8.8"


def request_warrant(*, user_id: str, user_client_ip: str) -> dict[str, Any]:
    if not oral_eval_configured():
        raise RuntimeError("口语评测未配置（缺少 ORAL_EVAL_APP_ID / ORAL_EVAL_APP_SECRET）")

    app_id = oral_eval_app_id()
    app_secret = _clean_env(os.getenv("ORAL_EVAL_APP_SECRET"))
    timestamp = str(int(time.time()))
    ip = _normalize_client_ip(user_client_ip)
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
        # 注意：code=0 表示成功，不能用 `code or -1`（0 在 Python 里是 falsy）
        if code is None and data.get("success") is True:
            payload = data.get("data") or {}
            warrant = payload.get("warrantId") or payload.get("warrant_id") or payload.get("AccessWarrantId")
            expire = payload.get("expireTime") or payload.get("expire_at") or payload.get("ExpireTime")
            if warrant:
                try:
                    expire_at_i = int(expire) if expire is not None else None
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

        try:
            code_i = int(code) if code is not None else -1
        except (TypeError, ValueError):
            code_i = -1
        if code_i != 0:
            last_err = str(data.get("msg") or data.get("message") or f"code={code}")
            # 签名错误时给出可操作提示（常见于 AppSecret 配错/多空格）
            if code_i == 430008 or "request_sign" in last_err.lower():
                raise RuntimeError(
                    "口语评测密钥校验失败：请到智能科教控制台核对并更新 "
                    "ORAL_EVAL_APP_ID / ORAL_EVAL_APP_SECRET 后重启后端"
                )
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

    if "request_sign" in last_err.lower():
        raise RuntimeError(
            "口语评测密钥校验失败：请到智能科教控制台核对并更新 "
            "ORAL_EVAL_APP_ID / ORAL_EVAL_APP_SECRET 后重启后端"
        )
    raise RuntimeError(f"口语评测授权失败：{last_err}")


# 口语录音云端域名（attachAudioUrl 返回的地址，可能是 http / 带端口）
ORAL_AUDIO_HOST_SUFFIXES = (
    "cloud.ssapi.cn",
    "ssapi.cn",
)


def is_allowed_oral_audio_url(url: str) -> bool:
    from urllib.parse import urlparse

    try:
        parsed = urlparse((url or "").strip())
    except Exception:
        return False
    if parsed.scheme not in ("http", "https"):
        return False
    host = (parsed.hostname or "").lower()
    if not host:
        return False
    return any(host == suf or host.endswith("." + suf) for suf in ORAL_AUDIO_HOST_SUFFIXES)


def _extract_audio_url(payload: dict[str, Any]) -> str:
    """从评测回包中取出可播放的 audioUrl（勿自行拼错误 .mp3 路径）。"""
    candidates: list[Any] = [
        payload.get("audioUrl"),
        payload.get("audio_url"),
    ]
    result = payload.get("result")
    if isinstance(result, dict):
        candidates.extend([result.get("audioUrl"), result.get("audio_url")])
    for raw in candidates:
        url = str(raw or "").strip()
        if url.startswith("http://") or url.startswith("https://"):
            return url
    return ""


def fetch_oral_audio_bytes(url: str) -> tuple[bytes, str]:
    """服务端拉取口语云端录音，供前端在 HTTPS 下安全回放。"""
    cleaned = (url or "").strip()
    if not is_allowed_oral_audio_url(cleaned):
        raise ValueError("录音地址不在允许范围内")

    req = urllib.request.Request(
        cleaned,
        headers={"User-Agent": "vloglish-oral-audio/1.0", "Accept": "*/*"},
        method="GET",
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            data = resp.read()
            ctype = (resp.headers.get("Content-Type") or "").split(";")[0].strip()
    except urllib.error.HTTPError as exc:
        raise RuntimeError(f"录音下载失败 ({exc.code})") from exc
    except Exception as exc:
        raise RuntimeError(f"录音下载失败：{exc}") from exc

    if not data:
        raise RuntimeError("录音文件为空")
    if not ctype or ctype == "application/octet-stream":
        # 文档示例多为 ogg/无扩展名；浏览器可按字节嗅探，缺省给 ogg
        lower = cleaned.lower()
        if lower.endswith(".mp3"):
            ctype = "audio/mpeg"
        elif lower.endswith(".wav"):
            ctype = "audio/wav"
        else:
            ctype = "audio/ogg"
    return data, ctype


def _level_from_score(score: int) -> str:
    if score >= 85:
        return "优秀"
    if score >= 75:
        return "良好"
    if score >= 60:
        return "及格"
    return "需加强"


def _praise_from_score(score: int, *, mode: str) -> str:
    if mode == "word":
        if score >= 85:
            return "这个词读得很准，记牢了！"
        if score >= 75:
            return "不错，再听一遍示范音微调一下。"
        if score >= 60:
            return "接近了，对着音标慢慢读两遍。"
        return "先听示范音，再跟着慢读。"
    if mode == "passage":
        if score >= 85:
            return "篇章朗读很流畅，继续保持！"
        if score >= 75:
            return "整体不错，标红处再练几遍会更稳。"
        if score >= 60:
            return "已经读下来了，注意完整度和停顿。"
        return "可以先分段练，再连起来读整段。"
    if score >= 85:
        return "发音很棒，继续保持！"
    if score >= 75:
        return "整体不错，再打磨一下细节会更好。"
    if score >= 60:
        return "已经有进步，对照标红单词多练几遍。"
    return "别着急，先听清原句再慢一点跟读。"


def _as_int(value: Any, default: int = 0) -> int:
    try:
        return int(round(float(value)))
    except (TypeError, ValueError):
        return default


def _extract_words(result: dict[str, Any]) -> list[dict[str, Any]]:
    words: list[dict[str, Any]] = []
    details = result.get("details") if isinstance(result.get("details"), list) else []
    for item in details:
        if not isinstance(item, dict):
            continue
        # 篇章：details 是句子，词在 snt_details
        snt = item.get("snt_details")
        if isinstance(snt, list):
            for w in snt:
                if not isinstance(w, dict):
                    continue
                char = str(w.get("char") or "").strip()
                if not char:
                    continue
                words.append({"char": char, "score": max(0, min(100, _as_int(w.get("score"))))})
            continue
        char = str(item.get("char") or "").strip()
        if not char:
            continue
        words.append({"char": char, "score": max(0, min(100, _as_int(item.get("score"))))})
    return words


def build_feedback_from_oral_result(
    payload: dict[str, Any],
    *,
    target: str,
    core_type: str = CORE_SENT,
) -> dict[str, Any]:
    """把引擎 JSON 归一化为统一点评结构（单词 / 句子 / 篇章）。"""
    result = payload.get("result") if isinstance(payload.get("result"), dict) else payload
    if not isinstance(result, dict):
        result = {}

    mode = "sentence"
    if core_type == CORE_WORD:
        mode = "word"
    elif core_type == CORE_PASSAGE:
        mode = "passage"

    overall = max(0, min(100, _as_int(result.get("overall"))))
    accuracy = max(0, min(100, _as_int(result.get("accuracy") or result.get("pron") or overall)))

    fluency_raw = result.get("fluency")
    if isinstance(fluency_raw, dict):
        fluency = max(0, min(100, _as_int(fluency_raw.get("overall"))))
        speed = fluency_raw.get("speed")
        pause_n = _as_int(fluency_raw.get("pause"))
    else:
        fluency = max(0, min(100, _as_int(fluency_raw)))
        speed = None
        pause_n = 0

    rhythm_obj = result.get("rhythm") if isinstance(result.get("rhythm"), dict) else {}
    rhythm = max(0, min(100, _as_int(rhythm_obj.get("overall"))))
    integrity = max(0, min(100, _as_int(result.get("integrity"))))

    words = _extract_words(result)

    issues: list[str] = []
    tips: list[str] = []
    weak = [w for w in words if w["score"] < 60]
    if weak:
        shown = "、".join(f"「{w['char']}」" for w in weak[:4])
        issues.append(f"这些词发音偏弱：{shown}")
        tips.append("先单独慢读弱项单词，再连起来。" if mode != "word" else "听示范音后，再慢读两遍这个词。")
    elif words and any(w["score"] < 75 for w in words):
        mid = [w for w in words if w["score"] < 75][:3]
        shown = "、".join(f"「{w['char']}」" for w in mid)
        tips.append(f"可再练：{shown}")

    if speed == 0:
        issues.append("语速偏慢")
        tips.append("熟悉后稍微加快，保持单词完整即可。")
    elif speed == 2:
        issues.append("语速偏快")
        tips.append("放慢一点，注意词尾和连读。")

    if pause_n >= 3:
        issues.append("停顿偏多")
        tips.append("按意群一口气读完，减少不必要停顿。")

    if mode == "passage" and integrity and integrity < 70:
        issues.append("完整度偏低，可能有漏读")
        tips.append("对照文本读完整段，漏读的句子单独补练。")

    if not tips and overall >= 85:
        tips.append("可以挑战下一题，或用更快语速再读一遍。")
    if not tips:
        tips.append("对照示范再跟读一次。")

    audio_url = _extract_audio_url(payload)

    out: dict[str, Any] = {
        "score": overall,
        "level": _level_from_score(overall),
        "praise": _praise_from_score(overall, mode=mode),
        "issues": issues[:5],
        "tips": tips[:5],
        "engine": "oral",
        "core_type": core_type,
        "mode": mode,
        "accuracy": accuracy,
        "fluency": fluency,
        "rhythm": rhythm,
        "integrity": integrity if mode == "passage" else None,
        "words": words,
        "audio_url": audio_url,
        "target": target or "",
        "transcript": " ".join(w["char"] for w in words) if words else "",
    }
    return out
