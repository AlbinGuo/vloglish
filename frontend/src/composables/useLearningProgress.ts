import { onUnmounted, ref, type Ref } from 'vue'
import {
  endLearningSession,
  getEpisodeProgress,
  startLearningSession,
  updateEpisodeProgress,
} from '@/api/learning'
import { useAuthStore } from '@/stores/auth'
import type { SubtitleDisplayMode } from '@/utils/subtitleHtml'

export function useLearningProgress(opts: {
  videoId: Ref<string>
  currentIndex: Ref<number>
  currentTime: Ref<number>
  sortedSubs: Ref<{ id: number; index: number }[]>
  subtitleMode: Ref<SubtitleDisplayMode>
  loopMode: Ref<string>
  playbackRate: Ref<number>
}) {
  const auth = useAuthStore()
  const sessionId = ref<number | null>(null)
  const isCompleted = ref(false)
  const resumePrompt = ref<{ index: number; position: number } | null>(null)

  let watchAccumulator = 0
  let lastFlushAt = 0
  let lastSubtitleId: number | null = null
  let lookupsSinceFlush = 0
  let replaysSinceFlush = 0

  async function init() {
    if (!auth.isLoggedIn || opts.videoId.value === '') return
    try {
      const [progress, session] = await Promise.all([
        getEpisodeProgress(opts.videoId.value),
        startLearningSession(opts.videoId.value, opts.subtitleMode.value, opts.loopMode.value),
      ])
      sessionId.value = session.id
      isCompleted.value = progress.is_completed
      if (!progress.is_completed && progress.last_subtitle_index > 0) {
        resumePrompt.value = {
          index: progress.last_subtitle_index,
          position: progress.last_position_sec,
        }
      }
    } catch {
      // ignore when not logged in or network error
    }
  }

  function tickWatchTime(deltaSec: number) {
    if (!auth.isLoggedIn || deltaSec <= 0) return
    watchAccumulator += deltaSec
    const now = Date.now()
    if (now - lastFlushAt < 15000) return
    void flush(false)
    lastFlushAt = now
  }

  function noteLookup() {
    lookupsSinceFlush += 1
  }

  function noteReplay() {
    replaysSinceFlush += 1
  }

  async function flush(forceComplete = false) {
    if (!auth.isLoggedIn || !opts.videoId.value) return
    const sub = opts.sortedSubs.value[opts.currentIndex.value]
    const heardId = sub && sub.id !== lastSubtitleId ? sub.id : undefined
    if (heardId) lastSubtitleId = heardId

    try {
      const result = await updateEpisodeProgress(opts.videoId.value, {
        last_subtitle_index: opts.currentIndex.value,
        last_position_sec: opts.currentTime.value,
        max_reached_index: opts.currentIndex.value,
        watch_time_delta_sec: Math.round(watchAccumulator),
        heard_subtitle_id: heardId,
        is_completed: forceComplete || isCompleted.value,
        session_id: sessionId.value ?? undefined,
        session_lookups_delta: lookupsSinceFlush,
        session_replays_delta: replaysSinceFlush,
        playback_rate: opts.playbackRate.value,
        subtitle_mode: opts.subtitleMode.value,
        loop_mode: opts.loopMode.value,
      })
      watchAccumulator = 0
      lookupsSinceFlush = 0
      replaysSinceFlush = 0
      isCompleted.value = result.is_completed
    } catch {
      // ignore
    }
  }

  async function markComplete() {
    if (!auth.isLoggedIn) return
    isCompleted.value = true
    await flush(true)
  }

  function clearResumePrompt() {
    resumePrompt.value = null
  }

  onUnmounted(async () => {
    await flush(false)
    if (sessionId.value) {
      try {
        await endLearningSession(sessionId.value)
      } catch {
        // ignore
      }
    }
  })

  return {
    sessionId,
    isCompleted,
    resumePrompt,
    init,
    tickWatchTime,
    noteLookup,
    noteReplay,
    flush,
    markComplete,
    clearResumePrompt,
  }
}
