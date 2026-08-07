/**
 * Capacitor 壳层初始化（仅原生环境生效）。
 * JS 桥接包装在 frontend；android/ios 工程在根目录 app/。
 */
import { applyPlatformClass, isNativePlatform } from '@/utils/platform'

/** 浅色底用深色图标，深色底用浅色图标 */
export async function syncNativeStatusBarStyle(resolved: 'light' | 'dark') {
  if (!isNativePlatform()) return
  try {
    const { StatusBar, Style } = await import('@capacitor/status-bar')
    await StatusBar.setStyle({ style: resolved === 'dark' ? Style.Light : Style.Dark })
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
    await StatusBar.setOverlaysWebView({ overlay: true })
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
