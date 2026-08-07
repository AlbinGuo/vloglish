# Vloglish App（Capacitor）

原生壳工程。业务 UI 来自 `../frontend` 的 App 构建产物。

- **AppId**: `cc.vloglish.app`
- **API**: 见 `../frontend/.env.app`（当前 `https://en.yunankexun.com`）

## 常用命令

```bash
cd app
npm install
npm run assets:generate   # 从 BrandLogo 生成图标/启动图（需本机 Python + pillow）
npm run sync              # 构建 frontend → www → cap sync
npm run build:apk         # 同步并打 debug APK（真机测试）
npm run add:android       # 首次添加 Android 工程
npm run open:android      # 用 Android Studio 打开
```

图标源文件在 `assets/`（`icon-only.png` 等），由 `scripts/generate-brand-assets.py` 写入 Android `mipmap-*` / splash。

Debug APK 输出：

- `android/app/build/outputs/apk/debug/app-debug.apk`
- 同步后也可从 `dist/vloglish-debug.apk` 取（若执行了复制）

真机安装：打开手机「允许未知来源」，把 APK 拷到手机安装即可。

iOS 工程需在 macOS 上执行 `npm run add:ios`。

> 打包需要 JDK 21。已在 `android/gradle.properties` 指向本机 Android Studio JBR。
