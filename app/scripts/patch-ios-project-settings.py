#!/usr/bin/env python3
"""把指定的 build settings 注入到 App.xcodeproj 的【项目级】build configuration。

为什么不用命令行传？
    xcodebuild 命令行传入的 build setting 优先级最高，会作用到 workspace 中的所有
    target，包括 Pods.xcodeproj 里的 Capacitor / Pods-App / CapacitorSplashScreen 等，
    于是会报：

        error: Capacitor does not support provisioning profiles.

    项目级（project-level）配置只对本项目内的 target 生效，不会影响 Pods。

用法:
    python3 patch_ios_project_settings.py <project.pbxproj> KEY=VALUE [KEY=VALUE ...]

示例（手动签名）:
    python3 patch_ios_project_settings.py ios/App/App.xcodeproj/project.pbxproj \
        CODE_SIGN_STYLE=Manual \
        "CODE_SIGN_IDENTITY=Apple Distribution: Someone (TEAMID)" \
        PROVISIONING_PROFILE_SPECIFIER="My AdHoc Profile" \
        DEVELOPMENT_TEAM=ABCDE12345

示例（自动签名 + 版本号）:
    python3 patch_ios_project_settings.py ios/App/App.xcodeproj/project.pbxproj \
        CODE_SIGN_STYLE=Automatic \
        DEVELOPMENT_TEAM=ABCDE12345 \
        MARKETING_VERSION=1.2.0 \
        CURRENT_PROJECT_VERSION=42

值里含空格时会自动加引号，无需调用方自己处理。
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


def quote_value(value):
    """含空格的值自动加引号。"""
    if value and ' ' in value and not (value.startswith('"') and value.endswith('"')):
        return '"%s"' % value
    return value


def main():
    if len(sys.argv) < 3:
        raise SystemExit(__doc__)

    path = sys.argv[1]
    to_set = []
    to_clear = []
    for item in sys.argv[2:]:
        if '=' not in item:
            raise SystemExit('参数格式应为 KEY=VALUE，收到: %s' % item)
        key, value = item.split('=', 1)
        key = key.strip()
        if not re.match(r'^[A-Za-z_][A-Za-z0-9_]*$', key):
            raise SystemExit('非法的 setting 名称: %s' % key)
        value = value.strip()
        if value == '':
            # KEY=  表示彻底移除该设置（例如从手动签名切到自动签名时清掉描述文件）
            to_clear.append(key)
        else:
            to_set.append((key, quote_value(value)))

    with open(path, 'r', encoding='utf-8') as f:
        text = f.read()

    config_ids = find_config_ids(text, find_project_config_list(text))
    if not config_ids:
        raise SystemExit('项目级 configuration 列表为空')

    for key in to_clear + [k for k, _ in to_set]:
        text = strip_setting(text, key)
    for config_id in config_ids:
        text = inject(text, config_id, to_set)

    with open(path, 'w', encoding='utf-8') as f:
        f.write(text)

    print('已写入项目级设置 -> %s (configurations: %s)'
          % (', '.join('%s=%s' % kv for kv in to_set) or '无',
             ', '.join(config_ids)))
    if to_clear:
        print('已移除设置 -> %s' % ', '.join(to_clear))


if __name__ == '__main__':
    main()