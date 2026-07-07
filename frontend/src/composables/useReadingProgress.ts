import { onUnmounted, ref, watch, type Ref } from 'vue'
import { updateArticleProgress } from '@/api/articles'

const REPORT_INTERVAL_MS = 5000

export function useReadingProgress(articleId: Ref<string>, segmentCount: Ref<number>) {
  const currentIndex = ref(0)
  let lastReportAt = Date.now()
  let pendingDeltaSec = 0
  let reportTimer: ReturnType<typeof setInterval> | null = null

  async function flushProgress(force = false) {
    if (!articleId.value) return
    const now = Date.now()
    const deltaSec = force ? pendingDeltaSec : Math.floor((now - lastReportAt) / 1000)
    if (!force && deltaSec <= 0 && pendingDeltaSec <= 0) return

    const readTimeDelta = Math.max(pendingDeltaSec, force ? 0 : deltaSec)
    pendingDeltaSec = 0
    lastReportAt = now

    try {
      await updateArticleProgress(articleId.value, {
        last_segment_index: currentIndex.value,
        read_time_delta_sec: readTimeDelta,
      })
    } catch {
      pendingDeltaSec += readTimeDelta
    }
  }

  function setCurrentIndex(index: number) {
    const max = Math.max(segmentCount.value - 1, 0)
    currentIndex.value = Math.max(0, Math.min(index, max))
    void flushProgress()
  }

  function startReporting() {
    if (reportTimer) return
    lastReportAt = Date.now()
    reportTimer = setInterval(() => {
      pendingDeltaSec += REPORT_INTERVAL_MS / 1000
      void flushProgress()
    }, REPORT_INTERVAL_MS)
  }

  function stopReporting() {
    if (reportTimer) {
      clearInterval(reportTimer)
      reportTimer = null
    }
    void flushProgress(true)
  }

  watch(segmentCount, (count) => {
    if (currentIndex.value > count - 1) {
      currentIndex.value = Math.max(0, count - 1)
    }
  })

  onUnmounted(stopReporting)

  return { currentIndex, setCurrentIndex, startReporting, stopReporting }
}
