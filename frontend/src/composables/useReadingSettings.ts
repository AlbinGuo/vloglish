import { computed, ref, watch } from 'vue'

export type ReadingWordHighlightStyle = 'color' | 'color-underline'
export type ReadingLayoutMode = 'dual' | 'single'
export type ReadingTtsRate = 0.75 | 1 | 1.25

const WORD_HIGHLIGHT_KEY = 'reading-word-highlight-style'
const LAYOUT_MODE_KEY = 'reading-layout-mode'
const TTS_RATE_KEY = 'reading-tts-rate'
const TTS_AUTO_ADVANCE_KEY = 'reading-tts-auto-advance'
const TTS_AUTO_SCROLL_KEY = 'reading-tts-auto-scroll'

function loadWordHighlightStyle(): ReadingWordHighlightStyle {
  try {
    const stored = localStorage.getItem(WORD_HIGHLIGHT_KEY)
    if (stored === 'color' || stored === 'color-underline') return stored
  } catch {
    /* ignore */
  }
  return 'color-underline'
}

function loadLayoutMode(): ReadingLayoutMode {
  try {
    const stored = localStorage.getItem(LAYOUT_MODE_KEY)
    if (stored === 'dual' || stored === 'single') return stored
  } catch {
    /* ignore */
  }
  return 'dual'
}

function loadTtsRate(): ReadingTtsRate {
  try {
    const stored = Number(localStorage.getItem(TTS_RATE_KEY))
    if (stored === 0.75 || stored === 1 || stored === 1.25) return stored
  } catch {
    /* ignore */
  }
  return 1
}

function loadBool(key: string, defaultValue: boolean): boolean {
  try {
    const stored = localStorage.getItem(key)
    if (stored === 'true') return true
    if (stored === 'false') return false
  } catch {
    /* ignore */
  }
  return defaultValue
}

const wordHighlightStyle = ref<ReadingWordHighlightStyle>(loadWordHighlightStyle())
const layoutMode = ref<ReadingLayoutMode>(loadLayoutMode())
const ttsRate = ref<ReadingTtsRate>(loadTtsRate())
const autoAdvance = ref(loadBool(TTS_AUTO_ADVANCE_KEY, true))
const autoScrollOnTts = ref(loadBool(TTS_AUTO_SCROLL_KEY, true))

watch(wordHighlightStyle, (value) => {
  try {
    localStorage.setItem(WORD_HIGHLIGHT_KEY, value)
  } catch {
    /* ignore */
  }
})

watch(layoutMode, (value) => {
  try {
    localStorage.setItem(LAYOUT_MODE_KEY, value)
  } catch {
    /* ignore */
  }
})

watch(ttsRate, (value) => {
  try {
    localStorage.setItem(TTS_RATE_KEY, String(value))
  } catch {
    /* ignore */
  }
})

watch(autoAdvance, (value) => {
  try {
    localStorage.setItem(TTS_AUTO_ADVANCE_KEY, value ? 'true' : 'false')
  } catch {
    /* ignore */
  }
})

watch(autoScrollOnTts, (value) => {
  try {
    localStorage.setItem(TTS_AUTO_SCROLL_KEY, value ? 'true' : 'false')
  } catch {
    /* ignore */
  }
})

export function useReadingSettings() {
  const readingPageClass = computed(() => ({
    'reading-highlight-color-only': wordHighlightStyle.value === 'color',
    'reading-highlight-underline': wordHighlightStyle.value === 'color-underline',
  }))

  function setWordHighlightStyle(style: ReadingWordHighlightStyle) {
    wordHighlightStyle.value = style
  }

  function setLayoutMode(mode: ReadingLayoutMode) {
    layoutMode.value = mode
  }

  function setTtsRate(rate: ReadingTtsRate) {
    ttsRate.value = rate
  }

  return {
    wordHighlightStyle,
    layoutMode,
    ttsRate,
    autoAdvance,
    autoScrollOnTts,
    readingPageClass,
    setWordHighlightStyle,
    setLayoutMode,
    setTtsRate,
  }
}
