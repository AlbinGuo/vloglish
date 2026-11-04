import { ref, watch } from 'vue'
import type { SubtitleAlign } from '@/utils/subtitleHtml'

const STORAGE_KEY = 'teco-subtitle-align'

function loadSubtitleAlign(): SubtitleAlign {
  try {
    const v = localStorage.getItem(STORAGE_KEY)
    if (v === 'left' || v === 'center') return v
  } catch {
    /* ignore */
  }
  return 'left'
}

const subtitleAlign = ref<SubtitleAlign>(loadSubtitleAlign())

watch(subtitleAlign, (v) => {
  try {
    localStorage.setItem(STORAGE_KEY, v)
  } catch {
    /* ignore */
  }
})

export function useSubtitleAlign() {
  function setSubtitleAlign(v: SubtitleAlign) {
    subtitleAlign.value = v
  }

  return {
    subtitleAlign,
    setSubtitleAlign,
  }
}
