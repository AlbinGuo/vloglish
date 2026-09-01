import { defineStore } from 'pinia'
import { computed, ref } from 'vue'
import {
  fetchVoiceCloneStatus,
  setVoiceClonePreferPlayback,
  type ClonedVoiceInfo,
} from '@/api/voiceClone'
import { useAuthStore } from '@/stores/auth'

const VOICE_MODE_KEY = 'vloglish.subtitleVoiceMode'

/**
 * 复刻音色按登录账号存在服务端，各端（App / 手机浏览器 / iPad / PC）共享。
 */
export const useVoiceCloneStore = defineStore('voiceClone', () => {
  const voice = ref<ClonedVoiceInfo | null>(null)
  const loading = ref(false)
  const loaded = ref(false)
  const error = ref('')
  const configured = ref(true)
  const enrollText = ref('')
  const subtitleVoiceMode = ref<'original' | 'cloned'>(
    typeof localStorage !== 'undefined' && localStorage.getItem(VOICE_MODE_KEY) === 'cloned'
      ? 'cloned'
      : 'original',
  )

  const hasClonedVoice = computed(() => Boolean(voice.value?.voice))

  function persistMode(mode: 'original' | 'cloned') {
    subtitleVoiceMode.value = mode
    try {
      localStorage.setItem(VOICE_MODE_KEY, mode)
    } catch {
      /* ignore */
    }
  }

  async function refresh(): Promise<ClonedVoiceInfo | null> {
    const auth = useAuthStore()
    if (!auth.ready || !auth.isLoggedIn) {
      voice.value = null
      loaded.value = true
      error.value = ''
      return null
    }
    loading.value = true
    error.value = ''
    try {
      const st = await fetchVoiceCloneStatus()
      configured.value = st.configured
      if (st.enrollText) enrollText.value = st.enrollText
      voice.value = st.voice
      loaded.value = true
      if (st.voice?.voice) {
        const prefer = st.voice.preferPlayback !== false
        persistMode(prefer ? 'cloned' : 'original')
      } else if (subtitleVoiceMode.value === 'cloned') {
        persistMode('original')
      }
      return st.voice
    } catch (e) {
      loaded.value = true
      error.value = e instanceof Error ? e.message : '无法加载复刻音色'
      // 失败时不要清空已有内存态，避免短暂网络错误导致误判「未复刻」
      return voice.value
    } finally {
      loading.value = false
    }
  }

  function setLocalVoice(next: ClonedVoiceInfo | null) {
    voice.value = next
    loaded.value = true
    if (next?.voice) {
      persistMode(next.preferPlayback === false ? 'original' : 'cloned')
    } else if (subtitleVoiceMode.value === 'cloned') {
      persistMode('original')
    }
  }

  async function setPreferPlayback(prefer: boolean): Promise<boolean> {
    if (!hasClonedVoice.value) return false
    try {
      const next = await setVoiceClonePreferPlayback(prefer)
      voice.value = next
      persistMode(prefer ? 'cloned' : 'original')
      return true
    } catch (e) {
      error.value = e instanceof Error ? e.message : '同步声音偏好失败'
      return false
    }
  }

  /**
   * 切换字幕声音。若本地还没有音色，先向服务端拉取；仍没有再返回 needEnroll。
   */
  async function selectMode(mode: 'original' | 'cloned'): Promise<'ok' | 'needEnroll' | 'needLogin'> {
    const auth = useAuthStore()
    if (mode === 'original') {
      persistMode('original')
      if (auth.isLoggedIn && hasClonedVoice.value) {
        void setPreferPlayback(false)
      }
      return 'ok'
    }

    if (!auth.isLoggedIn) return 'needLogin'

    if (!hasClonedVoice.value) {
      await refresh()
    }
    if (!hasClonedVoice.value) return 'needEnroll'

    persistMode('cloned')
    void setPreferPlayback(true)
    return 'ok'
  }

  function clear() {
    voice.value = null
    loaded.value = false
    error.value = ''
    loading.value = false
  }

  return {
    voice,
    loading,
    loaded,
    error,
    configured,
    enrollText,
    subtitleVoiceMode,
    hasClonedVoice,
    refresh,
    setLocalVoice,
    setPreferPlayback,
    selectMode,
    persistMode,
    clear,
  }
})
