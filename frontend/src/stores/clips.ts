import { defineStore } from 'pinia'
import { ref } from 'vue'
import {
  generateClipExamples as apiGenerateClipExamples,
  getSubtitleClips,
  removeSubtitleClip as apiRemoveClip,
  saveSubtitleClip as apiSaveClip,
  updateSubtitleClip as apiUpdateClip,
  type SubtitleClip,
} from '@/api/learning'
import { getErrorDetail } from '@/api/tokens'
import { useAuthStore } from '@/stores/auth'

const STORAGE_PREFIX = 'vloglish_clips_cache_v2:'
const LOCAL_TTL_MS = 10 * 60 * 1000

type CacheBlob = {
  userId: number
  items: SubtitleClip[]
  savedAt: number
}

function storageKey(userId: number) {
  return `${STORAGE_PREFIX}${userId}`
}

function readLocal(userId: number): SubtitleClip[] | null {
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

function writeLocal(userId: number, items: SubtitleClip[]) {
  try {
    localStorage.setItem(storageKey(userId), JSON.stringify({ userId, items, savedAt: Date.now() }))
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
  return '摘录加载失败，请稍后重试'
}

export const useClipsStore = defineStore('clips', () => {
  const items = ref<SubtitleClip[]>([])
  const loading = ref(false)
  const refreshing = ref(false)
  const error = ref('')
  const loadedUserId = ref<number | null>(null)

  let inflight: Promise<SubtitleClip[]> | null = null
  let inflightUserId: number | null = null

  function persist(userId: number) {
    writeLocal(userId, items.value)
  }

  function hydrateFromLocal(userId: number) {
    const cached = readLocal(userId)
    if (!cached) return false
    items.value = cached
    loadedUserId.value = userId
    return true
  }

  async function resolveUserId(): Promise<number | null> {
    const auth = useAuthStore()
    if (!auth.ready) await auth.hydrate()
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

  async function fetchClips(userId: number): Promise<SubtitleClip[]> {
    if (inflight && inflightUserId === userId) return inflight
    inflightUserId = userId
    inflight = getSubtitleClips()
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

  async function refreshInBackground(userId: number) {
    if (refreshing.value) return
    refreshing.value = true
    try {
      await fetchClips(userId)
    } catch {
      // keep cache
    } finally {
      refreshing.value = false
    }
  }

  async function load(options: { force?: boolean } = {}) {
    const userId = await resolveUserId()
    if (!userId) {
      items.value = []
      loadedUserId.value = null
      error.value = '请先登录后查看摘录'
      return
    }

    const force = Boolean(options.force)
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
      await fetchClips(userId)
    } catch (e) {
      if (!items.value.length) error.value = loadErrorMessage(e)
    } finally {
      loading.value = false
    }
  }

  async function add(payload: { text: string; video_id: string; subtitle_id?: number | null; note?: string }) {
    const row = await apiSaveClip(payload)
    const idx = items.value.findIndex((item) => item.id === row.id)
    if (idx >= 0) items.value.splice(idx, 1)
    items.value.unshift(row)
    const userId = useAuthStore().user?.id
    if (userId) persist(userId)
    return row
  }

  async function update(clipId: number, payload: { text?: string; note?: string }) {
    const row = await apiUpdateClip(clipId, payload)
    const idx = items.value.findIndex((item) => item.id === clipId)
    if (idx >= 0) items.value[idx] = row
    const userId = useAuthStore().user?.id
    if (userId) persist(userId)
    return row
  }

  async function remove(clipId: number) {
    await apiRemoveClip(clipId)
    items.value = items.value.filter((item) => item.id !== clipId)
    const userId = useAuthStore().user?.id
    if (userId) persist(userId)
  }

  async function generateExamples(clipId: number, force = false) {
    const row = await apiGenerateClipExamples(clipId, force)
    const idx = items.value.findIndex((item) => item.id === clipId)
    if (idx >= 0) items.value[idx] = row
    else items.value.unshift(row)
    const userId = useAuthStore().user?.id
    if (userId) persist(userId)
    return row
  }

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
    add,
    update,
    remove,
    generateExamples,
    invalidate,
    clear,
  }
})
