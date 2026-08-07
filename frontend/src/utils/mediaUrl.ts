/**
 * 规范化封面/媒体 URL。
 * Capacitor App 页面是 https://localhost，http 媒体会被当成混合内容拦截，
 * 因此对可升级的资源强制 https（七牛 oss.sxakgs.com 等已支持）。
 */
export function resolveMediaUrl(url: string): string {
  const cleaned = (url || '').trim()
  if (!cleaned) return ''

  let out = cleaned
  if (out.startsWith('//')) out = `https:${out}`

  if (out.startsWith('http://') && shouldUpgradeToHttps(out)) {
    out = `https://${out.slice('http://'.length)}`
  }
  return out
}

function shouldUpgradeToHttps(url: string): boolean {
  // 口语云临时链等继续走原有代理逻辑，不强行改协议
  if (/ssapi\./i.test(url)) return false
  return true
}
