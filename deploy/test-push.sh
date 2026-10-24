#!/usr/bin/env bash
# 直接发一条测试推送：不写用户通知、不打扰其他用户，只发给你已注册的真机。
# 用法（服务器仓库根目录）：bash deploy/test-push.sh
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1
docker compose --env-file .env.prod exec -T backend python - <<'PY'
from app.database import SessionLocal
from app.models import PushDevice
from app.services import push as p

db = SessionLocal()
devs = db.query(PushDevice).filter(PushDevice.is_active.is_(True)).all()
print("活动设备:", [(d.id, d.platform, d.env) for d in devs])
for d in devs:
    if d.platform == "ios":
        r = p._send_apns(d.token, "测试推送", "Vloglish 测试通知", {"type": "test"}, d.env)
    else:
        r = p._send_fcm(d.token, "测试推送", "Vloglish 测试通知", {"type": "test"})
    print("设备", d.id, d.platform, "->", r)
db.close()
PY