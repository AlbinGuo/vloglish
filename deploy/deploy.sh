#!/usr/bin/env bash
# 本地/单机部署：在服务器上从源码构建镜像（不经过 ACR）
# 生产环境请使用 Gitee Go + deploy/update.sh，见 deploy/README.md
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ENV_FILE=".env.prod"
COMPOSE="docker compose"

if ! command -v docker >/dev/null 2>&1; then
  echo "错误：未找到 docker，请先安装 Docker。"
  exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "错误：未找到 docker compose 插件。"
  exit 1
fi

if [ ! -f "$ENV_FILE" ]; then
  if [ -f ".env.prod.example" ]; then
    cp .env.prod.example "$ENV_FILE"
    echo "已创建 $ENV_FILE，请编辑其中的密钥与域名后重新运行。"
    exit 1
  fi
  echo "错误：缺少 $ENV_FILE 与 .env.prod.example"
  exit 1
fi

if grep -q "change-me-in-production" "$ENV_FILE" || grep -q "change-me-strong-password" "$ENV_FILE"; then
  echo "警告：$ENV_FILE 仍含默认密钥，生产环境请先修改 JWT_SECRET 与 ADMIN_PASSWORD。"
fi

DEPLOY_DIR="$(dirname "${BASH_SOURCE[0]}")"
if ! docker pull postgres:16-alpine >/dev/null 2>&1; then
  echo "==> 无法访问 docker.io，配置镜像加速..."
  if [ "$(id -u)" -eq 0 ]; then
    bash "$DEPLOY_DIR/configure-docker-mirror.sh"
  else
    echo "错误：请以 root 运行: sudo bash deploy/configure-docker-mirror.sh"
    echo "      然后重新执行 bash deploy/deploy.sh"
    exit 1
  fi
fi

echo "==> 构建并启动容器..."
$COMPOSE --env-file "$ENV_FILE" up -d --build

echo "==> 等待后端健康检查..."
for i in $(seq 1 30); do
  if $COMPOSE --env-file "$ENV_FILE" exec -T backend curl -sf http://localhost:8000/api/health >/dev/null 2>&1; then
    break
  fi
  if [ "$i" -eq 30 ]; then
    echo "错误：后端健康检查超时，请执行: docker compose logs backend"
    exit 1
  fi
  sleep 2
done

if ! $COMPOSE --env-file "$ENV_FILE" exec -T backend python - <<'PY' >/dev/null 2>&1
from app.database import SessionLocal
from app.models import Episode
db = SessionLocal()
try:
    raise SystemExit(0 if db.query(Episode).count() > 0 else 1)
finally:
    db.close()
PY
then
  echo "==> 初始化数据库..."
  $COMPOSE --env-file "$ENV_FILE" exec -T backend python seed.py
fi

HTTP_PORT="$(grep -E '^HTTP_PORT=' "$ENV_FILE" | cut -d= -f2- | tr -d '\r' || true)"
HTTP_PORT="${HTTP_PORT:-80}"

echo ""
echo "部署完成。"
echo "  站点: http://localhost:${HTTP_PORT}/english"
echo "  管理: http://localhost:${HTTP_PORT}/gnadmin"
echo "  健康: http://localhost:${HTTP_PORT}/api/health"
echo ""
echo "常用命令:"
echo "  查看日志: docker compose --env-file $ENV_FILE logs -f"
echo "  停止服务: docker compose --env-file $ENV_FILE down"
echo "  重新构建: docker compose --env-file $ENV_FILE up -d --build"
