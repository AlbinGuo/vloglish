<script setup lang="ts">
import { computed, nextTick, onMounted, onUnmounted, ref, watch } from 'vue'
import { useListenPlayerStore } from '@/stores/listenPlayer'
import { useRoute } from 'vue-router'

const listen = useListenPlayerStore()
const route = useRoute()

const expandedVideo = computed(
  () => route.name === 'ListenEpisode' && Boolean(listen.episode),
)
const canTeleport = ref(false)
const videoReady = ref(false)
let recoverTimer: ReturnType<typeof setTimeout> | null = null
let srcWatchReady = false

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

function mediaEl() {
  const el = listen.videoEl
  return el instanceof HTMLVideoElement ? el : null
}

function markReady() {
  const el = mediaEl()
  if (!el || !canTeleport.value) return
  if (el.videoWidth > 0 && el.readyState >= 2) videoReady.value = true
}

function resetReady() {
  videoReady.value = false
}

function scheduleRecover() {
  if (recoverTimer) clearTimeout(recoverTimer)
  recoverTimer = setTimeout(() => {
    void recoverSurface()
  }, 700)
}

async function recoverSurface() {
  if (expandedVideo.value && !canTeleport.value) {
    await syncTeleportTarget()
  }
  const el = mediaEl()
  if (!el) return
  if (listen.isPlaying && el.paused) {
    try {
      await listen.play()
    } catch {
      /* ignore */
    }
  }
  if (listen.isPlaying && canTeleport.value && el.videoWidth === 0 && el.readyState >= 2) {
    const t = el.currentTime
    try {
      el.currentTime = Math.max(0, t + 0.001)
    } catch {
      /* ignore */
    }
  }
  markReady()
}

watch(canTeleport, async (ready) => {
  await nextTick()
  const el = listen.videoEl
  if (el && el.paused && listen.isPlaying) void listen.play()
  if (ready) scheduleRecover()
})

watch(
  () => expandedVideo.value,
  () => {
    void syncTeleportTarget()
  },
  { immediate: true },
)

watch(
  () => listen.mediaSrc,
  () => {
    resetReady()
    if (!srcWatchReady) {
      srcWatchReady = true
      return
    }
    scheduleRecover()
  },
)

function bindEl(el: Element | { $el?: Element } | null) {
  const node = el && '$el' in el ? el.$el : el
  if (node instanceof HTMLMediaElement) listen.registerVideo(node)
}

function onEnded() {
  void listen.handleEnded()
}

function onLoadedMeta() {
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
  markReady()
  if (listen.isPlaying && el?.paused) void listen.play()
}

function onPlaying() {
  listen.syncFromVideo()
  const el = mediaEl()
  if (el && 'requestVideoFrameCallback' in el) {
    el.requestVideoFrameCallback(() => {
      if (canTeleport.value) videoReady.value = true
    })
  }
  markReady()
}

function onTimeUpdate() {
  listen.syncFromVideo()
  markReady()
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
</script>

<template>
  <Teleport to="#listen-video-slot" :disabled="!canTeleport" defer>
    <video
      :ref="bindEl"
      class="listen-engine-video"
      :class="{ 'listen-engine-video--ready': canTeleport && videoReady }"
      :src="listen.mediaSrc"
      playsinline
      webkit-playsinline
      x5-video-player-type="h5"
      x5-video-player-fullscreen="false"
      preload="auto"
      @timeupdate="onTimeUpdate"
      @play="listen.syncFromVideo()"
      @playing="onPlaying"
      @pause="listen.syncFromVideo()"
      @ended="onEnded"
      @loadedmetadata="onLoadedMeta"
      @loadeddata="markReady"
      @canplay="markReady"
      @waiting="scheduleRecover"
    />
  </Teleport>
</template>

<style scoped>
/* 默认停在布局外：切页时绝不能先套 inset:0，否则会按视口铺满盖住听页 */
.listen-engine-video {
  position: fixed !important;
  width: 1px !important;
  height: 1px !important;
  opacity: 0;
  pointer-events: none;
  left: -80px;
  bottom: 0;
  z-index: 0;
  object-fit: contain;
}
</style>

<style>
#listen-video-slot > .listen-engine-video {
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
  background: transparent;
  pointer-events: auto;
  opacity: 0;
  z-index: 1;
  transition: opacity 160ms ease;
}
#listen-video-slot > .listen-engine-video.listen-engine-video--ready {
  opacity: 1;
}
</style>
