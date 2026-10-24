#!/usr/bin/env python3
"""为「收听模式」开启 iOS 后台播放。

做两件事（都做了「找不到就跳过、不报错」的防御，避免不同模板导致 CI 失败）：
  1) Info.plist 增加 UIBackgroundModes = ['audio']（缺失则补，已有则并入）。
  2) AppDelegate.swift 启动时把 AVAudioSession 设为 playback。
     否则 WKWebView 里的音频在锁屏/切后台会被系统静音。

用法: python3 add-background-audio.py <project_dir>   # 传 app/ios/App
"""
import os
import plistlib
import re
import sys

MARK = "// vloglish: background audio session"


def ensure_plist(project_dir):
    info_abs = os.path.join(project_dir, "App", "Info.plist")
    if not os.path.exists(info_abs):
        print("跳过：未找到 Info.plist ->", info_abs)
        return
    with open(info_abs, "rb") as f:
        data = plistlib.load(f)

    modes = data.get("UIBackgroundModes")
    if not isinstance(modes, list):
        modes = []

    if "audio" not in modes:
        modes.append("audio")
        data["UIBackgroundModes"] = modes
        with open(info_abs, "wb") as f:
            plistlib.dump(data, f)
        print("已写入 UIBackgroundModes=audio ->", info_abs)
    else:
        print("Info.plist 已包含 audio 后台模式，跳过")


def patch_appdelegate(project_dir):
    path = os.path.join(project_dir, "App", "AppDelegate.swift")
    if not os.path.exists(path):
        print("跳过：未找到 AppDelegate.swift ->", path)
        return

    with open(path, "r", encoding="utf-8") as f:
        src = f.read()

    if MARK in src:
        print("AppDelegate 已注入后台音频设置，跳过")
        return

    if "import AVFoundation" not in src:
        imports = list(re.finditer(r"^import\s+\w+\s*$", src, re.M))
        if imports:
            idx = imports[-1].end()
            src = src[:idx] + "\nimport AVFoundation" + src[idx:]
        else:
            src = "import AVFoundation\n" + src

    inject = (
        "\n    %s\n"
        "    do {\n"
        "      let session = AVAudioSession.sharedInstance()\n"
        "      try session.setCategory(.playback, mode: .spokenAudio, options: [])\n"
        "      try session.setActive(true)\n"
        "    } catch {\n"
        "      print(\"audio session setup failed: \\(error)\")\n"
        "    }\n" % MARK
    )

    m = re.search(
        r"func\s+application\([^)]*didFinishLaunchingWithOptions[^)]*\)[^{]*\{", src
    )
    if not m:
        print("警告：未找到 didFinishLaunchingWithOptions，仅补了 import，请手动确认")
        with open(path, "w", encoding="utf-8") as f:
            f.write(src)
        return

    ret = src.find("return true", m.end())
    if ret == -1:
        print("警告：didFinishLaunching 内未找到 return true，跳过注入")
        with open(path, "w", encoding="utf-8") as f:
            f.write(src)
        return

    src = src[:ret] + inject + "    " + src[ret:]
    with open(path, "w", encoding="utf-8") as f:
        f.write(src)
    print("已注入 AVAudioSession playback ->", path)


def main():
    if len(sys.argv) < 2:
        raise SystemExit(__doc__)
    project_dir = sys.argv[1]
    ensure_plist(project_dir)
    patch_appdelegate(project_dir)


if __name__ == "__main__":
    main()
