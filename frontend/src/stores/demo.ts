import { defineStore } from 'pinia'
import { ref } from 'vue'
import { getDemoEpisodes, verifyDemoCode } from '@/api/demo'
import { getDemoCode, isDemoVerified } from '@/api/client'
import type { EpisodeSummary } from '@/types'

export const useDemoStore = defineStore('demo', () => {
  const verified = ref(isDemoVerified())
  const code = ref(getDemoCode() ?? '')
  const episodes = ref<EpisodeSummary[]>([])
  const loading = ref(false)
  const error = ref('')

  async function verify(inputCode?: string) {
    const c = (inputCode ?? code.value).trim()
    if (!c) return false
    loading.value = true
    error.value = ''
    try {
      const res = await verifyDemoCode(c)
      if (res.success) {
        verified.value = true
        code.value = c
        await loadEpisodes()
        return true
      }
      error.value = res.message || '无效体验码'
      return false
    } catch (e: unknown) {
      const err = e as { response?: { data?: { message?: string } } }
      error.value = err.response?.data?.message ?? '验证失败'
      return false
    } finally {
      loading.value = false
    }
  }

  async function loadEpisodes() {
    loading.value = true
    try {
      episodes.value = await getDemoEpisodes()
    } catch {
      episodes.value = []
      error.value = '加载试用内容失败'
    } finally {
      loading.value = false
    }
  }

  async function init() {
    if (verified.value) await loadEpisodes()
  }

  return { verified, code, episodes, loading, error, verify, loadEpisodes, init }
})
