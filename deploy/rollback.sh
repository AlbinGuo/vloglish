#!/usr/bin/env bash
# 回滚到指定构建号：bash deploy/rollback.sh 42
set -euo pipefail

TAG="${1:-}"
if [ -z "$TAG" ]; then
  echo "用法: bash deploy/rollback.sh <IMAGE_TAG>"
  echo "示例: bash deploy/rollback.sh 15"
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

export IMAGE_TAG="$TAG"
exec bash deploy/update.sh
