FROM python:3.13-slim

WORKDIR /app/backend

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl ffmpeg \
    && rm -rf /var/lib/apt/lists/*

COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt yt-dlp

COPY backend/app ./app
COPY backend/seed.py .
COPY analysis /app/analysis

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
