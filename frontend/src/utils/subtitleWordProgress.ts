export type SubtitleHtmlToken =
  | { kind: 'word'; html: string; wordIndex: number }
  | { kind: 'space'; text: string }

/** 将 english_html 拆成词级 span 与空白，用于逐词跟读高亮 */
export function tokenizeSubtitleHtml(html: string): SubtitleHtmlToken[] {
  const tokens: SubtitleHtmlToken[] = []
  const re = /(<span[\s\S]*?<\/span>)|(\s+)/gi
  let match: RegExpExecArray | null
  let wordIndex = 0

  while ((match = re.exec(html)) !== null) {
    if (match[1]) {
      tokens.push({ kind: 'word', html: match[1], wordIndex: wordIndex++ })
    } else if (match[2]) {
      tokens.push({ kind: 'space', text: match[2] })
    }
  }

  if (wordIndex === 0 && html.trim()) {
    const words = html.trim().split(/\s+/)
    words.forEach((word, i) => {
      if (i > 0) tokens.push({ kind: 'space', text: ' ' })
      tokens.push({
        kind: 'word',
        html: `<span>${word}</span>`,
        wordIndex: i,
      })
    })
  }

  return tokens
}

export function countSubtitleWords(html: string): number {
  return tokenizeSubtitleHtml(html).filter((t) => t.kind === 'word').length
}

/** 词 i 在整句时长内按序点亮（累计高亮，不回退） */
export function isSubtitleWordRead(
  wordIndex: number,
  wordCount: number,
  time: number,
  start: number,
  end: number,
): boolean {
  if (wordCount <= 0 || end <= start) return false
  if (time >= end) return true
  if (time < start) return false
  const duration = end - start
  return time >= start + (duration * wordIndex) / wordCount
}

export interface SubtitleWordHighlight {
  time: number
  start: number
  end: number
}
