"""本地开发切库配置（复制为 db_switch.py 后修改，勿提交 Git）。

切库：只改 ACTIVE_DB 这一行，然后重启 uvicorn。
"""

# "local" = 本机开发库 | "remote" = 生产库（抓取 TikTok/YouTube 时用）
ACTIVE_DB = "local"

# 密码含 # $ ! 等须 URL 编码，例：G7#kLp$Qw9!zR → G7%23kLp%24Qw9%21zR
DATABASE_URLS = {
    "local": "postgresql+psycopg://postgres:your_password@localhost:5432/postgres",
  # remote 推荐经 SSH 隧道：ssh -L 15432:127.0.0.1:5432 root@8.137.196.234
    "remote": "postgresql+psycopg://postgres:your_password@127.0.0.1:15432/postgres",
}
