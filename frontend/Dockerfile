FROM node:22-alpine AS build

WORKDIR /app

# 国内构建默认使用 npmmirror，海外可通过 --build-arg NPM_REGISTRY=https://registry.npmjs.org 覆盖
ARG NPM_REGISTRY=https://registry.npmmirror.com

COPY frontend/package.json frontend/package-lock.json* ./
RUN npm config set registry "${NPM_REGISTRY}" \
    && npm config set fetch-timeout 300000 \
    && npm config set fetch-retries 5 \
    && npm install --no-audit --no-fund

COPY frontend/ .
RUN npm run build:docker

FROM nginx:1.27-alpine

COPY frontend/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget -qO- http://127.0.0.1/ >/dev/null || exit 1
