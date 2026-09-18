import { computed, nextTick, ref, shallowRef, watch } from 'vue'
import { defineStore } from 'pinia'
import { getEpisodeDetail, getEpisodeList, getSeriesDetail } from '@/api/episodes'
import { getEpisodeProgress, updateEpisodeProgress } from '@/api/learning'
import router from '@/router'
import { useAuthStore } from '@/stores/auth'
import type { EpisodeDetail, EpisodeSummary, Subtitle } from '@/types'
import { resolveDisplaySub } from '@/utils/subtitleHtml'
import { resolveMediaUrl } from '@/utils/mediaUrl'
import { pauseMedia, resumeMedia, seekMedia, silenceMedia } from '@/utils/playMedia'

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
    cover: episode.cover || episode.media.thumbnail_url || '',
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
  const sheetMotion = ref<'idle' | 'opening' | 'closing'>('idle')

  let sleepTimer: ReturnType<typeof setTimeout> | null = null
  let progressTimer: ReturnType<typeof setInterval> | null = null
  let clockTimer: ReturnType<typeof setInterval> | null = null
  let lastFlushAt = 0
  let restoredCurrentId = ''
  let pendingPlay = false
  let hydrated = false
  let ignoreEndedUntil = 0
  let holdPlayingUntil = 0
  let inFlightId = ''
  let loadWaiters: Array<() => void> = []

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
  const incomingId = ref('')
  const incomingCover = ref('')
  const surfaceReady = ref(false)
  const coverUrl = computed(() => {
    if (incomingCover.value) return incomingCover.value
    return resolveMediaUrl(episode.value?.cover || episode.value?.media.thumbnail_url || '')
  })
  const coverKey = computed(() => incomingId.value || currentVideoId.value)

  function pinIncomingCover(videoId: string) {
    incomingId.value = videoId
    const queued = queue.value.find((row) => row.video_id === videoId)
    incomingCover.value = resolveMediaUrl(queued?.cover || '')
    surfaceReady.value = false
  }

  function markSurfaceReady() {
    if (incomingId.value && incomingId.value !== currentVideoId.value) return
    surfaceReady.value = true
  }
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
    const resume = isPlaying.value || Boolean(videoEl.value && !videoEl.value.paused)
    viewMode.value = mode
    try {
      localStorage.setItem(VIEW_KEY, mode)
    } catch {
      /* ignore */
    }
    if (!resume) return
    isPlaying.value = true
    pendingPlay = true
    holdPlayingUntil = Date.now() + 1500
    void play()
  }

  function listenMediaNodes(keep?: HTMLMediaElement | null) {
    if (typeof document === 'undefined') return [] as HTMLMediaElement[]
    const nodes = new Set<HTMLMediaElement>()
    document.querySelectorAll('video.listen-engine-video, #listen-video-slot video').forEach((node) => {
      if (node instanceof HTMLMediaElement && node !== keep) nodes.add(node)
    })
    const cur = videoEl.value
    if (cur && cur !== keep) nodes.add(cur)
    return [...nodes]
  }

  function silenceOtherListenMedia(keep?: HTMLMediaElement | null) {
    for (const node of listenMediaNodes(keep)) silenceMedia(node)
  }

  function pauseAllListenMedia() {
    for (const node of listenMediaNodes()) pauseMedia(node)
  }

  function liveMedia() {
    const el = videoEl.value
    if (el && el.isConnected) return el
    const live = document.getElementById('listen-video-slot')?.querySelector('video, audio')
    const parked = document.querySelector('video.listen-engine-video')
    const found = live || parked
    if (found instanceof HTMLMediaElement) {
      videoEl.value = found
      return found
    }
    return null
  }

  function registerVideo(el: HTMLMediaElement | null) {
    if (!el) {
      const cur = videoEl.value
      if (cur && !cur.isConnected) {
        silenceMedia(cur)
        videoEl.value = null
      }
      return
    }
    const prev = videoEl.value
    const isNew = prev !== el
    videoEl.value = el
    if (prev && prev !== el) silenceMedia(prev)
    silenceOtherListenMedia(el)
    if (el instanceof HTMLVideoElement) {
      el.playsInline = true
      el.setAttribute('playsinline', 'true')
      el.setAttribute('webkit-playsinline', 'true')
      el.setAttribute('referrerpolicy', 'no-referrer')
      if (coverUrl.value) el.setAttribute('poster', coverUrl.value)
    }
    el.preload = 'auto'
    el.playbackRate = playbackRate.value
    if (!isNew) return
    ignoreEndedUntil = Date.now() + 600
    if (currentTime.value > 0.4 && Math.abs(el.currentTime - currentTime.value) > 0.4) {
      el.currentTime = currentTime.value
    }
    if (pendingPlay || isPlaying.value) void play()
  }

  function syncFromVideo() {
    let el = liveMedia()
    if (!el) return
    currentTime.value = el.currentTime || 0
    if (el.paused && Date.now() < holdPlayingUntil) {
      isPlaying.value = true
      void play()
      return
    }
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
    if (loading.value && inFlightId === videoId) {
      await new Promise<void>((resolve) => {
        loadWaiters.push(resolve)
      })
      if (autoplay) await play()
      return
    }
    inFlightId = videoId
    loading.value = true
    loadError.value = ''
    ignoreEndedUntil = Date.now() + 1200
    pinIncomingCover(videoId)
    try {
      const data = await getEpisodeDetail(videoId)
      episode.value = data.episode
      incomingCover.value = resolveMediaUrl(
        data.episode.cover || data.episode.media.thumbnail_url || incomingCover.value,
      )
      await ensureQueueFor(data.episode)
      currentTime.value = 0
      await nextTick()
      const auth = useAuthStore()
      const progressTask = auth.isLoggedIn
        ? getEpisodeProgress(videoId).catch(() => null)
        : Promise.resolve(null)
      if (autoplay) void play()
      const progress = await progressTask
      if (progress && !progress.is_completed && progress.last_position_sec > 1.5) {
        currentTime.value = progress.last_position_sec
      }
      const el = videoEl.value
      if (el) {
        el.playbackRate = playbackRate.value
        const start = currentTime.value
        const applyStart = () => {
          if (start > 0.4) {
            try {
              el.currentTime = start
            } catch {
              /* ignore */
            }
          }
        }
        if (el.readyState >= 1) applyStart()
        else el.addEventListener('loadedmetadata', applyStart, { once: true })
      }
      if (autoplay) await play()
      startProgressLoop()
      persistQueue()
    } catch (err) {
      loadError.value = err instanceof Error ? err.message : '无法加载节目'
    } finally {
      loading.value = false
      inFlightId = ''
      const waiters = loadWaiters
      loadWaiters = []
      waiters.forEach((fn) => fn())
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
    const el = liveMedia()
    if (!el) {
      pendingPlay = true
      isPlaying.value = true
      return
    }
    pendingPlay = false
    silenceOtherListenMedia(el)
    el.playbackRate = playbackRate.value
    isPlaying.value = true
    holdPlayingUntil = Date.now() + 1800
    const ok = await resumeMedia(el)
    isPlaying.value = ok || (!el.paused && !el.ended)
  }

  function pause() {
    pendingPlay = false
    holdPlayingUntil = 0
    liveMedia()?.pause()
    pauseAllListenMedia()
    isPlaying.value = false
    void flushProgress(true)
  }

  async function togglePlay() {
    const el = liveMedia()
    const anyPlaying =
      Boolean(el && !el.paused && !el.ended) ||
      listenMediaNodes(el).some((node) => !node.paused && !node.ended)
    if (isPlaying.value || anyPlaying) pause()
    else await play()
  }

  function seek(sec: number, opts?: { resume?: boolean }) {
    const el = liveMedia()
    const next = Math.max(0, Math.min(duration.value || sec, sec))
    currentTime.value = next
    const resume = opts?.resume ?? (isPlaying.value || Boolean(el && !el.paused))
    if (resume) {
      isPlaying.value = true
      holdPlayingUntil = Date.now() + 1800
    }
    if (!el) return
    void seekMedia(el, next, { resume }).then(() => {
      currentTime.value = el.currentTime || next
      if (resume) isPlaying.value = !el.paused && !el.ended
    })
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
    if (expand && router.currentRoute.value.name !== 'ListenEpisode') {
      await router.push(`/english/listen/${videoId}`)
    }
    await loadEpisode(videoId)
    if (
      router.currentRoute.value.name === 'ListenEpisode' &&
      router.currentRoute.value.params.videoId !== videoId
    ) {
      await router.replace(`/english/listen/${videoId}`)
    }
  }

  async function handleEnded() {
    if (loading.value || Date.now() < ignoreEndedUntil) return
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
    pendingPlay = true
    isPlaying.value = true
    holdPlayingUntil = Date.now() + 2500
    await loadEpisode(videoId)
    if (router.currentRoute.value.path !== `/english/listen/${videoId}`) {
      await router.push(`/english/listen/${videoId}`)
    }
  }

  function collapse() {
    void flushProgress(true)
    if (router.currentRoute.value.name !== 'ListenHome') {
      void router.push('/english/listen').finally(() => {
        sheetMotion.value = 'idle'
      })
      return
    }
    sheetMotion.value = 'idle'
  }

  function expand() {
    if (!currentVideoId.value) {
      void router.push('/english/listen')
      return
    }
    if (router.currentRoute.value.name === 'ListenEpisode') return
    sheetMotion.value = 'opening'
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

  watch(coverUrl, (url) => {
    const el = liveMedia()
    if (el instanceof HTMLVideoElement) {
      if (url) el.setAttribute('poster', url)
      else el.removeAttribute('poster')
    }
  })

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
    sheetMotion,
    currentVideoId,
    subs,
    duration,
    currentIndex,
    currentSub,
    queueIndex,
    hasSession,
    coverUrl,
    coverKey,
    surfaceReady,
    markSurfaceReady,
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
