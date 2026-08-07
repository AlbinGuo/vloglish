"""
从 BrandLogo（圆底 + V）生成 App 图标与启动图，写入 Android / iOS 资源目录。
运行：python scripts/generate-brand-assets.py
"""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw

APP_ROOT = Path(__file__).resolve().parents[1]
ASSETS = APP_ROOT / "assets"
ANDROID_RES = APP_ROOT / "android" / "app" / "src" / "main" / "res"
IOS_ICON = (
    APP_ROOT / "ios" / "App" / "App" / "Assets.xcassets" / "AppIcon.appiconset"
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
        ios_icons = [
            ("AppIcon-20x20@2x.png", 40),
            ("AppIcon-20x20@3x.png", 60),
            ("AppIcon-29x29@2x.png", 58),
            ("AppIcon-29x29@3x.png", 87),
            ("AppIcon-40x40@2x.png", 80),
            ("AppIcon-40x40@3x.png", 120),
            ("AppIcon-60x60@2x.png", 120),
            ("AppIcon-60x60@3x.png", 180),
            ("AppIcon-1024x1024.png", 1024),
        ]
        for name, size in ios_icons:
            save(draw_brand_circle(size, canvas_fill=BG), IOS_ICON / name)
        print("iOS AppIcon updated")
    else:
        print("skip iOS: AppIcon.appiconset not found (ok if Android-only)")

    print("done")


if __name__ == "__main__":
    main()
