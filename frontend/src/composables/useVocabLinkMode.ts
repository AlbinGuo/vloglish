import { ref, watch } from 'vue'

const STORAGE_KEY = 'reading-vocab-link-mode'

function loadEnabled(): boolean {
  try {
    const stored = localStorage.getItem(STORAGE_KEY)
    if (stored === 'false') return false
    if (stored === 'true') return true
  } catch {
    /* ignore */
  }
  // 默认开启
  return true
}

const enabled = ref(loadEnabled())

watch(enabled, (value) => {
  try {
    localStorage.setItem(STORAGE_KEY, value ? 'true' : 'false')
  } catch {
    /* ignore */
  }
})

/** 新闻阅读「词文对照 / 词文串学」模式，默认开 */
export function useVocabLinkMode() {
  function toggle() {
    enabled.value = !enabled.value
  }

  return { vocabLinkMode: enabled, toggleVocabLinkMode: toggle }
}
