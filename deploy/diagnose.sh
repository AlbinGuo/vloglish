#!/usr/bin/env bash
# 502 / 无法访问 排查脚本
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ENV_FILE=".env.prod"
HTTP_PORT="${HTTP_PORT:-80}"

if [ -f "$ENV_FILE" ]; then
  # shellcheck source=lib/load-env.sh
  source "$ROOT_DIR/deploy/lib/load-env.sh"
  load_env_file "$ENV_FILE"
  HTTP_PORT="${HTTP_PORT:-80}"
fi

echo "========== 1. 容器状态 =========="
docker compose --env-file "$ENV_FILE" ps 2>/dev/null || docker compose ps

echo ""
echo "========== 2. 端口占用（谁在使用 80）=========="
if command -v ss >/dev/null 2>&1; then
  ss -tlnp | grep -E ':80|:8080' || echo "(无 80/8080 监听)"
elif command -v netstat >/dev/null 2>&1; then
  netstat -tlnp | grep -E ':80|:8080' || true
else
  echo "未找到 ss/netstat"
fi

echo ""
echo "========== 3. Docker 端口映射 =========="
docker compose --env-file "$ENV_FILE" port web 80 2>/dev/null || echo "web 容器未映射 80"

echo ""
echo "========== 4. 本机访问 web 容器 =========="
echo -n "GET /api/health -> "
curl -sf -o /dev/null -w "%{http_code}\n" "http://127.0.0.1:${HTTP_PORT}/api/health" 2>/dev/null || echo "失败"

echo -n "GET /english -> "
curl -sf -o /dev/null -w "%{http_code}\n" "http://127.0.0.1:${HTTP_PORT}/english" 2>/dev/null || echo "失败"

echo ""
echo "========== 5. web 容器内访问 backend =========="
docker compose --env-file "$ENV_FILE" exec -T web wget -qO- http://backend:8000/api/health 2>/dev/null || \
  docker compose --env-file "$ENV_FILE" exec -T web sh -c "wget -qO- http://backend:8000/api/health" 2>/dev/null || \
  echo "web -> backend 不通"

echo ""
echo "========== 6. backend 最近日志 =========="
docker compose --env-file "$ENV_FILE" logs backend --tail=30 2>/dev/null

echo ""
echo "========== 7. web 最近日志 =========="
docker compose --env-file "$ENV_FILE" logs web --tail=15 2>/dev/null

echo ""
echo "========== 判断提示 =========="
cat <<'EOF'
- 本机 curl 成功、公网 502  → 检查阿里云安全组是否放行 80
- 本机 curl 也 502          → 看第 5 步 backend 是否通
- 第 2 步除 docker 外还有 nginx → 宿主机 Nginx 占 80，需停掉或改端口
- HTTP_PORT 不是 80         → 访问要带端口，如 http://IP:8080/english
EOF
