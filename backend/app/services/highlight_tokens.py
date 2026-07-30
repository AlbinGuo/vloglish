"""从字幕 english_html 抽取高亮词（与前端 readingHighlights 对齐）。"""

from __future__ import annotations

import re
from html.parser import HTMLParser

HIGHLIGHT_CLASS_RE = re.compile(r"\bhighlight-([adiclfp])\b", re.I)


class HighlightToken:
    __slots__ = ("word", "type", "highlight")

    def __init__(self, word: str, token_type: int, highlight: str | None):
        self.word = word
        self.type = token_type
        self.highlight = highlight


class _HighlightParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.tokens: list[HighlightToken] = []
        self._seen: set[str] = set()
        self._depth = 0
        self._is_phrase = False
        self._highlight: str | None = None
        self._buf: list[str] = []

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        if tag != "span":
            return
        attr_map = {k: (v or "") for k, v in attrs}
        classes = attr_map.get("class", "")
        class_list = classes.split()
        if "highlight" not in class_list:
            return
        if self._depth == 0:
            self._is_phrase = "pid" in attr_map or "phrase-token" in class_list
            match = HIGHLIGHT_CLASS_RE.search(classes)
            self._highlight = match.group(1).lower() if match else None
            self._buf = []
        self._depth += 1

    def handle_endtag(self, tag: str) -> None:
        if tag != "span" or self._depth == 0:
            return
        self._depth -= 1
        if self._depth != 0:
            return
        word = re.sub(r"\s+", " ", "".join(self._buf)).strip()
        self._buf = []
        if not word:
            return
        key = word.lower()
        if key in self._seen:
            return
        self._seen.add(key)
        self.tokens.append(
            HighlightToken(word=word, token_type=2 if self._is_phrase else 1, highlight=self._highlight)
        )

    def handle_data(self, data: str) -> None:
        if self._depth > 0:
            self._buf.append(data)


def extract_highlight_tokens(html: str) -> list[HighlightToken]:
    if not (html or "").strip():
        return []
    parser = _HighlightParser()
    try:
        parser.feed(html)
        parser.close()
    except Exception:
        return []
    return parser.tokens
