# Vloglish App 调试打包指南（Android APK）

本文说明如何把当前 Capacitor App 打成可在真机安装的 **debug APK**，用于内部测试。

## 目录结构

```text
frontend/     # Web 业务 UI（App 构建产物来自这里）
app/          # Capacitor 原生壳（Android / iOS）
  android/    # Android 工程
  www/        # frontend App 构建输出（自动生成）
  dist/       # 便捷复制的 APK（自动生成，不入库）
```

- **AppId**: `cc.vloglish.app`
- **API 域名**: 见 `frontend/.env.app`（当前为 `https://en.yunankexun.com`）

## 环境要求

| 依赖 | 说明 |
|------|------|
| Node.js + npm | 构建 frontend / 运行 Capacitor |
| Android Studio | 含 Android SDK、模拟器（可选） |
| JDK 21 | Capacitor 7 需要；推荐用 Android Studio 自带 JBR |

本仓库已在 `app/android/gradle.properties` 中配置：

```properties
org.gradle.java.home=D:\\softs\\install\\Android Studio\\jbr
```

若你本机 Android Studio 安装路径不同，请改成自己的 `jbr` 目录。

首次若 Gradle 发行版下载超时，可将 `gradle-8.11.1-all.zip` 放到：

```text
%USERPROFILE%\.gradle\wrapper\dists\gradle-8.11.1-all\<hash>\gradle-8.11.1-all.zip
```

（`<hash>` 以本机已生成的目录名为准；放好后删掉同目录下的 `.lck` / `.part`。）

## 一键打包（推荐）

```bash
cd app
npm install          # 首次需要
npm run build:apk
```

该命令会依次：

1. 用 `frontend` 的 App 模式构建静态资源 → `app/www`
2. `npx cap sync` 同步到 Android 工程
3. `gradlew assembleRelease` 打 **release APK**
4. 复制到 `app/dist/vloglish-release.apk`（已签名优先；未配置签名时复制未签名包并告警）

> 为什么默认出 release：debug 包用调试证书签名、`debuggable=true`，安装时会被系统/Play 保护机制提示“存在风险”。正式发布请务必用 release 签名。

## 正式签名（Release）

只需配置一次：

```bash
# 1) 生成发布密钥库（妥善备份 .jks，丢失将无法给老用户升级）
cd app/android
keytool -genkeypair -v -keystore vloglish-release.jks ^
  -keyalg RSA -keysize 2048 -validity 10000 -alias vloglish

# 2) 复制签名配置样例并填写
copy keystore.properties.example keystore.properties
```

`keystore.properties`（已 gitignore，不入库）：
```properties
storeFile=vloglish-release.jks
keyAlias=vloglish
# 密码推荐用环境变量注入，避免明文入库：
#   set VLOG_ANDROID_STORE_PASSWORD=你的密钥库密码
#   set VLOG_ANDROID_KEY_PASSWORD=你的密钥密码
```

配置好后 `npm run build:apk` 会自动产出已签名的 `app-release.apk`。

## 分步打包

```bash
# 1) 构建并同步
cd app
npm run sync

# 2) 打 release APK
cd android
gradlew.bat assembleRelease
```

> 自测若想临时出 debug 包：`gradlew.bat assembleDebug`（仅内部使用，勿对外分发）。

## APK 输出位置

| 路径 | 说明 |
|------|------|
| `app/android/app/build/outputs/apk/release/app-release.apk` | 已签名 release 产物 |
| `app/android/app/build/outputs/apk/release/app-release-unsigned.apk` | 未配置签名时的产物（不可直接分发） |
| `app/dist/vloglish-release.apk` | `npm run build:apk` 复制后的便捷路径 |

## 真机安装

1. 把 `vloglish-release.apk`（或 `app-release.apk`）拷到手机（微信 / QQ / 数据线均可）
2. 手机开启「允许安装未知应用」（或针对该文件管理器/浏览器开启）
3. 点击 APK 安装
4. 打开 **Vloglish** 登录测试

> 即使 release 签名，从网页/聊天工具侧载安装，Android 仍会提示“未知来源/可能有害”（系统安全机制，无法完全去除）。点「仍要安装/继续」即可；要彻底消除提示需上架应用商店（Google Play / 国内商店）。
> 注意：从旧的 debug 包换成 release 包时 **签名不同无法覆盖安装，需先卸载旧包**。

## 用 Android Studio 运行（可选）

```bash
cd app
npm run sync
npm run open:android
```

在 Android Studio 中：

1. 等待 Gradle Sync 完成
2. 选择模拟器或已连接真机
3. Run 配置选 `app`，点击 Run

真机需开启 **USB 调试**；若 Run 按钮灰色，通常是未选中设备或 Sync 未完成。

## 改代码后如何更新包

业务页面改在 `frontend/`，原生壳改在 `app/`。更新 APK：

```bash
cd app
npm run build:apk
```

再把新的 APK 装到手机（覆盖安装即可；若失败可先卸载旧包再装）。

## 常见问题

### 1. 登录失败 / 连不上接口

检查 `frontend/.env.app`：

```env
VITE_APP_TARGET=mobile
VITE_API_BASE_URL=https://en.yunankexun.com
```

改完后必须重新 `npm run build:apk`（或至少 `npm run sync` 后再打包）。

### 2. 图片不显示 / 视频播不了

App WebView 是 `https` 页面，接口若返回 `http://` 媒体地址会被混合内容拦截。当前前端已在 App 构建中把媒体链升级为 `https`。若仍失败，确认已用最新代码重新 `build:apk`。

### 3. 构建报错：无效的源发行版 21

当前 shell 的 `JAVA_HOME` 仍是 JDK 17。确认 `app/android/gradle.properties` 里 `org.gradle.java.home` 指向 Android Studio 的 **JDK 21 JBR**。

### 4. `npm run open:android` 只打印 Opening...

属正常现象，它只是唤起 Android Studio；若未自动打开，可手动打开工程目录：

`app/android`

## 相关文件

- `frontend/.env.app` — App API 域名与构建开关
- `app/capacitor.config.ts` — AppId / webDir 等
- `app/android/gradle.properties` — JDK 21 路径
- `app/README.md` — App 目录简要说明
