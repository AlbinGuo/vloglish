# 从 teco-lab.com /english 拉取剧集

## 推荐：管理端一键导入

1. 在 **已登录** 的 https://www.teco-lab.com/english 打开开发者工具 → Console，执行：

```javascript
copy(JSON.stringify({
  access: localStorage.getItem('access_token'),
  refresh: localStorage.getItem('refresh_token'),
  device_id: localStorage.getItem('device_id'),
}, null, 2))
```

2. 保存为 `backend/data/teco_session.json`

3. 配置七牛 `QINIU_*` 与 ffmpeg（`FFMPEG_DIR` 或 `VLOGISH_TOOLS_DIR`）

4. 管理后台 → **导入导出** → **从 teco-lab.com 导入**
   - 默认导入第 **150–190** 期
   - 自动：去左上角原站水印、加 **vloglish** 水印、从视频截帧生成**独立封面**（不用 teco 原图）

## 品牌化说明

| 项目 | 行为 |
|------|------|
| 视频 | ffmpeg `delogo` 去除左上角区域 + `drawtext` 加 vloglish |
| 封面 | 从视频 10%–45% 处截帧（每期偏移不同）+ vloglish / Ep.N / 标题条 |
| 字幕 | 直接使用 teco detail API（中英 + IPA），无需 DeepSeek |

可在 `backend/.env` 调整：

```
VLOGISH_DELOGO_X=0
VLOGISH_DELOGO_Y=0
VLOGISH_DELOGO_W=150
VLOGISH_DELOGO_H=52
VLOGISH_WATERMARK_TEXT=vloglish
```

## CLI（可选）

```bash
cd backend
python scripts/import_english_episodes.py 5
```

脚本仍可用；管理端导入会额外做品牌化与自生成封面。

## 合规提示

对外商用请确保你对素材、字幕与衍生处理拥有合法授权；本工具仅提供技术导入能力。
