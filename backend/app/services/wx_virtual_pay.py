"""个人主体小程序虚拟支付：签名、下单、查单、发货。"""

from __future__ import annotations

import hashlib
import hmac
import json
import logging
import os
import secrets
import time
import urllib.error
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET
from datetime import datetime, timedelta

from fastapi import HTTPException
from sqlalchemy.orm import Session

from ..demo_access import user_is_member
from ..models import MembershipOrder, PcPaySession, User

logger = logging.getLogger(__name__)

PLAN_QUARTER = "quarter"
PLAN_YEAR = "year"
PLAN_FOREVER = "forever"

PLANS: dict[str, dict] = {
    PLAN_QUARTER: {
        "name": "季度会员",
        "days": 90,
        "price_cent": 2900,
        "product_env": "WECHAT_XPAY_PRODUCT_QUARTER",
        "product_default": "member_quarter",
    },
    PLAN_YEAR: {
        "name": "年度会员",
        "days": 365,
        "price_cent": 5900,
        "product_env": "WECHAT_XPAY_PRODUCT_YEAR",
        "product_default": "member_year",
    },
    PLAN_FOREVER: {
        "name": "永久会员",
        "days": None,
        "price_cent": 9900,
        "product_env": "WECHAT_XPAY_PRODUCT_FOREVER",
        "product_default": "member_forever",
    },
}

# query_order.status：2 已支付待发货，3 发货中，4 已发货
PAID_STATUSES = {2, 3, 4}

_token_cache: dict[str, object] = {"token": "", "exp": 0.0}


def offer_id() -> str:
    return (os.getenv("WECHAT_XPAY_OFFER_ID") or os.getenv("WECHAT_MINI_OFFER_ID") or "").strip()


def app_key() -> str:
    return (os.getenv("WECHAT_XPAY_APP_KEY") or os.getenv("WECHAT_MINI_APP_KEY") or "").strip()


def app_id() -> str:
    return (os.getenv("WECHAT_MINI_APPID") or os.getenv("WECHAT_APPID") or "").strip()


def app_secret() -> str:
    return (os.getenv("WECHAT_MINI_SECRET") or os.getenv("WECHAT_SECRET") or "").strip()


def xpay_configured() -> bool:
    return bool(offer_id() and app_key() and app_id() and app_secret())


def product_id_for(plan: str) -> str:
    meta = PLANS[plan]
    return (os.getenv(meta["product_env"]) or meta["product_default"]).strip()


def compact_json(payload: dict) -> str:
    return json.dumps(payload, ensure_ascii=False, separators=(",", ":"))


def calc_pay_sig(uri: str, post_body: str) -> str:
    key = app_key()
    msg = f"{uri}&{post_body}"
    return hmac.new(key.encode("utf-8"), msg.encode("utf-8"), hashlib.sha256).hexdigest()


def calc_user_sig(post_body: str, session_key: str) -> str:
    return hmac.new(session_key.encode("utf-8"), post_body.encode("utf-8"), hashlib.sha256).hexdigest()


def new_out_trade_no() -> str:
    stamp = datetime.utcnow().strftime("%Y%m%d%H%M%S")
    return f"T{stamp}{secrets.token_hex(4).upper()}"


def grant_membership(user: User, plan: str) -> None:
    now = datetime.utcnow()
    user.is_member = True
    if user.member_activated_at is None:
        user.member_activated_at = now
    meta = PLANS[plan]
    days = meta["days"]
    if days is None:
        user.member_until = None
        return
    base = now
    if user.member_until and user.member_until > now:
        base = user.member_until
    user.member_until = base + timedelta(days=int(days))


def deliver_order(db: Session, order: MembershipOrder, *, wx_order_id: str = "", raw: str = "") -> None:
    if order.wx_order_id and wx_order_id and order.wx_order_id == wx_order_id and order.status == "paid":
        return
    if order.status == "paid":
        if wx_order_id and not order.wx_order_id:
            order.wx_order_id = wx_order_id[:64]
            db.commit()
        return
    if wx_order_id:
        dup = (
            db.query(MembershipOrder)
            .filter(MembershipOrder.wx_order_id == wx_order_id[:64], MembershipOrder.id != order.id)
            .first()
        )
        if dup and dup.status == "paid":
            order.status = "paid"
            order.paid_at = dup.paid_at
            order.wx_order_id = wx_order_id[:64]
            db.commit()
            return

    user = db.query(User).filter(User.id == order.user_id).first() if order.user_id else None
    if user:
        grant_membership(user, order.plan or PLAN_FOREVER)
    order.status = "paid"
    order.paid_at = datetime.utcnow()
    if wx_order_id:
        order.wx_order_id = wx_order_id[:64]
    if raw:
        order.notify_raw = raw[:8000]
    if order.order_no:
        db.query(PcPaySession).filter(
            PcPaySession.order_no == order.order_no,
            PcPaySession.status != "paid",
        ).update(
            {
                PcPaySession.status: "paid",
                PcPaySession.paid_at: datetime.utcnow(),
            },
            synchronize_session=False,
        )
    db.commit()


def _access_token() -> str:
    now = time.time()
    if _token_cache["token"] and float(_token_cache["exp"] or 0) > now:
        return str(_token_cache["token"])
    qs = urllib.parse.urlencode(
        {"grant_type": "client_credential", "appid": app_id(), "secret": app_secret()}
    )
    url = f"https://api.weixin.qq.com/cgi-bin/token?{qs}"
    with urllib.request.urlopen(url, timeout=15) as resp:
        body = json.loads(resp.read().decode("utf-8"))
    token = (body.get("access_token") or "").strip()
    if not token:
        raise RuntimeError(body.get("errmsg") or "无法获取微信 access_token")
    _token_cache["token"] = token
    _token_cache["exp"] = now + max(60, int(body.get("expires_in") or 7200) - 200)
    return token


def _xpay_post(path: str, payload: dict) -> dict:
    body = compact_json(payload)
    sig = calc_pay_sig(path, body)
    token = _access_token()
    url = f"https://api.weixin.qq.com{path}?access_token={urllib.parse.quote(token)}&pay_sig={sig}"
    req = urllib.request.Request(
        url,
        data=body.encode("utf-8"),
        method="POST",
        headers={"Content-Type": "application/json"},
    )
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        raw = exc.read().decode("utf-8", errors="replace")
        logger.warning("xpay %s http %s %s", path, exc.code, raw)
        try:
            return json.loads(raw)
        except json.JSONDecodeError:
            raise RuntimeError(f"微信接口失败 ({exc.code})") from exc


def query_wx_order(*, openid: str, out_trade_no: str) -> dict:
    return _xpay_post(
        "/xpay/query_order",
        {"openid": openid, "env": 0, "order_id": out_trade_no},
    )


def notify_provide_goods(*, openid: str, wx_order_id: str) -> None:
    if not wx_order_id:
        return
    try:
        _xpay_post(
            "/xpay/notify_provide_goods",
            {"openid": openid, "env": 0, "wx_order_id": wx_order_id},
        )
    except Exception:
        logger.exception("notify_provide_goods failed wx_order_id=%s", wx_order_id)


def create_pay_order(
    db: Session, *, user: User, plan: str, login_code: str, pc_token: str = ""
) -> dict:
    if not xpay_configured():
        raise HTTPException(status_code=503, detail="未配置虚拟支付（OfferID / AppKey）")
    if plan not in PLANS:
        raise HTTPException(status_code=400, detail="无效套餐")
    if user_is_member(user) and user.member_until is None:
        raise HTTPException(status_code=400, detail="你已是永久会员，无需重复购买")

    from . import wechat_mini as wechat_mini_svc

    try:
        session = wechat_mini_svc.code_to_session(login_code)
    except RuntimeError as exc:
        raise HTTPException(status_code=401, detail=str(exc)) from exc

    openid = session["openid"]
    if user.wx_openid and user.wx_openid != openid:
        raise HTTPException(status_code=403, detail="微信账号与当前登录不一致")
    if not user.wx_openid:
        user.wx_openid = openid
    session_key = (session.get("session_key") or "").strip()
    if not session_key:
        raise HTTPException(status_code=401, detail="未拿到微信 session，请重试")
    user.wx_session_key = session_key

    meta = PLANS[plan]
    product_id = product_id_for(plan)
    if not product_id:
        raise HTTPException(status_code=503, detail="未配置该套餐的道具 ID")

    order_no = new_out_trade_no()
    while db.query(MembershipOrder.id).filter(MembershipOrder.order_no == order_no).first():
        order_no = new_out_trade_no()

    attach = compact_json({"uid": user.id, "plan": plan})
    order = MembershipOrder(
        order_no=order_no,
        user_id=user.id,
        email=(user.email or "").strip().lower() or f"wx_{openid}@weixin.vloglish.invalid",
        amount_cent=int(meta["price_cent"]),
        currency="CNY",
        status="pending",
        channel="wx_virtual",
        plan=plan,
        product_id=product_id,
    )
    db.add(order)
    db.commit()
    db.refresh(order)

    token = (pc_token or "").strip()
    if token:
        sess = db.query(PcPaySession).filter(PcPaySession.token == token).first()
        if not sess or sess.user_id != user.id:
            raise HTTPException(status_code=400, detail="支付会话无效")
        if sess.expires_at <= datetime.utcnow() and sess.status != "paid":
            raise HTTPException(status_code=400, detail="支付码已过期，请在网页刷新")
        if sess.plan != plan:
            raise HTTPException(status_code=400, detail="套餐与网页选择不一致")
        sess.order_no = order_no
        db.commit()

    sign_obj = {
        "offerId": offer_id(),
        "buyQuantity": 1,
        "env": 0,
        "currencyType": "CNY",
        "productId": product_id,
        "goodsPrice": int(meta["price_cent"]),
        "outTradeNo": order_no,
        "attach": attach,
    }
    sign_data = compact_json(sign_obj)
    return {
        "out_trade_no": order_no,
        "plan": plan,
        "plan_name": meta["name"],
        "amount_cent": int(meta["price_cent"]),
        "mode": "short_series_goods",
        "sign_data": sign_data,
        "pay_sig": calc_pay_sig("requestVirtualPayment", sign_data),
        "signature": calc_user_sig(sign_data, session_key),
    }


def sync_order_from_wechat(db: Session, order: MembershipOrder) -> MembershipOrder:
    user = db.query(User).filter(User.id == order.user_id).first() if order.user_id else None
    openid = (user.wx_openid if user else "") or ""
    if not openid:
        raise HTTPException(status_code=400, detail="订单没有绑定微信")
    result = query_wx_order(openid=openid, out_trade_no=order.order_no)
    err = result.get("errcode")
    if err:
        raise HTTPException(status_code=502, detail=result.get("errmsg") or f"查单失败 ({err})")
    info = result.get("order") or result
    status = int(info.get("status") or 0)
    wx_order_id = str(info.get("wx_order_id") or "")
    if status in PAID_STATUSES:
        deliver_order(db, order, wx_order_id=wx_order_id, raw=compact_json(result))
        if status == 2:
            notify_provide_goods(openid=openid, wx_order_id=wx_order_id)
        db.refresh(order)
    return order


def _iter_xml_text(root: ET.Element) -> dict[str, str]:
    out: dict[str, str] = {}
    for node in root.iter():
        name = node.tag.split("}")[-1]
        if node.text and node.text.strip():
            out[name] = node.text.strip()
    return out


def parse_deliver_payload(raw: str, content_type: str = "") -> dict:
    text = (raw or "").strip()
    if not text:
        return {}
    if "json" in (content_type or "") or text[:1] in "{[":
        data = json.loads(text)
        if isinstance(data, dict) and isinstance(data.get("event"), dict):
            data = {**data, **data["event"]}
        return data
    root = ET.fromstring(text)
    return _iter_xml_text(root)


def handle_deliver_notify(db: Session, raw: str, content_type: str = "") -> str:
    try:
        data = parse_deliver_payload(raw, content_type)
    except Exception:
        logger.exception("wx deliver parse fail")
        return _xml_ack(1, "parse error")

    event = str(data.get("Event") or data.get("event") or "")
    if event and event != "xpay_goods_deliver_notify":
        return _xml_ack(0, "ignored")

    out_trade_no = str(data.get("OutTradeNo") or data.get("outTradeNo") or data.get("out_trade_no") or "")
    wx_order_id = str(
        data.get("MchOrderNo")
        or data.get("wx_order_id")
        or data.get("WxOrderId")
        or ""
    )
    wechat_pay = data.get("WeChatPayInfo") or data.get("weChatPayInfo") or {}
    if isinstance(wechat_pay, dict) and not wx_order_id:
        wx_order_id = str(wechat_pay.get("MchOrderNo") or wechat_pay.get("mchOrderNo") or "")

    if wx_order_id:
        existed = db.query(MembershipOrder).filter(MembershipOrder.wx_order_id == wx_order_id[:64]).first()
        if existed and existed.status == "paid":
            return _xml_ack(0, "success")

    order = None
    if out_trade_no:
        order = db.query(MembershipOrder).filter(MembershipOrder.order_no == out_trade_no).first()
    if order is None and wx_order_id:
        order = db.query(MembershipOrder).filter(MembershipOrder.wx_order_id == wx_order_id[:64]).first()
    if order is None:
        logger.warning("wx deliver unknown order out=%s wx=%s", out_trade_no, wx_order_id)
        return _xml_ack(1, "order not found")

    deliver_order(db, order, wx_order_id=wx_order_id, raw=raw)
    return _xml_ack(0, "success")


def _xml_ack(code: int, msg: str) -> str:
    return f"<xml><ErrCode>{code}</ErrCode><ErrMsg><![CDATA[{msg}]]></ErrMsg></xml>"
