import type { VocabSummaryGroup, VocabSummaryItem } from '@/utils/vocabSummary'
import { collectVocabLinkTerms } from '@/utils/vocabSummary'

export interface VocabDanmakuSource {
  id: string
  word: string
  gloss: string
  tokenType: 1 | 2
  highlight: string | null
  groupTitle?: string
}

const MAX_ITEMS = 6
const HIGHLIGHT_LETTERS = ['a', 'd', 'i', 'c', 'l', 'f', 'p'] as const

function itemGloss(item: VocabSummaryItem | undefined): string {
  if (!item) return ''
  return (item.zh || item.note || '').replace(/\s+/g, ' ').trim()
}

function findSummaryItem(groups: VocabSummaryGroup[], en: string): VocabSummaryItem | undefined {
  const key = en.trim().toLowerCase()
  for (const g of groups) {
    for (const item of g.items) {
      if (item.en.trim().toLowerCase() === key) return item
    }
  }
  return undefined
}

function highlightForGroup(title: string): string {
  let hash = 0
  const s = (title || '').trim().toLowerCase()
  for (let i = 0; i < s.length; i++) hash = (hash * 31 + s.charCodeAt(i)) >>> 0
  return HIGHLIGHT_LETTERS[hash % HIGHLIGHT_LETTERS.length]!
}

function isPhraseTerm(en: string): boolean {
  return /\s/.test(en) || /[^A-Za-z0-9']/i.test(en.replace(/[()]/g, ''))
}

/**
 * 用「汇总」词库在当前句英文中匹配，生成弹幕词条（按句内出现顺序，更长词优先占位）。
 */
export function matchSummaryDanmakuSources(
  sentence: string,
  groups: VocabSummaryGroup[],
  maxItems = MAX_ITEMS,
): VocabDanmakuSource[] {
  const source = (sentence || '').trim()
  if (!source || !groups.length) return []

  const terms = collectVocabLinkTerms(groups)
  if (!terms.length) return []

  type Hit = { start: number; end: number; en: string; groupTitle: string }
  const hits: Hit[] = []
  const lower = source.toLowerCase()

  for (const term of terms) {
    const needle = term.en.toLowerCase()
    if (!needle) continue
    const phrase = isPhraseTerm(term.en)
    let from = 0
    while (from < lower.length) {
      const idx = lower.indexOf(needle, from)
      if (idx < 0) break
      const end = idx + needle.length
      if (!phrase) {
        const before = idx === 0 ? '' : source[idx - 1]
        const after = end >= source.length ? '' : source[end]
        if (before && /[A-Za-z0-9']/i.test(before)) {
          from = idx + 1
          continue
        }
        if (after && /[A-Za-z0-9']/i.test(after)) {
          from = idx + 1
          continue
        }
      }
      const overlap = hits.some((h) => !(end <= h.start || idx >= h.end))
      if (!overlap) {
        hits.push({
          start: idx,
          end,
          en: term.en,
          groupTitle: term.groupTitle,
        })
      }
      from = end
    }
  }

  hits.sort((a, b) => a.start - b.start)

  const seen = new Set<string>()
  const result: VocabDanmakuSource[] = []
  for (let i = 0; i < hits.length; i++) {
    const hit = hits[i]!
    const key = hit.en.toLowerCase()
    if (seen.has(key)) continue
    seen.add(key)
    const item = findSummaryItem(groups, hit.en)
    const word = (item?.en || hit.en).trim()
    result.push({
      id: `${key}-${i}`,
      word,
      gloss: itemGloss(item).slice(0, 16),
      tokenType: isPhraseTerm(word) ? 2 : 1,
      highlight: highlightForGroup(hit.groupTitle),
      groupTitle: hit.groupTitle,
    })
    if (result.length >= maxItems) break
  }
  return result
}

/** @deprecated 弹幕已改用汇总匹配；保留空实现避免旧引用报错 */
export function extractVocabDanmakuSources(_html: string): VocabDanmakuSource[] {
  return []
}
