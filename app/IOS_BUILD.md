# iOS 打包（GitHub Actions）

把 `app/`（Capacitor 壳）在 macOS runner 上打成可安装的 `.ipa`，推送到 `master` 自动出包。

> 背景：iOS 只能在 macOS 上编译（`xcodebuild`），Windows 本地打不了。
> 这里用 GitHub Actions 的 macOS runner 完成构建 + 签名 + 导出。
> **签名走手动签名**：p12 证书 + `.mobileprovision` 描述文件（Windows 上用 OpenSSL 生成，无需 Mac）。

---

## 一、前置条件

1. **付费 Apple 开发者账号**（$99/年）——否则无法生成能装到真机的正式 ipa。
2. 仓库托管在 GitHub（原 Gitee 远端为 `gitee`，见文末）。
3. 准备两样东西（见第二、三节）：
   - 证书文件 `distribution.p12`
   - 描述文件 `xxx.mobileprovision`

---

## 二、在 Windows 上生成证书（p12）

### 1) 生成私钥 + CSR

用 Git Bash（自带 OpenSSL）：

```bash
mkdir -p ~/ios-certs && cd ~/ios-certs
export MSYS_NO_PATHCONV=1     # 关键：否则 Git Bash 会把 /CN 当路径转换

openssl req -new -newkey rsa:2048 -nodes \
  -keyout ios_dist.key \
  -out ios_dist.certSigningRequest \
  -subj "/emailAddress=你的邮箱/CN=你的名字 Distribution/O=你的名字/C=CN"
```

- `ios_dist.key`：**私钥，务必妥善保管**，丢了要重签证书。
- `ios_dist.certSigningRequest`：上传给 Apple 的文件。

### 2) 在 Apple 后台创建证书

登录 [developer.apple.com](https://developer.apple.com) → **Certificates, Identifiers & Profiles** → **Certificates** → **Create a certificate**：

- 类型选 **Apple Distribution**（做 ad-hoc / 上架）
- 上传上面的 `ios_dist.certSigningRequest`
- 生成后**下载证书**，保存为 `distribution.cer` 放到 `~/ios-certs/`。

### 3) 合成 p12（Windows）

在 Git Bash 里：

```bash
cd ~/ios-certs
export MSYS_NO_PATHCONV=1
openssl x509 -inform DER -in distribution.cer -out distribution.pem

# 必须指定 3DES + SHA1：OpenSSL 3 默认生成的是 PBES2/AES-256-CBC，
# macOS 的 security import 读不了，会报 "MAC verification failed during PKCS12 import"
openssl pkcs12 -export -inkey ios_dist.key -in distribution.pem \
  -out distribution.p12 -passout pass:自定义密码 \
  -certpbe PBE-SHA1-3DES -keypbe PBE-SHA1-3DES -macalg sha1
```

> ⚠️ **踩坑提示**：不要用默认参数生成 p12。OpenSSL 3.x 默认用 PBES2/AES-256-CBC 加密，
> macOS 的 `security import` 只认老式 3DES + SHA1，会直接报 `MAC verification failed`。
> 上面命令里的 `-certpbe/-keypbe/-macalg` 三个参数不能省。
> 另外 `-legacy` 参数也不行——它会用 RC2-40，OpenSSL 自己都读不回来。

这里 `自定义密码` 就是后面 Secret `P12_PASSWORD` 的值。

---

## 三、创建描述文件（mobileprovision）

Apple Developer → **Profiles** → **Create a profile**：

- 类型按需选：**Ad Hoc**（装到已登记设备，内测推荐）/ **App Store** / **Development**
- App ID 选 **`cc.vloglish.app`**（没有就先在 **Identifiers** 里注册）
- 勾选上面创建的**证书**；Ad Hoc / Development 还要勾选**设备**
- 生成后下载，得到 `vloglish.mobileprovision`

> 注意：证书类型和描述文件类型必须匹配
> —— Distribution 证书 ↔ Ad Hoc / App Store 描述文件；Apple Development 证书 ↔ Development 描述文件。

---

## 四、生成两个文件的 base64（Windows / PowerShell）

在文件所在目录执行，结果自动进剪贴板：

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("$PWD\distribution.p12")) | Set-Clipboard
[Convert]::ToBase64String([IO.File]::ReadAllBytes("$PWD\vloglish.mobileprovision")) | Set-Clipboard
```

> 生成的是**一整行、无换行**。**别用** `certutil -encode`（会产生换行和头尾标记，Secret 会解析失败）。
> macOS 等价：`base64 -i file | pbcopy`

---

## 五、需要在 GitHub 配置的 Secrets / Variables

`仓库 → Settings → Secrets and variables → Actions`，用 **Repository secrets / variables**（workflow 未声明 environment）。

### Secrets

| 名称 | 说明 |
|------|------|
| `BUILD_CERTIFICATE_BASE64` | `distribution.p12` 的 base64 |
| `P12_PASSWORD` | 导出 p12 时设的密码 |
| `PROVISIONING_PROFILE_BASE64` | `.mobileprovision` 的 base64 |
| `KEYCHAIN_PASSWORD` | 任意随机字符串（CI 临时钥匙串用） |
| `APPLE_TEAM_ID` | 10 位 Team ID（Membership 页） |
| `CODE_SIGN_IDENTITY` | 可选，不填按导出方式自动推断 |

### Variables

| 名称 | 默认 | 可选值 |
|------|------|--------|
| `EXPORT_METHOD` | `ad-hoc` | `development` / `ad-hoc` / `app-store-connect` |

---

## 六、触发与产物

- **push** 到 `master`（改动涉及 `frontend/**`、`app/**` 或本 workflow）
- 打 **tag**：`v*`
- 或手动：Actions → iOS Build → **Run workflow**

产物：`vloglish-ios-<sha>` 工件，内含 `App.ipa`。

---

## 七、建议：把 ios/ 工程提交进仓库

当前 `app/ios/` 尚未生成，workflow 会在 CI 里首次用 `npx cap add ios` 生成。
**更推荐**生成一次并提交（`.gitignore` 已忽略 `Pods/`、`DerivedData/`、`public/` 等）：

```bash
cd app
npm install
npx cap add ios
npm run sync
git add ios
git commit -m "chore(app): 提交 Capacitor iOS 工程"
```

---

## 八、Gitee 远端

当前 `origin` 为 `git@github.com:AlbinGuo/vloglish.git`（SSH over 443），原 Gitee 远端为 `gitee`。
本地双推：`git push origin master && git push gitee master`。

---

## 九、TestFlight 自动上传（`.github/workflows/ios-testflight.yml`）

比 ad-hoc 更适合长期内测分发：**不需要 Mac、不需要重签名、不限设备台数**。

### 与 ad-hoc 流程的差异

| | iOS Build（ad-hoc） | iOS TestFlight |
|---|---|---|
| 签名 | 手动（p12 + 描述文件） | 手动（固定分发证书 p12 + **App Store** 描述文件） |
| 上传鉴权 | 无（只导出 ipa） | App Store Connect API Key |
| 需要 Secrets | 5 个 | 签名 4 个 + ASC 3 个（共用 `APPLE_TEAM_ID`） |
| 产物 | 下载 `App.ipa` 自行安装 | **直接上传 App Store Connect** |
| 安装方式 | 限已登记 UDID 的设备 | 任何人凭 TestFlight 链接安装，90 天有效 |
| 版本号 | 固定 | tag 或手动指定，写入 `CFBundleShortVersionString` |

### 前置准备

**① App Store Connect 里要有 App 记录**
[App Store Connect](https://appstoreconnect.apple.com) → 我的 App → **「+」** → App，填写：
- 名称：Vloglish
- 主要语言：简体中文
- Bundle ID：选 **`cc.vloglish.app`**（已注册）
- SKU：`vloglish-ios`

> 元数据（截图、描述等）可以不填，**不影响上传和 TestFlight 分发**，只是上架 App Store 前才需要补齐。

**② 创建 App Store Connect API Key**
Users and Access → **Integrations** → App Store Connect API → **+**：
- Name：`vloglish-ci`
- Access：**App Manager** 或 **Admin**（需要能管理证书/描述文件）
- 下载 `.p8`（只能下载一次），记下 **Key ID** 和 **Issuer ID**

**③ 转 base64**
```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("$PWD\AuthKey_你的KeyID.p8")) | Set-Clipboard
```

**④ 配置 Repository Secrets**（签名 4 个 + 上传 3 个，共用 `APPLE_TEAM_ID`）

| 名称 | 用途 | 说明 |
|------|------|------|
| `APPLE_TEAM_ID` | 共用 | 10 位 Team ID |
| `BUILD_CERTIFICATE_BASE64` | 签名 | **Apple Distribution** 的 `distribution.p12` 的 base64（与 ad-hoc 那套用同一个即可） |
| `P12_PASSWORD` | 签名 | 上面 p12 的密码 |
| `KEYCHAIN_PASSWORD` | 签名 | CI 临时钥匙串密码，随便设 |
| `PROVISIONING_PROFILE_BASE64` | 签名 | **App Store 类型**的 `.mobileprovision` 的 base64 |
| `ASC_API_KEY_ID` | 上传 | API Key 的 Key ID |
| `ASC_API_ISSUER_ID` | 上传 | API Key 的 Issuer ID |
| `ASC_API_KEY_BASE64` | 上传 | `.p8` 的 base64 |

> ⚠️ **关键**：TestFlight 上传要求描述文件是 **App Store 类型**（Distribution 证书 ↔ App Store 描述文件）。
> 若你之前给 ad-hoc 生成的是 **Ad Hoc** 描述文件，需在 Apple 后台按**同一张 Distribution 证书**再生成一个 **App Store** 描述文件（Bundle ID = `cc.vloglish.app`），导出后更新 `PROVISIONING_PROFILE_BASE64`。
>
> 说明：CI 用**手动签名**复用固定的 p12，不再每次新建分发证书，避免撞上 Apple「每账号最多 3 张分发证书」的限制。

### 使用

```bash
# 方式一：打 tag（版本号自动取 tag 名）
git tag v1.2.0 && git push origin v1.2.0

# 方式二：手动触发
# Actions → iOS TestFlight → Run workflow → 填版本号
```

### 分发

构建号取自 `github.run_number`，同一个 tag 重跑会自动递增。

上传成功后，到 App Store Connect → 我的 App → Vloglish → **TestFlight**：
- 等 Apple 处理构建（通常几分钟）
- **「+」添加测试人员**（输入对方 Apple ID，或开启「公开链接」任何人可装）
- 测试人员在 iPhone 上装 **TestFlight App**，接受邀请即可安装

---

### 环境要求

App Store Connect 强制要求 **用 iOS 26 SDK（Xcode 26+）构建**，否则上传会被拒绝：

```
error: exportArchive: Validation failed. SDK version issue.
This app was built with the iOS 17.5 SDK.
```

所以 TestFlight 流水线固定跑在 `macos-26` 镜像上（`macos-14` 只有 Xcode 15.4 / iOS 17.5 SDK）。
流水线开头有「检查 Xcode 版本」步骤，版本不够会**立刻失败并提示**，不会白等十几分钟。

> ad-hoc 那条 `ios.yml` 不上传 App Store Connect，不受此限制，仍跑 `macos-14`。

---

## 十、常见问题

### TestFlight 相关

- **`SDK version issue` / `built with the iOS 17.5 SDK`** → runner 镜像太旧，必须用 `macos-26`（Xcode 26+）。
- **`Choose a certificate to revoke. Your account has reached the maximum number of certificates`** → 旧版用「自动签名」时，每次全新 runner 都会新建一张分发证书，撞上 Apple **每账号最多 3 张分发证书**上限。现已改为**手动签名**（复用固定 p12，不再新建证书），一般不会再现。若仍出现：到 developer.apple.com → Certificates 撤销多余的 Apple Distribution 证书后重跑。
- **`No profiles for 'cc.vloglish.app' were found`** → 描述文件**类型/ Bundle ID 不匹配**（TestFlight 必须是 **App Store** 类型），或未正确导入。按第九节重新生成 App Store 描述文件并更新 secret。
- **`No app record found matching this bundle identifier`** → App Store Connect 里没有该 Bundle ID 的 App 记录，或选错了 Bundle ID。
- **`Invalid base64-encoded string`** → `ASC_API_KEY_BASE64` Secret 内容不完整/不是那个 `.p8` 的编码。一个 `.p8`（约 257 字节）的 base64 应该是 **344** 个字符。

- **`No signing certificate found`**：p12 与描述文件类型不匹配，或 `P12_PASSWORD` 不对。
- **`No profiles for 'cc.vloglish.app' were found`**：描述文件里的 Bundle ID 不一致 / 未导入成功。
- **ad-hoc 装不上设备**：设备 UDID 未登记，或未重新生成描述文件。
- **`method` 无效**：旧 Xcode 上 `app-store-connect` 应写 `app-store`。
- **Git Bash 里 `-subj` 报路径错误**：加 `export MSYS_NO_PATHCONV=1`。

---

## 十一、Apple 内购（IAP）配置与测试

App 内会员走 Apple 内购（StoreKit）。前端已接 `cordova-plugin-purchase`（见 `app/package.json`），
云构建里的 `cap sync ios` + `pod install` 会自动把它接进原生工程，**无需手动改 Xcode**。

### 1) 商品与代码里的 product id 必须一致

| 套餐 | 类型 | product id |
|------|------|-----------|
| 季度会员 | 自动续期订阅（3 个月） | `cc.vloglish.app.member.quarter` |
| 年度会员 | 自动续期订阅（12 个月） | `cc.vloglish.app.member.year` |
| 永久会员 | 非消耗型 | `cc.vloglish.app.member.forever` |

> 这些 id 定义在 `frontend/src/pages/PricingPage.vue` 的 `APPLE_PRODUCT_IDS`。
> 后端默认按 id 里的关键字（quarter / year / forever）判断套餐；如需自定义，用环境变量
> `APPLE_IAP_PRODUCTS` 覆盖（见第 4 步）。

### 2) 在 App Store Connect 创建商品

[App Store Connect](https://appstoreconnect.apple.com) → 我的 App → Vloglish → **App 内购买项目 / 功能**。

**自动续期订阅（季度 / 年度）**

1. 先建一个**订阅群组**（例如「Vloglish 会员」），所有订阅放同一群组，方便用户升降级。
2. 群组内 **+ 创建订阅**：分别填 product id `cc.vloglish.app.member.quarter`、`cc.vloglish.app.member.year`，
   选择时长（3 个月 / 12 个月），设定价格档位。
3. 每个商品填「显示名称」「描述」，上传审核截图；状态可先留「准备提交」用于沙盒测试。

**非消耗型（永久）**

- 「App 内购买项目」→ **+** → 类型选 **非消耗型**，product id 填 `cc.vloglish.app.member.forever`，设价格。

> 商品首次创建后，通常需要有一个**已上传到 TestFlight 的构建**、且商品可用于测试，沙盒里才能拉取到。
> 若前端提示「商品未就绪」，先按第九节把构建传到 TestFlight 再试。

### 3) 生成「App 专用共享密钥」

App Store Connect → 我的 App → Vloglish → App 信息 → **App 专用共享密钥** → 生成并复制。
后端用这串密钥调用 Apple `verifyReceipt` 校验收据（必填）。

### 4) 后端配置环境变量

在服务器（`.env.prod` / `docker-compose` 等）加上：

```bash
# App Store Connect 的「App 专用共享密钥」，用于 verifyReceipt 校验
APPLE_IAP_SHARED_SECRET=你的共享密钥

# 可选：覆盖「商品 id → 套餐」映射（默认按 id 关键字 quarter/year/forever 判断）
# plan: quarter|year|forever|custom；days 省略或 0 表示永久
# APPLE_IAP_PRODUCTS={"cc.vloglish.app.member.year":{"plan":"year","days":365}}
```

> 未配置 `APPLE_IAP_SHARED_SECRET` 时，`POST /api/membership/apple/verify/` 返回 503，
> 前端提示「会员开通确认中」，**不会误开通**。

### 5) In-App Purchase 能力

`cordova-plugin-purchase` 的 pod 会自动链接 StoreKit，绝大多数情况**无需手动加 Capability**。
若运行 / 审核提示缺少内购能力，再在 Xcode → Target → Signing & Capabilities → **+ Capability → In-App Purchase** 添加一次即可。

### 6) 测试（无需 Mac、无需单独沙盒账号）

- 按第九节把包传到 **TestFlight**，用 iPhone 的 TestFlight 装好。
- 用**测试员 Apple ID** 点「开通会员」，走真实内购弹窗；TestFlight 环境自带**沙盒**，不会真实扣款。
- 首次购买会弹「确认使用沙盒账户」，属正常。
- 购买成功后前端把收据提交后端校验，通过即开通会员，可在「我的」页看会员状态。

### 7) 常见问题

- **点支付提示「商品未就绪 / Apple 内购暂不可用」** → 商品未在 App Store Connect 建好、product id 不一致，
  或插件未随构建打进去（确认 CI 跑过 `cap sync ios` + `pod install`）。
- **后端返回 503** → 没配 `APPLE_IAP_SHARED_SECRET`。
- **后端返回 400「Apple 收据无效」** → 商品类型 / 收据不匹配；订阅需响应里带 `latest_receipt_info`。
  若插件只给 StoreKit 2 的 JWS 而无旧版收据，需改用 **App Store Server API** 校验。
- **后端返回 400「未找到对应的购买记录」** → 收据里没有该 product id 的交易，确认买的是对应商品。
- **购买成功但会员没开通** → 看后端 verify 接口日志，确认 `APPLE_IAP_PRODUCTS` 映射与 product id 对得上。
