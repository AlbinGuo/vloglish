#!/usr/bin/env python3
"""写入 APNs 推送所需 entitlement：aps-environment。

会**合并**进已存在的 App/App.entitlements（保留 Sign in with Apple 等其它能力），
默认 production（对应分发/Ad Hoc/TestFlight/App Store 描述文件）；
可用环境变量 APS_ENVIRONMENT=development 覆盖（用于开发包 / sandbox 网关）。

配合 patch-ios-project-settings 的 CODE_SIGN_ENTITLEMENTS=App/App.entitlements 生效。

⚠️ 还需在 Apple Developer 后台：
    1) Identifiers → App ID(cc.vloglish.app) → 勾选 Push Notifications 保存；
    2) 重新生成分发描述文件（让描述文件包含 Push 能力），更新 PROVISIONING_PROFILE_BASE64；
    否则签名会因 entitlement 与描述文件不一致而失败。

用法: python3 add-push-notifications.py <project_dir>   # 传 app/ios/App
"""
import os
import plistlib
import sys


def main() -> None:
    if len(sys.argv) < 2:
        raise SystemExit(__doc__)
    project_dir = sys.argv[1]
    ent_abs = os.path.join(project_dir, "App", "App.entitlements")
    os.makedirs(os.path.dirname(ent_abs), exist_ok=True)

    data: dict = {}
    if os.path.exists(ent_abs):
        try:
            with open(ent_abs, "rb") as f:
                data = plistlib.load(f) or {}
        except Exception:
            data = {}

    env = (os.getenv("APS_ENVIRONMENT") or "production").strip() or "production"
    data["aps-environment"] = env
    with open(ent_abs, "wb") as f:
        plistlib.dump(data, f)
    print(f"已写入 aps-environment={env} entitlements:", ent_abs)


if __name__ == "__main__":
    main()
