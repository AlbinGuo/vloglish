import { onMounted, ref } from 'vue'
import { checkAppVersion, type AppVersionCheck } from '@/api/appDownload'
import { getNativePlatform, isNativePlatform } from '@/utils/platform'

const SKIP_KEY = 'app-update-skip-code'

export function useAppUpdateCheck() {
  const open = ref(false)
  const info = ref<AppVersionCheck | null>(null)

  function later() {
    if (info.value?.latest_version_code) {
      try {
        localStorage.setItem(SKIP_KEY, String(info.value.latest_version_code))
      } catch {
        /* ignore */
      }
    }
    open.value = false
  }

  function onUpdateClicked() {
    // 强制更新保持弹窗，避免关掉后继续用旧版
    if (!info.value?.force_update) open.value = false
  }

  async function runCheck() {
    if (!isNativePlatform()) return
    if (getNativePlatform() !== 'android') return

    let versionCode = 0
    try {
      const { App } = await import('@capacitor/app')
      const appInfo = await App.getInfo()
      versionCode = Number.parseInt(String(appInfo.build || '0'), 10) || 0
    } catch {
      return
    }
    if (versionCode <= 0) return

    try {
      const result = await checkAppVersion(versionCode)
      if (!result.has_update) return
      if (!result.force_update) {
        try {
          const skipped = Number(localStorage.getItem(SKIP_KEY) || '0')
          if (skipped === result.latest_version_code) return
        } catch {
          /* ignore */
        }
      }
      info.value = result
      open.value = true
    } catch {
      /* 静默：网络失败不打扰 */
    }
  }

  onMounted(() => {
    // 稍晚检查，避免挡住首屏
    window.setTimeout(() => {
      void runCheck()
    }, 1200)
  })

  return { open, info, later, onUpdateClicked, runCheck }
}
