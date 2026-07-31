import { ref, watch } from 'vue'

export type HighlightStyle = 'underline' | 'background'

const STORAGE_KEY = 'teco-highlight-style'

function loadHighlightStyle(): HighlightStyle {
  try {
    const stored = localStorage.getItem(STORAGE_KEY)
    if (stored === 'underline' || stored === 'background') return stored
  } catch {
    /* ignore */
  }
  return 'background'
}

function applyHighlightStyle(style: HighlightStyle) {
  const root = document.documentElement
  root.classList.remove('highlight-style-underline', 'highlight-style-background')
  root.classList.add(`highlight-style-${style}`)
}

const highlightStyle = ref<HighlightStyle>(loadHighlightStyle())

watch(
  highlightStyle,
  (style) => {
    try {
      localStorage.setItem(STORAGE_KEY, style)
    } catch {
      /* ignore */
    }
    applyHighlightStyle(style)
  },
  { immediate: true },
)

export function useHighlightStyle() {
  function setHighlightStyle(style: HighlightStyle) {
    highlightStyle.value = style
  }

  return {
    highlightStyle,
    setHighlightStyle,
  }
}
