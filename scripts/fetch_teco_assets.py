import urllib.request
from pathlib import Path

base = "https://www.teco-lab.com"
js = urllib.request.urlopen(base + "/assets/Page-DoNuFud6.js", timeout=30).read().decode("utf-8", "replace")
out = Path("d:/code/teco-lab/analysis/page-controls-context.txt")
lines = []
keywords = ["倍速", "隐藏视频", "全屏", "音标", "上一句", "重播", "下一句", "B点", "单句循环", "间隔", "单句暂停"]
for kw in keywords:
    idx = 0
    while True:
        idx = js.find(kw, idx)
        if idx == -1:
            break
        lines.append(f"\n--- {kw} @ {idx} ---\n")
        lines.append(js[max(0, idx - 500) : idx + 500])
        idx += len(kw)
out.write_text("\n".join(lines), encoding="utf-8")
print("written", len(lines))
