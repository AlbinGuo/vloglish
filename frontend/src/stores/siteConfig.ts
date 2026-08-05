import { defineStore } from 'pinia'
import { computed, ref } from 'vue'
import { fetchSiteConfig } from '@/api/siteConfig'

export const useSiteConfigStore = defineStore('siteConfig', () => {
  const membershipGateEnabled = ref(true)
  const ready = ref(false)

  /** 是否仍对非会员做内容限量（视频/合集/文章） */
  const isContentGated = computed(() => membershipGateEnabled.value)

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
    hydrate,
    setMembershipGateEnabled,
  }
})
