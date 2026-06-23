import { ref, watch } from 'vue'

export type SentenceProgressStyle = 'off' | 'bar' | 'gradient'

const STORAGE_KEY = 'teco-sentence-progress-style'

function loadSentenceProgressStyle(): SentenceProgressStyle {
  try {
    const stored = localStorage.getItem(STORAGE_KEY)
    if (stored === 'off' || stored === 'bar' || stored === 'gradient') return stored
  } catch {
    /* ignore */
  }
  return 'off'
}

const sentenceProgressStyle = ref<SentenceProgressStyle>(loadSentenceProgressStyle())

watch(sentenceProgressStyle, (style) => {
  try {
    localStorage.setItem(STORAGE_KEY, style)
  } catch {
    /* ignore */
  }
})

export function useSentenceProgressStyle() {
  function setSentenceProgressStyle(style: SentenceProgressStyle) {
    sentenceProgressStyle.value = style
  }

  return {
    sentenceProgressStyle,
    setSentenceProgressStyle,
  }
}
