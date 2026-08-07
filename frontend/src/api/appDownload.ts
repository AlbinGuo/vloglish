import api from '@/api/client'

export interface PublicAppDownload {
  enabled: boolean
  android_version: string
  android_apk_url: string
  android_changelog: string
  ios_note: string
  ios_link: string
  has_android: boolean
}

export async function fetchAppDownload() {
  const { data } = await api.get<PublicAppDownload>('/api/app-download/')
  return data
}
