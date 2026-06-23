import re
import urllib.request

js = urllib.request.urlopen(
    "https://www.teco-lab.com/assets/Page-DoNuFud6.js", timeout=60
).read().decode("utf-8", "ignore")
for m in re.finditer(r'S\.value="[^"]+"', js):
    print(m.group())
