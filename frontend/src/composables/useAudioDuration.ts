import { computed, onUnmounted, ref, toValue, watch, type MaybeRefOrGetter } from 'vue'
import { formatAudioClock, probeAudioDuration } from '@/utils/audioDuration'

/** 根据录音 URL 探测时长，供回放按钮展示 */
export function useAudioDuration(urlSource: MaybeRefOrGetter<string | null | undefined>) {
  const durationSec = ref<number | null>(null)
  let token = 0

  const label = computed(() =>
    durationSec.value != null ? formatAudioClock(durationSec.value) : '',
  )

  async function refresh() {
    const url = (toValue(urlSource) || '').trim()
    const my = ++token
    if (!url) {
      durationSec.value = null
      return
    }
    const sec = await probeAudioDuration(url)
    if (my !== token) return
    durationSec.value = sec
  }

  function setKnownDuration(sec: number | null | undefined) {
    if (sec == null || !Number.isFinite(sec) || sec <= 0) return
    durationSec.value = sec
  }

  watch(() => toValue(urlSource), () => {
    void refresh()
  }, { immediate: true })

  onUnmounted(() => {
    token += 1
  })

  return { durationSec, label, refresh, setKnownDuration }
}
