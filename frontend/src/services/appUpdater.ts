import { registerPlugin } from '@capacitor/core'
import { getNativePlatform, isNativePlatform } from '@/utils/platform'

interface AppUpdaterPlugin {
  openDownload(options: { url: string }): Promise<void>
}

const AppUpdater = registerPlugin<AppUpdaterPlugin>('AppUpdater')

/**
 * 让系统浏览器/下载器打开 APK 下载地址（仅 Android 原生壳可用）。
 * 返回是否成功交由原生处理；失败时调用方再回退到 window.open。
 */
export async function openApkDownload(url: string): Promise<boolean> {
  if (!isNativePlatform() || getNativePlatform() !== 'android') return false
  try {
    await AppUpdater.openDownload({ url })
    return true
  } catch {
    return false
  }
}
