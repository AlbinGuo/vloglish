import { ref, type Ref } from 'vue'
import { isMobileAppBuild, isNativePlatform } from '@/utils/platform'
import { resolveBilibili, type BilibiliResolved } from '@/api/bilibili'

const BILI_HOSTS = ['bilibili.com', 'b23.tv', 'bili2233.cn', 'b23.wtf']
const URL_RE = /https?:\/\/[^\s"'<>）】]+/gi

/** 从任意剪贴板文本里挑出 B 站链接（兼容“【标题】 https://b23.tv/xxx”这类分享文案）。 */
function extractBilibiliUrl(text: string): string {
  const raw = (text || '').trim()
  if (!raw || raw.length > 1000) return ''
  const urls = raw.match(URL_RE) || []
  for (const u of urls) {
    try {
      const host = new URL(u).host.toLowerCase()
      if (BILI_HOSTS.some((h) => host === h || host.endsWith(`.${h}`))) {
        return u.replace(/[.,;]+$/, '')
      }
    } catch {
      /* ignore bad url */
    }
  }
  const short = raw.match(/(?:b23\.tv|bili2233\.cn|b23\.wtf)\/[A-Za-z0-9]+/i)
  if (short) return `https://${short[0]}`
  const bv = raw.match(/bilibili\.com\/video\/(BV[0-9A-Za-z]{10})/i)
  if (bv) return `https://www.bilibili.com/video/${bv[1]}`
  return ''
}

export interface BilibiliClipboardWatcher {
  open: Ref<boolean>
  loading: Ref<boolean>
  error: Ref<string>
  data: Ref<BilibiliResolved | null>
  start: () => void
  check: () => Promise<void>
  close: () => void
  reset: () => void
}

export function useBilibiliClipboardWatcher(): BilibiliClipboardWatcher {
  const open = ref(false)
  const loading = ref(false)
  const error = ref('')
  const data = ref<BilibiliResolved | null>(null)

  let started = false
  let lastHandled = ''

  async function readClipboard(): Promise<string> {
    if (isNativePlatform()) {
      try {
        const { Clipboard } = await import('@capacitor/clipboard')
        const result = await Clipboard.read()
        return result.value || ''
      } catch {
        /* native clipboard permission may be unavailable */
      }
    }
    try {
      if (navigator.clipboard?.readText) {
        return (await navigator.clipboard.readText()) || ''
      }
    } catch {
      /* 权限被拒或非安全上下文 */
    }
    return ''
  }

  async function check(): Promise<void> {
    if (loading.value || open.value) return
    const text = await readClipboard()
    const link = extractBilibiliUrl(text)
    if (!link || link === lastHandled) return
    lastHandled = link
    loading.value = true
    error.value = ''
    try {
      data.value = await resolveBilibili(link)
      open.value = true
    } catch (e: unknown) {
      data.value = null
      error.value =
        (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail ||
        '解析 B 站视频失败'
    } finally {
      loading.value = false
    }
  }

  function onVisibility() {
    if (document.visibilityState === 'visible') void check()
  }

  function start(): void {
    if (started) return
    if (!(isMobileAppBuild() || isNativePlatform())) return
    started = true
    document.addEventListener('visibilitychange', onVisibility)
    window.addEventListener('focus', onVisibility)
    if (isNativePlatform()) {
      void import('@capacitor/app')
        .then(({ App }) => {
          void App.addListener('resume', () => {
            void check()
          })
        })
        .catch(() => {})
    }
    void check()
  }

  function close(): void {
    open.value = false
  }

  function reset(): void {
    open.value = false
    data.value = null
    error.value = ''
  }

  return { open, loading, error, data, start, check, close, reset }
}
