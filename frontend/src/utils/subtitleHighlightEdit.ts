/** 管理端字幕高亮编辑：解析 / 生成 english_html（含可选 data-gloss） */

export const HIGHLIGHT_TYPE_OPTIONS = [
  { key: 'a', label: '单词', hint: '核心词汇' },
  { key: 'd', label: '短语动词', hint: '动词搭配' },
  { key: 'i', label: '惯用表达', hint: '习语' },
  { key: 'c', label: '固定搭配', hint: '介词短语等' },
  { key: 'l', label: '长难表达', hint: '从句片段' },
  { key: 'f', label: '话语标记', hint: 'filler 等' },
] as const

export type HighlightTypeKey = (typeof HIGHLIGHT_TYPE_OPTIONS)[number]['key']

export interface HighlightEditToken {
  text: string
  highlight: HighlightTypeKey | null
  gloss: string
  /** 多词短语或显式短语标记 */
  phrase: boolean
}

const HIGHLIGHT_CLASS_RE = /\bhighlight-([adiclf])\b/i

export function escapeHtmlAttr(value: string): string {
  return value
    .replace(/&/g, '&amp;')
    .replace(/"/g, '&quot;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
}

export function decodeHtmlAttr(value: string): string {
  const ta = document.createElement('textarea')
  ta.innerHTML = value
  return ta.value
}

export function plainFromEnglishHtml(html: string): string {
  if (!html?.trim()) return ''
  const doc = new DOMParser().parseFromString(html, 'text/html')
  return (doc.body.textContent || '').replace(/\s+/g, ' ').trim()
}

export function tokenizeEnglishPlain(english: string): HighlightEditToken[] {
  const words = english.trim().split(/\s+/).filter(Boolean)
  return words.map((text) => ({
    text,
    highlight: null,
    gloss: '',
    phrase: false,
  }))
}

export function parseEnglishHtmlTokens(html: string, englishFallback = ''): HighlightEditToken[] {
  if (!html?.trim()) {
    return tokenizeEnglishPlain(englishFallback)
  }

  const doc = new DOMParser().parseFromString(html, 'text/html')
  const spans = [...doc.body.querySelectorAll(':scope > span')]
  if (!spans.length) {
    // 可能无 span 包裹，或结构异常
    const plain = plainFromEnglishHtml(html) || englishFallback
    return tokenizeEnglishPlain(plain)
  }

  const tokens: HighlightEditToken[] = []
  for (const span of spans) {
    const text = (span.textContent || '').replace(/\s+/g, ' ').trim()
    if (!text) continue
    const className = span.getAttribute('class') || ''
    const match = className.match(HIGHLIGHT_CLASS_RE)
    const highlight = (match?.[1]?.toLowerCase() as HighlightTypeKey | undefined) ?? null
    const glossRaw = span.getAttribute('data-gloss') || ''
    const gloss = glossRaw ? decodeHtmlAttr(glossRaw) : ''
    const phrase =
      span.hasAttribute('pid') ||
      className.includes('phrase-token') ||
      /\s/.test(text)
    tokens.push({
      text,
      highlight: highlight && HIGHLIGHT_TYPE_OPTIONS.some((o) => o.key === highlight) ? highlight : null,
      gloss,
      phrase,
    })
  }

  if (!tokens.length) {
    return tokenizeEnglishPlain(englishFallback || plainFromEnglishHtml(html))
  }
  return tokens
}

export function tokensToEnglishHtml(tokens: HighlightEditToken[]): string {
  let tid = 50_000
  let pid = 500
  const parts: string[] = []

  for (const token of tokens) {
    const text = token.text.trim()
    if (!text) continue
    const escapedText = text
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
    const glossAttr = token.gloss.trim()
      ? ` data-gloss="${escapeHtmlAttr(token.gloss.trim())}"`
      : ''

    if (token.highlight) {
      const isPhrase = token.phrase || /\s/.test(text)
      if (isPhrase) {
        pid += 1
        parts.push(
          `<span pid="${pid}" class="highlight highlight-${token.highlight}"${glossAttr}>${escapedText}</span>`,
        )
      } else {
        tid += 1
        parts.push(
          `<span tid="${tid}" class="highlight highlight-${token.highlight}"${glossAttr}>${escapedText}</span>`,
        )
      }
    } else {
      parts.push(`<span>${escapedText}</span>`)
    }
  }

  return parts.join('')
}

export function highlightTypeLabel(key: string | null | undefined): string {
  if (!key) return ''
  return HIGHLIGHT_TYPE_OPTIONS.find((o) => o.key === key)?.label ?? key
}

/** 将选中的连续 token 合并为一个短语高亮（或单个词高亮） */
export function applyHighlightToRange(
  tokens: HighlightEditToken[],
  start: number,
  end: number,
  highlight: HighlightTypeKey,
  gloss: string,
): HighlightEditToken[] {
  if (start < 0 || end < start || end >= tokens.length) return tokens
  const before = tokens.slice(0, start)
  const selected = tokens.slice(start, end + 1)
  const after = tokens.slice(end + 1)
  const mergedText = selected.map((t) => t.text).join(' ')
  const merged: HighlightEditToken = {
    text: mergedText,
    highlight,
    gloss: gloss.trim(),
    phrase: selected.length > 1 || /\s/.test(mergedText),
  }
  return [...before, merged, ...after]
}

export function clearHighlightAt(tokens: HighlightEditToken[], index: number): HighlightEditToken[] {
  if (index < 0 || index >= tokens.length) return tokens
  const token = tokens[index]
  if (!token.highlight && !token.gloss) return tokens

  // 短语取消高亮时拆回单词，便于再选
  if (token.phrase || /\s/.test(token.text)) {
    const words = token.text.split(/\s+/).filter(Boolean)
    const split = words.map((text) => ({
      text,
      highlight: null as HighlightTypeKey | null,
      gloss: '',
      phrase: false,
    }))
    return [...tokens.slice(0, index), ...split, ...tokens.slice(index + 1)]
  }

  const next = [...tokens]
  next[index] = { ...token, highlight: null, gloss: '', phrase: false }
  return next
}

/** 英文改动后尽量保留按序匹配的高亮 */
export function resyncTokensPreservingHighlights(
  english: string,
  previous: HighlightEditToken[],
): HighlightEditToken[] {
  const fresh = tokenizeEnglishPlain(english)
  if (!fresh.length) return []
  if (!previous.length) return fresh

  const result: HighlightEditToken[] = []
  let i = 0
  let p = 0
  while (i < fresh.length) {
    const prev = previous[p]
    if (!prev) {
      result.push(...fresh.slice(i))
      break
    }
    const prevWords = prev.text.split(/\s+/).filter(Boolean)
    const slice = fresh.slice(i, i + prevWords.length)
    const matches =
      slice.length === prevWords.length &&
      slice.every((t, idx) => t.text.toLowerCase() === prevWords[idx].toLowerCase())

    if (matches && prev.highlight) {
      result.push({
        text: slice.map((t) => t.text).join(' '),
        highlight: prev.highlight,
        gloss: prev.gloss,
        phrase: prev.phrase || slice.length > 1,
      })
      i += prevWords.length
      p += 1
    } else if (matches) {
      result.push(...slice)
      i += prevWords.length
      p += 1
    } else {
      // 尝试跳过 previous 中已消失的 token
      const freshWord = fresh[i].text.toLowerCase()
      let found = false
      for (let q = p + 1; q < previous.length; q++) {
        const cand = previous[q].text.split(/\s+/).filter(Boolean)[0]?.toLowerCase()
        if (cand === freshWord) {
          p = q
          found = true
          break
        }
      }
      if (!found) {
        result.push(fresh[i])
        i += 1
        p += 1
      }
    }
  }
  return result
}

export function countHighlights(tokens: HighlightEditToken[]): number {
  return tokens.filter((t) => t.highlight).length
}
