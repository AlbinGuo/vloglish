#!/usr/bin/env bash
# 配置 Docker 镜像加速（国内阿里云 ECS 拉 docker.io 超时时必做）
# 用法：
#   sudo bash deploy/configure-docker-mirror.sh
#   sudo ALIYUN_MIRROR_URL=https://xxxx.mirror.aliyuncs.com bash deploy/configure-docker-mirror.sh
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "请使用 root 或 sudo 运行"
  exit 1
fi

mkdir -p /etc/docker

# 优先使用阿里云个人加速器（控制台 → 容器镜像服务 → 镜像工具 → 镜像加速器）
# https://cr.console.aliyun.com/cn-hangzhou/instances/mirrors
ALIYUN_MIRROR="${ALIYUN_MIRROR_URL:-}"

if [ -n "$ALIYUN_MIRROR" ]; then
  cat > /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": [
    "${ALIYUN_MIRROR}",
    "https://docker.m.daocloud.io"
  ],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  }
}
EOF
else
  cat > /etc/docker/daemon.json <<'EOF'
{
  "registry-mirrors": [
    "https://docker.m.daocloud.io",
    "https://docker.1ms.run"
  ],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  }
}
EOF
  echo "提示：建议在阿里云控制台获取专属加速器地址后重跑："
  echo "  ALIYUN_MIRROR_URL=https://xxxx.mirror.aliyuncs.com bash deploy/configure-docker-mirror.sh"
fi

systemctl daemon-reload
systemctl restart docker

echo "==> 镜像加速已配置，当前 mirrors："
docker info 2>/dev/null | grep -A5 'Registry Mirrors' || true

echo "==> 测试拉取 postgres:16-alpine ..."
if docker pull postgres:16-alpine; then
  echo "镜像拉取成功，可继续 bash deploy/deploy.sh"
else
  echo ""
  echo "仍无法拉取，请到阿里云控制台复制专属加速器地址后执行："
  echo "  ALIYUN_MIRROR_URL=https://你的ID.mirror.aliyuncs.com bash deploy/configure-docker-mirror.sh"
  exit 1
fi
