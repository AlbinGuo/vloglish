"""微信小程序登录：code 换 openid。"""

from __future__ import annotations

import json
import os
import urllib.error
import urllib.parse
import urllib.request


def wechat_mini_configured() -> bool:
    return bool(_app_id() and _secret())


def _app_id() -> str:
    return (os.getenv("WECHAT_MINI_APPID") or os.getenv("WECHAT_APPID") or "").strip()


def _secret() -> str:
    return (os.getenv("WECHAT_MINI_SECRET") or os.getenv("WECHAT_SECRET") or "").strip()


def code_to_session(js_code: str) -> dict:
    """返回 {openid, session_key?, unionid?}。"""
    if not wechat_mini_configured():
        raise RuntimeError("未配置 WECHAT_MINI_APPID / WECHAT_MINI_SECRET")
    code = (js_code or "").strip()
    if not code:
        raise RuntimeError("缺少微信登录 code")
    qs = urllib.parse.urlencode(
        {
            "appid": _app_id(),
            "secret": _secret(),
            "js_code": code,
            "grant_type": "authorization_code",
        }
    )
    url = f"https://api.weixin.qq.com/sns/jscode2session?{qs}"
    try:
        with urllib.request.urlopen(url, timeout=15) as resp:
            body = json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        raise RuntimeError(f"微信登录接口失败 ({exc.code})") from exc
    except OSError as exc:
        raise RuntimeError("无法连接微信登录接口") from exc

    err = body.get("errcode")
    if err:
        raise RuntimeError(body.get("errmsg") or f"微信登录失败 ({err})")
    openid = (body.get("openid") or "").strip()
    if not openid:
        raise RuntimeError("微信未返回 openid")
    return {
        "openid": openid,
        "session_key": (body.get("session_key") or "").strip(),
        "unionid": (body.get("unionid") or "").strip(),
    }
