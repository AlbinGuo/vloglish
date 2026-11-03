import { isNativePlatform } from '@/utils/platform'

const CSS_FS_ATTR = 'data-css-fullscreen'
const CSS_FS_CLASS = 'vloglish-css-fullscreen'

type FullscreenDocument = Document & {
  webkitFullscreenElement?: Element | null
  webkitCurrentFullScreenElement?: Element | null
  webkitExitFullscreen?: () => Promise<void> | void
  webkitCancelFullScreen?: () => void
}

type FullscreenElement = HTMLElement & {
  webkitRequestFullscreen?: (options?: FullscreenOptions) => Promise<void> | void
  webkitRequestFullScreen?: () => void
}

function fsDoc(): FullscreenDocument {
  return document as FullscreenDocument
}

export function getFullscreenElement(): Element | null {
  const doc = fsDoc()
  return (
    document.fullscreenElement ||
    doc.webkitFullscreenElement ||
    doc.webkitCurrentFullScreenElement ||
    document.querySelector(`[${CSS_FS_ATTR}]`)
  )
}

export function subscribeFullscreenChange(handler: () => void): () => void {
  document.addEventListener('fullscreenchange', handler)
  document.addEventListener('webkitfullscreenchange', handler)
  return () => {
    document.removeEventListener('fullscreenchange', handler)
    document.removeEventListener('webkitfullscreenchange', handler)
  }
}

function notifyFullscreenChange() {
  document.dispatchEvent(new Event('fullscreenchange'))
}

function nativeFullscreenEnabled(): boolean {
  if (typeof document.fullscreenEnabled === 'boolean') return document.fullscreenEnabled
  return Boolean(
    document.documentElement.requestFullscreen ||
      (document.documentElement as FullscreenElement).webkitRequestFullscreen,
  )
}

/** iPhone Safari 对 div 的 Fullscreen API 基本不可用，直接走 CSS 铺满 */
function shouldSkipNativeFullscreen(): boolean {
  if (typeof navigator === 'undefined') return false
  const ua = navigator.userAgent || ''
  const iPhone = /iPhone|iPod/i.test(ua)
  if (!iPhone) return false
  return !nativeFullscreenEnabled()
}

function enterCssFullscreen(el: HTMLElement) {
  el.setAttribute(CSS_FS_ATTR, '1')
  document.documentElement.classList.add(CSS_FS_CLASS)
  document.body.classList.add(CSS_FS_CLASS)
  notifyFullscreenChange()
}

function leaveCssFullscreen(el: HTMLElement | null = document.querySelector(`[${CSS_FS_ATTR}]`)) {
  el?.removeAttribute(CSS_FS_ATTR)
  document.documentElement.classList.remove(CSS_FS_CLASS)
  document.body.classList.remove(CSS_FS_CLASS)
  notifyFullscreenChange()
}

async function requestNativeFullscreen(el: HTMLElement): Promise<boolean> {
  const node = el as FullscreenElement
  try {
    if (typeof el.requestFullscreen === 'function') {
      try {
        await el.requestFullscreen({ navigationUI: 'hide' })
      } catch {
        await el.requestFullscreen()
      }
      return getFullscreenElement() === el
    }
    const webkit = node.webkitRequestFullscreen || node.webkitRequestFullScreen
    if (typeof webkit === 'function') {
      const ret = webkit.call(el)
      if (ret && typeof (ret as Promise<void>).then === 'function') await ret
      return getFullscreenElement() === el
    }
  } catch {
    return false
  }
  return false
}

async function exitNativeFullscreen(): Promise<void> {
  const doc = fsDoc()
  const exit = document.exitFullscreen || doc.webkitExitFullscreen || doc.webkitCancelFullScreen
  if (typeof exit !== 'function') return
  const ret = exit.call(document)
  if (ret && typeof (ret as Promise<void>).then === 'function') await ret
}

type OrientationLockApi = {
  lock?: (orientation: string) => Promise<void>
  unlock?: () => void
}

function orientationApi(): OrientationLockApi | null {
  if (typeof screen === 'undefined') return null
  return (screen as unknown as { orientation?: OrientationLockApi }).orientation ?? null
}

function isTouchDevice(): boolean {
  if (typeof window === 'undefined' || typeof window.matchMedia !== 'function') return false
  return window.matchMedia('(pointer: coarse)').matches
}

/**
 * 全屏时尝试锁定横屏。
 * - 原生壳（iOS / Android）：用 @capacitor/screen-orientation 插件（iOS 必须走插件才能转屏）。
 * - 移动端浏览器：用 Screen Orientation API（Android Chrome 支持；iOS Safari 会 reject，忽略）。
 */
async function lockLandscape(): Promise<void> {
  if (isNativePlatform()) {
    try {
      const { ScreenOrientation } = await import('@capacitor/screen-orientation')
      await ScreenOrientation.lock({ orientation: 'landscape' })
    } catch {
      /* 插件不可用 / 平台不支持：保持原方向 */
    }
    return
  }
  if (!isTouchDevice()) return
  const api = orientationApi()
  if (!api?.lock) return
  try {
    await api.lock('landscape')
  } catch {
    /* 不支持或未处于全屏：静默忽略 */
  }
}

function unlockOrientation(): void {
  if (isNativePlatform()) {
    void (async () => {
      try {
        const { ScreenOrientation } = await import('@capacitor/screen-orientation')
        await ScreenOrientation.unlock()
      } catch {
        /* ignore */
      }
    })()
    return
  }
  const api = orientationApi()
  if (!api?.unlock) return
  try {
    api.unlock()
  } catch {
    /* ignore */
  }
}

// 用户通过系统手势/返回键退出全屏时也要解除横屏锁定
if (typeof document !== 'undefined') {
  const onFsChange = () => {
    if (!getFullscreenElement()) unlockOrientation()
  }
  document.addEventListener('fullscreenchange', onFsChange)
  document.addEventListener('webkitfullscreenchange', onFsChange)
}

export async function requestAppFullscreen(el: HTMLElement): Promise<void> {
  if (getFullscreenElement() === el) return
  if (getFullscreenElement()) await exitAppFullscreen()
  if (!shouldSkipNativeFullscreen()) {
    const ok = await requestNativeFullscreen(el)
    if (ok) {
      // 不阻塞全屏切换：横屏锁定失败（如 iOS）就保持原方向
      void lockLandscape()
      return
    }
  }
  enterCssFullscreen(el)
  void lockLandscape()
}

export async function exitAppFullscreen(): Promise<void> {
  unlockOrientation()
  const cssEl = document.querySelector(`[${CSS_FS_ATTR}]`) as HTMLElement | null
  if (cssEl) {
    leaveCssFullscreen(cssEl)
    return
  }
  if (getFullscreenElement()) await exitNativeFullscreen()
}

export async function toggleAppFullscreen(el: HTMLElement | null | undefined): Promise<void> {
  const current = getFullscreenElement()
  if (current) {
    if (el && current !== el) {
      await exitAppFullscreen()
      if (el.isConnected) await requestAppFullscreen(el)
      return
    }
    await exitAppFullscreen()
    return
  }
  if (!el?.isConnected) return
  await requestAppFullscreen(el)
}
