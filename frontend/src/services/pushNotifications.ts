/**
 * App 系统推送（Capacitor Push Notifications）。
 *
 * - iOS 拿到的是 APNs device token，Android 拿到的是 FCM token；
 * - token 上报需要登录态，故在登录后调用 initPushNotifications()；
 * - 权限未授予或非原生环境时静默返回，不影响 Web / 开发。
 */
import api from '@/api/client'
import router from '@/router'
import { getNativePlatform, isNativePlatform } from '@/utils/platform'

let inited = false
let lastToken = ''

async function reportToken(token: string) {
  if (!token) return
  try {
    await api.post('/api/push/register/', {
      token,
      platform: getNativePlatform(),
      env: import.meta.env.PROD ? 'production' : 'sandbox',
    })
  } catch {
    /* 未登录 / 网络失败：登录后会自动重试 */
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
        lastToken = t.value
        void reportToken(t.value)
      })
      PushNotifications.addListener('pushNotificationActionPerformed', (e) => {
        const d = (e.notification?.data || {}) as Record<string, string>
        if (d.video_id) void router.push(`/english/episode/${d.video_id}`)
      })
    }

    await PushNotifications.register()
    if (lastToken) void reportToken(lastToken)
  } catch {
    /* 模拟器 / 未配置 / 用户拒绝：忽略 */
  }
}
