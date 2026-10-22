/**
 * App 系统推送（Capacitor Push Notifications）。
 * 关键阶段回传后端日志，便于无 Mac 排查 iOS 拿不到 token 的原因。
 */
import api from '@/api/client'
import router from '@/router'
import { getNativePlatform, isMobileAppBuild, isNativePlatform } from '@/utils/platform'

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

async function reportStage(stage: string, error = '') {
  try {
    await api.post('/api/push/register/', {
      token: '',
      platform: getNativePlatform(),
      env: import.meta.env.PROD ? 'production' : 'sandbox',
      stage,
      error,
    })
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
  } catch (e) {
    console.warn('[push] 上报 token 失败（稍后重试）', e)
  }
}

export async function syncPushToken(): Promise<void> {
  const token = loadToken()
  if (token) await reportToken(token)
}

export async function initPushNotifications(): Promise<void> {
  // App 构建无论原生检测结果如何都先上报一次，确认新代码确实在跑、并暴露 platform 识别情况
  if (isMobileAppBuild()) await reportStage('init:platform=' + getNativePlatform())
  if (!isNativePlatform()) return
  try {
    const { PushNotifications } = await import('@capacitor/push-notifications')

    let perm = await PushNotifications.checkPermissions()
    if (perm.receive === 'prompt') perm = await PushNotifications.requestPermissions()
    await reportStage('perm:' + perm.receive)
    if (perm.receive !== 'granted') return

    if (!inited) {
      inited = true
      PushNotifications.addListener('registration', (t) => {
        saveToken(t.value)
        void reportToken(t.value)
      })
      PushNotifications.addListener('registrationError', (err) => {
        console.warn('[push] registrationError', err)
        void reportStage('registrationError', JSON.stringify(err))
      })
      PushNotifications.addListener('pushNotificationActionPerformed', (e) => {
        const d = (e.notification?.data || {}) as Record<string, string>
        if (d.video_id) void router.push('/english/episode/' + d.video_id)
      })
    }

    await PushNotifications.register()
    await syncPushToken()
  } catch (e) {
    console.warn('[push] initPushNotifications 失败', e)
    void reportStage('exception', String(e))
  }
}