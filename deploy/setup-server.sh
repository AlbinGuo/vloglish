#!/usr/bin/env bash
# 阿里云服务器首次初始化（以 root 登录后执行一次）
# 用法：curl -fsSL https://gitee.com/guonan01/vlogish/raw/master/deploy/setup-server.sh | bash
# 或克隆仓库后：bash deploy/setup-server.sh
set -euo pipefail

APP_DIR="${APP_DIR:-/opt/vlogish}"
REPO_URL="${REPO_URL:-https://gitee.com/guonan01/vlogish.git}"
BRANCH="${BRANCH:-master}"

echo "==> 安装 Docker（如未安装）..."
if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com | sh
  systemctl enable docker
  systemctl start docker
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "错误：未找到 docker compose 插件"
  exit 1
fi

echo "==> 准备目录 ${APP_DIR}..."
mkdir -p "$APP_DIR"
cd "$APP_DIR"

if [ ! -d .git ]; then
  echo "==> 克隆代码库..."
  git clone -b "$BRANCH" "$REPO_URL" .
else
  echo "==> 更新代码..."
  git fetch origin
  git checkout "$BRANCH"
  git pull origin "$BRANCH"
fi

if [ ! -f .env.prod ]; then
  cp .env.prod.example .env.prod
  echo ""
  echo "已创建 .env.prod，请编辑以下项后重新运行 deploy/update.sh："
  echo "  - POSTGRES_PASSWORD / DATABASE_URL"
  echo "  - JWT_SECRET / ADMIN_PASSWORD"
  echo "  - ACR_REGISTRY / ACR_USERNAME / ACR_PASSWORD"
  echo "  - 七牛、DeepSeek 等"
  exit 0
fi

chmod +x deploy/update.sh deploy/deploy.sh 2>/dev/null || true

echo ""
echo "初始化完成。下一步："
echo "  1. 编辑 ${APP_DIR}/.env.prod"
echo "  2. 首次部署：bash deploy/deploy.sh（本地构建）"
echo "     或配置 Gitee Go 流水线后 push 代码自动部署"
echo "  3. HTTPS（可选）：docker compose -f docker-compose.prod.yml --env-file .env.prod --profile https up -d"
