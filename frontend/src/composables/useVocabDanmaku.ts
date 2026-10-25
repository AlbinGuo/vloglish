import { ref, watch } from 'vue'

const STORAGE_KEY = 'teco-vocab-danmaku'

/** 默认关闭；仅显式存为 true 时开启（新用户默认不显示弹幕） */
function loadVocabDanmakuEnabled(): boolean {
  try {
    const v = localStorage.getItem(STORAGE_KEY)
    if (v === null) return false
    return v === 'true'
  } catch {
    /* ignore */
  }
  return false
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
