import { ref, watch } from 'vue'

export type PlayerSubtitlePosition = 'top' | 'middle' | 'bottom' | 'off'

const STORAGE_KEY = 'teco-player-subtitle-position'

function loadPosition(): PlayerSubtitlePosition {
  try {
    const v = localStorage.getItem(STORAGE_KEY)
    if (v === 'top' || v === 'middle' || v === 'bottom' || v === 'off') return v
  } catch {
    /* ignore */
  }
  return 'bottom'
}

const playerSubtitlePosition = ref<PlayerSubtitlePosition>(loadPosition())

watch(playerSubtitlePosition, (v) => {
  try {
    localStorage.setItem(STORAGE_KEY, v)
  } catch {
    /* ignore */
  }
})

export function usePlayerSubtitlePosition() {
  function setPlayerSubtitlePosition(v: PlayerSubtitlePosition) {
    playerSubtitlePosition.value = v
  }

  return {
    playerSubtitlePosition,
    setPlayerSubtitlePosition,
  }
}
