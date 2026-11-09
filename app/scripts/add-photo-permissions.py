#!/usr/bin/env python3
"""为「用户上传自定义头像」写入 iOS 相册/相机权限说明。

<input type="file" accept="image/*"> 在 WKWebView 中会调用系统照片选择器/相机，
缺少 Info.plist 说明时 iOS 会拒绝访问甚至崩溃：
    - NSPhotoLibraryUsageDescription（照片图库，选择头像必需）
    - NSCameraUsageDescription（拍照设为头像，使用相机时需要）

用法: python3 add-photo-permissions.py <project_dir>   # 传 app/ios/App
"""
import os
import plistlib
import sys

KEYS = {
    "NSPhotoLibraryUsageDescription": "用于从相册选择照片作为你的头像。",
    "NSCameraUsageDescription": "用于拍照并设置为你的头像。",
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
        print("已写入相册/相机权限说明:", info_abs)
    else:
        print("Info.plist 已包含相册/相机权限说明，跳过")


if __name__ == "__main__":
    main()
