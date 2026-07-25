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

/** 分组标题 → 标签配色（用户端「难度/类型」标签） */
const GROUP_TAG_CLASSES: Record<string, string> = {
  医学术语: 'bg-blue-50 text-blue-700 dark:bg-blue-950/45 dark:text-blue-300',
  '固定搭配 / 惯用表达': 'bg-violet-50 text-violet-700 dark:bg-violet-950/45 dark:text-violet-300',
  固定搭配: 'bg-violet-50 text-violet-700 dark:bg-violet-950/45 dark:text-violet-300',
  惯用表达: 'bg-sky-50 text-sky-700 dark:bg-sky-950/45 dark:text-sky-300',
  '口语 / 非正式表达': 'bg-rose-50 text-rose-700 dark:bg-rose-950/45 dark:text-rose-300',
  口语: 'bg-rose-50 text-rose-700 dark:bg-rose-950/45 dark:text-rose-300',
  非正式表达: 'bg-rose-50 text-rose-700 dark:bg-rose-950/45 dark:text-rose-300',
  其他重点词汇: 'bg-amber-50 text-amber-700 dark:bg-amber-950/45 dark:text-amber-300',
  重点词汇: 'bg-amber-50 text-amber-700 dark:bg-amber-950/45 dark:text-amber-300',
  汇总: 'bg-neutral-100 text-neutral-600 dark:bg-neutral-800 dark:text-neutral-300',
}

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

const FALLBACK_TAG_CLASS =
  'bg-neutral-100 text-neutral-600 dark:bg-neutral-800 dark:text-neutral-300'

export function vocabGroupTagClass(title: string): string {
  if (GROUP_TAG_CLASSES[title]) return GROUP_TAG_CLASSES[title]
  for (const [key, cls] of Object.entries(GROUP_TAG_CLASSES)) {
    if (title.includes(key) || key.includes(title)) return cls
  }
  return FALLBACK_TAG_CLASS
}

export function vocabLevelTagClass(level: string): string {
  return LEVEL_TAG_CLASSES[level] || FALLBACK_TAG_CLASS
}
