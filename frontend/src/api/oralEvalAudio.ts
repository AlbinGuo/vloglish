import api from '@/api/client'

/** 通过后端代理拉取口语云端录音，避免 HTTPS 页加载 http 音频被拦截 */
export async function fetchOralRemoteAudio(remoteUrl: string): Promise<Blob> {
  const { data } = await api.get<Blob>('/api/ai/oral-eval/audio/', {
    params: { url: remoteUrl },
    responseType: 'blob',
    timeout: 60000,
  })
  if (!(data instanceof Blob) || data.size <= 0) {
    throw new Error('录音下载失败')
  }
  if (data.type && data.type.includes('application/json')) {
    throw new Error('录音地址无效')
  }
  return data
}
