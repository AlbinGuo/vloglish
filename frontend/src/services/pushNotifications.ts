/**
 * App 系统推送（Capacitor Push Notifications）。
 *
 * - iOS 拿 APNs device token，Android 拿 FCM token；
 * - 点击通知跳转由 setupPushNotificationRouting() 在 App 启动时挂载（不等登录、支持冷启动）；
 * - token 上报需要登录态：登录后调用 initPushNotifications() + syncPushToken()；
 * - token 持久化到本地，登录/回前台会补报一次，避免"注册早于登录"漏报。
 */
import api from '@/api/client'
import router from '@/router'
import { getNativePlatform, isNativePlatform } from '@/utils/platform'

const TOKEN_KEY = 'push_token'
let inited = false

function loadToken(): string {
  try {
    return localStorage.getItem(TOKEN_KEY) || ''
  } catch {
    return ''
  }
}

function saveToken(token: string) {
  try {
    localStorage.setItem(TOKEN_KEY, token)
  } catch {
    /* ignore */
  }
}

async function reportToken(token: string) {
  if (!token) return
  try {
    await api.post('/api/push/register/', {
      token,
      platform: getNativePlatform(),
      env: import.meta.env.PROD ? 'production' : 'sandbox',
    })
  } catch {
    /* 未登录 / 网络失败：下次登录或回前台再补报 */
  }
}

/** 把本地已保存的 token 补报一次（登录后 / 回到前台时调用，幂等） */
export async function syncPushToken(): Promise<void> {
  const token = loadToken()
  if (token) await reportToken(token)
}

/** 根据推送附带数据算出要跳转的路由（发布视频 -> 视频详情页） */
function routeForPushData(data: Record<string, string>): string | null {
  const videoId = data.video_id || data.videoId
  if (videoId) return '/english/episode/' + videoId
  const articleId = data.article_id || data.articleId
  if (articleId) return '/english/reading/' + articleId
  // 系统广播等无具体内容：跳到通知中心
  if (data.type === 'admin_broadcast' || data.jump === 'notifications') return '/english/notifications'
  return null
}

async function navigateTo(path: string, attempt = 0) {
  try {
    await router.push(path)
  } catch {
    // 冷启动时 router 可能尚未就绪，稍后重试
    if (attempt < 8) {
      setTimeout(() => void navigateTo(path, attempt + 1), 120)
    }
  }
}

let routingInited = false

/**
 * 挂载"点击通知"跳转监听。应在 App 启动时调用（native 才会生效，幂等）。
 * 这样即使 App 被杀死后点通知冷启动，也能在页面就绪后跳到对应详情页。
 */
export async function setupPushNotificationRouting(): Promise<void> {
  if (!isNativePlatform() || routingInited) return
  routingInited = true
  try {
    const { PushNotifications } = await import('@capacitor/push-notifications')
    PushNotifications.addListener('pushNotificationActionPerformed', (e) => {
      const data = (e.notification?.data || {}) as Record<string, string>
      const target = routeForPushData(data)
      if (target) void navigateTo(target)
    })
  } catch {
    /* 插件不可用时忽略 */
  }
}

export async function initPushNotifications(): Promise<void> {
  if (!isNativePlatform()) return
  try {
    const { PushNotifications } = await import('@capacitor/push-notifications')

    let perm = await PushNotifications.checkPermissions()
    if (perm.receive === 'prompt') perm = await PushNotifications.requestPermissions()
    if (perm.receive !== 'granted') return

    if (!inited) {
      inited = true
      PushNotifications.addListener('registration', (t) => {
        saveToken(t.value)
        void reportToken(t.value)
      })
      PushNotifications.addListener('registrationError', (err) => {
        console.warn('[push] registrationError', err)
        void api
          .post('/api/push/register/', {
            token: '',
            platform: getNativePlatform(),
            env: import.meta.env.PROD ? 'production' : 'sandbox',
            error: JSON.stringify(err),
          })
          .catch(() => {})
      })
    }

    // 注册；刚授予权限时首次可能拿不到 token，静默重试几次
    await PushNotifications.register()
    for (let i = 0; i < 3 && !loadToken(); i++) {
      await new Promise((r) => setTimeout(r, 2500))
      if (loadToken()) break
      await PushNotifications.register()
    }
    await syncPushToken()
  } catch (e) {
    console.warn('[push] initPushNotifications 失败', e)
  }
}