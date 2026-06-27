# 开发环境数据库切换（代码切库）

本地可访问 TikTok/YouTube，生产 ECS 不能。在本机 backend 抓取后数据写入七牛，剧集元数据可直写生产库。

## 一次性配置

```powershell
cd backend
Copy-Item db_switch.example.py db_switch.py
```

编辑 `db_switch.py`，填好两个 `DATABASE_URL`（密码特殊字符须 URL 编码）。

## 切库（只改一行）

打开 `backend/db_switch.py`：

```python
ACTIVE_DB = "local"    # 日常开发
# ACTIVE_DB = "remote"  # 抓取写入生产库
```

改完后**重启 uvicorn**。启动日志示例：

```text
[vloglish] database → local (localhost:5432)
[vloglish] database → remote/production (127.0.0.1:15432)
```

## 抓取流程

```powershell
# 1. SSH 隧道（另开窗口，保持不关）
ssh -L 15432:127.0.0.1:5432 root@8.137.196.234

# 2. db_switch.py 里 ACTIVE_DB = "remote"，重启 backend

# 3. 浏览器清 admin token 后重新登录 /gnadmin/login（生产账号）

# 4. 抓取完成后改回 ACTIVE_DB = "local"
```

## 注意

1. `db_switch.py` 已 gitignore，**勿提交**（含数据库密码）。
2. Docker 生产环境没有 `db_switch.py`，仍用 `.env.prod` 的 `DATABASE_URL`。
3. `remote` 写的是**生产数据**，用完立刻改回 `local`。
4. 切库后需**重新登录**管理后台（清 `admin_access_token` / `admin_refresh_token`）。
