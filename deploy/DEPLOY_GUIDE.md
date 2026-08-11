# Vloglish 从本地开发到上线部署 — 操作手册


# 部署-最短记忆版
```js
ssh root@8.137.196.234
cd /opt/vlogish && git pull && bash deploy/deploy.sh
```

本文档列出**你需要亲手执行的步骤**，按顺序完成即可。

- 代码仓库：https://gitee.com/guonan01/vlogish.git  
- 部署方案：**方案 B**（Gitee Go 构建镜像 → 阿里云 ACR → 服务器拉取更新）  
- 国内镜像加速：**docker.1ms.run**

---

## 总览

```text
┌─────────────────────────────────────────────────────────────────┐
│ 阶段一  本地开发 & 自测                                          │
│ 阶段二  推送 Gitee                                               │
│ 阶段三  阿里云服务器一次性初始化                                  │
│ 阶段四  首次上线（服务器本地构建，不依赖 ACR）                     │
│ 阶段五  配置 Gitee Go + ACR（后续自动发版，可选但推荐）           │
│ 阶段六  日常迭代发版                                             │
└─────────────────────────────────────────────────────────────────┘
```

| 阶段 | 在哪里执行 | 频率 |
|------|------------|------|
| 一 | 本机 Windows | 每次开发 |
| 二 | 本机 | 每次提交 |
| 三～四 | 阿里云 ECS | 仅首次 |
| 五 | Gitee + 阿里云控制台 | 仅首次 |
| 六 | 本机 push + 自动部署 | 每次发版 |

---

## 阶段一：本地开发

### 1.1 环境要求

- Node.js 18+
- Python 3.11+
- PostgreSQL（本地，端口 5432）或后续仅在 Docker 内使用

### 1.2 后端

```bash
cd backend
python -m venv .venv

# Windows
.venv\Scripts\activate

pip install -r requirements.txt
```

创建 `backend/.env`（**不要提交 Git**），至少包含：

```env
DATABASE_URL=postgresql+psycopg://postgres:你的密码@localhost:5432/postgres

# 七牛、DeepSeek 等按 backend/.env.example 填写
```

> 密码含 `#` `$` `!` 时：`DATABASE_URL` 里用 URL 编码；`.env` 里明文密码用单引号包裹。

导入样本数据并启动：

```bash
python seed.py
uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```

### 1.3 前端

```bash
cd frontend
npm install
npm run dev
```

浏览器访问：http://127.0.0.1:5173/english

### 1.4 本地自测清单

- [ ] 目录页 `/english` 正常
- [ ] 登录 / 学习页 / 管理后台 `/gnadmin` 正常
- [ ] 接口 `/api/health` 返回 ok

---

## 阶段二：推送到 Gitee

### 2.1 配置远程仓库（首次）

```bash
git remote add gitee https://gitee.com/guonan01/vlogish.git
# 若已存在：git remote -v 确认
```

### 2.2 日常提交

```bash
git add .
git commit -m "描述你的改动"
git push gitee master
```

> **切勿提交**：`.env`、`.env.prod`、`backend/.venv`、`node_modules` 等（已在 `.gitignore` 中）。

---

## 阶段三：阿里云服务器一次性初始化

以下在 **ECS** 上执行（示例 IP 换成你的公网 IP）。

### 3.1 安全组放行

| 端口 | 用途 |
|------|------|
| 22 | SSH |
| 80 | HTTP 站点 |

### 3.2 SSH 登录

```bash
ssh root@你的公网IP
```

### 3.3 克隆代码

```bash
mkdir -p /opt/vlogish
git clone https://gitee.com/guonan01/vlogish.git /opt/vlogish
cd /opt/vlogish
```

私有仓库需配置 Git 凭据或 SSH Key。

### 3.4 安装 Docker

```bash
bash deploy/setup-server.sh
```

脚本会通过**阿里云软件源**安装 Docker；若已安装可跳过。

### 3.5 配置 Docker 镜像加速（必做）

国内服务器无法直接访问 docker.io，使用 **docker.1ms.run**：

```bash
sudo DOCKER_MIRROR_URL=https://docker.1ms.run bash deploy/configure-docker-mirror.sh
```

成功标志：终端输出 `postgres:16-alpine` **拉取成功**。

验证：

```bash
docker info | grep -A3 "Registry Mirrors"
# 应包含 https://docker.1ms.run
```

---

## 阶段四：首次上线部署

> 首次部署 **不要** 用 `update.sh`（ACR 里还没有镜像）。用 `deploy.sh` 在服务器上本地构建。

### 4.1 创建生产配置

```bash
cd /opt/vlogish
cp .env.prod.example .env.prod
vim .env.prod
```

### 4.2 `.env.prod` 必填项说明

```env
HTTP_PORT=80

# PostgreSQL — 密码用单引号；DATABASE_URL 里密码必须 URL 编码
POSTGRES_IMAGE=docker.1ms.run/library/postgres:16-alpine
POSTGRES_USER=postgres
POSTGRES_PASSWORD='你的数据库密码'
POSTGRES_DB=postgres
POSTGRES_PUBLISH=127.0.0.1:5432
DATABASE_URL=postgresql+psycopg://postgres:URL编码后的密码@db:5432/postgres

# 七牛、DeepSeek
QINIU_ACCESS_KEY=...
QINIU_SECRET_KEY=...
QINIU_BUCKET=sxak-oss
QINIU_DOMAIN=http://oss.sxakgs.com
QINIU_PREFIX=en
# 防盗链：后端默认签发短时 URL；请在七牛控制台把空间改为「私有」，
# 并建议开启 Referer 防盗链。调试可设 QINIU_SIGN_URLS=0
QINIU_SIGN_URLS=1
QINIU_MEDIA_EXPIRES=14400
QINIU_COVER_EXPIRES=86400
DEEPSEEK_API_KEY=...

# JWT & 管理后台
JWT_SECRET=随机长字符串
ADMIN_EMAIL=admin@vloglish.com
ADMIN_PASSWORD='管理后台密码'

# 站点地址（填 ECS 公网 IP 或域名）
FRONTEND_URL=http://你的公网IP
APP_DEBUG=false

# ACR — 首次 deploy.sh 可不填；配置流水线后再填
ACR_REGISTRY=registry.cn-hangzhou.aliyuncs.com/vlogish
ACR_USERNAME=
ACR_PASSWORD=''
BACKEND_IMAGE=
WEB_IMAGE=
```

**URL 编码对照**（`DATABASE_URL` 用）：

| 字符 | 编码 |
|------|------|
| `#` | `%23` |
| `$` | `%24` |
| `!` | `%21` |

**`BACKEND_IMAGE` / `WEB_IMAGE`**：留空即可；只有跑 `update.sh` 从 ACR 拉镜像时才需要（或由脚本根据 `ACR_REGISTRY` 自动生成）。

### 4.3 执行首次部署

```bash
cd /opt/vlogish
git pull   # 确保 Dockerfile 已含国内 npm/pip 镜像配置
bash deploy/deploy.sh
```

> 构建时前端 `npm ci` 使用 `registry.npmmirror.com`，后端 `pip` / `apt` 使用阿里云镜像，避免访问国外源超时。

等待构建完成（首次约 5～15 分钟）。

### 4.4 验证上线

```bash
curl http://127.0.0.1/api/health
# {"status":"ok"}
```

浏览器访问：

- 用户端：`http://你的公网IP/english`
- 管理端：`http://你的公网IP/gnadmin`

### 4.5 常用运维命令

```bash
cd /opt/vlogish

# 查看容器
docker compose --env-file .env.prod ps

# 查看日志
docker compose --env-file .env.prod logs -f backend web

# 停止
docker compose --env-file .env.prod down
```

### 4.6 从本机连接 PostgreSQL

数据库跑在 ECS 的 Docker 容器里。默认 `POSTGRES_PUBLISH=127.0.0.1:5432`，**只监听服务器本机**，外网无法直接连库，需用 SSH 隧道（推荐）或改为 `0.0.0.0:5432` 并配置安全组。

#### 方式一：SSH 隧道（推荐，更安全）

**1. 确保 `.env.prod` 中有：**

```env
POSTGRES_PUBLISH=127.0.0.1:5432
```

**2. 在 ECS 上重建 db 容器（若刚改配置）：**

```bash
cd /opt/vlogish
docker compose --env-file .env.prod up -d db
```

**3. 在本机 Windows PowerShell 建立隧道：**

```powershell
ssh -L 15432:127.0.0.1:5432 root@你的ECS公网IP
```

保持该窗口不要关闭。本机用 **15432** 端口连库（避免与本机已有 PostgreSQL 冲突）。

**4. 连接参数（DBeaver / DataGrip / psql）：**

| 项 | 值 |
|----|-----|
| Host | `127.0.0.1` |
| Port | `15432` |
| Database | `postgres` |
| User | `postgres` |
| Password | `.env.prod` 里 `POSTGRES_PASSWORD` 的明文（非 URL 编码） |

JDBC URL 示例：

```
jdbc:postgresql://127.0.0.1:15432/postgres
```

psql 示例：

```bash
psql "postgresql://postgres:你的密码@127.0.0.1:15432/postgres"
```

> 密码含 `#` `$` `!` 等特殊字符时，在 URL 里须 URL 编码；在 GUI 工具的「密码」框里填明文即可。

#### 方式二：外网直连

**1. 修改 `/opt/vlogish/.env.prod`：**

```env
POSTGRES_PUBLISH=0.0.0.0:5432
```

**2. 阿里云安全组** → 入方向 → 添加规则：

- 协议：TCP
- 端口：`5432`
- 授权对象：**仅你的公网 IP**/32（不要用 `0.0.0.0/0`）

**3. 重建 db 容器：**

```bash
cd /opt/vlogish
docker compose --env-file .env.prod up -d db
```

**4. 本机连接：**

| 项 | 值 |
|----|-----|
| Host | ECS 公网 IP（如 `8.137.196.234`） |
| Port | `5432` |
| Database / User / Password | 同上 |

**安全提醒：**

- 务必使用强密码，且安全组只放行你的 IP
- 生产环境优先 SSH 隧道，避免把 5432 暴露到公网
- `DATABASE_URL` 给 backend 用时主机名仍是 `db`（容器内网），不要改成公网 IP

---

## 阶段五：配置 Gitee Go 自动发版（推荐）

完成阶段四后站点已可用。配置流水线后，后续 `git push` 可自动构建并部署。

### 5.1 阿里云 ACR

1. 打开 [容器镜像服务](https://cr.console.aliyun.com/)
2. 创建命名空间：`vlogish`
3. 创建镜像仓库：`backend`、`web`（类型选「私有」）
4. **访问凭证** → 设置固定密码 → 记录用户名和密码
5. 记录 `ACR_REGISTRY=registry.cn-hangzhou.aliyuncs.com/vlogish`（地域以控制台为准）

### 5.2 补全服务器 `.env.prod` 中的 ACR

```bash
vim /opt/vlogish/.env.prod
```

```env
ACR_REGISTRY=registry.cn-hangzhou.aliyuncs.com/vlogish
ACR_USERNAME=你的ACR用户名
ACR_PASSWORD='你的ACR密码'
```

### 5.3 开通 Gitee Go

1. 打开仓库 → **流水线** → 开通 **Gitee Go**
2. **主机管理** → 添加主机 → 在 ECS 上安装 Agent
3. 创建主机组（如 `vlogish-prod`），把 ECS 加入该组
4. 记录主机组 ID

### 5.4 配置流水线私密变量

仓库 → **流水线** → **变量**（全部勾选「私密」）：

| 变量名 | 示例值 |
|--------|--------|
| `ACR_REGISTRY` | `registry.cn-hangzhou.aliyuncs.com/vlogish` |
| `ACR_USERNAME` | ACR 用户名 |
| `ACR_PASSWORD` | ACR 密码 |
| `DEPLOY_HOST_GROUP` | `vlogish-prod` |

### 5.5 触发首次流水线

```bash
# 本机
git push gitee master
```

在 Gitee **流水线** 页面查看构建是否成功（构建并 push `backend`、`web` 镜像）。

---

## 阶段六：日常迭代发版

### 6.1 开发 → 上线流程

```text
1. 本机开发、自测（阶段一）
2. git commit && git push gitee master（阶段二）
3. Gitee Go 自动：构建镜像 → 推送 ACR → 服务器执行 deploy/update.sh
4. 浏览器验证
```

### 6.2 手动在服务器更新（备用）

```bash
cd /opt/vlogish
git pull
IMAGE_TAG=流水线构建号 bash deploy/update.sh
```

### 6.3 回滚

```bash
cd /opt/vlogish
bash deploy/rollback.sh 上一版本的构建号
```

### 6.4 仅改配置、未改代码

```bash
vim /opt/vlogish/.env.prod
docker compose --env-file .env.prod up -d
```

---

## 故障排查

| 现象 | 处理 |
|------|------|
| `Qw9: unbound variable` | `.env.prod` 中含 `$` 的密码加**单引号** |
| `DATABASE_URL` 报错 | 使用 **URL 编码**密码，不要用明文 `#$!` |
| docker.io 超时 | `sudo DOCKER_MIRROR_URL=https://docker.1ms.run bash deploy/configure-docker-mirror.sh` |
| postgres 拉取失败 | `.env.prod` 设 `POSTGRES_IMAGE=docker.1ms.run/library/postgres:16-alpine` |
| redis 拉取失败 | `.env.prod` 设 `REDIS_IMAGE=docker.1ms.run/library/redis:7-alpine`，并确认 `REDIS_URL=redis://redis:6379/0` |
| 词卡二次仍慢 / health 显示 redis:down | 检查 redis 容器 `docker compose --env-file .env.prod ps redis`；backend 日志是否有 Redis connected |
| `npm ci` / `pip install` 超时 | `git pull` 拉最新 Dockerfile（已配 npmmirror / 阿里云 pip）后重跑 `deploy.sh` |
| `update.sh` 镜像 not found | 首次用 `deploy.sh`；或先跑通 Gitee 流水线 |
| backend unhealthy / 依赖启动失败 | `docker compose --env-file .env.prod logs backend`；确认 `DATABASE_URL` 主机为 `@db:`；`git pull` 后重建 backend |
| ACR 401 | 检查 `ACR_USERNAME/PASSWORD`，`docker login registry.cn-hangzhou.aliyuncs.com` |

---

## 命令速查

| 场景 | 命令 |
|------|------|
| 本地后端 | `uvicorn app.main:app --reload --port 8000` |
| 本地前端 | `npm run dev` |
| 服务器首次部署 | `bash deploy/deploy.sh` |
| 配置镜像加速 | `sudo DOCKER_MIRROR_URL=https://docker.1ms.run bash deploy/configure-docker-mirror.sh` |
| 服务器更新 | `bash deploy/update.sh` |
| SQLite → PG 迁移（本地） | `python backend/scripts/migrate_sqlite_to_postgres.py --force` |

---

## 安全提醒

- 所有密钥只放在 `backend/.env`（本地）和 `/opt/vlogish/.env.prod`（服务器）
- Gitee 流水线变量勾选「私密」
- 不要将 `.env.prod` 提交到 Git
- 生产环境定期更换 JWT、数据库、ACR 密码

---

## 管理端抓取 TikTok / YouTube（重要）

**阿里云大陆 ECS 无法直连 TikTok**（YouTube 也常不稳定），在服务器上点「抓取并上传七牛」会报 `Network is unreachable`。

### 方案 A：本地抓取（推荐）

在你本机 Windows（能访问 TikTok 的环境）：

1. 配置 `backend/.env`（七牛、DeepSeek 等）
2. 安装 yt-dlp、ffmpeg（或使用 `VLOGISH_TOOLS_DIR`）
3. 在管理后台本地环境打开新建剧集，使用「抓取并上传七牛」  
   或运行后端 API / 脚本完成抓取

抓取成功后媒体已在七牛，线上服务器只需保存剧集元数据。

### 方案 B：服务器配置代理

若你有可访问外网的 HTTP/SOCKS 代理，在 `/opt/vlogish/.env.prod` 添加：

```env
YT_DLP_PROXY=http://你的代理地址:端口
# TikTok 可选
YT_DLP_IMPERSONATE=chrome
```

然后重建 backend：

```bash
docker compose --env-file .env.prod up -d --build backend
```

### 方案 C：ECS 换到香港等地域

香港等区域一般可直接访问 TikTok/YouTube，可在该机器上跑抓取任务。

---

## 相关文件

| 文件 | 说明 |
|------|------|
| `docker-compose.yml` | 本地构建部署（`deploy.sh`） |
| `docker-compose.prod.yml` | ACR 镜像部署（`update.sh`） |
| `.workflow/MasterPipeline.yml` | Gitee Go 流水线 |
| `deploy/deploy.sh` | 首次 / 源码构建部署 |
| `deploy/update.sh` | 从 ACR 拉镜像更新 |
| `deploy/configure-docker-mirror.sh` | Docker 镜像加速 |
