import DOMPurify from 'dompurify'
import { marked } from 'marked'

marked.setOptions({
  gfm: true,
  breaks: true,
})

/** Parse Markdown (HTML passthrough) then sanitize for safe v-html. */
export function renderRichText(source: string): string {
  const raw = (source || '').trim()
  if (!raw) return ''
  const html = marked.parse(raw, { async: false }) as string
  return DOMPurify.sanitize(html, {
    USE_PROFILES: { html: true },
  })
}
