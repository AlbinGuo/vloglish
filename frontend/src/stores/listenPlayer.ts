import { computed, ref, shallowRef, watch } from 'vue'
import { defineStore } from 'pinia'
import { getEpisodeDetail, getEpisodeList, getSeriesDetail } from '@/api/episodes'
import { getEpisodeProgress, updateEpisodeProgress } from '@/api/learning'
import router from '@/router'
import { useAuthStore } from '@/stores/auth'
import type { EpisodeDetail, EpisodeSummary, Subtitle } from '@/types'
import { resolveDisplaySub } from '@/utils/subtitleHtml'
import { resolveMediaUrl } from '@/utils/mediaUrl'

export type ListenViewMode = 'video' | 'subtitles'
export type ListenPlaylistTab = 'queue' | 'favorites' | 'history'

export interface ListenQueueItem {
  video_id: string
  short_title: string
  cover: string
  clip_length: number
  author_name: string
}

const QUEUE_KEY = 'vloglish_listen_queue_v1'
const VIEW_KEY = 'vloglish_listen_view_mode'
const RATE_KEY = 'vloglish_listen_rate'
const LOOP_KEY = 'vloglish_listen_loop_single'

export const LISTEN_PLAYBACK_RATES = [0.75, 1, 1.25, 1.5, 1.75, 2] as const

function durationOf(episode: EpisodeDetail | null, fallback = 0) {
  if (!episode) return fallback
  if (episode.clip_length && episode.clip_length > 0) return episode.clip_length
  const last = episode.subtitles[episode.subtitles.length - 1]
  return last?.end || fallback
}

function toQueueItem(episode: EpisodeDetail): ListenQueueItem {
  return {
    video_id: episode.video_id,
    short_title: episode.short_title,
    cover: episode.media.thumbnail_url || '',
    clip_length: durationOf(episode),
    author_name: episode.author?.name || '',
  }
}

function summaryToQueueItem(row: EpisodeSummary): ListenQueueItem {
  return {
    video_id: row.video_id,
    short_title: row.short_title,
    cover: row.cover || '',
    clip_length: row.clip_length || 0,
    author_name: row.author?.name || '',
  }
}

export const useListenPlayerStore = defineStore('listenPlayer', () => {
  const episode = shallowRef<EpisodeDetail | null>(null)
  const queue = ref<ListenQueueItem[]>([])
  const viewMode = ref<ListenViewMode>('video')
  const playlistOpen = ref(false)
  const playlistTab = ref<ListenPlaylistTab>('queue')
  const sleepOpen = ref(false)
  const sleepEndsAt = ref<number | null>(null)
  const sleepAfterCurrent = ref(false)
  const loading = ref(false)
  const loadError = ref('')
  const currentTime = ref(0)
  const isPlaying = ref(false)
  const playbackRate = ref(1)
  const loopSingle = ref(false)
  const videoEl = shallowRef<HTMLMediaElement | null>(null)
  const clock = ref(Date.now())

  let sleepTimer: ReturnType<typeof setTimeout> | null = null
  let progressTimer: ReturnType<typeof setInterval> | null = null
  let clockTimer: ReturnType<typeof setInterval> | null = null
  let lastFlushAt = 0
  let restoredCurrentId = ''
  let pendingPlay = false
  let hydrated = false

  const currentVideoId = computed(() => episode.value?.video_id || '')
  const subs = computed(() => episode.value?.subtitles ?? [])
  const duration = computed(() => durationOf(episode.value, currentTime.value))
  const currentIndex = computed(() => {
    const list = subs.value
    const t = currentTime.value
    const idx = list.findIndex((s) => t >= s.start && t < s.end)
    if (idx >= 0) return idx
    const next = list.findIndex((s) => t < s.start)
    return next >= 0 ? Math.max(0, next - 1) : Math.max(0, list.length - 1)
  })
  const currentSub = computed(() => resolveDisplaySub(subs.value, currentTime.value))
  const queueIndex = computed(() =>
    queue.value.findIndex((item) => item.video_id === currentVideoId.value),
  )
  const hasSession = computed(() => Boolean(episode.value))
  const coverUrl = computed(() => resolveMediaUrl(episode.value?.media.thumbnail_url || ''))
  const mediaSrc = computed(() => {
    const media = episode.value?.media
    if (!media) return ''
    return resolveMediaUrl(media.video_url || media.audio_url || '')
  })
  const audioSrc = computed(() => {
    const media = episode.value?.media
    if (!media) return ''
    return resolveMediaUrl(media.audio_url || media.video_url || '')
  })
  const sleepLeftSec = computed(() => {
    if (!sleepEndsAt.value) return 0
    return Math.max(0, Math.round((sleepEndsAt.value - clock.value) / 1000))
  })

  function persistQueue() {
    try {
      localStorage.setItem(
        QUEUE_KEY,
        JSON.stringify({
          currentId: currentVideoId.value,
          queue: queue.value,
        }),
      )
    } catch {
      /* ignore */
    }
  }

  function restoreQueue() {
    try {
      const raw = localStorage.getItem(QUEUE_KEY)
      if (!raw) return
      const parsed = JSON.parse(raw) as { queue?: ListenQueueItem[]; currentId?: string }
      if (Array.isArray(parsed.queue)) queue.value = parsed.queue
      if (parsed.currentId) restoredCurrentId = parsed.currentId
    } catch {
      /* ignore */
    }
    try {
      const mode = localStorage.getItem(VIEW_KEY)
      if (mode === 'video' || mode === 'subtitles') viewMode.value = mode
    } catch {
      /* ignore */
    }
    try {
      const rate = Number(localStorage.getItem(RATE_KEY))
      if (rate > 0 && rate <= 3) playbackRate.value = rate
    } catch {
      /* ignore */
    }
    try {
      loopSingle.value = localStorage.getItem(LOOP_KEY) === '1'
    } catch {
      /* ignore */
    }
  }

  function setViewMode(mode: ListenViewMode) {
    viewMode.value = mode
    try {
      localStorage.setItem(VIEW_KEY, mode)
    } catch {
      /* ignore */
    }
  }

  function registerVideo(el: HTMLMediaElement | null) {
    videoEl.value = el
    if (!el) return
    if (el instanceof HTMLVideoElement) {
      el.playsInline = true
      el.setAttribute('playsinline', 'true')
      el.setAttribute('webkit-playsinline', 'true')
      el.setAttribute('x5-playsinline', 'true')
      el.setAttribute('x5-video-player-type', 'h5')
      el.setAttribute('x5-video-player-fullscreen', 'false')
    }
    el.preload = 'auto'
    el.playbackRate = playbackRate.value
    if (currentTime.value > 0 && Math.abs(el.currentTime - currentTime.value) > 0.4) {
      el.currentTime = currentTime.value
    }
    if (pendingPlay || isPlaying.value) void play()
  }

  function syncFromVideo() {
    let el = videoEl.value
    if (!el || !el.isConnected) {
      const live = document.getElementById('listen-video-slot')?.querySelector('video, audio')
      const parked = document.querySelector('video.listen-engine-video')
      const found = live || parked
      el = found instanceof HTMLMediaElement ? found : null
      if (el) videoEl.value = el
    }
    if (!el) return
    currentTime.value = el.currentTime || 0
    isPlaying.value = !el.paused && !el.ended
  }

  async function flushProgress(force = false) {
    const auth = useAuthStore()
    const ep = episode.value
    if (!auth.isLoggedIn || !ep) return
    const now = Date.now()
    if (!force && now - lastFlushAt < 12000) return
    lastFlushAt = now
    try {
      await updateEpisodeProgress(ep.video_id, {
        last_subtitle_index: currentIndex.value,
        last_position_sec: currentTime.value,
        max_reached_index: currentIndex.value,
        watch_time_delta_sec: force ? 0 : 12,
      })
    } catch {
      /* ignore */
    }
  }

  function startProgressLoop() {
    if (progressTimer) return
    progressTimer = setInterval(() => {
      if (isPlaying.value) void flushProgress()
    }, 15000)
  }

  function startClock() {
    if (clockTimer) return
    clockTimer = setInterval(() => {
      clock.value = Date.now()
    }, 1000)
  }

  function stopClock() {
    if (clockTimer) {
      clearInterval(clockTimer)
      clockTimer = null
    }
  }

  async function ensureQueueFor(ep: EpisodeDetail) {
    const item = toQueueItem(ep)
    const existing = queue.value.findIndex((row) => row.video_id === ep.video_id)
    if (existing < 0) {
      if (ep.series?.slug) {
        try {
          const series = await getSeriesDetail(ep.series.slug)
          queue.value = series.episodes.map(summaryToQueueItem)
          if (!queue.value.some((row) => row.video_id === ep.video_id)) {
            queue.value.unshift(item)
          }
        } catch {
          queue.value = [item]
        }
      } else if (queue.value.length === 0) {
        queue.value = [item]
      } else {
        const idx = Math.max(0, queueIndex.value)
        queue.value.splice(idx + 1, 0, item)
      }
    } else {
      queue.value[existing] = { ...queue.value[existing], ...item }
    }
    persistQueue()
  }

  async function loadEpisode(videoId: string, { autoplay = true } = {}) {
    if (!videoId) return
    if (episode.value?.video_id === videoId && !loading.value) {
      if (autoplay) await play()
      return
    }
    loading.value = true
    loadError.value = ''
    try {
      const data = await getEpisodeDetail(videoId)
      episode.value = data.episode
      await ensureQueueFor(data.episode)
      currentTime.value = 0
      const el = videoEl.value
      if (el) el.playbackRate = playbackRate.value
      const auth = useAuthStore()
      if (auth.isLoggedIn) {
        try {
          const progress = await getEpisodeProgress(videoId)
          if (!progress.is_completed && progress.last_position_sec > 1.5) {
            currentTime.value = progress.last_position_sec
            if (el) el.currentTime = progress.last_position_sec
          }
        } catch {
          /* ignore */
        }
      }
      if (autoplay) await play()
      startProgressLoop()
      persistQueue()
    } catch (err) {
      loadError.value = err instanceof Error ? err.message : '无法加载节目'
    } finally {
      loading.value = false
    }
  }

  async function hydrateSession() {
    if (hydrated) return
    hydrated = true
    if (episode.value || !restoredCurrentId) return
    if (router.currentRoute.value.name === 'ListenEpisode') return
    await loadEpisode(restoredCurrentId, { autoplay: false })
  }

  async function play() {
    const el = videoEl.value
    if (!el) {
      pendingPlay = true
      isPlaying.value = true
      return
    }
    pendingPlay = false
    try {
      await el.play()
      isPlaying.value = true
    } catch {
      isPlaying.value = false
    }
  }

  function pause() {
    pendingPlay = false
    videoEl.value?.pause()
    isPlaying.value = false
    void flushProgress(true)
  }

  async function togglePlay() {
    if (isPlaying.value) pause()
    else await play()
  }

  function seek(sec: number) {
    const el = videoEl.value
    const next = Math.max(0, Math.min(duration.value || sec, sec))
    currentTime.value = next
    if (el) el.currentTime = next
  }

  function seekToSub(sub: Subtitle) {
    seek(sub.start)
  }

  function setRate(rate: number) {
    playbackRate.value = rate
    if (videoEl.value) videoEl.value.playbackRate = rate
    try {
      localStorage.setItem(RATE_KEY, String(rate))
    } catch {
      /* ignore */
    }
  }

  function setLoopSingle(on: boolean) {
    loopSingle.value = on
    try {
      localStorage.setItem(LOOP_KEY, on ? '1' : '0')
    } catch {
      /* ignore */
    }
  }

  function toggleLoopSingle() {
    setLoopSingle(!loopSingle.value)
  }

  async function playFromQueue(videoId: string, expand = false) {
    await loadEpisode(videoId)
    const onListenPage = router.currentRoute.value.name === 'ListenEpisode'
    if (onListenPage) {
      if (router.currentRoute.value.params.videoId !== videoId) {
        await router.replace(`/english/listen/${videoId}`)
      }
      return
    }
    if (expand) {
      await router.push(`/english/listen/${videoId}`)
    }
  }

  async function handleEnded() {
    if (sleepAfterCurrent.value) {
      sleepAfterCurrent.value = false
      pause()
      return
    }
    if (loopSingle.value) {
      seek(0)
      await play()
      return
    }
    await playNext()
  }

  async function playNext() {
    const idx = queueIndex.value
    const next = queue.value[idx + 1] || queue.value[0]
    if (!next || next.video_id === currentVideoId.value) {
      seek(0)
      if (loopSingle.value) await play()
      else pause()
      return
    }
    await playFromQueue(next.video_id, router.currentRoute.value.name === 'ListenEpisode')
  }

  async function playPrev({ force = false } = {}) {
    const idx = queueIndex.value
    if (!force && currentTime.value > 3) {
      seek(0)
      return
    }
    const prev = queue.value[idx - 1] || queue.value[queue.value.length - 1]
    if (!prev || prev.video_id === currentVideoId.value) {
      seek(0)
      return
    }
    await playFromQueue(prev.video_id, router.currentRoute.value.name === 'ListenEpisode')
  }

  function removeFromQueue(videoId: string) {
    if (queue.value.length <= 1 && videoId === currentVideoId.value) return
    queue.value = queue.value.filter((row) => row.video_id !== videoId)
    persistQueue()
    if (videoId === currentVideoId.value) void playNext()
  }

  async function enqueueAndPlay(row: ListenQueueItem | EpisodeSummary, expand = true) {
    const item = 'author' in row ? summaryToQueueItem(row) : row
    if (!queue.value.some((q) => q.video_id === item.video_id)) {
      queue.value.push(item)
      persistQueue()
    }
    await playFromQueue(item.video_id, expand)
  }

  async function openEpisode(videoId: string) {
    await loadEpisode(videoId)
    if (router.currentRoute.value.path !== `/english/listen/${videoId}`) {
      await router.push(`/english/listen/${videoId}`)
    }
  }

  function collapse() {
    void flushProgress(true)
    if (router.currentRoute.value.name !== 'ListenHome') {
      void router.push('/english/listen')
    }
  }

  function expand() {
    if (!currentVideoId.value) {
      void router.push('/english/listen')
      return
    }
    void router.push(`/english/listen/${currentVideoId.value}`)
  }

  function dismissSession() {
    pause()
    episode.value = null
    currentTime.value = 0
    isPlaying.value = false
    restoredCurrentId = ''
    persistQueue()
  }

  function clearSleep() {
    if (sleepTimer) {
      clearTimeout(sleepTimer)
      sleepTimer = null
    }
    sleepEndsAt.value = null
    sleepAfterCurrent.value = false
    stopClock()
  }

  function setSleepMinutes(minutes: number | null) {
    clearSleep()
    sleepAfterCurrent.value = false
    if (!minutes) return
    startClock()
    sleepEndsAt.value = Date.now() + minutes * 60 * 1000
    sleepTimer = setTimeout(() => {
      pause()
      sleepEndsAt.value = null
      sleepTimer = null
      stopClock()
    }, minutes * 60 * 1000)
  }

  function setSleepAfterCurrent() {
    clearSleep()
    sleepAfterCurrent.value = true
    startClock()
    const leftMs = Math.max(1000, (duration.value - currentTime.value) * 1000)
    sleepEndsAt.value = Date.now() + leftMs
    sleepTimer = setTimeout(() => {
      pause()
      sleepEndsAt.value = null
      sleepTimer = null
      sleepAfterCurrent.value = false
      stopClock()
    }, leftMs)
  }

  async function loadFavoriteQueue() {
    const { results } = await getEpisodeList({ status: 'favorite', page_size: 40 })
    return results.map(summaryToQueueItem)
  }

  watch(viewMode, (mode) => {
    try {
      localStorage.setItem(VIEW_KEY, mode)
    } catch {
      /* ignore */
    }
  })

  restoreQueue()

  return {
    episode,
    queue,
    viewMode,
    playlistOpen,
    playlistTab,
    sleepOpen,
    sleepEndsAt,
    sleepAfterCurrent,
    loading,
    loadError,
    currentTime,
    isPlaying,
    playbackRate,
    loopSingle,
    videoEl,
    currentVideoId,
    subs,
    duration,
    currentIndex,
    currentSub,
    queueIndex,
    hasSession,
    coverUrl,
    mediaSrc,
    audioSrc,
    sleepLeftSec,
    registerVideo,
    syncFromVideo,
    flushProgress,
    loadEpisode,
    hydrateSession,
    play,
    pause,
    togglePlay,
    seek,
    seekToSub,
    setRate,
    setLoopSingle,
    toggleLoopSingle,
    playFromQueue,
    handleEnded,
    playNext,
    playPrev,
    removeFromQueue,
    enqueueAndPlay,
    openEpisode,
    collapse,
    expand,
    dismissSession,
    setViewMode,
    setSleepMinutes,
    setSleepAfterCurrent,
    clearSleep,
    loadFavoriteQueue,
  }
})
