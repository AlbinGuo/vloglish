import re
import urllib.request
from pathlib import Path

base = "https://www.teco-lab.com/assets/"
icons = [
    "ClockIcon-Cwiu-NtU.js",
    "ChevronRightIcon-DXXhm5RP.js",
    "ChevronLeftIcon-???",
    "user-DUha_F2W.js",
    "XMarkIcon-BReZT3zn.js",
]
# discover from Page imports
page = urllib.request.urlopen("https://www.teco-lab.com/assets/Page-DoNuFud6.js", timeout=30).read().decode()
imports = re.findall(r'from"\./([^"]+Icon[^"]+\.js)"', page)
imports += re.findall(r'from"\./(user-DUha_F2W\.js)"', page)
imports += re.findall(r'from"\./(audioPlayer[^"]+\.js)"', page)
out_dir = Path("d:/code/teco-lab/frontend/public/teco-assets")
out_dir.mkdir(parents=True, exist_ok=True)
for name in sorted(set(imports)):
    try:
        data = urllib.request.urlopen(base + name, timeout=20).read()
        (out_dir / name).write_bytes(data)
        print("ok", name, len(data))
    except Exception as e:
        print("fail", name, e)
