# iOS 打包（GitHub Actions）

把 `app/`（Capacitor 壳）在 macOS runner 上打成可安装的 `.ipa`，推送到 `master` 自动出包。

> 背景：iOS 只能在 macOS 上编译（`xcodebuild`），Windows 本地打不了。
> 这里用 GitHub Actions 的 macOS runner 完成构建 + 签名 + 导出。
> **签名走 App Store Connect API Key + 自动签名**，无需 p12 / 描述文件，Windows 用户全程不用 Mac。

---

## 一、前置条件

1. **付费 Apple 开发者账号**（$99/年）——否则无法生成能装到真机的正式 ipa。
2. 仓库托管在 GitHub（当前另有 Gitee 远端 `gitee`，见文末）。
3. 在 App Store Connect 建一个 **API Key**（见下）。

---

## 二、创建 App Store Connect API Key

1. 登录 [App Store Connect](https://appstoreconnect.apple.com) → **Users and Access** → **Integrations**（集成）标签 → **App Store Connect API**。
2. 点 **+** 新建 Key：
   - Name：任意，如 `vloglish-ci`
   - Access（角色）：**App Manager** 或 **Admin**（需要能管理证书/描述文件）
3. 创建后**一次性下载** `.p8`（AuthKey_XXXXXXXXXX.p8，只能下一次）。
4. 记下页面上的：
   - **Key ID**（10 位，如 `ABCD123456`）
   - **Issuer ID**（UUID 形式）
5. Team ID 在 [developer.apple.com](https://developer.apple.com) → **Membership** 里看（10 位）。

> API Key 的 `.p8` 属于敏感材料，**切勿提交到仓库**。

---

## 三、需要在 GitHub 仓库配置的 Secrets / Variables

设置路径：`仓库 → Settings → Secrets and variables → Actions`，**用 Repository secrets / variables**（workflow 未声明 environment）。

### Secrets（加密）

| 名称 | 说明 |
|------|------|
| `ASC_API_KEY_ID` | API Key 的 Key ID |
| `ASC_API_ISSUER_ID` | API Key 的 Issuer ID |
| `ASC_API_KEY_BASE64` | `.p8` 文件的 base64 编码（见第四节） |
| `APPLE_TEAM_ID` | 10 位 Team ID |

### Variables（明文，可选）

| 名称 | 默认 | 可选值 |
|------|------|--------|
| `EXPORT_METHOD` | `ad-hoc` | `development` / `ad-hoc` / `app-store-connect` |

**导出方式怎么选：**

- `development` —— 装到**已登记**设备，开发用。
- `ad-hoc` —— 装到**已登记**设备（最多 100 台）。**推荐日常内测。**
- `app-store-connect` —— 用于 TestFlight / 上架。

> `ad-hoc` / `development` 需要目标设备 UDID 已登记到开发者账号；`app-store-connect` 不需要。

---

## 四、生成 `.p8` 的 base64（Windows / PowerShell）

在 `.p8` 所在目录执行：

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("$PWD\AuthKey_ABCD123456.p8")) | Set-Clipboard
```

结果是一整行，直接粘到 `ASC_API_KEY_BASE64`。

> macOS 等价命令：`base64 -i AuthKey_ABCD123456.p8 | pbcopy`
> **别用** `certutil -encode`（会产生带换行和头尾标记的文本，Secret 会解析失败）。

---

## 五、触发与产物

- **push** 到 `master`（改动涉及 `frontend/**`、`app/**` 或本 workflow）
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
→ 写入 ASC API Key
→ xcodebuild archive（自动签名，-allowProvisioningUpdates）
→ 导出 .ipa
→ 上传工件
```

---

## 六、建议：把 ios/ 工程提交进仓库

当前 `app/ios/` 尚未生成，workflow 会在 CI 里首次用 `npx cap add ios` 生成。
**更推荐**找机会生成一次并提交（`.gitignore` 已忽略 `Pods/`、`DerivedData/`、`public/` 等生成物）：

```bash
cd app
npm install
npx cap add ios      # 生成 app/ios
npm run sync
git add ios
git commit -m "chore(app): 提交 Capacitor iOS 工程"
```

好处：构建更快、版本可控。

---

## 七、本地 Mac 打包（可选，非 CI）

```bash
cd app
npm install
npm run add:ios        # 首次
npm run sync
npx @capacitor/cli open ios   # Xcode 里选 Team 自动签名，Product → Archive → Distribute
```

---

## 八、Gitee → GitHub 同步

当前 `origin` 为 `git@github.com:AlbinGuo/vloglish.git`（SSH over 443），原 Gitee 远端为 `gitee`。
若要让 GitHub Actions 持续生效，可：

1. Gitee 仓库 → 管理 → 仓库镜像管理 → 配推到 GitHub。
2. 或本地双推：`git push origin master && git push gitee master`。

---

## 九、常见问题

- **`Authorization failed`/`No profiles found`**：API Key 角色权限不足（需 App Manager/Admin），或 App ID `cc.vloglish.app` 未注册（自动签名通常会自动创建）。
- **`-allowProvisioningUpdates` 无效**：确认 `.p8` 解码正确、Key ID / Issuer ID 无空格。
- **ad-hoc 装不上设备**：设备 UDID 未登记，或 `EXPORT_METHOD` 与证书类型不匹配。
- **导出报 `method` 无效**：Xcode 版本差异，旧 Xcode 上 `app-store-connect` 应写 `app-store`。
