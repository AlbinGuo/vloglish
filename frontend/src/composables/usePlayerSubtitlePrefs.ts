import { computed, ref, watch } from 'vue'

export type PlayerSubtitleSize = 'small' | 'medium' | 'large'

const SIZE_KEY = 'teco-player-subtitle-size'

function loadSize(): PlayerSubtitleSize {
  try {
    const v = localStorage.getItem(SIZE_KEY)
    if (v === 'small' || v === 'medium' || v === 'large') return v
  } catch {
    /* ignore */
  }
  return 'small'
}

const subtitleSize = ref<PlayerSubtitleSize>(loadSize())

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

export function usePlayerSubtitlePrefs() {
  return {
    subtitleSize,
    sizeScale,
    setSubtitleSize: (v: PlayerSubtitleSize) => {
      subtitleSize.value = v
    },
  }
}
