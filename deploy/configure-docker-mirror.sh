#!/usr/bin/env bash
# 配置 Docker 镜像加速（国内 ECS 拉 docker.io 超时时必做）
# 用法：
#   sudo bash deploy/configure-docker-mirror.sh
#   sudo DOCKER_MIRROR_URL=https://docker.1ms.run bash deploy/configure-docker-mirror.sh
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "请使用 root 或 sudo 运行"
  exit 1
fi

mkdir -p /etc/docker

# 默认使用 docker.1ms.run；可通过环境变量覆盖
# DOCKER_MIRROR_URL 或 ALIYUN_MIRROR_URL（兼容旧用法）
PRIMARY_MIRROR="${DOCKER_MIRROR_URL:-${ALIYUN_MIRROR_URL:-https://docker.1ms.run}}"

cat > /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": [
    "${PRIMARY_MIRROR}",
    "https://docker.m.daocloud.io"
  ],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  }
}
EOF

systemctl daemon-reload
systemctl restart docker

echo "==> 镜像加速已配置"
echo "    主镜像：${PRIMARY_MIRROR}"
docker info 2>/dev/null | grep -A5 'Registry Mirrors' || true

echo "==> 测试拉取 postgres:16-alpine ..."
if docker pull postgres:16-alpine; then
  echo "镜像拉取成功，可继续 bash deploy/deploy.sh"
else
  echo ""
  echo "仍无法拉取，请检查："
  echo "  1. 镜像地址是否可访问：curl -I ${PRIMARY_MIRROR}"
  echo "  2. 更换其他加速器后重试："
  echo "     DOCKER_MIRROR_URL=https://你的加速器地址 bash deploy/configure-docker-mirror.sh"
  exit 1
fi
