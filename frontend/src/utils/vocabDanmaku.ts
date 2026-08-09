import { extractHighlightClass } from '@/utils/readingHighlights'

export interface VocabDanmakuSource {
  id: string
  word: string
  gloss: string
  tokenType: 1 | 2
  highlight: string | null
}

const MAX_ITEMS = 6

/** 从字幕 english_html 提取高亮词（含 data-gloss）供弹幕使用 */
export function extractVocabDanmakuSources(html: string): VocabDanmakuSource[] {
  if (!html?.trim()) return []

  const doc = new DOMParser().parseFromString(html, 'text/html')
  const spans = doc.querySelectorAll('span.highlight')
  const seen = new Set<string>()
  const result: VocabDanmakuSource[] = []

  spans.forEach((span, index) => {
    const word = span.textContent?.trim().replace(/\s+/g, ' ') ?? ''
    if (!word) return
    const key = word.toLowerCase()
    if (seen.has(key)) return
    seen.add(key)

    const isPhrase = span.hasAttribute('pid') || span.classList.contains('phrase-token')
    const gloss = (span.getAttribute('data-gloss') || '').trim()
    result.push({
      id: `${key}-${index}`,
      word,
      gloss,
      tokenType: isPhrase ? 2 : 1,
      highlight: extractHighlightClass(span.className),
    })
  })

  return result.slice(0, MAX_ITEMS)
}
