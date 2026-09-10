/** 在已有词 span 上加 user-clip-mark，不包新父级，避免打断 tokenizeSubtitleHtml。 */

function spanInnerText(spanHtml: string): string {
  return spanHtml
    .replace(/<[^>]+>/g, '')
    .replace(/&nbsp;/gi, ' ')
    .replace(/&amp;/gi, '&')
    .replace(/&lt;/gi, '<')
    .replace(/&gt;/gi, '>')
    .replace(/&quot;/gi, '"')
    .replace(/&#39;/gi, "'")
}

function escapeRegExp(value: string): string {
  return value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
}

function addUserClipMarkClass(spanHtml: string): string {
  const openEnd = spanHtml.indexOf('>')
  if (openEnd < 0) return spanHtml
  const open = spanHtml.slice(0, openEnd + 1)
  const rest = spanHtml.slice(openEnd + 1)
  if (/\buser-clip-mark\b/.test(open)) return spanHtml
  let nextOpen: string
  if (/\sclass="/i.test(open)) {
    nextOpen = open.replace(/\sclass="/i, ' class="user-clip-mark ')
  } else if (/\sclass='/i.test(open)) {
    nextOpen = open.replace(/\sclass='/i, " class='user-clip-mark ")
  } else {
    nextOpen = open.replace(/^<span\b/i, '<span class="user-clip-mark"')
  }
  return nextOpen + rest
}

export function clipMarkSnippet(clip: {
  original_text?: string
  text: string
  context_english?: string
}): string {
  const original = (clip.original_text || '').replace(/\s+/g, ' ').trim()
  if (original) return original
  const text = (clip.text || '').replace(/\s+/g, ' ').trim()
  const ctx = (clip.context_english || '').replace(/\s+/g, ' ').trim()
  if (text && ctx.toLowerCase().includes(text.toLowerCase())) return text
  return ''
}

export function applyUserClipMarks(html: string, snippets: string[]): string {
  const cleaned = [
    ...new Set(
      snippets
        .map((item) => item.replace(/\s+/g, ' ').trim())
        .filter((item) => item.length >= 2),
    ),
  ]
  if (!html || !cleaned.length) return html

  type SpanHit = { start: number; end: number; html: string; inner: string }
  const spans: SpanHit[] = []
  const re = /<span\b[\s\S]*?<\/span>/gi
  let match: RegExpExecArray | null
  while ((match = re.exec(html)) !== null) {
    spans.push({
      start: match.index,
      end: match.index + match[0].length,
      html: match[0],
      inner: spanInnerText(match[0]),
    })
  }
  if (!spans.length) return html

  const haystack = spans.map((span) => span.inner).join(' ')
  const ranges: { start: number; end: number }[] = []
  let cursor = 0
  for (let i = 0; i < spans.length; i++) {
    const len = spans[i].inner.length
    ranges.push({ start: cursor, end: cursor + len })
    cursor += len + (i < spans.length - 1 ? 1 : 0)
  }

  const marked = new Set<number>()
  for (const snippet of cleaned) {
    const words = snippet.split(' ').map(escapeRegExp).filter(Boolean)
    if (!words.length) continue
    const findRe = new RegExp(words.join('\\s+'), 'gi')
    let hit: RegExpExecArray | null
    while ((hit = findRe.exec(haystack)) !== null) {
      const a = hit.index
      const b = a + hit[0].length
      ranges.forEach((range, i) => {
        if (range.start < b && range.end > a && spans[i].inner.trim()) marked.add(i)
      })
      if (!hit[0].length) findRe.lastIndex += 1
    }
  }
  if (!marked.size) return html

  let out = ''
  let last = 0
  spans.forEach((span, i) => {
    out += html.slice(last, span.start)
    out += marked.has(i) ? addUserClipMarkClass(span.html) : span.html
    last = span.end
  })
  out += html.slice(last)
  return out
}
