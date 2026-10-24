#!/usr/bin/env python3
"""为「App 内跟读 / 单词打分」写入 iOS 语音识别权限说明。

原生语音识别插件 @capacitor-community/speech-recognition 需要 Info.plist 里有：
    - NSMicrophoneUsageDescription（麦克风）
    - NSSpeechRecognitionUsageDescription（语音识别）
缺少时 iOS 上申请麦克风/识别权限会直接失败，跟读与打分不可用。

用法: python3 add-speech-permissions.py <project_dir>   # 传 app/ios/App
"""
import os
import plistlib
import sys

KEYS = {
    "NSMicrophoneUsageDescription": "用于录制你的发音，进行跟读与发音打分。",
    "NSSpeechRecognitionUsageDescription": "用于将你的朗读识别为文字，进行跟读点评。",
}


def main():
    if len(sys.argv) < 2:
        raise SystemExit(__doc__)
    info_abs = os.path.join(sys.argv[1], "App", "Info.plist")
    if not os.path.exists(info_abs):
        raise SystemExit(f"未找到 Info.plist: {info_abs}")
    with open(info_abs, "rb") as f:
        data = plistlib.load(f)

    changed = False
    for key, value in KEYS.items():
        if key not in data:
            data[key] = value
            changed = True

    if changed:
        with open(info_abs, "wb") as f:
            plistlib.dump(data, f)
        print("已写入语音识别权限说明:", info_abs)
    else:
        print("Info.plist 已包含语音识别权限说明，跳过")


if __name__ == "__main__":
    main()
