/**
 * Capacitor 壳层初始化（仅原生环境生效）。
 * JS 桥接包装在 frontend；android/ios 工程在根目录 app/。
 */
import { applyPlatformClass, getNativePlatform, isNativePlatform } from '@/utils/platform'

const STATUS_BAR_BG = {
  light: '#ffffff',
  dark: '#171717', // 对齐 header 的 neutral-900
} as const

/** 浅色底用深色图标，深色底用浅色图标 */
export async function syncNativeStatusBarStyle(resolved: 'light' | 'dark') {
  if (!isNativePlatform()) return
  try {
    const { StatusBar, Style } = await import('@capacitor/status-bar')
    // Capacitor 枚举语义：Style.Dark = 深色底用浅色文字；Style.Light = 浅色底用深色文字
    await StatusBar.setStyle({ style: resolved === 'dark' ? Style.Dark : Style.Light })
    // Android 非 overlay 时需显式设状态栏背景，否则可能发灰/发黑与 header 不一致
    if (getNativePlatform() === 'android') {
      await StatusBar.setBackgroundColor({ color: STATUS_BAR_BG[resolved] })
    }
  } catch {
    /* 部分模拟器可能不支持 */
  }
}

export async function initNativeShell() {
  applyPlatformClass()
  if (!isNativePlatform()) return

  const [{ App }, { StatusBar }, { SplashScreen }] = await Promise.all([
    import('@capacitor/app'),
    import('@capacitor/status-bar'),
    import('@capacitor/splash-screen'),
  ])

  try {
    const platform = getNativePlatform()
    // Android System WebView 经常读不到 safe-area-inset-top（为 0）。
    // overlay=true 时 header 会被状态栏盖住；Android 改为不叠加，由系统预留顶栏空间。
    // iOS 的 safe-area 正常，可继续沉浸式 overlay。
    await StatusBar.setOverlaysWebView({ overlay: platform === 'ios' })
    const dark = document.documentElement.classList.contains('dark')
    await syncNativeStatusBarStyle(dark ? 'dark' : 'light')
  } catch {
    /* 部分模拟器可能不支持 */
  }

  App.addListener('backButton', ({ canGoBack }) => {
    if (canGoBack) {
      window.history.back()
      return
    }
    void App.exitApp()
  })

  try {
    await SplashScreen.hide()
  } catch {
    /* ignore */
  }
}
