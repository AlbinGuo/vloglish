#!/usr/bin/env bash
# App 推送自检（只读，不改数据）。在服务器仓库根目录执行：bash deploy/diagnose-push.sh
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1
DC=(docker compose --env-file .env.prod)
line() { printf '\n===== %s =====\n' "$1"; }

line "1. 推送 worker 是否启动"
"${DC[@]}" logs backend 2>/dev/null | grep -E "\[push\]" | tail -n 20 || echo "(无 push 日志)"

line "2. 容器内是否装了 h2"
"${DC[@]}" exec -T backend pip show h2 2>/dev/null | grep -E "Name|Version" || echo "缺少 h2：镜像需重建"

line "3. APNS 环境变量"
"${DC[@]}" exec -T backend printenv 2>/dev/null | grep -E "^APNS_" || echo "未注入 APNS_*"

line "4. 容器内密钥文件"
"${DC[@]}" exec -T backend sh -c 'ls -l /app/backend/certs 2>/dev/null; head -1 /app/backend/certs/AuthKey_*.p8 2>/dev/null' || echo "看不到 /app/backend/certs"

line "5. 已注册设备（这里必须 >=1 行 ios）"
"${DC[@]}" exec -T db psql -U postgres -c "select id,user_id,platform,env,is_active,created_at from push_devices order by id desc limit 10;" 2>/dev/null

line "6. 最近发送任务"
"${DC[@]}" exec -T db psql -U postgres -c "select id,title,status,recipient_count,processed_at from push_outbox order by id desc limit 5;" 2>/dev/null

line "7. 注册/发送日志"
"${DC[@]}" logs backend 2>/dev/null | grep -iE "push/register|outbox|APNs" | tail -n 30 || echo "(无相关日志)"

line "8. nginx 最近的 /api 请求"
"${DC[@]}" logs web 2>/dev/null | grep -iE "/api/" | tail -n 20 || echo "(无：App 可能没连这台后端)"

echo ""
echo "完成。重点看第5步有没有 ios 行、第7步有没有 push/register 及状态码。"