import type { SubtitleHtmlToken } from '@/utils/subtitleWordProgress'

export interface GlossInfo {
  ipa: string
  gloss: string
  loading: boolean
}

export function isHighlightTokenHtml(html: string): boolean {
  return /\bhighlight\b/.test(html)
}

export function wordFromTokenHtml(html: string): string {
  const doc = new DOMParser().parseFromString(html, 'text/html')
  return doc.body.textContent?.trim().replace(/\s+/g, ' ') ?? ''
}

export function tokenTypeFromHtml(html: string): 1 | 2 {
  return html.includes('pid=') || html.includes('phrase-token') ? 2 : 1
}

export function glossKey(word: string): string {
  return word.trim().toLowerCase()
}

/** 精读分词：保留 span、裸文本与空白，相邻词之间保证有空格 */
export function tokenizeForIntensive(html: string): SubtitleHtmlToken[] {
  if (!html?.trim()) return []

  const tokens: SubtitleHtmlToken[] = []
  const re = /(<span[\s\S]*?<\/span>)|(\s+)|([^<\s]+)/gi
  let match: RegExpExecArray | null
  let wordIndex = 0

  while ((match = re.exec(html)) !== null) {
    if (match[1]) {
      tokens.push({ kind: 'word', html: match[1], wordIndex: wordIndex++ })
    } else if (match[2]) {
      tokens.push({ kind: 'space', text: ' ' })
    } else if (match[3]) {
      tokens.push({
        kind: 'word',
        html: `<span>${match[3]}</span>`,
        wordIndex: wordIndex++,
      })
    }
  }

  if (wordIndex === 0 && html.trim()) {
    html
      .trim()
      .split(/\s+/)
      .forEach((word, i) => {
        if (i > 0) tokens.push({ kind: 'space', text: ' ' })
        tokens.push({
          kind: 'word',
          html: `<span>${word}</span>`,
          wordIndex: i,
        })
      })
  }

  const normalized: SubtitleHtmlToken[] = []
  for (let i = 0; i < tokens.length; i++) {
    const token = tokens[i]
    if (token.kind === 'space') {
      if (normalized.length === 0) continue
      const prev = normalized[normalized.length - 1]
      const next = tokens[i + 1]
      if (prev.kind !== 'word' || next?.kind !== 'word') continue
      if (normalized[normalized.length - 1]?.kind === 'space') continue
      normalized.push({ kind: 'space', text: ' ' })
      continue
    }
    normalized.push(token)
    const next = tokens[i + 1]
    if (token.kind === 'word' && next?.kind === 'word') {
      normalized.push({ kind: 'space', text: ' ' })
    }
  }

  return normalized
}
