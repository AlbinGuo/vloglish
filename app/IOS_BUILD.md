# iOS 打包（GitHub Actions）

把 `app/`（Capacitor 壳）在 macOS runner 上打成可安装的 `.ipa`，推送到 `master` 自动出包。

> 背景：iOS 只能在 macOS 上编译（`xcodebuild`），Windows 本地打不了。
> 所以这里用 GitHub Actions 的 maccOS runner 完成构建 + 签名 + 导出。

---

## 一、前置条件

1. **付费 Apple 开发者账号**（$99/年）——否则无法生成能装到真机的正式 ipa。
2. 仓库托管在 GitHub（当前 `origin` 是 Gitee，见文末「Gitee 镜像」）。
3. 在 Apple Developer 后台完成：
   - 注册 App ID：`cc.vloglish.app`（用 Explicit App ID，勾选所需 Capabilities）
   - 生成 **证书**：Distribution（App Store / Ad Hoc 通用），导出为 `.p12`
   - 生成 **描述文件**：按你要的分发方式选 Ad Hoc / App Store / Development，得到 `.mobileprovision`
   - 记录 10 位 **Team ID**（Membership 页）

---

## 二、需要在 GitHub 仓库配置的 Secrets / Variables

设置路径：`仓库 → Settings → Secrets and variables → Actions`。

### Secrets（加密）

| 名称 | 说明 |
|------|------|
| `BUILD_CERTIFICATE_BASE64` | 证书 `.p12` 的 base64 编码 |
| `P12_PASSWORD` | 导出 `.p12` 时设置的密码 |
| `PROVISIONING_PROFILE_BASE64` | 描述文件 `.mobileprovision` 的 base64 编码 |
| `KEYCHAIN_PASSWORD` | 任意随机字符串（CI 里临时钥匙串的密码，无需记住） |
| `APPLE_TEAM_ID` | 10 位 Team ID，如 `ABCDE12345` |
| `CODE_SIGN_IDENTITY` | 可选。不填则按导出方式自动推断（见下） |

### Variables（明文，可选）

| 名称 | 默认 | 可选值 |
|------|------|--------|
| `EXPORT_METHOD` | `ad-hoc` | `development` / `ad-hoc` / `app-store-connect` |

**导出方式怎么选：**

- `development` —— 只装到**已登记**的设备，用开发证书/描述文件（调试用）。
- `ad-hoc` —— 装到**已登记**设备（最多 100 台），用分发证书 + Ad Hoc 描述文件。**推荐日常内测。**
- `app-store-connect` —— 上传 TestFlight / App Store，用分发证书 + App Store 描述文件。

> 证书类型与描述文件类型必须匹配 `EXPORT_METHOD`：
> `development` ↔ 开发证书 + Development 描述文件；
> `ad-hoc` / `app-store-connect` ↔ 分发证书 + Ad Hoc / App Store 描述文件。

---

## 三、生成 base64（在 macOS 本机执行）

```bash
# 证书 .p12（导出时设的密码填到 P12_PASSWORD）
base64 -i cert.p12 | pbcopy

# 描述文件 .mobileprovision
base64 -i profile.mobileprovision | pbcopy
# Linux / WSL 用：base64 -w0 file | xclip -selection clipboard
```

把结果粘到对应的 Secret 里即可。

---

## 四、触发与产物

- **push** 到 `master`（只要改动涉及 `frontend/**`、`app/**` 或本 workflow）
- 打 **tag**：`v*`（如 `v1.2.0`）
- 或手动：Actions → iOS Build → **Run workflow**

产物：`vloglish-ios-<sha>` 工件，内含 `App.ipa`，在 Actions 运行页下载。

流程内部做的事：

```
npm ci (frontend, app)
→ frontend 构建到 app/www
→ 无 app/ios 时 npx cap add ios
→ 生成图标/启动图（含 iOS AppIcon）
→ cap sync ios
→ pod install
→ 导入证书/描述文件
→ xcodebuild archive → 导出 .ipa
→ 上传工件
```

---

## 五、建议：把 ios/ 工程提交进仓库

当前 `app/ios/` 尚未生成，workflow 会在 CI 里首次用 `npx cap add ios` 生成。
**更推荐找一台 Mac 执行一次**，然后把 `app/ios/` 提交进库（`.gitignore` 已忽略 `Pods/`、`DerivedData/`、`public/` 等生成物）：

```bash
cd app
npm install
npx cap add ios      # 生成 app/ios
npm run sync         # 构建 web + cap sync
git add ios
git commit -m "chore(app): 提交 Capacitor iOS 工程"
```

好处：构建更快、版本可控、签名/描述文件匹配更稳定。

---

## 六、本地 Mac 打包（可选，非 CI）

```bash
cd app
npm install
npm run add:ios        # 首次
npm run sync           # 每次改动 web 后
npx @capacitor/cli open ios   # 用 Xcode 打开，配好签名后 Archive
```

Xcode 里：选中 `App` target → Signing & Capabilities → 选 Team（自动签名）→ Product → Archive → Distribute App。

---

## 七、Gitee → GitHub 镜像

当前 `origin` 是 `https://gitee.com/guonan01/vlogish.git`。要让 GitHub Actions 生效，需把代码同步到 GitHub，两种做法：

1. **Gitee 仓库镜像**：Gitee 仓库 → 管理 → 仓库镜像管理 → 添加推送到 GitHub 的镜像（需要 GitHub 的 PAT）。
2. **本地双推**：
   ```bash
   git remote add github git@github.com:<you>/vlogish.git
   git push github master
   ```

---

## 八、常见问题

- **`No signing certificate found`**：`.p12` 与描述文件类型不匹配，或 `P12_PASSWORD` 不对。
- **`No profiles for 'cc.vloglish.app' were found`**：App ID 未注册 / 描述文件里的 Bundle ID 不一致。
- **导出报 `method` 无效**：Xcode 版本差异，`app-store-connect` 在旧 Xcode 上应写 `app-store`。
- **install 到设备失败**：`ad-hoc`/`development` 需把设备 UDID 加进开发者后台并重新生成描述文件。
- **CocoaPods 慢**：可给 `pod install` 加缓存或改用 Capacitor 的 SwiftPM 模式（进阶）。
