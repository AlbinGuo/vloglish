/**
 * App 系统推送（Capacitor Push Notifications）。
 *
 * - iOS 拿 APNs device token，Android 拿 FCM token；
 * - token 上报需要登录态：登录后调用 initPushNotifications() + syncPushToken()；
 * - token 持久化到本地，登录/回前台会补报一次，避免"注册早于登录"漏报；
 * - 仅权限未授予或非原生环境时静默返回，不影响 Web / 开发。
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
        // 失败时回传后端日志，便于后续排查（不影响正常流程）
        void api
          .post('/api/push/register/', {
            token: '',
            platform: getNativePlatform(),
            env: import.meta.env.PROD ? 'production' : 'sandbox',
            error: JSON.stringify(err),
          })
          .catch(() => {})
      })
      PushNotifications.addListener('pushNotificationActionPerformed', (e) => {
        const d = (e.notification?.data || {}) as Record<string, string>
        if (d.video_id) void router.push('/english/episode/' + d.video_id)
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