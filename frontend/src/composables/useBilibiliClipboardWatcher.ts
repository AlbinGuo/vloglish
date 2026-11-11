import { ref, type Ref } from 'vue'
import { isMobileAppBuild, isNativePlatform } from '@/utils/platform'
import { resolveBilibili, type BilibiliResolved } from '@/api/bilibili'

const BILI_HOSTS = ['bilibili.com', 'b23.tv', 'bili2233.cn', 'b23.wtf']
const URL_RE = /https?:\/\/[^\s"'<>）】]+/gi
const HANDLED_KEY = 'vloglish.bili.clip.handled'
const IMPORTED_KEY = 'vloglish.bili.clip.imported'

function readStore(key: string): string {
  try {
    return localStorage.getItem(key) || ''
  } catch {
    return ''
  }
}

function writeStore(key: string, value: string): void {
  try {
    localStorage.setItem(key, value)
  } catch {
    /* ignore quota errors */
  }
}

function loadImported(): string[] {
  try {
    const list = JSON.parse(readStore(IMPORTED_KEY) || '[]')
    return Array.isArray(list) ? list.filter((v) => typeof v === 'string') : []
  } catch {
    return []
  }
}

function saveImported(list: string[]): void {
  writeStore(IMPORTED_KEY, JSON.stringify(list.slice(-100)))
}

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
  markImported: (bvid: string) => void
  clearHistory: () => void
}

// 模块级单例：App 与设置页共享同一份状态与去重记录
const open = ref(false)
const loading = ref(false)
const error = ref('')
const data = ref<BilibiliResolved | null>(null)

let started = false
// 本次会话已提示过的链接（避免取消后反复弹），导入成功后还会持久化
let sessionHandled = ''
let lastLink = ''
// 读取/检查节流：避免 resume/visibility/focus 多次触发重复读取，减少 iOS 粘贴气泡
let lastReadTs = 0
let lastReadText = ''
let lastCheckTs = 0

async function readClipboard(): Promise<string> {
  const now = Date.now()
  // 1.5s 内复用上次读数，避免连续系统剪贴板访问触发系统“粘贴”提示
  if (now - lastReadTs < 1500) return lastReadText
  lastReadTs = now
  if (isNativePlatform()) {
    try {
      const { Clipboard } = await import('@capacitor/clipboard')
      lastReadText = (await Clipboard.read()).value || ''
      return lastReadText
    } catch {
      // 原生读取失败时不要回退到 navigator.clipboard：
      // WebView 的 readText 会弹出持久的系统“粘贴”授权气泡，这里直接放弃本次读取
      lastReadText = ''
      return ''
    }
  }
  // 仅 Web/PWA 使用 navigator
  try {
    if (navigator.clipboard?.readText) {
      lastReadText = (await navigator.clipboard.readText()) || ''
      return lastReadText
    }
  } catch {
    /* 权限被拒或非安全上下文 */
  }
  lastReadText = ''
  return ''
}

async function check(): Promise<void> {
  // 正在解析，或已打开并展示着内容时不再重复处理
  if (loading.value || (open.value && data.value)) return
  const now = Date.now()
  if (now - lastCheckTs < 800) return
  lastCheckTs = now
  const text = await readClipboard()
  const link = extractBilibiliUrl(text)
  if (!link) return
  // 已导入过 / 本次会话已提示过 / 持久化记录命中，都不再弹
  if (link === sessionHandled || link === readStore(HANDLED_KEY)) return

  // 立即给用户提示：先打开弹窗展示“解析中”，再填充内容
  open.value = true
  loading.value = true
  data.value = null
  error.value = ''
  try {
    const meta = await resolveBilibili(link)
    lastLink = link
    sessionHandled = link
    if (loadImported().includes(meta.bvid)) {
      // 已经导入过：静默关闭，避免重复弹窗
      writeStore(HANDLED_KEY, link)
      open.value = false
      return
    }
    data.value = meta
  } catch (e: unknown) {
    data.value = null
    error.value =
      (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail ||
      '解析 B 站视频失败，请稍后重试'
  } finally {
    loading.value = false
  }
}

/** 导入成功后调用：记住该链接与视频，之后切回 App 不再重复弹窗。 */
function markImported(bvid: string): void {
  if (bvid) {
    const list = loadImported()
    if (!list.includes(bvid)) {
      list.push(bvid)
      saveImported(list)
    }
  }
  if (lastLink) {
    writeStore(HANDLED_KEY, lastLink)
    sessionHandled = lastLink
  }
}

/** 清除“已提示/已导入”记录，让同一视频可以重新触发剪贴板导入。 */
function clearHistory(): void {
  try {
    localStorage.removeItem(HANDLED_KEY)
    localStorage.removeItem(IMPORTED_KEY)
  } catch {
    /* ignore */
  }
  sessionHandled = ''
  lastLink = ''
  open.value = false
  data.value = null
  error.value = ''
}

function onVisibility() {
  if (document.visibilityState === 'visible') void check()
}

function start(): void {
  if (started) return
  if (!(isMobileAppBuild() || isNativePlatform())) return
  started = true
  if (isNativePlatform()) {
    // 原生壳只监听真正的“回到前台”，避免 WebView 内 visibility/focus 重复触发读取
    void import('@capacitor/app')
      .then(({ App }) => {
        void App.addListener('resume', () => {
          void check()
        })
      })
      .catch(() => {})
  } else {
    // 非原生（如 PWA）退回页面可见性
    document.addEventListener('visibilitychange', onVisibility)
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

export function useBilibiliClipboardWatcher(): BilibiliClipboardWatcher {
  return { open, loading, error, data, start, check, close, reset, markImported, clearHistory }
}
