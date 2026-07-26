/** 解析剧集「词汇与表达汇总」粘贴文本（与后端 vocab_summary.py 规则一致） */

export interface VocabSummaryItem {
  en: string
  zh: string
  /** 剧中含义 */
  note?: string
  /** 例句 */
  example?: string
  /** 难度（可选粘贴字段「难度：四级」；否则前端可用分组标题） */
  level?: string
}

export interface VocabSummaryGroup {
  title: string
  items: VocabSummaryItem[]
}

const SPLIT_RE = /(?:\t+|\|+|／+|\/+|[\u0020\u00a0\u3000]{2,}|[ ]*[-–—][ ]*)/
const LATIN_RE = /[A-Za-z]/
const FIELD_PREFIXES: [string, 'note' | 'example' | 'zh' | 'level'][] = [
  ['剧中含义：', 'note'],
  ['剧中含义:', 'note'],
  ['例句：', 'example'],
  ['例句:', 'example'],
  ['释义：', 'zh'],
  ['释义:', 'zh'],
  ['中文：', 'zh'],
  ['中文:', 'zh'],
  ['难度：', 'level'],
  ['难度:', 'level'],
]

function matchField(line: string): { key: 'note' | 'example' | 'zh' | 'level'; value: string } | null {
  for (const [prefix, key] of FIELD_PREFIXES) {
    if (line.startsWith(prefix)) {
      return { key, value: line.slice(prefix.length).trim() }
    }
  }
  return null
}

function splitSimpleEntry(line: string): VocabSummaryItem | null {
  const parts = line.split(SPLIT_RE, 2)
  if (parts.length !== 2) return null
  const en = (parts[0] || '').trim()
  const zh = (parts[1] || '').trim()
  if (!en || !LATIN_RE.test(en) || !zh) return null
  return { en, zh, note: '', example: '', level: '' }
}

export function parseVocabSummary(text: string): VocabSummaryGroup[] {
  const raw = (text || '').replace(/\r\n/g, '\n').replace(/\r/g, '\n')
  const groups: VocabSummaryGroup[] = []
  let current: VocabSummaryGroup | null = null
  let currentEntry: {
    en: string
    zh: string
    note?: string
    example?: string
    level?: string
  } | null = null

  function ensureGroup(title: string): VocabSummaryGroup {
    const t = (title || '').trim() || '汇总'
    if (current && current.title === t) return current
    current = { title: t, items: [] }
    groups.push(current)
    return current
  }

  function flushEntry() {
    if (!currentEntry) return
    const en = currentEntry.en.trim()
    if (!en) {
      currentEntry = null
      return
    }
    const g = current ?? ensureGroup('汇总')
    g.items.push({
      en,
      zh: (currentEntry.zh || '').trim(),
      note: (currentEntry.note || '').trim(),
      example: (currentEntry.example || '').trim(),
      level: (currentEntry.level || '').trim(),
    })
    currentEntry = null
  }

  for (const line of raw.split('\n')) {
    const trimmed = line.trim()
    if (!trimmed) {
      flushEntry()
      continue
    }

    const field = matchField(trimmed)
    if (field) {
      if (currentEntry) {
        currentEntry[field.key] = field.value
      }
      continue
    }

    const simple = splitSimpleEntry(trimmed)
    if (simple) {
      flushEntry()
      const g = current ?? ensureGroup('汇总')
      g.items.push(simple)
      continue
    }

    if (!LATIN_RE.test(trimmed)) {
      flushEntry()
      ensureGroup(trimmed)
      continue
    }

    flushEntry()
    currentEntry = { en: trimmed, zh: '', note: '', example: '', level: '' }
  }

  flushEntry()
  return groups.filter((g) => g.items.length > 0)
}

export function countVocabSummaryItems(groups: VocabSummaryGroup[]): number {
  return groups.reduce((n, g) => n + g.items.length, 0)
}

/** 分组标题 → 标签配色（用户端二级 Tab / 词条标签） */
const GROUP_TAG_CLASSES: Record<string, string> = {
  医学术语: 'bg-blue-50 text-blue-700 dark:bg-blue-950/45 dark:text-blue-300',
  '固定搭配 / 惯用表达': 'bg-violet-50 text-violet-700 dark:bg-violet-950/45 dark:text-violet-300',
  '固定搭配／惯用表达': 'bg-violet-50 text-violet-700 dark:bg-violet-950/45 dark:text-violet-300',
  固定搭配: 'bg-violet-50 text-violet-700 dark:bg-violet-950/45 dark:text-violet-300',
  惯用表达: 'bg-sky-50 text-sky-700 dark:bg-sky-950/45 dark:text-sky-300',
  '口语 / 非正式表达': 'bg-rose-50 text-rose-700 dark:bg-rose-950/45 dark:text-rose-300',
  '口语／非正式表达': 'bg-rose-50 text-rose-700 dark:bg-rose-950/45 dark:text-rose-300',
  口语: 'bg-rose-50 text-rose-700 dark:bg-rose-950/45 dark:text-rose-300',
  非正式表达: 'bg-rose-50 text-rose-700 dark:bg-rose-950/45 dark:text-rose-300',
  其他重点词汇: 'bg-amber-50 text-amber-700 dark:bg-amber-950/45 dark:text-amber-300',
  重点词汇: 'bg-amber-50 text-amber-700 dark:bg-amber-950/45 dark:text-amber-300',
}

/** 未知分类名时按标题稳定轮转，避免落到无辨识度的灰色 */
const GROUP_TAG_PALETTE = [
  'bg-blue-50 text-blue-700 dark:bg-blue-950/45 dark:text-blue-300',
  'bg-violet-50 text-violet-700 dark:bg-violet-950/45 dark:text-violet-300',
  'bg-rose-50 text-rose-700 dark:bg-rose-950/45 dark:text-rose-300',
  'bg-amber-50 text-amber-700 dark:bg-amber-950/45 dark:text-amber-300',
  'bg-emerald-50 text-emerald-700 dark:bg-emerald-950/45 dark:text-emerald-300',
  'bg-sky-50 text-sky-700 dark:bg-sky-950/45 dark:text-sky-300',
  'bg-orange-50 text-orange-700 dark:bg-orange-950/45 dark:text-orange-300',
  'bg-fuchsia-50 text-fuchsia-700 dark:bg-fuchsia-950/45 dark:text-fuchsia-300',
] as const

const LEVEL_TAG_CLASSES: Record<string, string> = {
  四级: 'bg-emerald-50 text-emerald-700 dark:bg-emerald-950/45 dark:text-emerald-300',
  六级: 'bg-teal-50 text-teal-700 dark:bg-teal-950/45 dark:text-teal-300',
  专四: 'bg-amber-50 text-amber-700 dark:bg-amber-950/45 dark:text-amber-300',
  专八: 'bg-orange-50 text-orange-700 dark:bg-orange-950/45 dark:text-orange-300',
  雅思: 'bg-sky-50 text-sky-700 dark:bg-sky-950/45 dark:text-sky-300',
  托福: 'bg-indigo-50 text-indigo-700 dark:bg-indigo-950/45 dark:text-indigo-300',
  GRE: 'bg-rose-50 text-rose-700 dark:bg-rose-950/45 dark:text-rose-300',
  初级: 'bg-emerald-50 text-emerald-700 dark:bg-emerald-950/45 dark:text-emerald-300',
  中级: 'bg-amber-50 text-amber-700 dark:bg-amber-950/45 dark:text-amber-300',
  高级: 'bg-rose-50 text-rose-700 dark:bg-rose-950/45 dark:text-rose-300',
}

const FALLBACK_TAG_CLASS = GROUP_TAG_PALETTE[0]

function normalizeGroupTitle(title: string): string {
  return (title || '')
    .trim()
    .replace(/[／∕]/g, '/')
    .replace(/\s*\/\s*/g, ' / ')
    .replace(/\s+/g, ' ')
}

function paletteClassForTitle(title: string): string {
  const s = normalizeGroupTitle(title) || '汇总'
  let hash = 0
  for (let i = 0; i < s.length; i++) hash = (hash * 31 + s.charCodeAt(i)) >>> 0
  return GROUP_TAG_PALETTE[hash % GROUP_TAG_PALETTE.length]
}

export function vocabGroupTagClass(title: string): string {
  const normalized = normalizeGroupTitle(title)
  if (!normalized) return paletteClassForTitle(title)

  if (GROUP_TAG_CLASSES[normalized]) return GROUP_TAG_CLASSES[normalized]
  if (GROUP_TAG_CLASSES[title.trim()]) return GROUP_TAG_CLASSES[title.trim()]

  // 先匹配更长的 key，避免「口语」抢先匹配「口语 / 非正式表达」
  const keys = Object.keys(GROUP_TAG_CLASSES).sort((a, b) => b.length - a.length)
  for (const key of keys) {
    const nk = normalizeGroupTitle(key)
    if (normalized.includes(nk) || nk.includes(normalized)) {
      return GROUP_TAG_CLASSES[key]
    }
  }
  return paletteClassForTitle(normalized)
}

export function vocabLevelTagClass(level: string): string {
  const key = (level || '').trim()
  return LEVEL_TAG_CLASSES[key] || paletteClassForTitle(key || 'level')
}

/** 词文串学：正文高亮底色（与分组标签同色系） */
const GROUP_HIGHLIGHT_CLASSES: Record<string, string> = {
  医学术语: 'bg-blue-200/80 text-blue-950 dark:bg-blue-700/45 dark:text-blue-50',
  '固定搭配 / 惯用表达': 'bg-violet-200/80 text-violet-950 dark:bg-violet-700/45 dark:text-violet-50',
  '固定搭配／惯用表达': 'bg-violet-200/80 text-violet-950 dark:bg-violet-700/45 dark:text-violet-50',
  固定搭配: 'bg-violet-200/80 text-violet-950 dark:bg-violet-700/45 dark:text-violet-50',
  惯用表达: 'bg-sky-200/80 text-sky-950 dark:bg-sky-700/45 dark:text-sky-50',
  '口语 / 非正式表达': 'bg-rose-200/80 text-rose-950 dark:bg-rose-700/45 dark:text-rose-50',
  '口语／非正式表达': 'bg-rose-200/80 text-rose-950 dark:bg-rose-700/45 dark:text-rose-50',
  口语: 'bg-rose-200/80 text-rose-950 dark:bg-rose-700/45 dark:text-rose-50',
  非正式表达: 'bg-rose-200/80 text-rose-950 dark:bg-rose-700/45 dark:text-rose-50',
  其他重点词汇: 'bg-amber-200/80 text-amber-950 dark:bg-amber-700/45 dark:text-amber-50',
  重点词汇: 'bg-amber-200/80 text-amber-950 dark:bg-amber-700/45 dark:text-amber-50',
}

const GROUP_HIGHLIGHT_PALETTE = [
  'bg-blue-200/80 text-blue-950 dark:bg-blue-700/45 dark:text-blue-50',
  'bg-violet-200/80 text-violet-950 dark:bg-violet-700/45 dark:text-violet-50',
  'bg-rose-200/80 text-rose-950 dark:bg-rose-700/45 dark:text-rose-50',
  'bg-amber-200/80 text-amber-950 dark:bg-amber-700/45 dark:text-amber-50',
  'bg-emerald-200/80 text-emerald-950 dark:bg-emerald-700/45 dark:text-emerald-50',
  'bg-sky-200/80 text-sky-950 dark:bg-sky-700/45 dark:text-sky-50',
  'bg-orange-200/80 text-orange-950 dark:bg-orange-700/45 dark:text-orange-50',
  'bg-fuchsia-200/80 text-fuchsia-950 dark:bg-fuchsia-700/45 dark:text-fuchsia-50',
] as const

/** 词文串学：左侧词卡底色 */
const GROUP_CARD_CLASSES: Record<string, string> = {
  医学术语: 'bg-blue-100 border-blue-200/80 dark:bg-blue-950/50 dark:border-blue-800/60',
  '固定搭配 / 惯用表达': 'bg-violet-100 border-violet-200/80 dark:bg-violet-950/50 dark:border-violet-800/60',
  '固定搭配／惯用表达': 'bg-violet-100 border-violet-200/80 dark:bg-violet-950/50 dark:border-violet-800/60',
  固定搭配: 'bg-violet-100 border-violet-200/80 dark:bg-violet-950/50 dark:border-violet-800/60',
  惯用表达: 'bg-sky-100 border-sky-200/80 dark:bg-sky-950/50 dark:border-sky-800/60',
  '口语 / 非正式表达': 'bg-rose-100 border-rose-200/80 dark:bg-rose-950/50 dark:border-rose-800/60',
  '口语／非正式表达': 'bg-rose-100 border-rose-200/80 dark:bg-rose-950/50 dark:border-rose-800/60',
  口语: 'bg-rose-100 border-rose-200/80 dark:bg-rose-950/50 dark:border-rose-800/60',
  非正式表达: 'bg-rose-100 border-rose-200/80 dark:bg-rose-950/50 dark:border-rose-800/60',
  其他重点词汇: 'bg-amber-100 border-amber-200/80 dark:bg-amber-950/50 dark:border-amber-800/60',
  重点词汇: 'bg-amber-100 border-amber-200/80 dark:bg-amber-950/50 dark:border-amber-800/60',
}

const GROUP_CARD_PALETTE = [
  'bg-blue-100 border-blue-200/80 dark:bg-blue-950/50 dark:border-blue-800/60',
  'bg-violet-100 border-violet-200/80 dark:bg-violet-950/50 dark:border-violet-800/60',
  'bg-rose-100 border-rose-200/80 dark:bg-rose-950/50 dark:border-rose-800/60',
  'bg-amber-100 border-amber-200/80 dark:bg-amber-950/50 dark:border-amber-800/60',
  'bg-emerald-100 border-emerald-200/80 dark:bg-emerald-950/50 dark:border-emerald-800/60',
  'bg-sky-100 border-sky-200/80 dark:bg-sky-950/50 dark:border-sky-800/60',
  'bg-orange-100 border-orange-200/80 dark:bg-orange-950/50 dark:border-orange-800/60',
  'bg-fuchsia-100 border-fuchsia-200/80 dark:bg-fuchsia-950/50 dark:border-fuchsia-800/60',
] as const

function resolveGroupMappedClass(
  title: string,
  map: Record<string, string>,
  palette: readonly string[],
): string {
  const normalized = normalizeGroupTitle(title)
  if (!normalized) {
    let hash = 0
    const s = title || '汇总'
    for (let i = 0; i < s.length; i++) hash = (hash * 31 + s.charCodeAt(i)) >>> 0
    return palette[hash % palette.length]
  }
  if (map[normalized]) return map[normalized]
  if (map[title.trim()]) return map[title.trim()]
  const keys = Object.keys(map).sort((a, b) => b.length - a.length)
  for (const key of keys) {
    const nk = normalizeGroupTitle(key)
    if (normalized.includes(nk) || nk.includes(normalized)) return map[key]
  }
  let hash = 0
  for (let i = 0; i < normalized.length; i++) hash = (hash * 31 + normalized.charCodeAt(i)) >>> 0
  return palette[hash % palette.length]
}

export function vocabGroupHighlightClass(title: string): string {
  return resolveGroupMappedClass(title, GROUP_HIGHLIGHT_CLASSES, GROUP_HIGHLIGHT_PALETTE)
}

export function vocabGroupCardClass(title: string): string {
  return resolveGroupMappedClass(title, GROUP_CARD_CLASSES, GROUP_CARD_PALETTE)
}

function escapeHtml(s: string): string {
  return s
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
}

export interface VocabLinkTerm {
  en: string
  groupTitle: string
}

/** 从分组汇总生成待高亮词条（更长优先，去重） */
export function collectVocabLinkTerms(groups: VocabSummaryGroup[]): VocabLinkTerm[] {
  const seen = new Set<string>()
  const terms: VocabLinkTerm[] = []
  for (const g of groups) {
    for (const item of g.items) {
      const en = (item.en || '').trim()
      if (!en) continue
      const key = en.toLowerCase()
      if (seen.has(key)) continue
      seen.add(key)
      terms.push({ en, groupTitle: g.title })
    }
  }
  terms.sort((a, b) => b.en.length - a.en.length)
  return terms
}

/**
 * 在纯英文上叠加词文串学高亮（转义 HTML）。
 * 词边界：短语按字面匹配；单词要求非字母数字边界。
 */
export function highlightVocabLinkText(text: string, groups: VocabSummaryGroup[]): string {
  const source = text || ''
  if (!source.trim() || !groups.length) return escapeHtml(source)

  const terms = collectVocabLinkTerms(groups)
  if (!terms.length) return escapeHtml(source)

  type Hit = { start: number; end: number; groupTitle: string }
  const hits: Hit[] = []
  const lower = source.toLowerCase()

  for (const term of terms) {
    const needle = term.en.toLowerCase()
    if (!needle) continue
    const isPhrase = /\s/.test(term.en) || /[^A-Za-z0-9']/.test(term.en.replace(/[()]/g, ''))
    let from = 0
    while (from < lower.length) {
      const idx = lower.indexOf(needle, from)
      if (idx < 0) break
      const end = idx + needle.length
      if (!isPhrase) {
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
      if (!overlap) hits.push({ start: idx, end, groupTitle: term.groupTitle })
      from = end
    }
  }

  hits.sort((a, b) => a.start - b.start)
  if (!hits.length) return escapeHtml(source)

  let out = ''
  let cursor = 0
  for (const hit of hits) {
    if (hit.start > cursor) out += escapeHtml(source.slice(cursor, hit.start))
    const cls = vocabGroupHighlightClass(hit.groupTitle)
    const slice = escapeHtml(source.slice(hit.start, hit.end))
    out += `<span class="vocab-link-hl rounded px-0.5 ${cls}" data-vocab-en="${escapeHtml(source.slice(hit.start, hit.end))}">${slice}</span>`
    cursor = hit.end
  }
  if (cursor < source.length) out += escapeHtml(source.slice(cursor))
  return out
}
