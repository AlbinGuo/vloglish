<script setup lang="ts">
import { computed, onMounted, onUnmounted, watch } from 'vue'
import { useListenPlayerStore } from '@/stores/listenPlayer'
import { useRoute } from 'vue-router'

const listen = useListenPlayerStore()
const route = useRoute()

const expandedVideo = computed(
  () => route.name === 'ListenEpisode' && listen.viewMode === 'video' && Boolean(listen.episode),
)

function bindEl(el: Element | { $el?: Element } | null) {
  const node = el && '$el' in el ? el.$el : el
  listen.registerVideo(node instanceof HTMLVideoElement ? node : null)
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
}

function onTimeUpdate() {
  listen.syncFromVideo()
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
  if (typeof document === 'undefined' || document.hidden) return
  listen.syncFromVideo()
}
</script>

<template>
  <Teleport to="#listen-video-slot" :disabled="!expandedVideo">
    <video
      :key="listen.mediaSrc || 'empty'"
      :ref="bindEl"
      class="listen-engine-video"
      :class="expandedVideo ? 'listen-engine-video--live' : 'listen-engine-video--parked'"
      :src="listen.mediaSrc"
      :poster="listen.coverUrl || undefined"
      playsinline
      webkit-playsinline
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
  position: fixed;
  width: 1px;
  height: 1px;
  opacity: 0;
  pointer-events: none;
  left: -80px;
  bottom: 0;
}
.listen-engine-video--live {
  display: block;
  width: 100%;
  height: 100%;
  object-fit: contain;
  background: #111;
}
</style>
