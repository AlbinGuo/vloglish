import { defineStore } from 'pinia'
import { ref } from 'vue'
import { useSiteConfigStore } from '@/stores/siteConfig'

/** 普通用户 AI 日额度用尽时的确认弹窗（不强制跳转） */
export const useAiQuotaPromptStore = defineStore('aiQuotaPrompt', () => {
  const open = ref(false)
  const detail = ref('')

  function show(message = '') {
    if (message && message.trim()) {
      detail.value = message.trim()
    } else {
      const gated = useSiteConfigStore().isContentGated
      detail.value = gated
        ? '今日 AI 免费次数已用完。开通会员后可无限使用讲解、挖空、跟读等功能。'
        : '今日 AI 免费次数已用完，请明天再试。'
    }
    open.value = true
  }

  function close() {
    open.value = false
  }

  return { open, detail, show, close }
})
