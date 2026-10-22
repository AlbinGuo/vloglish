<script setup lang="ts">
import { computed, nextTick, onMounted, onUnmounted, ref, watch } from 'vue'
import { useListenPlayerStore } from '@/stores/listenPlayer'
import { useRoute } from 'vue-router'
import { silenceMedia } from '@/utils/playMedia'
import { getNativePlatform } from '@/utils/platform'

const listen = useListenPlayerStore()
const route = useRoute()

// iOS 收听模式优先用独立的音频文件播放：WKWebView 对 <video> 后台续播不可靠，
// 对 <audio> 才稳定。仅当存在独立音频文件、且不是视频视图时才切换，避免影响画面。
const useAudioEngine = computed(
  () =>
    getNativePlatform() === 'ios' &&
    listen.viewMode !== 'video' &&
    Boolean(listen.episode?.media?.audio_url),
)

const expandedVideo = computed(
  () => route.name === 'ListenEpisode' && Boolean(listen.episode),
)
const canTeleport = ref(false)
let recoverTimer: ReturnType<typeof setTimeout> | null = null
let srcWatchReady = false
let boundEl: HTMLMediaElement | null = null

async function syncTeleportTarget() {
  if (!expandedVideo.value) {
    canTeleport.value = false
    return
  }
  for (let i = 0; i < 24; i += 1) {
    if (!expandedVideo.value) {
      canTeleport.value = false
      return
    }
    await nextTick()
    if (document.getElementById('listen-video-slot')) {
      canTeleport.value = true
      return
    }
    await new Promise((resolve) => window.setTimeout(resolve, 40))
  }
}

function scheduleRecover() {
  if (recoverTimer) clearTimeout(recoverTimer)
  recoverTimer = setTimeout(() => {
    void recoverSurface()
  }, 240)
}

async function recoverSurface() {
  if (expandedVideo.value && !canTeleport.value) {
    await syncTeleportTarget()
  }
  if (!listen.isPlaying) return
  try {
    await listen.play()
  } catch {
    /* ignore */
  }
}

watch(canTeleport, async (ready) => {
  await nextTick()
  if (ready && listen.isPlaying) {
    try {
      await listen.play()
    } catch {
      /* ignore */
    }
  }
})

watch(
  () => expandedVideo.value,
  () => {
    void syncTeleportTarget()
  },
  { immediate: true },
)

watch(
  () => listen.viewMode,
  (mode) => {
    if (mode === 'video' && expandedVideo.value) scheduleRecover()
  },
)

watch(
  () => listen.mediaSrc,
  () => {
    if (!srcWatchReady) {
      srcWatchReady = true
      return
    }
    scheduleRecover()
  },
)

function bindEl(el: Element | { $el?: Element } | null) {
  const node = el && '$el' in el ? el.$el : el
  const next = node instanceof HTMLMediaElement ? node : null
  if (next) {
    boundEl = next
    listen.registerVideo(next)
    return
  }
  if (boundEl && !boundEl.isConnected) {
    silenceMedia(boundEl)
    boundEl = null
    listen.registerVideo(null)
  }
}

function isLiveEvent(event: Event) {
  const el = listen.videoEl
  return Boolean(el && event.target === el)
}

function onEnded(event: Event) {
  if (!isLiveEvent(event)) return
  void listen.handleEnded()
}

function onLoadedMeta(event: Event) {
  if (!isLiveEvent(event)) return
  const el = listen.videoEl
  if (el && listen.currentTime > 0.4) {
    try {
      el.currentTime = listen.currentTime
    } catch {
      /* ignore */
    }
  }
  listen.syncFromVideo()
  updatePositionState()
  if (listen.isPlaying && el?.paused) void listen.play()
}

function onPlaying(event: Event) {
  if (!isLiveEvent(event)) return
  listen.syncFromVideo()
  listen.markSurfaceReady()
}

function onTimeUpdate(event: Event) {
  if (!isLiveEvent(event)) return
  listen.syncFromVideo()
  updatePositionState()
}

function updatePositionState() {
  if (typeof navigator === 'undefined' || !('mediaSession' in navigator)) return
  const dur = listen.duration
  if (!dur || !Number.isFinite(dur) || dur <= 0) return
  try {
    navigator.mediaSession.setPositionState({
      duration: dur,
      playbackRate: listen.playbackRate || 1,
      position: Math.max(0, Math.min(listen.currentTime, dur)),
    })
  } catch {
    /* ignore */
  }
}

function applyMediaSession() {
  if (typeof navigator === 'undefined' || !('mediaSession' in navigator) || !listen.episode) return
  const ep = listen.episode
  try {
    navigator.mediaSession.metadata = new MediaMetadata({
      title: ep.short_title,
      artist: ep.author?.name || 'Vloglish',
      artwork: ep.media.thumbnail_url
        ? [{ src: ep.media.thumbnail_url, sizes: '512x512', type: 'image/jpeg' }]
        : [],
    })
    navigator.mediaSession.playbackState = listen.isPlaying ? 'playing' : 'paused'
    navigator.mediaSession.setActionHandler('play', () => {
      void listen.play()
    })
    navigator.mediaSession.setActionHandler('pause', () => listen.pause())
    navigator.mediaSession.setActionHandler('previoustrack', () => {
      void listen.playPrev()
    })
    navigator.mediaSession.setActionHandler('nexttrack', () => {
      void listen.playNext()
    })
    navigator.mediaSession.setActionHandler('seekto', (details) => {
      if (typeof details.seekTime === 'number') listen.seek(details.seekTime)
    })
    updatePositionState()
  } catch {
    /* ignore unsupported handlers */
  }
}

watch(
  () => [listen.episode?.video_id, listen.isPlaying, listen.coverUrl] as const,
  () => applyMediaSession(),
)

onMounted(() => {
  applyMediaSession()
  void syncTeleportTarget()
  if (typeof document !== 'undefined') {
    document.addEventListener('visibilitychange', onVisibility)
  }
})

onUnmounted(() => {
  if (recoverTimer) clearTimeout(recoverTimer)
  if (typeof document !== 'undefined') {
    document.removeEventListener('visibilitychange', onVisibility)
  }
  if (boundEl) silenceMedia(boundEl)
  boundEl = null
})

function onVisibility() {
  if (typeof document === 'undefined') return
  if (document.hidden) {
    applyMediaSession()
    return
  }
  listen.syncFromVideo()
  applyMediaSession()
  if (expandedVideo.value) void syncTeleportTarget()
  if (listen.isPlaying) {
    void listen.play()
    scheduleRecover()
  }
}

const videoListeners = {
  timeupdate: onTimeUpdate,
  play: (event: Event) => {
    if (!isLiveEvent(event)) return
    listen.syncFromVideo()
  },
  playing: onPlaying,
  pause: (event: Event) => {
    if (!isLiveEvent(event)) return
    listen.syncFromVideo()
  },
  ended: onEnded,
  loadedmetadata: onLoadedMeta,
  canplay: (event: Event) => {
    if (!isLiveEvent(event)) return
    if (listen.isPlaying) void listen.play()
  },
  waiting: (event: Event) => {
    if (!isLiveEvent(event)) return
    scheduleRecover()
  },
}
</script>

<template>
  <!--
    Android WebView 不能把正在播的 video 挪 DOM（Teleport 会只剩声音、画面停在封面）。
    进听页时在槽里新建播放器，折叠时另建停车实例。
  -->
  <Teleport v-if="canTeleport" to="#listen-video-slot">
    <audio
      v-if="useAudioEngine"
      :key="(listen.currentVideoId || 'parked') + '-a'"
      :ref="bindEl"
      class="listen-engine-video listen-engine-video--docked"
      :src="listen.audioSrc"
      referrerpolicy="no-referrer"
      preload="auto"
      v-on="videoListeners"
    />
    <video
      v-else
      :key="listen.currentVideoId || 'parked'"
      :ref="bindEl"
      class="listen-engine-video listen-engine-video--docked"
      :src="listen.mediaSrc"
      :poster="listen.coverUrl || undefined"
      playsinline
      webkit-playsinline
      referrerpolicy="no-referrer"
      preload="auto"
      v-on="videoListeners"
    />
  </Teleport>
  <audio
    v-else-if="useAudioEngine"
    :key="(listen.currentVideoId || 'parked') + '-a'"
    :ref="bindEl"
    class="listen-engine-video listen-engine-video--parked"
    :src="listen.audioSrc"
    referrerpolicy="no-referrer"
    preload="auto"
    v-on="videoListeners"
  />
  <video
    v-else
    :key="listen.currentVideoId || 'parked'"
    :ref="bindEl"
    class="listen-engine-video listen-engine-video--parked"
    :src="listen.mediaSrc"
    :poster="listen.coverUrl || undefined"
    playsinline
    webkit-playsinline
    referrerpolicy="no-referrer"
    preload="auto"
    v-on="videoListeners"
  />
</template>

<style scoped>
.listen-engine-video--parked {
  position: fixed !important;
  width: 320px !important;
  height: 180px !important;
  left: -480px;
  bottom: 0;
  z-index: 0;
  opacity: 1;
  pointer-events: none;
  object-fit: contain;
  background: #000;
}
</style>

<style>
#listen-video-slot > .listen-engine-video,
.listen-engine-video--docked {
  position: absolute !important;
  inset: 0 !important;
  left: 0 !important;
  bottom: auto !important;
  display: block !important;
  width: 100% !important;
  height: 100% !important;
  max-width: none !important;
  max-height: none !important;
  object-fit: contain;
  object-position: center;
  background: #111;
  pointer-events: none;
  opacity: 1;
  z-index: 2;
  transform: translateZ(0);
  -webkit-transform: translateZ(0);
}
</style>
