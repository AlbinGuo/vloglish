/** Vite App 构建（`vite build --mode app`），产物输出到根目录 `app/www` */
export function isMobileAppBuild(): boolean {
  return import.meta.env.VITE_APP_TARGET === 'mobile'
}

/** 运行在 Capacitor 原生壳内 */
export function isNativePlatform(): boolean {
  try {
    const Cap = (window as unknown as { Capacitor?: { isNativePlatform?: () => boolean } }).Capacitor
    return Boolean(Cap?.isNativePlatform?.())
  } catch {
    return false
  }
}

export function getNativePlatform(): 'ios' | 'android' | 'web' {
  try {
    const Cap = (window as unknown as { Capacitor?: { getPlatform?: () => string } }).Capacitor
    const p = Cap?.getPlatform?.()
    if (p === 'ios' || p === 'android') return p
  } catch {
    /* ignore */
  }
  return 'web'
}

/** 给根节点打平台 class，便于 CSS 微调 */
export function applyPlatformClass(el: HTMLElement = document.documentElement) {
  el.classList.remove('platform-ios', 'platform-android', 'platform-web', 'platform-native')
  const platform = getNativePlatform()
  el.classList.add(`platform-${platform}`)
  if (platform !== 'web') el.classList.add('platform-native')
}
