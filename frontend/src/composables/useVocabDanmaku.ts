import { ref, watch } from 'vue'

const STORAGE_KEY = 'teco-vocab-danmaku'

/** 默认开启；仅显式存 false 时关闭 */
function loadVocabDanmakuEnabled(): boolean {
  try {
    const v = localStorage.getItem(STORAGE_KEY)
    if (v === null) return true
    return v === 'true'
  } catch {
    /* ignore */
  }
  return true
}

const vocabDanmakuEnabled = ref(loadVocabDanmakuEnabled())

watch(vocabDanmakuEnabled, (enabled) => {
  try {
    localStorage.setItem(STORAGE_KEY, enabled ? 'true' : 'false')
  } catch {
    /* ignore */
  }
})

export function useVocabDanmaku() {
  function setVocabDanmakuEnabled(enabled: boolean) {
    vocabDanmakuEnabled.value = enabled
  }

  function toggleVocabDanmaku() {
    vocabDanmakuEnabled.value = !vocabDanmakuEnabled.value
  }

  return {
    vocabDanmakuEnabled,
    setVocabDanmakuEnabled,
    toggleVocabDanmaku,
  }
}
