#!/usr/bin/env python3
"""写入 Sign in with Apple 所需的 entitlements 文件。

配合 patch-ios-project-settings.py 设置
    CODE_SIGN_ENTITLEMENTS=App/App.entitlements
即可让 App target 带上 com.apple.developer.applesignin 能力。

⚠️ 还需在 Apple Developer 后台：
    1) Identifiers → 选 App ID(cc.vloglish.app) → 勾选 “Sign In with Apple” 保存；
    2) 重新生成 App Store 描述文件（让描述文件包含该能力），更新 Secret；
    否则签名时会报 entitlement 与描述文件不匹配。

用法: python3 add-signin-with-apple.py <project_dir>   # 传 app/ios/App
"""
import os
import plistlib
import sys

ENTITLEMENTS = {"com.apple.developer.applesignin": ["Default"]}


def main():
    if len(sys.argv) < 2:
        raise SystemExit(__doc__)
    project_dir = sys.argv[1]
    ent_abs = os.path.join(project_dir, "App", "App.entitlements")
    os.makedirs(os.path.dirname(ent_abs), exist_ok=True)
    with open(ent_abs, "wb") as f:
        plistlib.dump(ENTITLEMENTS, f)
    print("已写入 Sign in with Apple entitlements:", ent_abs)


if __name__ == "__main__":
    main()
