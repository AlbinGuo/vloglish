#!/bin/sh
set -e

cd /app/backend

if [ ! -f data/teco.db ]; then
  echo "[entrypoint] Database not found, running seed.py..."
  python seed.py
fi

exec uvicorn app.main:app --host 0.0.0.0 --port 8000
