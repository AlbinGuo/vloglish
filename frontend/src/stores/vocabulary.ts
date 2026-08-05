import { defineStore } from 'pinia'
import { ref } from 'vue'
import {
  getVocabulary,
  removeVocabulary as apiRemoveVocabulary,
  type VocabularyItem,
} from '@/api/learning'
import { useAuthStore } from '@/stores/auth'

const STORAGE_PREFIX = 'vloglish_vocab_cache_v1:'
const LOCAL_TTL_MS = 10 * 60 * 1000

type CacheBlob = {
  userId: number
  items: VocabularyItem[]
  savedAt: number
}

function storageKey(userId: number) {
  return `${STORAGE_PREFIX}${userId}`
}

function readLocal(userId: number): VocabularyItem[] | null {
  try {
    const raw = localStorage.getItem(storageKey(userId))
    if (!raw) return null
    const data = JSON.parse(raw) as CacheBlob
    if (data.userId !== userId || !Array.isArray(data.items)) return null
    if (Date.now() - data.savedAt > LOCAL_TTL_MS) return null
    return data.items
  } catch {
    return null
  }
}

function writeLocal(userId: number, items: VocabularyItem[]) {
  try {
    const blob: CacheBlob = { userId, items, savedAt: Date.now() }
    localStorage.setItem(storageKey(userId), JSON.stringify(blob))
  } catch {
    // quota / private mode
  }
}

function clearLocal(userId: number) {
  try {
    localStorage.removeItem(storageKey(userId))
  } catch {
    // ignore
  }
}

export const useVocabularyStore = defineStore('vocabulary', () => {
  const items = ref<VocabularyItem[]>([])
  const loading = ref(false)
  const refreshing = ref(false)
  const error = ref('')
  const loadedUserId = ref<number | null>(null)

  function hydrateFromLocal(userId: number) {
    const cached = readLocal(userId)
    if (!cached) return false
    items.value = cached
    loadedUserId.value = userId
    return true
  }

  async function load(options: { force?: boolean } = {}) {
    const auth = useAuthStore()
    const userId = auth.user?.id
    if (!userId) {
      items.value = []
      loadedUserId.value = null
      error.value = '加载失败，请先登录'
      return
    }

    const force = Boolean(options.force)
    // 先展示内存/本地缓存，后台静默刷新（stale-while-revalidate）
    if (!force) {
      if (loadedUserId.value === userId) {
        void refreshInBackground(userId)
        return
      }
      if (hydrateFromLocal(userId)) {
        void refreshInBackground(userId)
        return
      }
    }

    loading.value = true
    error.value = ''
    try {
      const data = await getVocabulary()
      items.value = data
      loadedUserId.value = userId
      writeLocal(userId, data)
    } catch {
      if (!items.value.length) error.value = '加载失败，请先登录'
    } finally {
      loading.value = false
    }
  }

  async function refreshInBackground(userId: number) {
    if (refreshing.value) return
    refreshing.value = true
    try {
      const data = await getVocabulary()
      if (useAuthStore().user?.id !== userId) return
      items.value = data
      loadedUserId.value = userId
      writeLocal(userId, data)
      error.value = ''
    } catch {
      // 保留缓存展示
    } finally {
      refreshing.value = false
    }
  }

  async function remove(entryId: number) {
    await apiRemoveVocabulary(entryId)
    items.value = items.value.filter((v) => v.entry_id !== entryId)
    const userId = useAuthStore().user?.id
    if (userId) writeLocal(userId, items.value)
  }

  /** 标记缓存失效并重新拉取（保留旧列表直至新数据返回，避免顶栏词数闪 0） */
  function invalidate() {
    const userId = useAuthStore().user?.id
    loadedUserId.value = null
    if (userId) {
      clearLocal(userId)
      void load({ force: true })
      return
    }
    items.value = []
  }

  function clear() {
    items.value = []
    loadedUserId.value = null
    error.value = ''
    const userId = useAuthStore().user?.id
    if (userId) clearLocal(userId)
  }

  return {
    items,
    loading,
    refreshing,
    error,
    load,
    remove,
    invalidate,
    clear,
  }
})
