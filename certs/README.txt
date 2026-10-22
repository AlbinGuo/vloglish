# 把 APNs 推送密钥 AuthKey_XXXXXXXXXX.p8 放到本目录（仅服务器上，勿提交，已被 .gitignore 忽略）。
# docker-compose 已将该目录只读挂载到容器 /app/backend/certs。
# 对应 .env.prod: APNS_AUTH_KEY_FILE=/app/backend/certs/AuthKey_XXXXXXXXXX.p8
