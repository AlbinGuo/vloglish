import { computed, ref, watch } from 'vue'

export type PlayerSubtitleSize = 'small' | 'medium' | 'large'

const SIZE_KEY = 'teco-player-subtitle-size'
const STRIP_HIGHLIGHT_KEY = 'teco-player-subtitle-strip-highlight'

function loadSize(): PlayerSubtitleSize {
  try {
    const v = localStorage.getItem(SIZE_KEY)
    if (v === 'small' || v === 'medium' || v === 'large') return v
  } catch {
    /* ignore */
  }
  return 'medium'
}

function loadStripHighlight(): boolean {
  try {
    return localStorage.getItem(STRIP_HIGHLIGHT_KEY) === '1'
  } catch {
    return false
  }
}

const subtitleSize = ref<PlayerSubtitleSize>(loadSize())
const stripHighlight = ref<boolean>(loadStripHighlight())

const SIZE_SCALE: Record<PlayerSubtitleSize, number> = {
  small: 0.85,
  medium: 1,
  large: 1.2,
}

const sizeScale = computed(() => SIZE_SCALE[subtitleSize.value])

watch(subtitleSize, (v) => {
  try {
    localStorage.setItem(SIZE_KEY, v)
  } catch {
    /* ignore */
  }
})

watch(stripHighlight, (v) => {
  try {
    localStorage.setItem(STRIP_HIGHLIGHT_KEY, v ? '1' : '0')
  } catch {
    /* ignore */
  }
})

export function usePlayerSubtitlePrefs() {
  return {
    subtitleSize,
    stripHighlight,
    sizeScale,
    setSubtitleSize: (v: PlayerSubtitleSize) => {
      subtitleSize.value = v
    },
    setStripHighlight: (v: boolean) => {
      stripHighlight.value = v
    },
  }
}
