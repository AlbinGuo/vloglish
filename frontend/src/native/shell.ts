/**
 * Capacitor 壳层初始化（仅原生环境生效）。
 * JS 桥接包装在 frontend；android/ios 工程在根目录 app/。
 */
import { Capacitor } from '@capacitor/core'
import { applyPlatformClass, isNativePlatform } from '@/utils/platform'

export async function initNativeShell() {
  applyPlatformClass()
  if (!isNativePlatform()) return

  const [{ App }, { StatusBar, Style }, { SplashScreen }] = await Promise.all([
    import('@capacitor/app'),
    import('@capacitor/status-bar'),
    import('@capacitor/splash-screen'),
  ])

  try {
    const platform = Capacitor.getPlatform()
    await StatusBar.setOverlaysWebView({ overlay: true })
    if (platform === 'android') {
      await StatusBar.setStyle({ style: Style.Dark })
    }
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
