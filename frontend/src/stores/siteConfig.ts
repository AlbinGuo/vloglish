import { defineStore } from 'pinia'
import { computed, ref } from 'vue'
import { fetchSiteConfig } from '@/api/siteConfig'

export const useSiteConfigStore = defineStore('siteConfig', () => {
  const membershipGateEnabled = ref(true)
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
    } catch {
      membershipGateEnabled.value = true
    } finally {
      ready.value = true
    }
  }

  function setMembershipGateEnabled(enabled: boolean) {
    membershipGateEnabled.value = enabled
  }

  return {
    membershipGateEnabled,
    ready,
    isContentGated,
    memberToolsOpen,
    hydrate,
    setMembershipGateEnabled,
  }
})
