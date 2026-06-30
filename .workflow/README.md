# Gitee Go 流水线说明

## 生产部署（push master / main）

使用 **`MasterPipeline.yml`**：

1. Docker 构建 `backend` 镜像（`backend/Dockerfile`）
2. Docker 构建 `web` 镜像（`frontend/Dockerfile`）
3. 推送阿里云 ACR
4. 在 ECS 上执行 `deploy/update.sh`

### 镜像仓库认证（必做）

Gitee Go 的 `build@docker` **必须**指定认证方式，否则会报「认证方式没配置」。

**推荐：仓库凭证**

1. Gitee → **凭证管理** → 新建 **Docker Registry**
2. 仓库地址：`registry.cn-hangzhou.aliyuncs.com`
3. 用户名 / 密码：ACR 控制台设置的访问凭证
4. **凭证标识**填：`vlogish-acr`（与 `MasterPipeline.yml` 里 `certificate` 一致）

Backend / Web 两个镜像构建任务都用同一个凭证。

**备选：账号密码**（在 YAML 里把 `type: cert` 改成 `type: account`，见文件内注释）

### 流水线变量（私密）

| 变量 | 说明 |
|------|------|
| `ACR_REGISTRY` | 例 `registry.cn-hangzhou.aliyuncs.com/vlogish` |
| `DEPLOY_HOST_GROUP` | 主机组 ID |
| `ACR_USERNAME` / `ACR_PASSWORD` | 仅在使用 `type: account` 时需要 |

## 不要使用的模板

- `master-pipeline.yml`：Gitee 默认 Python 模板，**已停用**（会在仓库根目录找 `requirements.txt` / `main.py`，与本项目结构不符）

## 项目结构

```text
vlogish/                 ← 一个 Git 仓库（monorepo）
├── backend/             ← Python 后端，requirements.txt 在此
├── frontend/            ← Vue 前端
├── backend/Dockerfile   ← 后端镜像
└── frontend/Dockerfile  ← 前端镜像
```

前后端**共用一个仓库**，通过 **两个 Docker 镜像** 分别部署，无需拆成两个 Git 仓库。
