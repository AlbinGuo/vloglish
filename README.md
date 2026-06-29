# Vloglish

**Real vlogs · Real English** — 真实 YouTube Vlog 语料 + 沉浸式精听/跟读学习平台。

## 文档

- [产品与技术指南](./docs/ANALYSIS.md)
- [从本地开发到上线部署](./deploy/DEPLOY_GUIDE.md)

## 快速开始

### 1. 后端（FastAPI + SQLite）

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate          # Windows
pip install -r requirements.txt
python seed.py                  # 导入样本数据
python seed.py --fetch          # 可选：从参考站点下载其余剧集详情
uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```

或使用 `scripts\run-backend.bat`

### 2. 前端

```bash
cd frontend
npm install
npm run dev
```

API 默认代理到 `http://127.0.0.1:8000`（可在 `VITE_API_PROXY` 环境变量中修改）。

## 功能进度

### Phase 1 — 播放器增强 ✅
- 单句循环（次数 / 无限 / 句末暂停）
- A-B 区间循环
- 键盘快捷键（空格、方向键、L/R、[/]、?）

### Phase 2 — FastAPI 后端 ✅
- Demo 体验码验证（ALICE）
- 剧集列表 / 详情 / 词条 API
- SQLite 种子数据

### Phase 3 — 首页目录 ✅
- `/english` 语料目录
- 难度 / 口音 / 性别 / 主题 / 排序筛选
- 分页

### 管理后台 `/gnadmin` ✅
- 管理员登录、仪表盘、用户、激活码
- 剧集与字幕管理、批量导入导出、体验码配置

## 路由

| 路径 | 说明 |
|------|------|
| `/english` | 语料目录 |
| `/english/episode/:id` | 学习页 |
| `/demo` | 体验码 + 试用列表 |
| `/english/demo/:id` | 试用学习页 |
| `/gnadmin` | 管理后台 |

## 体验码

默认 `ALICE`
