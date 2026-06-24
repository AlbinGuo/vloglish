import logging
import os
import smtplib
from email.message import EmailMessage

logger = logging.getLogger(__name__)


def _frontend_url() -> str:
    return os.getenv("FRONTEND_URL", "http://127.0.0.1:5173").rstrip("/")


def build_password_reset_url(token: str) -> str:
    return f"{_frontend_url()}/reset-password?token={token}"


def smtp_configured() -> bool:
    return bool(os.getenv("SMTP_HOST") and os.getenv("SMTP_FROM"))


def send_password_reset_email(to_email: str, reset_url: str) -> bool:
    host = os.getenv("SMTP_HOST")
    from_addr = os.getenv("SMTP_FROM")
    if not host or not from_addr:
        logger.info("Password reset link for %s: %s", to_email, reset_url)
        return False

    port = int(os.getenv("SMTP_PORT", "587"))
    username = os.getenv("SMTP_USER", from_addr)
    password = os.getenv("SMTP_PASSWORD", "")
    use_tls = os.getenv("SMTP_USE_TLS", "true").lower() in {"1", "true", "yes"}

    msg = EmailMessage()
    msg["Subject"] = "Vloglish 重置密码"
    msg["From"] = from_addr
    msg["To"] = to_email
    msg.set_content(
        "你好，\n\n"
        "我们收到了你的密码重置请求。请点击以下链接设置新密码（1 小时内有效）：\n\n"
        f"{reset_url}\n\n"
        "如果这不是你的操作，请忽略此邮件。\n"
    )

    with smtplib.SMTP(host, port, timeout=20) as server:
        if use_tls:
            server.starttls()
        if password:
            server.login(username, password)
        server.send_message(msg)
    return True
