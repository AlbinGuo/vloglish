import type { AdminSubtitle } from '@/api/admin'
import { countHighlights, parseEnglishHtmlTokens, plainFromEnglishHtml } from '@/utils/subtitleHighlightEdit'

export type PreparedSubtitleJsonRow = {
  index?: number
  start?: number | string
  end?: number | string
  english?: string
  chinese?: string
  ipa?: string
  english_html?: string
}

export type ParsePreparedSubtitlesResult = {
  subtitles: AdminSubtitle[]
  highlightCount: number
  withHtmlCount: number
  withChineseCount: number
  withIpaCount: number
  warnings: string[]
}

function toNumber(value: unknown, fallback = 0): number {
  if (typeof value === 'number' && Number.isFinite(value)) return value
  if (typeof value === 'string' && value.trim()) {
    const n = Number(value.trim())
    if (Number.isFinite(n)) return n
  }
  return fallback
}

function extractRows(raw: unknown): PreparedSubtitleJsonRow[] {
  if (Array.isArray(raw)) return raw as PreparedSubtitleJsonRow[]
  if (raw && typeof raw === 'object') {
    const obj = raw as Record<string, unknown>
    for (const key of ['subtitles', 'results', 'items', 'data']) {
      if (Array.isArray(obj[key])) return obj[key] as PreparedSubtitleJsonRow[]
    }
  }
  throw new Error('JSON 须为字幕数组，或包含 subtitles / results 数组的对象')
}

/**
 * 解析外部 AI 处理好的整集字幕 JSON（含时间轴 + english_html）。
 * 接受：
 * - [ {...}, ... ]
 * - { "subtitles": [ ... ] }
 */
export function parsePreparedSubtitlesJson(text: string): ParsePreparedSubtitlesResult {
  const trimmed = text.trim()
  if (!trimmed) throw new Error('请粘贴字幕 JSON')

  let parsed: unknown
  try {
    parsed = JSON.parse(trimmed)
  } catch {
    throw new Error('不是合法 JSON，请检查是否完整复制')
  }

  const rows = extractRows(parsed)
  if (!rows.length) throw new Error('字幕数组为空')

  const warnings: string[] = []
  const subtitles: AdminSubtitle[] = []
  let highlightCount = 0
  let withHtmlCount = 0
  let withChineseCount = 0
  let withIpaCount = 0

  rows.forEach((row, i) => {
    if (!row || typeof row !== 'object') {
      warnings.push(`第 ${i + 1} 条不是对象，已跳过`)
      return
    }
    const start = Math.max(0, toNumber(row.start, NaN))
    const end = Math.max(0, toNumber(row.end, NaN))
    if (!Number.isFinite(start) || !Number.isFinite(end)) {
      warnings.push(`第 ${i + 1} 条缺少合法 start/end，已跳过`)
      return
    }
    if (end < start) {
      warnings.push(`第 ${i + 1} 条 end < start，已按原文保留`)
    }

    const englishHtml = String(row.english_html ?? '').trim()
    let english = String(row.english ?? '').trim()
    if (!english && englishHtml) {
      english = plainFromEnglishHtml(englishHtml)
    }
    if (!english && !englishHtml) {
      warnings.push(`第 ${i + 1} 条缺少 english / english_html，已跳过`)
      return
    }

    const chinese = String(row.chinese ?? '').trim()
    const ipa = String(row.ipa ?? '').trim()
    if (englishHtml) withHtmlCount += 1
    if (chinese) withChineseCount += 1
    if (ipa) withIpaCount += 1
    highlightCount += countHighlights(parseEnglishHtmlTokens(englishHtml, english))

    subtitles.push({
      index: subtitles.length,
      start,
      end: end < start ? start : end,
      english,
      chinese,
      ipa,
      english_html: englishHtml,
    })
  })

  if (!subtitles.length) {
    throw new Error(warnings[0] || '没有可导入的字幕行')
  }

  return {
    subtitles,
    highlightCount,
    withHtmlCount,
    withChineseCount,
    withIpaCount,
    warnings,
  }
}

/** 给管理端展示的字段说明示例 */
export const PREPARED_SUBTITLES_JSON_EXAMPLE = `[
  {
    "start": 0.0,
    "end": 3.2,
    "english": "I'm gonna go.",
    "chinese": "我要走了。",
    "ipa": "/aɪm ˈɡɔnə ɡoʊ/",
    "english_html": "<span>I'm</span><span tid=\\"50001\\" class=\\"highlight highlight-a\\" data-gloss=\\"打算\\">gonna</span><span>go.</span>"
  }
]`
