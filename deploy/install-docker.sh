#!/usr/bin/env bash
# 单独安装 Docker（阿里云镜像，国内 ECS 可用）
# 用法：sudo bash deploy/install-docker.sh
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "请使用 root 或 sudo 运行"
  exit 1
fi

if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  echo "Docker 已就绪：$(docker --version)"
  docker compose version
  exit 0
fi

# 复用 setup-server.sh 中的安装逻辑（内联，避免 source 复杂）
if [ -f /etc/os-release ]; then
  # shellcheck disable=SC1091
  . /etc/os-release
else
  echo "无法识别操作系统"
  exit 1
fi

echo "==> 通过阿里云镜像安装 Docker (${ID})..."

case "${ID:-}" in
  ubuntu|debian)
    apt-get update -qq
    apt-get install -y -qq ca-certificates curl gnupg lsb-release
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL "https://mirrors.aliyun.com/docker-ce/linux/${ID}/gpg" \
      | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.aliyun.com/docker-ce/linux/${ID} ${VERSION_CODENAME} stable" \
      > /etc/apt/sources.list.d/docker.list
    apt-get update -qq
    apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    ;;
  centos|rhel|rocky|almalinux|alinux|anolis)
    if command -v dnf >/dev/null 2>&1; then PKG_MGR=dnf; else PKG_MGR=yum; fi
    $PKG_MGR install -y yum-utils
    $PKG_MGR-config-manager --add-repo "https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo"
    $PKG_MGR install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    ;;
  *)
    echo "不支持的系统: ${ID}"
    exit 1
    ;;
esac

systemctl enable docker
systemctl start docker
docker --version
docker compose version
echo "安装完成"
