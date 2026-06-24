# 从 teco-lab.com /english 拉取剧集

脚本：`backend/scripts/import_english_episodes.py`

## 1. 导出浏览器登录态（推荐）

在 **已登录** 的 https://www.teco-lab.com/english 页面打开开发者工具 → Console，执行：

```javascript
copy(JSON.stringify({
  access: localStorage.getItem('access_token'),
  refresh: localStorage.getItem('refresh_token'),
  device_id: localStorage.getItem('device_id'),
}, null, 2))
```

将复制的内容保存为：

```
backend/data/teco_session.json
```

## 2. 运行导入

```bash
cd backend
.venv\Scripts\activate
python scripts/import_english_episodes.py 5
```

流程：

1. 从 `/api/episode-list/` 取 `/english` 目录前 5 期（**不走 /demo**）
2. 用会员 token 拉取 `/api/episode/{video_id}/detail/`（含完整字幕）
3. 下载封面、视频、音频
4. 上传七牛（需配置 `QINIU_*`）
5. 写入本地 SQLite，`status=published`

## 可选参数

| 参数 | 说明 |
|------|------|
| `5` | 导入条数，默认 5 |
| `--list-only` | 只拉列表，不下载媒体 |
| `--token eyJ...` | 直接传 access token |
| `--session path/to.json` | 指定 session 文件 |

或在 `backend/.env` 中设置：

```
TECO_ACCESS_TOKEN=...
TECO_DEVICE_ID=...   # 与浏览器 localStorage.device_id 一致
```

## 验证

重启 backend + frontend，用 **会员账号** 登录本地站，打开 `/english` 应能看到新导入的 5 期，进入学习页字幕应随视频滚动。
