import { defineStore } from 'pinia'
import { ref } from 'vue'
import { getMyCorpusBadge, markMyCorpusSeen } from '@/api/episodes'

export const useMyCorpusBadgeStore = defineStore('myCorpusBadge', () => {
  const count = ref(0)
  const hasNew = ref(false)

  async function refresh() {
    try {
      const data = await getMyCorpusBadge()
      count.value = data.count
      hasNew.value = data.has_new
    } catch {
      count.value = 0
      hasNew.value = false
    }
  }

  async function markSeen() {
    try {
      await markMyCorpusSeen()
      hasNew.value = false
      await refresh()
    } catch {
      hasNew.value = false
    }
  }

  function clear() {
    count.value = 0
    hasNew.value = false
  }

  return { count, hasNew, refresh, markSeen, clear }
})
