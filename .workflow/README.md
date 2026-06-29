# Gitee Go 流水线说明

## 生产部署（push master / main）

使用 **`MasterPipeline.yml`**：

1. Docker 构建 `backend` 镜像（`backend/Dockerfile`）
2. Docker 构建 `web` 镜像（`frontend/Dockerfile`）
3. 推送阿里云 ACR
4. 在 ECS 上执行 `deploy/update.sh`

在 Gitee **流水线 → 变量** 中配置（私密）：

| 变量 | 说明 |
|------|------|
| `ACR_REGISTRY` | 例 `registry.cn-hangzhou.aliyuncs.com/vlogish` |
| `ACR_USERNAME` | ACR 用户名 |
| `ACR_PASSWORD` | ACR 密码 |
| `DEPLOY_HOST_GROUP` | 主机组 ID |

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
