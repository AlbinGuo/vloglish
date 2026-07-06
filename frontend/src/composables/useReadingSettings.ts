import { computed, ref, watch } from 'vue'

export type ReadingWordHighlightStyle = 'color' | 'color-underline'
export type ReadingLayoutMode = 'dual' | 'single'

const WORD_HIGHLIGHT_KEY = 'reading-word-highlight-style'
const LAYOUT_MODE_KEY = 'reading-layout-mode'

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

const wordHighlightStyle = ref<ReadingWordHighlightStyle>(loadWordHighlightStyle())
const layoutMode = ref<ReadingLayoutMode>(loadLayoutMode())

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

  return {
    wordHighlightStyle,
    layoutMode,
    readingPageClass,
    setWordHighlightStyle,
    setLayoutMode,
  }
}
