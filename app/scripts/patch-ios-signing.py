#!/usr/bin/env python3
"""把签名相关 build settings 写入 App.xcodeproj 的【项目级】build configuration。

为什么不直接用命令行传？
    xcodebuild 命令行传入的 build setting 会作用到 workspace 中的所有 target，
    包括 Pods.xcodeproj 里的 Capacitor / Pods-App 等，于是会报：

        error: Capacitor does not support provisioning profiles.

    项目级（project-level）配置只对本项目内的 target 生效，不影响 Pods。

用法:
    python3 patch_ios_signing.py <project.pbxproj> <profile_name> <identity> <team_id>
"""

import re
import sys


def block_start(text, obj_id):
    """返回对象声明块的起始位置，兼容 "ID /* 注释 */ = {" 和 "/* ID */ = {" 两种写法。"""
    for pattern in (r'^[ \t]*' + re.escape(obj_id) + r'[ \t]*/\*.*?\*/[ \t]*=[ \t]*\{',
                    r'^[ \t]*/\*[ \t]*' + re.escape(obj_id) + r'[ \t]*\*/[ \t]*=[ \t]*\{'):
        m = re.search(pattern, text, re.M)
        if m:
            return m.start()
    return -1


def find_project_config_list(text):
    """找到根 project 对象引用的 buildConfigurationList ID。"""
    m = re.search(r'rootObject = ([0-9A-Fa-f]+)\s*/\* Project object \*/;', text)
    if not m:
        raise SystemExit('找不到 rootObject')

    idx = block_start(text, m.group(1))
    if idx == -1:
        raise SystemExit('找不到 PBXProject 块')

    m2 = re.search(r'buildConfigurationList = ([0-9A-Fa-f]+)\s*(?:/\*.*?\*/\s*)?;',
                   text[idx:idx + 8000], re.S)
    if not m2:
        raise SystemExit('找不到项目的 buildConfigurationList')
    return m2.group(1)


def find_config_ids(text, list_id):
    """列出该 configuration list 下的所有 XCBuildConfiguration ID。"""
    idx = block_start(text, list_id)
    if idx == -1:
        raise SystemExit('找不到 XCConfigurationList: %s' % list_id)

    m = re.search(r'buildConfigurations = \((.*?)\);', text[idx:idx + 8000], re.S)
    if not m:
        raise SystemExit('找不到 buildConfigurations 列表')
    return re.findall(r'([0-9A-Fa-f]{8,})\s*/\*', m.group(1))


def strip_setting(text, key):
    """删除已有的同名设置，避免重复键。"""
    return re.sub(r'\n[ \t]*' + re.escape(key) + r' = [^;]*;', '', text)


def inject(text, config_id, settings):
    """把设置插入到指定 configuration 的 buildSettings 末尾。"""
    idx = block_start(text, config_id)
    if idx == -1:
        return text

    bs = text.find('buildSettings = {', idx)
    if bs == -1:
        return text

    end = text.find('};', bs)
    if end == -1:
        return text

    lines = ['\t\t\t\t%s = %s;' % (k, v) for k, v in settings]
    return text[:end] + '\n' + '\n'.join(lines) + '\n\t\t\t' + text[end:]


def main():
    if len(sys.argv) != 5:
        raise SystemExit(__doc__)

    path, profile, identity, team = sys.argv[1:5]

    with open(path, 'r', encoding='utf-8') as f:
        text = f.read()

    config_ids = find_config_ids(text, find_project_config_list(text))
    if not config_ids:
        raise SystemExit('项目级 configuration 列表为空')

    settings = [
        ('CODE_SIGN_STYLE', 'Manual'),
        ('CODE_SIGN_IDENTITY', '"%s"' % identity),
        ('PROVISIONING_PROFILE_SPECIFIER', '"%s"' % profile),
        ('DEVELOPMENT_TEAM', team),
    ]
    for key, _ in settings:
        text = strip_setting(text, key)
    for config_id in config_ids:
        text = inject(text, config_id, settings)

    with open(path, 'w', encoding='utf-8') as f:
        f.write(text)

    print('已写入项目级签名设置 -> %s (configurations: %s)' % (profile, ', '.join(config_ids)))


if __name__ == '__main__':
    main()