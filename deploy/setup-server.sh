#!/usr/bin/env bash
# 阿里云服务器首次初始化（以 root 登录后执行一次）
# 用法：bash deploy/setup-server.sh
set -euo pipefail

APP_DIR="${APP_DIR:-/opt/vlogish}"
REPO_URL="${REPO_URL:-https://gitee.com/guonan01/vlogish.git}"
BRANCH="${BRANCH:-master}"

install_docker_via_aliyun() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "错误：安装 Docker 需要 root 权限，请使用 sudo 或以 root 运行"
    exit 1
  fi

  if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    echo "Docker 已安装：$(docker --version)"
    return 0
  fi

  echo "==> 通过阿里云镜像安装 Docker..."

  if [ -f /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
  else
    echo "错误：无法识别操作系统"
    exit 1
  fi

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
      if command -v dnf >/dev/null 2>&1; then
        PKG_MGR=dnf
      else
        PKG_MGR=yum
      fi
      $PKG_MGR install -y yum-utils
      $PKG_MGR-config-manager --add-repo "https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo"
      $PKG_MGR install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
      ;;

    *)
      echo "未识别的系统 ${ID}，尝试安装 docker.io..."
      if command -v apt-get >/dev/null 2>&1; then
        apt-get update -qq
        apt-get install -y -qq docker.io docker-compose-plugin || apt-get install -y -qq docker.io
      elif command -v dnf >/dev/null 2>&1; then
        dnf install -y docker docker-compose-plugin || dnf install -y docker
      elif command -v yum >/dev/null 2>&1; then
        yum install -y docker docker-compose-plugin || yum install -y docker
      else
        echo "错误：无法自动安装 Docker，请手动安装后重试"
        exit 1
      fi
      ;;
  esac

  systemctl enable docker
  systemctl start docker
  echo "Docker 安装完成：$(docker --version)"
}

install_docker_via_aliyun

if ! docker compose version >/dev/null 2>&1; then
  echo "错误：未找到 docker compose 插件"
  echo "可尝试：apt-get install -y docker-compose-plugin"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ "$(id -u)" -eq 0 ]; then
  bash "$SCRIPT_DIR/configure-docker-mirror.sh" || true
fi

echo "==> 准备目录 ${APP_DIR}..."
mkdir -p "$APP_DIR"
cd "$APP_DIR"

if [ ! -d .git ]; then
  echo "==> 克隆代码库..."
  git clone -b "$BRANCH" "$REPO_URL" .
else
  echo "==> 更新代码..."
  git fetch origin
  git checkout "$BRANCH"
  git pull origin "$BRANCH"
fi

if [ ! -f .env.prod ]; then
  cp .env.prod.example .env.prod
  echo ""
  echo "已创建 .env.prod，请编辑以下项后执行 bash deploy/update.sh："
  echo "  - POSTGRES_PASSWORD / DATABASE_URL"
  echo "  - JWT_SECRET / ADMIN_PASSWORD"
  echo "  - ACR_REGISTRY / ACR_USERNAME / ACR_PASSWORD"
  echo "  - 七牛、DeepSeek 等"
  exit 0
fi

chmod +x deploy/update.sh deploy/deploy.sh deploy/rollback.sh 2>/dev/null || true

echo ""
echo "初始化完成。下一步："
echo "  1. 编辑 ${APP_DIR}/.env.prod"
echo "  2. 首次部署：bash deploy/update.sh"
echo "  3. HTTPS（可选）：docker compose -f docker-compose.prod.yml --env-file .env.prod --profile https up -d"
