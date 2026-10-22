#!/usr/bin/env python3
"""为 iOS AppDelegate 注入 APNs 注册回调转发。

@capacitor/push-notifications 插件依赖 AppDelegate 把
didRegisterForRemoteNotificationsWithDeviceToken / didFailToRegisterForRemoteNotificationsWithError
转发为 NotificationCenter 通知（.capacitorDidRegisterForRemoteNotifications 等）。
默认工程模板可能没有这两个方法，导致 JS 端 register() 后既拿不到 token 也不报错。
本脚本幂等地补上它们。

用法: python3 add-push-appdelegate.py <ios/App 目录 或 AppDelegate.swift 路径>
"""
import os
import re
import sys

MARK = "capacitorDidRegisterForRemoteNotifications"

EXTENSION = '''
// Push: forward APNs registration callbacks to Capacitor PushNotifications plugin
extension AppDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NotificationCenter.default.post(name: .capacitorDidRegisterForRemoteNotifications, object: deviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NotificationCenter.default.post(name: .capacitorDidFailToRegisterForRemoteNotifications, object: error)
    }
}
'''

REG_SIG = r"func application\([^)]*didRegisterForRemoteNotificationsWithDeviceToken[^)]*\)\s*\{"
FAIL_SIG = r"func application\([^)]*didFailToRegisterForRemoteNotificationsWithError[^)]*\)\s*\{"


def resolve_path(arg):
    if os.path.isdir(arg):
        return os.path.join(arg, "App", "AppDelegate.swift")
    return arg


def main():
    if len(sys.argv) < 2:
        raise SystemExit(__doc__)
    path = resolve_path(sys.argv[1])
    if not os.path.exists(path):
        raise SystemExit("AppDelegate.swift not found: %s" % path)
    with open(path, "r", encoding="utf-8") as f:
        src = f.read()

    if MARK in src:
        print("AppDelegate already forwards push callbacks, skip:", path)
        return

    has_reg = re.search(REG_SIG, src) is not None
    has_fail = re.search(FAIL_SIG, src) is not None

    if has_reg or has_fail:
        if has_reg:
            src = re.sub(
                REG_SIG,
                lambda m: m.group(0) + "\n        NotificationCenter.default.post(name: .capacitorDidRegisterForRemoteNotifications, object: deviceToken)",
                src,
                count=1,
            )
        if has_fail:
            src = re.sub(
                FAIL_SIG,
                lambda m: m.group(0) + "\n        NotificationCenter.default.post(name: .capacitorDidFailToRegisterForRemoteNotifications, object: error)",
                src,
                count=1,
            )
        with open(path, "w", encoding="utf-8") as f:
            f.write(src)
        print("Injected NotificationCenter forwarding into existing AppDelegate methods:", path)
    else:
        with open(path, "a", encoding="utf-8") as f:
            f.write(EXTENSION)
        print("Appended AppDelegate push extension:", path)


if __name__ == "__main__":
    main()