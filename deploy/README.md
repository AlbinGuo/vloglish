# Vloglish 生产部署指南（方案 B）

**完整操作步骤见：[DEPLOY_GUIDE.md](./DEPLOY_GUIDE.md)**（从本地开发到上线，逐步清单）

Gitee Go 构建镜像 → 阿里云 ACR → 服务器拉取更新。

> **安全提示**：请勿将密码、Token 提交到 Git。流水线密钥在 Gitee 仓库「流水线 → 变量」中配置为**私密变量**。

---

## 架构

```text
push master → Gitee Go 构建 backend/web 镜像 → 推送 ACR
            → shell@agent 在阿里云执行 deploy/update.sh
            → docker compose pull + up -d
```

---

## 一、阿里云 ACR（镜像仓库）

1. 登录 [阿里云容器镜像服务](https://cr.console.aliyun.com/)
2. 创建**个人实例**或企业实例（推荐与 ECS 同地域，如 `cn-hangzhou`）
3. 创建命名空间，例如 `vlogish`
4. 创建两个**镜像仓库**：`backend`、`web`（无需手动 push，流水线会自动推）
5. 记录：
   - `ACR_REGISTRY`：`registry.cn-hangzhou.aliyuncs.com/vlogish`
   - `ACR_USERNAME` / `ACR_PASSWORD`：访问凭证

---

## 二、阿里云 ECS 服务器

### 2.1 安全组

| 端口 | 用途 |
|------|------|
| 22   | SSH |
| 80   | HTTP |
| 443  | HTTPS（可选） |

### 2.2 首次初始化

```bash
ssh root@YOUR_SERVER_IP

# 若 get.docker.com 无法访问（国内常见），脚本已改用阿里云镜像
mkdir -p /opt/vlogish
git clone https://gitee.com/guonan01/vlogish.git /opt/vlogish
cd /opt/vlogish
bash deploy/setup-server.sh

# 若 deploy 时 docker.io 超时，单独配置加速器：
# sudo bash deploy/configure-docker-mirror.sh
# 或（推荐，阿里云控制台获取专属地址）：
# sudo ALIYUN_MIRROR_URL=https://xxxx.mirror.aliyuncs.com bash deploy/configure-docker-mirror.sh
```

### 2.3 配置 `.env.prod`

```bash
cp .env.prod.example .env.prod
vim .env.prod
```

必填项：

- `POSTGRES_PASSWORD`、`DATABASE_URL`（密码 URL 编码）
- `JWT_SECRET`、`ADMIN_PASSWORD`
- `ACR_REGISTRY`、`ACR_USERNAME`、`ACR_PASSWORD`
- 七牛、DeepSeek 等

`DATABASE_URL` 示例（Docker 内连 db 容器）：

```env
DATABASE_URL=postgresql+psycopg://postgres:YOUR_URL_ENCODED_PASSWORD@db:5432/postgres
```

### 2.4 安装 Gitee Go Agent（用于自动部署）

1. Gitee 仓库 → **流水线** → 开通 **Gitee Go**
2. **主机管理** → 添加主机 → 按文档在 ECS 上安装 Agent
3. 创建主机组，例如 ID：`vlogish-prod`，加入 `8.137.196.234`
4. 记录 `DEPLOY_HOST_GROUP=vlogish-prod`

---

## 三、Gitee Go 流水线

### 3.1 开启流水线

仓库已包含 `.workflow/MasterPipeline.yml`，push 到 `master`/`main` 后自动触发。

### 3.2 配置私密变量

仓库 → **流水线** → **变量**（全部勾选「私密」）：

| 变量名 | 说明 |
|--------|------|
| `ACR_REGISTRY` | `registry.cn-hangzhou.aliyuncs.com/vlogish` |
| `ACR_USERNAME` | ACR 用户名 |
| `ACR_PASSWORD` | ACR 密码 |
| `DEPLOY_HOST_GROUP` | 主机组 ID，如 `vlogish-prod` |

### 3.3 发版流程

```text
本地开发 → git push gitee master → 流水线自动构建部署
```

---

## 四、常用命令（在 /opt/vlogish）

```bash
# 查看状态
docker compose -f docker-compose.prod.yml --env-file .env.prod ps

# 查看日志
docker compose -f docker-compose.prod.yml --env-file .env.prod logs -f backend web

# 手动更新（指定构建号）
IMAGE_TAG=42 bash deploy/update.sh

# 回滚
bash deploy/rollback.sh 41

# 启用 HTTPS（需先设置 SITE_DOMAIN 并解析 DNS）
docker compose -f docker-compose.prod.yml --env-file .env.prod --profile https up -d
```

---

## 五、本地 / 单机调试（不走 ACR）

仍在服务器或本机用源码构建：

```bash
bash deploy/deploy.sh
```

---

## 六、持续迭代建议

| 事项 | 做法 |
|------|------|
| 发版 | push `master`，流水线自动部署 |
| 回滚 | `bash deploy/rollback.sh <构建号>` |
| 数据库 | 每次 `update.sh` 自动 `pg_dump` 到 `backups/` |
| 数据库结构变更 | 后续引入 Alembic，在 `update.sh` 加 `alembic upgrade head` |
| 密钥轮换 | 只改 Gitee 变量 + 服务器 `.env.prod`，不要提交 Git |

---

## 七、故障排查

| 现象 | 处理 |
|------|------|
| 流水线构建失败 | Gitee Go 日志 → 检查 ACR 凭证、Dockerfile |
| 部署失败 | 服务器 `docker compose logs backend` |
| 拉镜像 401 | 检查 `ACR_USERNAME/PASSWORD`，手动 `docker login` |
| 健康检查超时 | 检查 `DATABASE_URL`、PostgreSQL 是否启动 |

---

## 仓库地址

https://gitee.com/guonan01/vlogish.git
