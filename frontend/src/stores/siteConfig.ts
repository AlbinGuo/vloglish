import { defineStore } from 'pinia'
import { computed, ref } from 'vue'
import { fetchSiteConfig } from '@/api/siteConfig'

export const useSiteConfigStore = defineStore('siteConfig', () => {
  const membershipGateEnabled = ref(true)
  const languageSelectionEnabled = ref(true)
  const availableTargetLanguages = ref<string[]>(['en', 'de', 'fr'])
  const ready = ref(false)

  /** 是否仍对非会员做内容限量（视频/合集/文章） */
  const isContentGated = computed(() => membershipGateEnabled.value)

  /**
   * 关会员内容限制时：登录用户可走上传视频/文章、我的语料库等入口
   *（不必 is_member；AI 日限仍按会员身份）
   */
  const memberToolsOpen = computed(() => !membershipGateEnabled.value)

  async function hydrate() {
    try {
      const data = await fetchSiteConfig()
      membershipGateEnabled.value = data.membership_gate_enabled
      languageSelectionEnabled.value = data.language_selection_enabled
      availableTargetLanguages.value = data.available_target_languages?.length
        ? data.available_target_languages
        : ['en', 'de', 'fr']
    } catch {
      membershipGateEnabled.value = true
    } finally {
      ready.value = true
    }
  }

  function setMembershipGateEnabled(enabled: boolean) {
    membershipGateEnabled.value = enabled
  }

  function setLanguageSelectionEnabled(enabled: boolean) {
    languageSelectionEnabled.value = enabled
  }

  function setAvailableTargetLanguages(codes: string[]) {
    availableTargetLanguages.value = codes
  }

  return {
    membershipGateEnabled,
    languageSelectionEnabled,
    availableTargetLanguages,
    ready,
    isContentGated,
    memberToolsOpen,
    hydrate,
    setMembershipGateEnabled,
    setLanguageSelectionEnabled,
    setAvailableTargetLanguages,
  }
})
