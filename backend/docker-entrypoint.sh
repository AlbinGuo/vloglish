#!/bin/sh
set -e

cd /app/backend

# 用 if ! python 包裹，避免空库时 exit 1 触发 set -e 导致容器直接退出
if ! python <<'PY'
from app.database import SessionLocal
from app.models import Episode

db = SessionLocal()
try:
    if db.query(Episode).count() == 0:
        raise SystemExit(1)
finally:
    db.close()
PY
then
  echo "[entrypoint] Empty database, running seed.py..."
  python seed.py
fi

exec uvicorn app.main:app --host 0.0.0.0 --port 8000
