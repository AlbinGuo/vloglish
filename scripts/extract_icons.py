import re
import urllib.request
js = urllib.request.urlopen("https://www.teco-lab.com/assets/Page-DoNuFud6.js", timeout=30).read().decode("utf-8", "replace")
for name in ["kr", "hr", "LoopCount", "ArrowPath"]:
    idx = js.find(f"function {name}")
    if idx >= 0:
        print("\n", name, js[idx:idx+400])
# LoopCount component
m = re.search(r'const \$r=\{', js)
if m:
    print("\n$r component", js[m.start():m.start()+800])
