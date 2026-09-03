/** 小程序 image 只走 HTTPS；七牛 oss 等 http 需升级。 */
export function resolveMediaUrl(url: string): string {
  const cleaned = (url || '').trim()
  if (!cleaned) return ''
  let out = cleaned
  if (out.startsWith('//')) out = `https:${out}`
  if (out.startsWith('http://') && !/ssapi\./i.test(out)) {
    out = `https://${out.slice('http://'.length)}`
  }
  return out
}
