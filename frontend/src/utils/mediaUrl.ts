/** 规范化封面/媒体 URL（支持 // 协议相对链接）。 */
export function resolveMediaUrl(url: string): string {
  const cleaned = url.trim()
  if (!cleaned) return ''
  if (cleaned.startsWith('//')) return `https:${cleaned}`
  return cleaned
}
