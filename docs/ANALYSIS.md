# TEco Lab 全面分析与复刻指南

> 基于体验码 `ALICE` 实测 API + 前端逆向分析  
> 目标站点：https://www.teco-lab.com

---

## 1. 产品定位

**TEco Lab（语库）** = 真实 YouTube Vlog 语料 + 沉浸式精听/跟读/词卡工作台

| 维度 | 说明 |
|------|------|
| 目标用户 | 想练真实口语/听力的自学者、雅思考生、商务英语用户 |
| 内容来源 | YouTube Vlog 剪辑片段（非整片搬运，有二次加工） |
| 商业模式 | 一次性付费永久会员；抖音店铺购买激活码 |
| 试用机制 | 体验码 → 5 期 Demo 内容 → 引导付费 |

---

## 2. 技术栈（原版）

| 层 | 技术 |
|----|------|
| 前端 | Vue 3 + Vite + Vue Router 4.5 + Pinia + Tailwind CSS |
| HTTP | Axios（Cookie 会话 + Bearer Token） |
| 设备指纹 | FingerprintJS → `localStorage.device_id` |
| 请求签名 | `X-Device-Id` + `X-Timestamp` + `X-Nonce` +（登录后）`X-Signature` |
| 服务器 | Nginx 反向代理 |
| 媒体存储 | 阿里云 OSS（`media.teco-lab.com`） |
| 发音音频 | 独立 OSS（`pronunciations.oss-cn-hangzhou.aliyuncs.com`） |
| 后端风格 | RESTful `/api/*`，疑似 Django REST Framework |

---

## 3. 路由架构

```
/                          → redirect /english
/demo                      → 体验码验证 + 试用列表
/english                   → 语料目录（需登录）
/english/episode/:video_id → 正式学习页（需登录）
/english/demo/:video_id      → 试用学习页（需体验码）  ← 你之前的链接
/english/search            → 字幕全文搜索
/english/favorite-entries  → 收藏词条
/english/learningtechniques→ 学习方法
/english/myprofile         → 个人中心
/login /signup /activate   → 账号体系
/a/:code                   → 推广落地页
/index                     → 营销/支付页
```

**路由守卫逻辑：**
- `requiresDemoCode`：未验证 → 重定向 `/demo`
- `requiresAuth`：无 `access_token` → 重定向 `/login?next=...`

---

## 4. 体验码 ALICE 实测结果

### 4.1 验证

```http
POST /api/demo/verify-code/
Content-Type: application/json
X-Device-Id: {uuid}
X-Timestamp: {unix}
X-Nonce: {uuid}

{"code": "ALICE", "device_id": "{uuid}"}
```

响应：
```json
{"success": true, "message": "体验码验证成功", "affiliate_code": null}
```

前端写入 `localStorage`：
- `demo_code` = 体验码
- `demo_code_verified` = `"true"`

### 4.2 试用剧集（5 期）

| video_id | 标题 | 难度 | 时长 | 作者 |
|----------|------|------|------|------|
| 074upYDO5FBjKTE | 谈财务自由的真相 | ★★★★ | 10:11 | Tyson Liberto 🇺🇸 |
| 071LsfyHOZD0Vr7 | 岘港咖啡馆漫游学英语 | ★ | 13:04 | English by Jay 🇬🇧 |
| 066p1Gu2ETQwliG | 墨西哥城旅行学英语 | ★★ | 12:10 | Volka English 🇺🇸 |
| 048daaeM6zLVq8v | 探秘全球最贵超市 Erewhon | ★★★★★ | 4:33 | Taylor Bell 🇺🇸 |
| 015TVreRGVVMqPl | Costco 超市采购 | ★★★ | 1:21 | Noah Anderson 🇺🇸 |

```http
GET /api/demo/get-episodes/
```

---

## 5. 完整 API 清单

### 5.1 Demo / 认证

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/demo/verify-code/` | 验证体验码 |
| GET | `/api/demo/get-episodes/` | 试用 5 期列表 |
| POST | `/api/token/refresh/` | 刷新 JWT（需 device_id） |

### 5.2 剧集

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/episode-list/` | 目录列表（分页/筛选） |
| GET | `/api/episode/{video_id}/detail/` | 单集详情 + 字幕 |
| GET | `/api/episode/{video_id}/entries/` | 词表（需登录，Demo 404） |
| GET | `/api/episodes/` | 用户剧集状态 |
| POST | `/api/episodes/{video_id}/learned/` | 打卡 |
| POST/DELETE | `/api/episodes/{video_id}/favorite/` | 收藏剧集 |
| GET | `/api/episodes-learned/` | 已学习记录 |
| GET | `/api/episodes-favorites/` | 收藏剧集 |
| GET | `/api/user/episodes-data/` | 用户统计 |
| GET | `/api/user/last-learned-episode/` | 上次学习 |

### 5.3 词条 / 字幕

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/entries/?v={video_id}` | 本集全部词条索引 |
| GET | `/api/entry-detail/?entry_id={id}` | 词条详情 |
| GET | `/api/entry/{id}/detail/` | 词条完整详情 |
| GET | `/api/lookup/?id={id}&type={1\|2}` | 点击字幕查词（tid/pid） |
| GET | `/api/entry-list/?video_id=` | 词条列表 |
| GET | `/api/entry-ocurrences/?id=&page=` | 词条出现位置 |
| GET | `/api/one-entry/` | 随机词条 |
| POST/PUT/DELETE | `/api/entries/favorites/*` | 词条收藏 |
| GET/POST/PUT/DELETE | `/api/collections/` | 收藏夹 |
| GET/POST/PUT/DELETE | `/api/entry-tags/` | 标签 |

### 5.4 学习交互

| 方法 | 路径 | 说明 |
|------|------|------|
| GET/POST | `/api/dictation-history/` | 听写记录 |
| GET/POST/DELETE | `/api/subtitle-favorites/` | 字幕收藏 |
| GET/POST/PUT/DELETE | `/api/subtitle-notes/` | 字幕笔记 |
| GET/POST/DELETE | `/api/user-recordings/` | 跟读录音 |
| GET | `/api/subtitles/search/?q=` | 字幕搜索 |

### 5.5 元数据

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/episode-tags/` | 主题标签 |
| GET | `/api/author-accents/` | 口音筛选 |

---

## 6. 核心数据模型

### 6.1 Episode（剧集）

```typescript
interface Episode {
  index: number;
  video_id: string;           // 15 位 opaque ID，如 074upYDO5FBjKTE
  short_title: string;
  summary: string;
  stars: 1 | 2 | 3 | 4 | 5;  // 难度
  voca_size: number;          // 词汇量
  subtitle_count: number;
  clip_length: number;        // 秒
  author: Author;
  tags: Tag[];
  media: {
    video_url: string;        // OSS 签名 URL，24h 过期
    audio_url: string;
    thumbnail_url: string;
  };
  original_video_url: string; // YouTube 原链
  subtitles: Subtitle[];
}
```

### 6.2 Subtitle（字幕）

```typescript
interface Subtitle {
  id: number;
  index: number;              // 句序号
  start: number;              // 秒，浮点
  end: number;
  english: string;
  chinese: string;
  ipa: string;                // 整句音标
  english_html: string;       // 带标注的 HTML
}
```

**english_html 标注规则：**
- `<span tid="51809">` → 单词词条 ID，点击查 `type=1`
- `<span pid="283">` → 短语词条 ID，点击查 `type=2`
- `class="highlight highlight-a"` → 重点词（a/i/d/l/c 等子类型）
- 挖空模式：给 `.highlight` 加 `text-transparent`

### 6.3 Entry（词条）

```typescript
interface Entry {
  id: number;
  headword: string;
  category: string;           // 单词|习语|俚语|短语动词|惯用表达|语法...
  pronunciations: {
    ipa: string;
    audio_url: string;
    accent_type: 'US' | 'UK';
    is_primary: boolean;
  }[];
  definitions: {
    pos: string;
    definition_en: string;
    definition_cn: string;
    usage_pattern: string;
    examples: { example_en: string; example_cn: string }[];
  }[];
  exam_tags: string[];        // 四级/雅思/托福...
  favorite: FavoriteMeta | null;
}
```

---

## 7. 学习页功能模块（Page 组件，288 个 UI 字符串）

### 7.1 播放器
- 视频/音频双轨，可隐藏视频
- 无级倍速（0.5x–2x+）
- 全屏、区间循环（A-B loop）
- 单句循环 + 次数/间隔设置
- 单句暂停、循环后暂停
- 下载音频

### 7.2 字幕系统
- 模式：英语 / 中文 / 双语 / 仅中文 / 动态字幕 / 挖空字幕
- 字号调节、音标显示
- 键盘快捷键（含空格键）
- 点击词/token → 词卡弹层
- 复制当前字幕

### 7.3 精听 & 听写
- 听写模式（字幕输入）
- 听写历史持久化（`/api/dictation-history/`）
- 挖空练习（隐藏 highlight 词）

### 7.4 跟读 & 录音
- 麦克风录音、多录音管理
- 播放对比、上传云端
- 最大时长/数量限制

### 7.5 词卡 & 收藏
- 词卡详情（释义/搭配/例句/发音）
- 收藏夹 + 标签体系
- 字幕收藏、字幕笔记
- 词条在其他字幕中的出现频率

### 7.6 学习记录
- 打卡（1–5 难度自评 + 笔记）
- 打印预览
- 上次学习进度记忆

---

## 8. 首页目录（HomePage）

- 卡片：封面、标题、作者、难度星、时长
- 筛选：口音、性别、难度、主题标签
- 状态：已学习 / 已打卡 / 已收藏
- 排序：正序/倒序、分页加载

---

## 9. 复刻实施路线图

### Phase 1 — MVP（当前骨架）
- [x] 项目初始化 Vue3 + TS + Tailwind
- [ ] 体验码验证 + Demo 列表
- [ ] 学习页：视频播放 + 字幕同步 + 点击查词
- [ ] 响应式布局（桌面顶栏 / 移动底栏）

### Phase 2 — 核心学习
- [ ] 倍速 / 单句循环 / A-B 循环
- [ ] 字幕模式切换（英/中/双语/挖空）
- [ ] 词卡弹层 + 发音播放
- [ ] 键盘快捷键

### Phase 3 — 用户体系
- [ ] 注册/登录/JWT
- [ ] 打卡 / 收藏 / 学习进度
- [ ] 个人中心

### Phase 4 — 高级功能
- [ ] 听写 + 历史
- [ ] 跟读录音 + 上传
- [ ] 字幕搜索
- [ ] 打印

### Phase 5 — 商业化
- [ ] 支付（微信/支付宝）
- [ ] 激活码
- [ ] 推广链接 `/a/:code`

---

## 10. 后端建议架构（复刻用）

```
backend/
├── apps/
│   ├── episodes/      # 剧集、字幕、媒体
│   ├── entries/       # 词条、释义、发音
│   ├── users/         # 认证、进度、收藏
│   ├── demo/          # 体验码
│   └── learning/      # 听写、录音、笔记
├── media/             # OSS 或本地 MinIO
└── api/               # DRF ViewSets
```

**关键实现点：**
1. 字幕 `english_html` 需在入库时预生成 token 标注
2. OSS 签名 URL 需后端动态签发（24h 过期）
3. 请求签名：`HMAC(access_token, METHOD+PATH+TIMESTAMP+BODY)`
4. FingerprintJS 设备 ID 用于防刷

---

## 11. 法律与合规提醒

复刻**产品形态**用于学习/自建平台时请注意：
- 不要直接搬运 TEco Lab 的视频、字幕、词库内容（有版权）
- 需使用自有或授权语料
- 品牌名/Logo 不要侵权
- 支付需合规资质

---

## 12. 参考样本数据

完整 API 响应见：`analysis/api-responses.json`（体验码 ALICE 实测）
