import { computed, ref } from 'vue'
import { fetchAppDownload, type PublicAppDownload } from '@/api/appDownload'

const data = ref<PublicAppDownload | null>(null)
const loaded = ref(false)
let inflight: Promise<void> | null = null

function detectClient(): 'ios' | 'android' | 'other' {
  if (typeof navigator === 'undefined') return 'other'
  const ua = navigator.userAgent
  if (/iphone|ipad|ipod/i.test(ua)) return 'ios'
  if (/android/i.test(ua)) return 'android'
  return 'other'
}

export async function ensureAppDownloadLoaded() {
  if (loaded.value) return
  if (inflight) return inflight
  inflight = (async () => {
    try {
      data.value = await fetchAppDownload()
    } catch {
      data.value = null
    } finally {
      loaded.value = true
      inflight = null
    }
  })()
  return inflight
}

/** 按设备决定是否展示「下载 App」入口 */
export function useAppDownloadAvailability() {
  const client = detectClient()

  const showAndroid = computed(() => {
    const d = data.value
    if (!d?.enabled) return false
    return Boolean(d.has_android && d.android_apk_url)
  })

  const showIos = computed(() => {
    const d = data.value
    if (!d?.enabled) return false
    return Boolean((d.ios_link || '').trim())
  })

  /** 入口是否显示：手机只看本平台是否可下；桌面两端任一可下即可 */
  const showEntry = computed(() => {
    if (!loaded.value) return false
    if (client === 'ios') return showIos.value
    if (client === 'android') return showAndroid.value
    return showAndroid.value || showIos.value
  })

  return {
    data,
    loaded,
    client,
    showAndroid,
    showIos,
    showEntry,
    ensureLoaded: ensureAppDownloadLoaded,
  }
}
