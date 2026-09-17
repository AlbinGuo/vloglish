<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { resumeMedia } from '@/utils/playMedia'

const props = withDefaults(
  defineProps<{
    video: HTMLVideoElement | null
    variant?: 'overlay' | 'dock'
  }>(),
  { variant: 'overlay' },
)

const emit = defineEmits<{
  seek: []
}>()

const trackRef = ref<HTMLElement | null>(null)
const currentTime = ref(0)
const duration = ref(0)
const dragging = ref(false)

const progress = computed(() => {
  if (!duration.value) return 0
  return Math.min(100, (currentTime.value / duration.value) * 100)
})

function formatTime(sec: number) {
  if (!Number.isFinite(sec) || sec < 0) return '0:00'
  const m = Math.floor(sec / 60)
  const s = Math.floor(sec % 60)
  return `${m}:${String(s).padStart(2, '0')}`
}

function syncDuration(v: HTMLVideoElement) {
  if (Number.isFinite(v.duration)) duration.value = v.duration
}

function seekToRatio(ratio: number) {
  const v = props.video
  if (!v || !duration.value) return
  const t = Math.max(0, Math.min(1, ratio)) * duration.value
  v.currentTime = t
  currentTime.value = t
  emit('seek')
}

function seekFromClientX(clientX: number) {
  const track = trackRef.value
  if (!track) return
  const rect = track.getBoundingClientRect()
  seekToRatio((clientX - rect.left) / rect.width)
}

function onTrackClick(e: MouseEvent) {
  const v = props.video
  const resume = Boolean(v && !v.paused)
  seekFromClientX(e.clientX)
  if (v && resume) {
    void resumeMedia(v)
  }
}

function onThumbDown(e: PointerEvent) {
  dragging.value = true
  const v = props.video
  const resume = Boolean(v && !v.paused)
  seekFromClientX(e.clientX)

  const onMove = (ev: PointerEvent) => seekFromClientX(ev.clientX)
  const onUp = () => {
    dragging.value = false
    window.removeEventListener('pointermove', onMove)
    window.removeEventListener('pointerup', onUp)
    if (v && resume) void resumeMedia(v)
  }
  window.addEventListener('pointermove', onMove)
  window.addEventListener('pointerup', onUp)
}

watch(
  () => props.video,
  (video, _, onCleanup) => {
    if (!video) {
      currentTime.value = 0
      duration.value = 0
      return
    }

    syncDuration(video)
    currentTime.value = video.currentTime

    const onMeta = () => syncDuration(video)
    const onTime = () => {
      if (!dragging.value) currentTime.value = video.currentTime
    }

    video.addEventListener('loadedmetadata', onMeta)
    video.addEventListener('durationchange', onMeta)
    video.addEventListener('timeupdate', onTime)

    onCleanup(() => {
      video.removeEventListener('loadedmetadata', onMeta)
      video.removeEventListener('durationchange', onMeta)
      video.removeEventListener('timeupdate', onTime)
    })
  },
  { immediate: true },
)
</script>

<template>
  <div
    v-if="video"
    :class="
      variant === 'overlay'
        ? 'absolute bottom-0 left-0 right-0 z-20 px-3 pb-2.5 pt-8 bg-gradient-to-t from-black/55 to-transparent pointer-events-auto'
        : 'px-3 pt-2 pb-1 pointer-events-auto'
    "
    @click.stop
  >
    <div class="flex items-center gap-2.5 pointer-events-auto">
      <span
        class="text-[11px] tabular-nums min-w-[2.25rem]"
        :class="variant === 'overlay' ? 'text-white sm:text-xs' : 'text-neutral-500 dark:text-neutral-400'"
      >
        {{ formatTime(currentTime) }}
      </span>

      <div
        ref="trackRef"
        class="relative flex-1 h-5 flex items-center cursor-pointer group"
        @click="onTrackClick"
      >
        <div
          class="absolute inset-x-0 h-0.5 rounded-full"
          :class="variant === 'overlay' ? 'bg-white/25' : 'bg-black/10 dark:bg-white/20'"
        />
        <div
          class="absolute left-0 h-0.5 rounded-full"
          :class="variant === 'overlay' ? 'bg-white/75' : 'bg-neutral-700 dark:bg-neutral-300'"
          :style="{ width: `${progress}%` }"
        />
        <div
          class="absolute w-3 h-3 -ml-1.5 rounded-full shadow-sm transition-transform group-hover:scale-110"
          :class="variant === 'overlay' ? 'bg-white' : 'bg-neutral-800 dark:bg-neutral-200'"
          :style="{ left: `${progress}%` }"
          @pointerdown.stop.prevent="onThumbDown"
        />
      </div>

      <span
        class="text-[11px] tabular-nums min-w-[2.25rem] text-right"
        :class="variant === 'overlay' ? 'text-white sm:text-xs' : 'text-neutral-500 dark:text-neutral-400'"
      >
        {{ formatTime(duration) }}
      </span>
    </div>
  </div>
</template>
