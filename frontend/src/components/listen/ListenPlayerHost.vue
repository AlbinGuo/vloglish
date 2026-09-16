<script setup lang="ts">
import { computed, nextTick, onMounted, onUnmounted, ref, watch } from 'vue'
import { useListenPlayerStore } from '@/stores/listenPlayer'
import { useRoute } from 'vue-router'

const listen = useListenPlayerStore()
const route = useRoute()

const expandedVideo = computed(
  () => route.name === 'ListenEpisode' && listen.viewMode === 'video' && Boolean(listen.episode),
)
const canTeleport = ref(false)

async function syncTeleportTarget() {
  if (!expandedVideo.value) {
    canTeleport.value = false
    return
  }
  await nextTick()
  canTeleport.value = Boolean(document.getElementById('listen-video-slot'))
  if (!canTeleport.value) {
    window.setTimeout(() => {
      canTeleport.value = Boolean(document.getElementById('listen-video-slot')) && expandedVideo.value
    }, 50)
  }
}

watch(
  () => [expandedVideo.value, route.fullPath, listen.viewMode] as const,
  () => {
    void syncTeleportTarget()
  },
  { immediate: true },
)

function bindEl(el: Element | { $el?: Element } | null) {
  const node = el && '$el' in el ? el.$el : el
  listen.registerVideo(node instanceof HTMLMediaElement ? node : null)
}

function onEnded() {
  void listen.handleEnded()
}

function onLoadedMeta() {
  const el = listen.videoEl
  if (el && listen.currentTime > 0.4) {
    el.currentTime = listen.currentTime
  }
  listen.syncFromVideo()
  updatePositionState()
}

function onTimeUpdate() {
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
}
</script>

<template>
  <Teleport to="#listen-video-slot" :disabled="!canTeleport" defer>
    <video
      :key="listen.mediaSrc || 'empty'"
      :ref="bindEl"
      class="listen-engine-video"
      :class="canTeleport ? 'listen-engine-video--live' : 'listen-engine-video--parked'"
      :src="listen.mediaSrc"
      :poster="listen.coverUrl || undefined"
      playsinline
      webkit-playsinline
      x5-video-player-type="h5"
      x5-video-player-fullscreen="false"
      preload="auto"
      @timeupdate="onTimeUpdate"
      @play="listen.syncFromVideo()"
      @pause="listen.syncFromVideo()"
      @ended="onEnded"
      @loadedmetadata="onLoadedMeta"
    />
  </Teleport>
</template>

<style scoped>
.listen-engine-video--parked {
  position: fixed !important;
  width: 1px !important;
  height: 1px !important;
  opacity: 0;
  pointer-events: none;
  left: -80px;
  bottom: 0;
  z-index: 0;
}
.listen-engine-video--live {
  position: absolute !important;
  inset: 0;
  display: block;
  width: 100%;
  height: 100%;
  object-fit: contain;
  object-position: center;
  background: #111;
}
</style>
