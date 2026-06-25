#!/bin/sh
set -e

cd /app/backend

python <<'PY'
from app.database import SessionLocal
from app.models import Episode

db = SessionLocal()
try:
    if db.query(Episode).count() == 0:
        raise SystemExit(1)
except Exception:
    raise SystemExit(1)
finally:
    db.close()
PY
if [ $? -ne 0 ]; then
  echo "[entrypoint] Empty database, running seed.py..."
  python seed.py
fi

exec uvicorn app.main:app --host 0.0.0.0 --port 8000
