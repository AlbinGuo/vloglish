import api from '@/api/client'

const API_BASE_URL = (import.meta.env.VITE_API_BASE_URL || '').replace(/\/$/, '')

export interface PublicAppDownload {
  enabled: boolean
  android_version: string
  android_version_code: number
  android_apk_url: string
  android_apk_bytes: number
  android_changelog: string
  force_update: boolean
  min_supported_version_code: number
  ios_note: string
  ios_link: string
  has_android: boolean
}

export interface AppVersionCheck {
  has_update: boolean
  force_update: boolean
  latest_version: string
  latest_version_code: number
  android_apk_url: string
  android_apk_bytes: number
  android_changelog: string
  download_page_path: string
}

/** 可计数的 Android 下载中转地址（302 → APK 直链） */
export function getAndroidApkTrackUrl() {
  return `${API_BASE_URL}/api/app-download/android/`
}

export async function fetchAppDownload() {
  const { data } = await api.get<PublicAppDownload>('/api/app-download/')
  return data
}

export async function checkAppVersion(versionCode: number) {
  const { data } = await api.get<AppVersionCheck>('/api/app/version-check/', {
    params: { version_code: versionCode },
  })
  return data
}
