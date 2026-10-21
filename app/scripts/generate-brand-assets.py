"""
从 BrandLogo（圆底 + V）生成 App 图标与启动图，写入 Android / iOS 资源目录。
运行：python scripts/generate-brand-assets.py
"""
from __future__ import annotations

import shutil
from pathlib import Path

from PIL import Image, ImageDraw

APP_ROOT = Path(__file__).resolve().parents[1]
ASSETS = APP_ROOT / "assets"
ANDROID_RES = APP_ROOT / "android" / "app" / "src" / "main" / "res"
IOS_ASSETS = ASSETS / "ios"
IOS_ICON_SRC = IOS_ASSETS / "AppIcon.appiconset"
IOS_SPLASH_SRC = IOS_ASSETS / "start.jpg"
IOS_ICON = (
    APP_ROOT / "ios" / "App" / "App" / "Assets.xcassets" / "AppIcon.appiconset"
)
IOS_SPLASH = (
    APP_ROOT / "ios" / "App" / "App" / "Assets.xcassets" / "Splash.imageset"
)

BG = (17, 17, 17, 255)  # #111111
WHITE = (255, 255, 255, 255)
SPLASH_BG = (15, 23, 42, 255)  # #0f172a
TRANSPARENT = (0, 0, 0, 0)

# BrandLogo path in viewBox 0..32（闭合多边形顶点）
V_POINTS_32 = [
    (10.2, 9.6),
    (13.25, 9.6),
    (15.8, 17.95),
    (18.35, 9.6),
    (21.4, 9.6),
    (16.95, 23.1),
    (15.05, 23.1),
]


def scale_points(points: list[tuple[float, float]], scale: float, ox: float, oy: float):
    return [(ox + x * scale, oy + y * scale) for x, y in points]


def draw_brand_circle(
    size: int,
    *,
    circle_fill=BG,
    v_fill=WHITE,
    canvas_fill=None,
    pad_ratio: float = 0.0,
) -> Image.Image:
    img = Image.new("RGBA", (size, size), canvas_fill if canvas_fill is not None else TRANSPARENT)
    draw = ImageDraw.Draw(img)
    pad = size * pad_ratio
    mark = size - pad * 2
    cx = cy = pad + mark / 2
    r = mark / 2
    draw.ellipse((cx - r, cy - r, cx + r, cy + r), fill=circle_fill)
    pts = scale_points(V_POINTS_32, mark / 32, pad, pad)
    draw.polygon(pts, fill=v_fill)
    return img


def draw_foreground(size: int) -> Image.Image:
    """自适应前景：透明底 + 圆标，约 66% 安全区。"""
    img = Image.new("RGBA", (size, size), TRANSPARENT)
    safe = int(size * 0.66)
    offset = (size - safe) // 2
    mark = draw_brand_circle(safe, canvas_fill=TRANSPARENT)
    img.paste(mark, (offset, offset), mark)
    return img


def draw_solid(size: int, color) -> Image.Image:
    return Image.new("RGBA", (size, size), color)


def draw_splash(size: int, bg) -> Image.Image:
    img = Image.new("RGBA", (size, size), bg)
    mark_size = max(1, int(size * 0.28))
    # Splash 用白圆 + 黑 V，在深蓝底上更醒目
    mark = draw_brand_circle(mark_size, circle_fill=WHITE, v_fill=BG, canvas_fill=TRANSPARENT)
    ox = (size - mark_size) // 2
    oy = (size - mark_size) // 2
    img.paste(mark, (ox, oy), mark)
    return img


def save(img: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    img.save(path, format="PNG")
    print(f"wrote {path.relative_to(APP_ROOT)} ({img.size[0]}x{img.size[1]})")


def _clear_dir(path: Path) -> None:
    if not path.is_dir():
        return
    for child in path.iterdir():
        if child.is_dir():
            shutil.rmtree(child)
        else:
            child.unlink()


def _copy_tree_files(src: Path, dst: Path) -> None:
    dst.mkdir(parents=True, exist_ok=True)
    for child in src.iterdir():
        target = dst / child.name
        if child.is_dir():
            shutil.copytree(child, target, dirs_exist_ok=True)
        else:
            shutil.copy2(child, target)


def _flatten_ios_icon(path: Path) -> None:
    """去掉 alpha 通道：App Store 大图标不允许带 alpha/透明。

    先用图标边缘的填充色铺满整块画布，再把图标叠上去，输出不带 alpha 的 RGB PNG。
    iOS 运行时会自己套圆角遮罩，所以把透明圆角铺成同色后视觉无缝、且能通过校验。
    """
    im = Image.open(path).convert("RGBA")
    w, h = im.size
    probes = [(w // 2, 0), (w // 2, h - 1), (0, h // 2), (w - 1, h // 2)]
    counts: dict[tuple[int, int, int], int] = {}
    for x, y in probes:
        for dx in range(-2, 3):
            for dy in range(-2, 3):
                px = im.getpixel((min(max(x + dx, 0), w - 1), min(max(y + dy, 0), h - 1)))
                if px[3] > 200:
                    key = (px[0], px[1], px[2])
                    counts[key] = counts.get(key, 0) + 1
    bg = max(counts, key=counts.get) if counts else (255, 255, 255)
    base = Image.new("RGB", (w, h), bg)
    base.paste(im, (0, 0), im)
    base.save(path, format="PNG")


def _flatten_ios_icons_dir() -> None:
    for png in sorted(IOS_ICON.glob("*.png")):
        _flatten_ios_icon(png)


def _install_ios_icons() -> None:
    """优先使用 assets/ios/AppIcon.appiconset 的整套图标；否则用品牌标生成 1024 单图。"""
    if IOS_ICON_SRC.is_dir():
        _clear_dir(IOS_ICON)
        _copy_tree_files(IOS_ICON_SRC, IOS_ICON)
        print("iOS AppIcon 已替换为 assets/ios/AppIcon.appiconset 的自定义图标")
    else:
        IOS_ICON.mkdir(parents=True, exist_ok=True)
        save(draw_brand_circle(1024, canvas_fill=BG), IOS_ICON / "AppIcon-512@2x.png")
        (IOS_ICON / "Contents.json").write_text(
            '{\n  "images" : [\n    {\n      "filename" : "AppIcon-512@2x.png",\n'
            '      "idiom" : "universal",\n      "platform" : "ios",\n'
            '      "size" : "1024x1024"\n    }\n  ],\n'
            '  "info" : {\n    "author" : "xcode",\n    "version" : 1\n  }\n}\n',
            encoding="utf-8",
        )
        print("iOS AppIcon 由品牌标生成（未提供 assets/ios/AppIcon.appiconset）")
    # 统一去掉 alpha，满足 App Store「大图标不允许透明/带 alpha 通道」的要求
    _flatten_ios_icons_dir()


def _install_ios_splash() -> None:
    """把 assets/ios/start.jpg 作为 iOS 启动图写入 Splash.imageset。"""
    if not IOS_SPLASH_SRC.is_file():
        print("skip iOS splash: 未提供 assets/ios/start.jpg")
        return
    IOS_SPLASH.mkdir(parents=True, exist_ok=True)
    _clear_dir(IOS_SPLASH)
    suffix = IOS_SPLASH_SRC.suffix.lower()
    filename = f"splash{suffix}"
    shutil.copy2(IOS_SPLASH_SRC, IOS_SPLASH / filename)
    (IOS_SPLASH / "Contents.json").write_text(
        '{\n  "images" : [\n    {\n      "idiom" : "universal",\n'
        f'      "filename" : "{filename}"\n    }}\n  ],\n'
        '  "info" : {\n    "version" : 1,\n    "author" : "xcode"\n  }\n}\n',
        encoding="utf-8",
    )
    print(f"iOS 启动图已写入 Splash.imageset（{filename}）")


def main() -> None:
    ASSETS.mkdir(parents=True, exist_ok=True)

    save(draw_brand_circle(1024, canvas_fill=BG), ASSETS / "icon-only.png")
    save(draw_foreground(1024), ASSETS / "icon-foreground.png")
    save(draw_solid(1024, BG), ASSETS / "icon-background.png")
    save(draw_splash(2732, SPLASH_BG), ASSETS / "splash.png")
    save(draw_splash(2732, SPLASH_BG), ASSETS / "splash-dark.png")

    if ANDROID_RES.is_dir():
        legacy = {
            "mipmap-mdpi": 48,
            "mipmap-hdpi": 72,
            "mipmap-xhdpi": 96,
            "mipmap-xxhdpi": 144,
            "mipmap-xxxhdpi": 192,
        }
        adaptive = {
            "mipmap-mdpi": 108,
            "mipmap-hdpi": 162,
            "mipmap-xhdpi": 216,
            "mipmap-xxhdpi": 324,
            "mipmap-xxxhdpi": 432,
        }
        for folder, size in legacy.items():
            icon = draw_brand_circle(size, canvas_fill=BG)
            save(icon, ANDROID_RES / folder / "ic_launcher.png")
            save(icon, ANDROID_RES / folder / "ic_launcher_round.png")
        for folder, size in adaptive.items():
            save(draw_foreground(size), ANDROID_RES / folder / "ic_launcher_foreground.png")

        (ANDROID_RES / "values" / "ic_launcher_background.xml").write_text(
            '<?xml version="1.0" encoding="utf-8"?>\n'
            "<resources>\n"
            '    <color name="ic_launcher_background">#111111</color>\n'
            "</resources>\n",
            encoding="utf-8",
        )
        adaptive_xml = (
            '<?xml version="1.0" encoding="utf-8"?>\n'
            '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
            '    <background android:drawable="@color/ic_launcher_background"/>\n'
            '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
            "</adaptive-icon>\n"
        )
        anydpi = ANDROID_RES / "mipmap-anydpi-v26"
        anydpi.mkdir(parents=True, exist_ok=True)
        (anydpi / "ic_launcher.xml").write_text(adaptive_xml, encoding="utf-8")
        (anydpi / "ic_launcher_round.xml").write_text(adaptive_xml, encoding="utf-8")

        splash_sizes = {
            "drawable": 480,
            "drawable-port-mdpi": 320,
            "drawable-port-hdpi": 480,
            "drawable-port-xhdpi": 720,
            "drawable-port-xxhdpi": 960,
            "drawable-port-xxxhdpi": 1280,
            "drawable-land-mdpi": 320,
            "drawable-land-hdpi": 480,
            "drawable-land-xhdpi": 720,
            "drawable-land-xxhdpi": 960,
            "drawable-land-xxxhdpi": 1280,
        }
        for folder, size in splash_sizes.items():
            save(draw_splash(size, SPLASH_BG), ANDROID_RES / folder / "splash.png")
        print("Android icons + splash updated")
    else:
        print("skip Android: res dir not found")

    if IOS_ICON.is_dir():
        _install_ios_icons()
        _install_ios_splash()
    else:
        print("skip iOS: AppIcon.appiconset not found (ok if Android-only)")

    print("done")


if __name__ == "__main__":
    main()
