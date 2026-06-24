from fastapi import Header


def get_device_id(x_device_id: str | None = Header(default=None, alias="X-Device-Id")) -> str:
    if not x_device_id or not x_device_id.strip():
        return "anonymous"
    return x_device_id.strip()[:64]
