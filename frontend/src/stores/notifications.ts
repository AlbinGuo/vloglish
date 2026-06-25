import { defineStore } from 'pinia'
import { ref } from 'vue'
import { getUnreadNotificationCount } from '@/api/notifications'

export const useNotificationStore = defineStore('notifications', () => {
  const unreadCount = ref(0)

  async function refresh() {
    try {
      unreadCount.value = await getUnreadNotificationCount()
    } catch {
      unreadCount.value = 0
    }
  }

  function setCount(count: number) {
    unreadCount.value = Math.max(0, count)
  }

  function decrement(by = 1) {
    unreadCount.value = Math.max(0, unreadCount.value - by)
  }

  function clear() {
    unreadCount.value = 0
  }

  return { unreadCount, refresh, setCount, decrement, clear }
})
