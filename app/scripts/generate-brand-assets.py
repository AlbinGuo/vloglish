"""
从 BrandLogo（圆底 + V）生成 App 图标与启动图，写入 Android / iOS 资源目录。
运行：python scripts/generate-brand-assets.py
"""
from __future__ import annotations

import json
import shutil
from pathlib import Path

from PIL import Image, ImageDraw

APP_ROOT = Path(__file__).resolve().parents[1]
ASSETS = APP_ROOT / "assets"
ANDROID_RES = APP_ROOT / "android" / "app" / "src" / "main" / "res"
IOS_ASSETS = ASSETS / "ios"
IOS_ICON_SRC = IOS_ASSETS / "AppIcon.appiconset"
IOS_ICON = (
    APP_ROOT / "ios" / "App" / "App" / "Assets.xcassets" / "AppIcon.appiconset"
)
IOS_SPLASH = (
    APP_ROOT / "ios" / "App" / "App" / "Assets.xcassets" / "Splash.imageset"
)
IOS_LAUNCH = (
    APP_ROOT / "ios" / "App" / "App" / "Base.lproj" / "LaunchScreen.storyboard"
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


# ---------------------------------------------------------------------------
# 自定义图标（app/assets/icon-source.png 等）
#
# 若 assets/ 下存在 icon-source.(png|jpg|jpeg|webp)，则优先用它作为图标母版，
# 统一生成 Android / iOS 各尺寸；否则回退到上面基于 BrandLogo(V) 的绘制。
# 换图标只需替换这张母版（建议 1024×1024 正方形、不带透明）。
# ---------------------------------------------------------------------------
CUSTOM_ICON_NAMES = ("icon-source.png", "icon-source.jpg", "icon-source.jpeg", "icon-source.webp")


def load_custom_icon() -> Image.Image | None:
    for name in CUSTOM_ICON_NAMES:
        path = ASSETS / name
        if not path.is_file():
            continue
        try:
            im = Image.open(path).convert("RGBA")
        except OSError:
            continue
        w, h = im.size
        side = min(w, h)
        left = (w - side) // 2
        top = (h - side) // 2
        im = im.crop((left, top, left + side, top + side))
        return im.resize((1024, 1024), Image.LANCZOS)
    return None


def icon_square(icon: Image.Image, size: int) -> Image.Image:
    return icon.resize((size, size), Image.LANCZOS)


def icon_round(icon: Image.Image, size: int) -> Image.Image:
    im = icon.resize((size, size), Image.LANCZOS)
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).ellipse((0, 0, size - 1, size - 1), fill=255)
    out = Image.new("RGBA", (size, size), TRANSPARENT)
    out.paste(im, (0, 0), mask)
    return out


def icon_foreground(icon: Image.Image, size: int, scale: float = 0.78) -> Image.Image:
    """自适应图标前景：把母版缩到安全区（约 0.78），四周透明，配合纯色背景层。"""
    inner = max(1, int(size * scale))
    small = icon.resize((inner, inner), Image.LANCZOS)
    canvas = Image.new("RGBA", (size, size), TRANSPARENT)
    offset = (size - inner) // 2
    canvas.paste(small, (offset, offset), small)
    return canvas


def edge_color(icon: Image.Image) -> tuple[int, int, int]:
    """取母版边缘主色，作为 Android 自适应图标的背景色。"""
    w, h = icon.size
    probes = [(3, 3), (w - 4, 3), (3, h - 4), (w - 4, h - 4), (w // 2, 3), (w // 2, h - 4)]
    colors: list[tuple[int, int, int]] = []
    for x, y in probes:
        p = icon.getpixel((x, y))
        if p[3] > 200:
            colors.append((p[0], p[1], p[2]))
    if not colors:
        return (255, 255, 255)
    return tuple(sorted(channel)[len(channel) // 2] for channel in zip(*colors))  # type: ignore[return-value]


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


def _generate_ios_appiconset_from(custom: Image.Image) -> None:
    """依据 assets/ios/AppIcon.appiconset/Contents.json 的尺寸清单，从母版生成每个尺寸。"""
    IOS_ICON_SRC.mkdir(parents=True, exist_ok=True)
    contents = IOS_ICON_SRC / "Contents.json"
    data = {}
    if contents.is_file():
        try:
            data = json.loads(contents.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError):
            data = {}
    images = data.get("images") if isinstance(data, dict) else None
    if not images:
        print("iOS AppIcon Contents.json 缺失/无 images，跳过母版生成")
        return
    for entry in images:
        if not isinstance(entry, dict):
            continue
        filename = entry.get("filename")
        size_str = str(entry.get("size") or "")
        scale_str = str(entry.get("scale") or "1x")
        if not filename or "x" not in size_str:
            continue
        try:
            base = float(size_str.split("x")[0])
            mul = float(scale_str.rstrip("x"))
        except ValueError:
            continue
        px = max(1, int(round(base * mul)))
        save(icon_square(custom, px), IOS_ICON_SRC / filename)
    print("iOS AppIcon 已由 assets/icon-source 母版生成")


def _install_ios_icons(custom: Image.Image | None = None) -> None:
    """优先使用自定义母版 assets/icon-source.* 生成整套图标；否则使用
    assets/ios/AppIcon.appiconset 的整套图标；再否则用品牌标生成 1024 单图。"""
    if custom is not None:
        _generate_ios_appiconset_from(custom)

    if IOS_ICON.is_dir():
        if IOS_ICON_SRC.is_dir():
            _clear_dir(IOS_ICON)
            _copy_tree_files(IOS_ICON_SRC, IOS_ICON)
            print("iOS AppIcon 已写入原生工程")
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
    elif custom is None:
        print("skip iOS native: AppIcon.appiconset not found (ok if Android-only)")


def _install_ios_splash() -> None:
    """生成纯色 iOS 启动图（无 logo），与应用内动画启动页首帧同色，实现无缝过渡。"""
    IOS_SPLASH.mkdir(parents=True, exist_ok=True)
    _clear_dir(IOS_SPLASH)
    width, height = 1290, 2796
    img = Image.new("RGB", (width, height), (17, 17, 17))  # #111111，与 AppSplash 背景一致
    filename = "splash.png"
    img.save(IOS_SPLASH / filename, format="PNG")
    (IOS_SPLASH / "Contents.json").write_text(
        '{\n  "images" : [\n    {\n      "idiom" : "universal",\n'
        f'      "filename" : "{filename}"\n    }}\n  ],\n'
        '  "info" : {\n    "version" : 1,\n    "author" : "xcode"\n  }\n}\n',
        encoding="utf-8",
    )
    print(f"iOS 启动图已生成纯色背景 Splash.imageset（{filename}）")


def _patch_ios_launch_screen() -> None:
    """把 iOS 启动 storyboard 的背景改成深色、启动图改为铺满。

    Capacitor 默认 LaunchScreen 的背景是 systemBackground（浅色下为白），
    启动图若用 aspect-fit，在宽高比不一致的机型上顶部会露出白边 —— 表现为
    「打开 App 时顶部闪一下」。这里统一成 #111111 并把图改为 aspect-fill。
    未匹配到对应节点时自动跳过（不破坏原文件）。
    """
    import re

    path = IOS_LAUNCH
    if not path.is_file():
        return
    try:
        xml = path.read_text(encoding="utf-8")
    except OSError:
        return

    dark_color = (
        '<color key="backgroundColor" red="0.06666666666666667" '
        'green="0.06666666666666667" blue="0.06666666666666667" alpha="1" '
        'colorSpace="custom" customColorSpace="sRGB"/>'
    )
    updated = re.sub(
        r'<color key="backgroundColor"[^>]*?/>',
        dark_color,
        xml,
    )
    updated = updated.replace('contentMode="scaleAspectFit"', 'contentMode="scaleAspectFill"')

    if updated != xml:
        path.write_text(updated, encoding="utf-8")
        print("iOS LaunchScreen.storyboard 已调整（深色背景 + 启动图铺满）")
    else:
        print("iOS LaunchScreen.storyboard 无需调整（跳过）")


def main() -> None:
    ASSETS.mkdir(parents=True, exist_ok=True)

    custom = load_custom_icon()
    if custom is not None:
        print("检测到 assets/icon-source.*，使用自定义母版生成图标")
        bg4 = (*edge_color(custom), 255)
        save(icon_square(custom, 1024), ASSETS / "icon-only.png")
        save(icon_foreground(custom, 1024), ASSETS / "icon-foreground.png")
        save(draw_solid(1024, bg4), ASSETS / "icon-background.png")
    else:
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
            if custom is not None:
                save(icon_square(custom, size), ANDROID_RES / folder / "ic_launcher.png")
                save(icon_round(custom, size), ANDROID_RES / folder / "ic_launcher_round.png")
            else:
                icon = draw_brand_circle(size, canvas_fill=BG)
                save(icon, ANDROID_RES / folder / "ic_launcher.png")
                save(icon, ANDROID_RES / folder / "ic_launcher_round.png")
        for folder, size in adaptive.items():
            fg = icon_foreground(custom, size) if custom is not None else draw_foreground(size)
            save(fg, ANDROID_RES / folder / "ic_launcher_foreground.png")

        bg_rgb = edge_color(custom) if custom is not None else BG[:3]
        bg_hex = "#%02X%02X%02X" % bg_rgb
        (ANDROID_RES / "values" / "ic_launcher_background.xml").write_text(
            '<?xml version="1.0" encoding="utf-8"?>\n'
            "<resources>\n"
            f'    <color name="ic_launcher_background">{bg_hex}</color>\n'
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

    if IOS_ICON.is_dir() or custom is not None:
        _install_ios_icons(custom)
        if IOS_ICON.is_dir():
            _install_ios_splash()
            _patch_ios_launch_screen()
    else:
        print("skip iOS: AppIcon.appiconset not found (ok if Android-only)")

    print("done")


if __name__ == "__main__":
    main()
