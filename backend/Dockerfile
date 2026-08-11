FROM python:3.13-slim

WORKDIR /app/backend

# 国内构建：apt / pip 使用阿里云镜像
RUN sed -i 's|deb.debian.org|mirrors.aliyun.com|g; s|security.debian.org|mirrors.aliyun.com|g' /etc/apt/sources.list.d/debian.sources 2>/dev/null \
    || sed -i 's|deb.debian.org|mirrors.aliyun.com|g; s|security.debian.org|mirrors.aliyun.com|g' /etc/apt/sources.list 2>/dev/null \
    || true

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl ffmpeg \
    && rm -rf /var/lib/apt/lists/*

COPY backend/requirements.txt .

ARG PIP_INDEX_URL=https://mirrors.aliyun.com/pypi/simple/
RUN pip install --no-cache-dir -r requirements.txt yt-dlp \
    -i "${PIP_INDEX_URL}" --trusted-host mirrors.aliyun.com

COPY backend/app ./app
COPY backend/seed.py .
COPY backend/scripts ./scripts
COPY analysis /app/analysis

RUN mkdir -p data \
    && curl -fsSL -o data/ip2region_v4.xdb \
      https://oss.sxakgs.com/file/ip2region_v4.xdb

RUN mkdir -p data/media

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    YT_DLP_BIN=/usr/local/bin/yt-dlp \
    FFMPEG_DIR=/usr/bin

COPY backend/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=120s --retries=3 \
    CMD curl -f http://localhost:8000/api/health || exit 1

ENTRYPOINT ["docker-entrypoint.sh"]
