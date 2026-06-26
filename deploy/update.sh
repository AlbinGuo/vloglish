#!/usr/bin/env bash
# 生产环境更新脚本（在阿里云服务器 /opt/vlogish 执行）
# 由 Gitee Go shell@agent 调用，也可手动：IMAGE_TAG=42 bash deploy/update.sh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ENV_FILE=".env.prod"
COMPOSE_FILE="docker-compose.prod.yml"
COMPOSE=(docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE")

if [ ! -f "$ENV_FILE" ]; then
  echo "错误：缺少 $ENV_FILE，请先 cp .env.prod.example .env.prod 并填写配置"
  exit 1
fi

# shellcheck disable=SC1090
set -a
source "$ENV_FILE"
set +a

IMAGE_TAG="${IMAGE_TAG:-latest}"
ACR_REGISTRY="${ACR_REGISTRY:-}"

if [ -z "${BACKEND_IMAGE:-}" ] || [ -z "${WEB_IMAGE:-}" ]; then
  if [ -z "$ACR_REGISTRY" ]; then
    echo "错误：请设置 BACKEND_IMAGE/WEB_IMAGE 或 ACR_REGISTRY"
    exit 1
  fi
  export BACKEND_IMAGE="${ACR_REGISTRY}/backend:${IMAGE_TAG}"
  export WEB_IMAGE="${ACR_REGISTRY}/web:${IMAGE_TAG}"
fi

echo "==> 更新版本: ${IMAGE_TAG}"
echo "    backend: ${BACKEND_IMAGE}"
echo "    web:     ${WEB_IMAGE}"

if [ -n "${ACR_USERNAME:-}" ] && [ -n "${ACR_PASSWORD:-}" ] && [ -n "$ACR_REGISTRY" ]; then
  echo "==> 登录镜像仓库..."
  echo "$ACR_PASSWORD" | docker login "${ACR_REGISTRY%%/*}" -u "$ACR_USERNAME" --password-stdin
fi

BACKUP_DIR="${BACKUP_DIR:-/opt/vlogish/backups}"
mkdir -p "$BACKUP_DIR"
STAMP="$(date +%Y%m%d_%H%M%S)"

if "${COMPOSE[@]}" ps db 2>/dev/null | grep -q 'Up'; then
  echo "==> 备份 PostgreSQL..."
  "${COMPOSE[@]}" exec -T db pg_dump -U "${POSTGRES_USER:-postgres}" "${POSTGRES_DB:-postgres}" \
    > "${BACKUP_DIR}/pg_${STAMP}.sql" || echo "警告：数据库备份失败，继续更新"
fi

echo "==> 拉取镜像..."
BACKEND_IMAGE="$BACKEND_IMAGE" WEB_IMAGE="$WEB_IMAGE" "${COMPOSE[@]}" pull backend web

echo "==> 启动服务..."
BACKEND_IMAGE="$BACKEND_IMAGE" WEB_IMAGE="$WEB_IMAGE" "${COMPOSE[@]}" up -d

echo "==> 等待健康检查..."
for i in $(seq 1 30); do
  if curl -sf "http://127.0.0.1:${HTTP_PORT:-80}/api/health" >/dev/null 2>&1; then
    break
  fi
  if [ "$i" -eq 30 ]; then
    echo "错误：健康检查超时"
    "${COMPOSE[@]}" logs --tail=80 backend web
    exit 1
  fi
  sleep 2
done

if ! "${COMPOSE[@]}" exec -T backend python - <<'PY' >/dev/null 2>&1
from app.database import SessionLocal
from app.models import Episode
db = SessionLocal()
try:
    raise SystemExit(0 if db.query(Episode).count() > 0 else 1)
finally:
    db.close()
PY
then
  echo "==> 空库，执行 seed..."
  "${COMPOSE[@]}" exec -T backend python seed.py
fi

echo ""
echo "更新完成 (#${IMAGE_TAG})"
echo "  健康: http://127.0.0.1:${HTTP_PORT:-80}/api/health"
