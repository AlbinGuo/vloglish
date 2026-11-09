"""推送配置自检 / 端到端测试。

在 backend 目录执行（推荐在容器内：docker compose -f docker-compose.prod.yml exec backend python scripts/verify_push.py）：

    python scripts/verify_push.py                 # 仅校验配置与凭据是否可用
    python scripts/verify_push.py --ios <deviceToken>          # 真发一条 APNs 测试（默认 production）
    python scripts/verify_push.py --ios <deviceToken> --apns-env sandbox
    python scripts/verify_push.py --android <fcmToken>         # 真发一条 FCM 测试

不会打印任何密钥内容；FCM 通过“能否换取 OAuth token”、APNs 通过“能否用 .p8 生成 JWT”来判定凭据是否有效。
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

# 允许以 `python scripts/verify_push.py` 直接运行（把 backend 目录加入 import path）
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from app.env import load_app_env  # noqa: E402

load_app_env()

from app.services import push  # noqa: E402


def _parse() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="推送配置自检 / 端到端测试")
    parser.add_argument("--ios", metavar="DEVICE_TOKEN", default="", help="APNs 设备 token（真发测试）")
    parser.add_argument(
        "--apns-env",
        choices=["production", "sandbox"],
        default="production",
        help="APNs 网关（Release/TestFlight 用 production，Debug 用 sandbox）",
    )
    parser.add_argument("--android", metavar="FCM_TOKEN", default="", help="FCM 设备 token（真发测试）")
    return parser.parse_args()


def main() -> int:
    args = _parse()
    status = push.push_status()
    print("[verify] 配置状态:", status)

    ok = True
    if not status["httpx"]:
        print("[verify] [FAIL] httpx 未安装：pip install 'httpx[http2]'")
        ok = False
    if not status["h2"]:
        print("[verify] [WARN] h2 缺失：APNs 必需（httpx[http2]）")

    if status["fcm_configured"]:
        token = push._fcm_access_token()
        if token:
            print("[verify] [OK] FCM 服务账号有效（已换取 OAuth access token）")
        else:
            print("[verify] [FAIL] FCM 无效：无法换取 access token（检查服务账号 JSON / 私钥 / 网络 / 是否启用 FCM API）")
            ok = False
    else:
        print("[verify] [WARN] FCM 未配置（跳过）")

    if status["apns_configured"]:
        if push._apns_jwt():
            print("[verify] [OK] APNs 私钥可解析（JWT 生成成功）")
        else:
            print("[verify] [FAIL] APNs 无效：JWT 生成失败（检查 .p8 / APNS_KEY_ID / APNS_TEAM_ID）")
            ok = False
        if not status["apns_topic_set"]:
            print("[verify] [FAIL] APNS_TOPIC 未设置（应为 cc.vloglish.app）")
            ok = False
    else:
        print("[verify] [WARN] APNs 未配置（跳过）")

    if args.ios:
        res = push._send_apns(
            args.ios, "Vloglish 测试", "iOS 推送测试", {"type": "verify"}, args.apns_env
        )
        print(f"[verify] APNs 真发结果: {res}（env={args.apns_env}）")
        ok = ok and res == "ok"
    if args.android:
        res = push._send_fcm(
            args.android, "Vloglish 测试", "Android 推送测试", {"type": "verify"}
        )
        print(f"[verify] FCM 真发结果: {res}")
        ok = ok and res == "ok"

    print("[verify] 结论:", "全部通过" if ok else "存在问题（见上）")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
