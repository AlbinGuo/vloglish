# 首页 API 字段映射表

> 对照 [teco-lab.com/english](https://www.teco-lab.com/english) 首页 UI 与本地复刻实现  
> 后端基址：`/api/`（FastAPI）

---

## 1. 目录列表 `GET /api/episode-list/`

### 请求参数

| 参数 | 原版 teco-lab | 本地实现 | 说明 |
|------|--------------|----------|------|
| `page` | ✅ | ✅ | 页码，从 1 开始 |
| `page_size` | ✅（默认 50） | ✅（默认 50，最大 50） | 每页条数 |
| `ordering` | ✅ | ✅ | `index` 期数倒序 / `-index` 正序 / `stars` / `-stars` |
| `stars` | ✅ | ✅ | 难度 1–5 |
| `accent` | ✅ | ✅ | 作者口音，如「美国」 |
| `gender` | ✅ | ✅ | `m` / `f` |
| `tag` | ✅（单选） | ⚠️ 兼容 | 单标签 ID，建议用 `tags` |
| `tags` | ✅（多选） | ✅ | 逗号分隔标签 ID，如 `30,57` |
| `date` | ✅ | ✅ | `YYYY-MM-DD`，按 `created_at` 日期筛选 |
| `status` | ✅（学习状态） | ⚠️ 部分 | `all` / `learned` / `unlearned` / `favorite`；**登录进度未接入前** learned/favorite 恒为空 |

### 响应结构

```json
{
  "count": 190,
  "results": [ /* EpisodeSummary[] */ ]
}
```

### EpisodeSummary 字段映射

| 字段 | 原版 | 本地 | 首页 UI 用途 |
|------|------|------|-------------|
| `index` | ✅ | ✅ | 卡片「第 N 期」 |
| `video_id` | ✅ | ✅ | 跳转 `/english/episode/:video_id` |
| `short_title` | ✅ | ✅ | 卡片标题 |
| `summary` | ✅ | ✅ | 卡片摘要（2–3 行） |
| `stars` | ✅ | ✅ | 难度星级 |
| `voca_size` | ✅ | ✅ | 底部「N 词」 |
| `subtitle_count` | ✅ | ✅ | 底部「N 句」 |
| `clip_length` | ✅ | ✅ | 封面右下角时长（秒） |
| `cover` | ✅ | ✅ | 封面图 URL |
| `created_at` | ✅ ISO8601 | ✅ ISO8601 | 底部发布日期 |
| `author.name` | ✅ | ✅ | 封面左下 `@作者` |
| `author.gender` | ✅ | ✅ | 筛选（不展示） |
| `author.nationality` | ✅ | ✅ | 可选展示国旗 |
| `author.accent` | ✅ | ✅ | 「口音: 美国」 |
| `tags[].id` | ✅ | ✅ | 筛选 Pill |
| `tags[].name` | ✅ | ✅ | 卡片标签 Pill |
| `is_learned` | ✅ | ⚠️ 恒 `false` | 统计卡片「已学习」 |
| `is_favorite` | ✅ | ⚠️ 恒 `false` | 统计卡片「已收藏」、卡片星标 |
| `remark` | ✅ | ✅ | 暂未在首页展示 |

---

## 2. 元数据接口

### `GET /api/episode-tags/`

| 字段 | 说明 |
|------|------|
| `id` | 标签 ID |
| `name` | 标签名（生活、旅行…） |

**UI**：左侧筛选区主题 Pill 多选 → 点「应用筛选」提交 `tags=1,30,57`

### `GET /api/author-accents/`

| 字段 | 说明 |
|------|------|
| `accent` | 口音字符串 |

**UI**：左侧口音下拉

---

## 3. 统计卡片（首页左侧 4 格）

| 卡片 | 数据来源 | 本地现状 |
|------|----------|----------|
| 当前期数 | `episode-list` 的 `count`（无 status） | ✅ |
| 已学习 | `status=learned` 的 `count` | ⚠️ 需用户打卡 API |
| 未学习 | 总数 − 已学习 | ⚠️ 暂等于总数 |
| 已收藏 | `status=favorite` 的 `count` | ⚠️ 需收藏 API |

**原版关联 API（未接入）**：

- `GET /api/user/episodes-data/` — 用户汇总统计
- `GET /api/episodes-learned/` — 已学习列表
- `GET /api/episodes-favorites/` — 收藏剧集

---

## 4. 日历筛选

| UI 行为 | API |
|---------|-----|
| 选某一天 | `date=2025-08-29` |
| 取消选择 | 不传 `date` |
| 月份切换 | 纯前端，不请求 |

**字段**：Episode.`created_at`（入库/发布时间）

---

## 5. 卡片收藏星标

| 原版 | 本地 |
|------|------|
| `POST/DELETE /api/episodes/{video_id}/favorite/` | 仅前端 UI 切换，未持久化 |

接入后需同步 `is_favorite` 与统计卡片计数。

---

## 6. 首页 vs 详情 字段差异

| 字段 | 列表 `EpisodeSummary` | 详情 `EpisodeDetail` |
|------|----------------------|---------------------|
| `index` | ✅ | ✅ |
| `media` | ❌ | ✅ video/audio/thumbnail |
| `subtitles` | ❌ | ✅ 完整字幕数组 |
| `original_video_url` | ❌ | ✅ YouTube 原链 |

---

## 7. 前端 Store 映射

| Store 字段 | API 参数 |
|------------|----------|
| `draft.*` | 侧边栏编辑中的草稿（未提交） |
| `applied.*` | 实际请求参数 |
| `applied.tagIds` → `tags` | 逗号拼接 |
| `applied.status` → `status` | 统计卡片快捷筛选 |
| `applied.date` → `date` | 日历选日 |
| `applyFilters()` | 草稿 → 已应用 → `loadEpisodes` |

---

## 8. 待接入（Phase 3 用户体系）

按优先级：

1. `POST /api/episodes/{id}/learned/` → `is_learned`、已学习统计
2. `POST/DELETE .../favorite/` → 卡片星标、已收藏统计
3. `GET /api/user/episodes-data/` → 一次请求拿齐 4 格统计

参考完整 API 清单见 [`docs/ANALYSIS.md`](./ANALYSIS.md) 第 5 节。
