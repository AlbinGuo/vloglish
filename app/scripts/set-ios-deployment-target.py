#!/usr/bin/env python3
"""把 iOS 工程的最低系统版本（IPHONEOS_DEPLOYMENT_TARGET）统一改成指定版本。

为什么要单独处理？
    Capacitor 生成的 App.xcodeproj 在【项目级】和【App target 级】都写了
    IPHONEOS_DEPLOYMENT_TARGET = 14.0。target 级优先级更高，只改项目级不生效，
    所以这里对 pbxproj 里所有出现处做替换；顺带同步 Podfile 的 platform 行。

用法:
    python3 set-ios-deployment-target.py <project.pbxproj> 15.0
"""
import os
import re
import sys


def main():
    if len(sys.argv) < 3:
        raise SystemExit(__doc__)
    path, version = sys.argv[1], sys.argv[2]

    with open(path, 'r', encoding='utf-8') as f:
        text = f.read()
    new, n = re.subn(
        r'IPHONEOS_DEPLOYMENT_TARGET = [0-9.]+;',
        'IPHONEOS_DEPLOYMENT_TARGET = %s;' % version,
        text,
    )
    with open(path, 'w', encoding='utf-8') as f:
        f.write(new)
    print('已设置 IPHONEOS_DEPLOYMENT_TARGET=%s（pbxproj %d 处）' % (version, n))

    # 同步 Podfile 的 platform :ios, 'x'（若存在）
    # pbxproj: .../App/App.xcodeproj/project.pbxproj -> Podfile 在 .../App/Podfile
    app_dir = os.path.dirname(os.path.dirname(path))  # 去掉 project.pbxproj 和 App.xcodeproj
    podfile = os.path.join(app_dir, 'Podfile')
    if os.path.isfile(podfile):
        with open(podfile, 'r', encoding='utf-8') as f:
            pf = f.read()
        pf_new, m = re.subn(r"platform :ios, '[0-9.]+'", "platform :ios, '%s'" % version, pf)
        if m:
            with open(podfile, 'w', encoding='utf-8') as f:
                f.write(pf_new)
            print('已设置 Podfile platform :ios, \'%s\'（%d 处）' % (version, m))


if __name__ == '__main__':
    main()
