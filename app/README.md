# Vloglish App（Capacitor）

原生壳工程。业务 UI 来自 `../frontend` 的 App 构建产物。

- **AppId**: `cc.vloglish.app`
- **API**: 见 `../frontend/.env.app`（当前 `https://en.yunankexun.com`）

## 常用命令

```bash
cd app
npm install              # 首次或依赖变更后必须执行
npm run assets:generate  # 从 BrandLogo 生成图标/启动图（需本机 Python + pillow）
npm run sync             # 构建 frontend → www（含旧 WebView CSS 降级）→ cap sync
npm run build:apk        # 同步并打 release APK（正式分发，需先配置签名）
powershell -ExecutionPolicy Bypass -File scripts/build-release.ps1  # 一键签名+打包+校验（见下）
npm run add:android      # 首次添加 Android 工程
npm run open:android     # 用 Android Studio 打开
```

### 旧 Android WebView 样式兼容

`npm run sync` / `build:app-assets` 会在 Vite 打包后运行
`frontend/scripts/compatWebViewCss.mjs`，把 Tailwind v4 产物中的
`oklch` / `@layer` / `@property` / `color-mix` 降级，避免部分国产机
系统 WebView 过旧导致「整页没样式」。

图标源文件在 `assets/`：把新图标（建议 1024×1024 正方形、不透明）保存为
`assets/icon-source.png`，运行 `npm run assets:generate` 即会自动生成 Android
`mipmap-*`（含自适应前景/圆形图标）、iOS `assets/ios/AppIcon.appiconset` 与启动图，
详见 `scripts/generate-brand-assets.py`。若没有 `icon-source.*`，则回退用 BrandLogo(V) 生成。

Release APK 输出：

- `android/app/build/outputs/apk/release/app-release.apk`（已签名）
- `android/app/build/outputs/apk/release/app-release-unsigned.apk`（未配置签名时）
- 打包后复制到 `dist/vloglish-release.apk`

正式签名：复制 `android/keystore.properties.example` 为 `android/keystore.properties` 并配置；
密码推荐用环境变量 `VLOG_ANDROID_STORE_PASSWORD` / `VLOG_ANDROID_KEY_PASSWORD` 注入（避免明文入库）。详见仓库根目录 `APP_DEBUG_BUILD.md`。

### 一键签名 + 打包 + 校验（PowerShell）

`scripts/build-release.ps1` 把「签名配置 + 打包 + 签名校验」串成一条命令：

```powershell
cd app

# 首次：生成密钥库并写 keystore.properties（会提示输入密码），然后继续出包
.\scripts\build-release.ps1 -Init

# 日常：密码走环境变量，避免每次输入
$env:VLOG_ANDROID_STORE_PASSWORD = "***"
$env:VLOG_ANDROID_KEY_PASSWORD = "***"
.\scripts\build-release.ps1

# 同时升版本号
.\scripts\build-release.ps1 -VersionCode 13 -VersionName "1.2.0"
```

脚本会：校验 keystore → 调用 `npm run build:apk`（构建前端资源 + cap sync + assembleRelease）
→ 确认产物是已签名 APK → 用 `apksigner` 校验签名 → 计算 SHA256 并输出 `dist/vloglish-release.apk`。

可选参数：`-Init`（初始化签名）、`-InitOnly`（只初始化不打包）、`-StorePassword`/`-KeyPassword`、
`-VersionCode`/`-VersionName`、`-SkipVerify`、`-OpenOutput`。

真机安装：打开手机「允许未知来源」，把 APK 拷到手机安装即可（侧载仍会有系统“未知来源”提示，属正常）。

iOS 工程需在 macOS 上执行 `npm run add:ios`。

> 打包需要 **带 jlink 的 JDK 21**（推荐 [Temurin 21](https://adoptium.net/)）。
> `npm run build:apk` 会自动探测；会跳过：无 jlink 的 IDE 精简 JBR、以及过新的 JDK 25（Gradle 8.11 不支持）。
