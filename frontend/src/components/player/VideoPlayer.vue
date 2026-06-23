<script setup lang="ts">
import { computed, onUnmounted, ref, watch } from 'vue'
import type { usePlayerControls } from '@/composables/usePlayerControls'

const props = defineProps<{
  src: string
  poster?: string
  hidden?: boolean
  registerVideo?: (el: HTMLVideoElement | null) => void
  player: ReturnType<typeof usePlayerControls>
}>()

const videoEl = ref<HTMLVideoElement | null>(null)
const trackRef = ref<HTMLElement | null>(null)
const currentTime = ref(0)
const duration = ref(0)
const dragging = ref(false)

function parseYoutubeId(src: string): string | null {
  if (!src) return null
  const embed = src.match(/youtube\.com\/embed\/([a-zA-Z0-9_-]{11})/)
  if (embed) return embed[1]!
  const watch = src.match(/(?:youtu\.be\/|[?&]v=)([a-zA-Z0-9_-]{11})/)
  if (watch) return watch[1]!
  if (/^[a-zA-Z0-9_-]{11}$/.test(src)) return src
  return null
}

const youtubeId = computed(() => parseYoutubeId(props.src))

watch(videoEl, (el) => {
  if (!youtubeId.value) props.registerVideo?.(el)
})

watch(youtubeId, (id) => {
  if (id) props.registerVideo?.(null)
})

const progress = computed(() => {
  if (!duration.value) return 0
  return Math.min(100, (currentTime.value / duration.value) * 100)
})

const showCenterPlay = computed(
  () => !props.hidden && !youtubeId.value && !props.player.isPlaying.value,
)

function formatTime(sec: number) {
  if (!Number.isFinite(sec) || sec < 0) return '0:00'
  const m = Math.floor(sec / 60)
  const s = Math.floor(sec % 60)
  return `${m}:${String(s).padStart(2, '0')}`
}

function onLoadedMetadata() {
  const v = videoEl.value
  if (v && Number.isFinite(v.duration)) duration.value = v.duration
}

function onTimeUpdate() {
  const v = videoEl.value
  if (!v || dragging.value) return
  currentTime.value = v.currentTime
  props.player.onTimeUpdate()
}

function seekToRatio(ratio: number) {
  const v = videoEl.value
  if (!v || !duration.value) return
  const t = Math.max(0, Math.min(1, ratio)) * duration.value
  v.currentTime = t
  currentTime.value = t
}

function seekFromClientX(clientX: number) {
  const track = trackRef.value
  if (!track) return
  const rect = track.getBoundingClientRect()
  seekToRatio((clientX - rect.left) / rect.width)
}

function onTrackClick(e: MouseEvent) {
  seekFromClientX(e.clientX)
}

function onThumbDown(e: PointerEvent) {
  dragging.value = true
  seekFromClientX(e.clientX)

  const onMove = (ev: PointerEvent) => seekFromClientX(ev.clientX)
  const onUp = () => {
    dragging.value = false
    window.removeEventListener('pointermove', onMove)
    window.removeEventListener('pointerup', onUp)
  }
  window.addEventListener('pointermove', onMove)
  window.addEventListener('pointerup', onUp)
}

function onVideoClick() {
  if (youtubeId.value) return
  props.player.togglePlay()
}

onUnmounted(() => {
  props.registerVideo?.(null)
})
</script>

<template>
  <div
    class="w-full"
    :class="
      hidden
        ? 'fixed w-px h-px opacity-0 pointer-events-none overflow-hidden'
        : 'relative aspect-video rounded-xl overflow-hidden bg-black shadow-sm cursor-pointer'
    "
  >
    <iframe
      v-if="youtubeId && !hidden"
      :src="`https://www.youtube.com/embed/${youtubeId}?rel=0`"
      title="YouTube video"
      class="w-full h-full border-0 bg-black"
      allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
      allowfullscreen
    />

    <video
      v-else
      ref="videoEl"
      :src="src"
      :poster="poster"
      playsinline
      class="w-full h-full object-contain bg-black cursor-pointer"
      @loadedmetadata="onLoadedMetadata"
      @durationchange="onLoadedMetadata"
      @timeupdate="onTimeUpdate"
      @play="player.onPlayState"
      @pause="player.onPlayState"
    />

    <template v-if="!hidden && !youtubeId">
      <!-- 点击区域：播放 / 暂停 -->
      <div
        class="absolute inset-0 z-10 cursor-pointer"
        aria-label="播放或暂停"
        @click="onVideoClick"
      >
        <div
          v-if="showCenterPlay"
          class="flex h-full items-center justify-center bg-black/10 pointer-events-none"
        >
          <svg
            class="w-16 h-16 sm:w-20 sm:h-20 text-white drop-shadow-md"
            viewBox="0 0 48 48"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path
              d="M18 12.5v23L36 24 18 12.5Z"
              stroke="currentColor"
              stroke-width="2"
              stroke-linejoin="round"
            />
          </svg>
        </div>
      </div>

      <!-- 底部进度条 -->
      <div
        data-progress-bar
        class="absolute bottom-0 left-0 right-0 z-20 px-3 pb-2.5 pt-8 bg-gradient-to-t from-black/55 to-transparent pointer-events-auto"
        @click.stop
      >
        <div class="flex items-center gap-2.5 pointer-events-auto">
          <span class="text-[11px] sm:text-xs text-white tabular-nums min-w-[2.25rem]">
            {{ formatTime(currentTime) }}
          </span>

          <div
            ref="trackRef"
            class="relative flex-1 h-5 flex items-center cursor-pointer group"
            @click="onTrackClick"
          >
            <div class="absolute inset-x-0 h-0.5 rounded-full bg-white/25" />
            <div
              class="absolute left-0 h-0.5 rounded-full bg-white/75"
              :style="{ width: `${progress}%` }"
            />
            <div
              class="absolute w-3 h-3 -ml-1.5 rounded-full bg-white shadow-sm transition-transform group-hover:scale-110"
              :style="{ left: `${progress}%` }"
              @pointerdown.stop.prevent="onThumbDown"
            />
          </div>

          <span class="text-[11px] sm:text-xs text-white tabular-nums min-w-[2.25rem] text-right">
            {{ formatTime(duration) }}
          </span>
        </div>
      </div>
    </template>
  </div>
</template>
