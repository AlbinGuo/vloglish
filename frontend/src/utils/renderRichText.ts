import DOMPurify from 'dompurify'
import { marked } from 'marked'

marked.setOptions({
  gfm: true,
  breaks: true,
})

const THEME_HOSTILE_STYLE_PROPS = new Set([
  'color',
  'background',
  'background-color',
  'background-image',
  '-webkit-text-fill-color',
])

/** 去掉粘贴 HTML 里写死的前景/背景色，避免深色主题下黑字难辨 */
export function stripThemeHostileInlineStyles(html: string): string {
  if (!html) return ''
  const scrubStyle = (style: string) =>
    style
      .split(';')
      .map((part) => part.trim())
      .filter((part) => {
        if (!part) return false
        const prop = part.split(':')[0]?.trim().toLowerCase()
        return Boolean(prop) && !THEME_HOSTILE_STYLE_PROPS.has(prop)
      })
      .join('; ')

  return html
    .replace(/\sstyle\s*=\s*(["'])([\s\S]*?)\1/gi, (_m, quote: string, style: string) => {
      const cleaned = scrubStyle(style)
      return cleaned ? ` style=${quote}${cleaned}${quote}` : ''
    })
    // 无引号 style=color:black 等极端情况
    .replace(/\sstyle\s*=\s*([^\s"'<>]+)/gi, (_m, style: string) => {
      const cleaned = scrubStyle(style)
      return cleaned ? ` style="${cleaned}"` : ''
    })
    .replace(/\s(?:color|bgcolor)\s*=\s*(["'])[\s\S]*?\1/gi, '')
    .replace(/\s(?:color|bgcolor)\s*=\s*[^\s"'<>]+/gi, '')
}

/** Parse Markdown (HTML passthrough) then sanitize for safe v-html. */
export function renderRichText(source: string): string {
  const raw = (source || '').trim()
  if (!raw) return ''
  const html = marked.parse(raw, { async: false }) as string
  return DOMPurify.sanitize(html, {
    USE_PROFILES: { html: true },
  })
}

/** 视频语境等需适配主题的富文本：清洗后去掉写死的颜色 */
export function renderThemedRichText(source: string): string {
  return stripThemeHostileInlineStyles(renderRichText(source))
}
