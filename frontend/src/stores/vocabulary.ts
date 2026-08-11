import { defineStore } from 'pinia'
import { ref } from 'vue'
import {
  getVocabulary,
  removeVocabulary as apiRemoveVocabulary,
  type VocabularyItem,
} from '@/api/learning'
import { getErrorDetail } from '@/api/tokens'
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

function loadErrorMessage(error: unknown): string {
  const status = (error as { response?: { status?: number } })?.response?.status
  const detail = getErrorDetail(error)
  const code = (error as { code?: string })?.code
  if (status === 401) return '登录已失效，请重新登录'
  if (status === 502 || (typeof detail === 'string' && detail.includes('后端未启动'))) {
    return '后端未连接，请确认服务已启动后重试'
  }
  if (code === 'ECONNABORTED' || code === 'ERR_NETWORK') {
    return code === 'ECONNABORTED' ? '加载超时，请稍后重试' : '网络异常，请稍后重试'
  }
  if (detail) return detail
  return '生词本加载失败，请稍后重试'
}

export const useVocabularyStore = defineStore('vocabulary', () => {
  const items = ref<VocabularyItem[]>([])
  const loading = ref(false)
  const refreshing = ref(false)
  const error = ref('')
  const loadedUserId = ref<number | null>(null)

  /** 合并 Layout / 页面并发 load，避免重复打接口 */
  let inflight: Promise<VocabularyItem[]> | null = null
  let inflightUserId: number | null = null

  function hydrateFromLocal(userId: number) {
    const cached = readLocal(userId)
    if (!cached) return false
    items.value = cached
    loadedUserId.value = userId
    return true
  }

  async function resolveUserId(): Promise<number | null> {
    const auth = useAuthStore()
    if (!auth.ready) {
      await auth.hydrate()
    }
    if (auth.user?.id) return auth.user.id
    if (auth.accessToken) {
      try {
        await auth.fetchMe()
      } catch {
        return null
      }
    }
    return auth.user?.id ?? null
  }

  async function fetchVocabulary(userId: number): Promise<VocabularyItem[]> {
    if (inflight && inflightUserId === userId) return inflight
    inflightUserId = userId
    inflight = getVocabulary()
      .then((data) => {
        if (useAuthStore().user?.id === userId) {
          items.value = data
          loadedUserId.value = userId
          writeLocal(userId, data)
          error.value = ''
        }
        return data
      })
      .finally(() => {
        if (inflightUserId === userId) {
          inflight = null
          inflightUserId = null
        }
      })
    return inflight
  }

  async function load(options: { force?: boolean } = {}) {
    const userId = await resolveUserId()
    if (!userId) {
      items.value = []
      loadedUserId.value = null
      error.value = '请先登录后查看生词本'
      return
    }

    const force = Boolean(options.force)
    // 先展示内存/本地缓存，后台静默刷新（stale-while-revalidate）
    if (!force) {
      if (loadedUserId.value === userId && items.value.length) {
        error.value = ''
        void refreshInBackground(userId)
        return
      }
      if (hydrateFromLocal(userId)) {
        error.value = ''
        void refreshInBackground(userId)
        return
      }
    }

    loading.value = true
    error.value = ''
    try {
      await fetchVocabulary(userId)
    } catch (e) {
      if (!items.value.length) error.value = loadErrorMessage(e)
    } finally {
      loading.value = false
    }
  }

  async function refreshInBackground(userId: number) {
    if (refreshing.value) return
    refreshing.value = true
    try {
      await fetchVocabulary(userId)
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
    inflight = null
    inflightUserId = null
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
