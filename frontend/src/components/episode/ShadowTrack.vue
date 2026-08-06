<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref, watch } from 'vue'
import { formatAudioClock } from '@/utils/audioDuration'
import { useAudioDuration } from '@/composables/useAudioDuration'

const props = defineProps<{
  audioUrl: string
  /** 该句参考时长（秒），用于轨道视觉比例 */
  sentenceDurationSec: number
  uploading?: boolean
}>()

const emit = defineEmits<{
  rerecord: []
  score: []
  playReference: []
}>()

const playing = ref(false)
const aligning = ref(false)
const progress = ref(0)
const currentLabel = ref('')
const menuOpen = ref(false)
const rootEl = ref<HTMLElement | null>(null)
const { label: durationLabel, durationSec } = useAudioDuration(() => props.audioUrl)

let audio: HTMLAudioElement | null = null
let alignTimer: ReturnType<typeof setTimeout> | null = null
let seeking = false

const displayDuration = computed(() => {
  if (playing.value && currentLabel.value) return currentLabel.value
  if (durationLabel.value) return durationLabel.value
  if (props.sentenceDurationSec > 0) return formatAudioClock(props.sentenceDurationSec)
  return ''
})

function stopAudio() {
  if (alignTimer) {
    clearTimeout(alignTimer)
    alignTimer = null
  }
  if (audio) {
    audio.pause()
    audio.onended = null
    audio.ontimeupdate = null
    audio.onerror = null
    audio = null
  }
  playing.value = false
  aligning.value = false
  progress.value = 0
  currentLabel.value = ''
  seeking = false
}

function bindAudio(el: HTMLAudioElement) {
  audio = el
  playing.value = true
  el.ontimeupdate = () => {
    if (seeking) return
    const d = el.duration || durationSec.value || props.sentenceDurationSec || 0
    if (d > 0) {
      progress.value = Math.min(100, (el.currentTime / d) * 100)
      currentLabel.value = formatAudioClock(el.currentTime)
    }
  }
  el.onended = () => stopAudio()
  el.onerror = () => stopAudio()
  void el.play().catch(() => stopAudio())
}

function togglePlay() {
  if (!props.audioUrl || props.uploading) return
  menuOpen.value = false
  if (playing.value) {
    stopAudio()
    return
  }
  stopAudio()
  bindAudio(new Audio(props.audioUrl))
}

function onAlignReference() {
  if (!props.audioUrl || props.uploading) return
  menuOpen.value = false
  stopAudio()
  aligning.value = true
  emit('playReference')
  alignTimer = setTimeout(() => {
    alignTimer = null
    if (!props.audioUrl) {
      aligning.value = false
      return
    }
    bindAudio(new Audio(props.audioUrl))
  }, 160)
}

function onRerecord() {
  menuOpen.value = false
  emit('rerecord')
}

function onScore() {
  menuOpen.value = false
  emit('score')
}

function seekFromClientX(clientX: number, trackEl: HTMLElement) {
  if (!audio || !playing.value) return
  const rect = trackEl.getBoundingClientRect()
  if (rect.width <= 0) return
  const ratio = Math.min(1, Math.max(0, (clientX - rect.left) / rect.width))
  const d = audio.duration || durationSec.value || props.sentenceDurationSec || 0
  if (d <= 0) return
  audio.currentTime = d * ratio
  progress.value = ratio * 100
  currentLabel.value = formatAudioClock(audio.currentTime)
}

function onTrackPointerDown(e: PointerEvent) {
  if (!audio || !playing.value || props.uploading) return
  menuOpen.value = false
  const el = e.currentTarget as HTMLElement
  seeking = true
  el.setPointerCapture(e.pointerId)
  seekFromClientX(e.clientX, el)
}

function onTrackPointerMove(e: PointerEvent) {
  if (!seeking) return
  seekFromClientX(e.clientX, e.currentTarget as HTMLElement)
}

function onTrackPointerUp(e: PointerEvent) {
  if (!seeking) return
  seeking = false
  try {
    ;(e.currentTarget as HTMLElement).releasePointerCapture(e.pointerId)
  } catch {
    /* ignore */
  }
}

function onDocPointerDown(e: PointerEvent) {
  if (!menuOpen.value || !rootEl.value) return
  if (!rootEl.value.contains(e.target as Node)) menuOpen.value = false
}

watch(
  () => props.audioUrl,
  () => stopAudio(),
)

onMounted(() => {
  document.addEventListener('pointerdown', onDocPointerDown, true)
})

onUnmounted(() => {
  document.removeEventListener('pointerdown', onDocPointerDown, true)
  stopAudio()
})
</script>

<template>
  <div
    ref="rootEl"
    class="relative mt-1.5 rounded-xl border border-emerald-200/60 bg-emerald-50/70 dark:border-emerald-800/40 dark:bg-emerald-950/30"
    @click.stop
  >
    <div class="flex items-center gap-1.5 px-2 py-1.5">
      <button
        type="button"
        class="shrink-0 flex h-9 w-9 items-center justify-center rounded-full text-white transition active:scale-95 touch-manipulation disabled:opacity-50"
        :class="playing ? 'bg-emerald-600' : 'bg-emerald-500'"
        :disabled="uploading || !audioUrl"
        :aria-label="playing ? '暂停' : '播放我的跟读'"
        @click="togglePlay"
      >
        <svg v-if="playing" width="12" height="12" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
          <rect x="6" y="5" width="4" height="14" rx="1" />
          <rect x="14" y="5" width="4" height="14" rx="1" />
        </svg>
        <svg v-else class="ml-0.5" width="13" height="13" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
          <path d="M8 5v14l11-7L8 5z" />
        </svg>
      </button>

      <div
        class="relative flex-1 h-8 rounded-lg bg-emerald-100/80 dark:bg-emerald-900/35 overflow-hidden touch-manipulation select-none"
        role="slider"
        :aria-valuenow="Math.round(progress)"
        aria-valuemin="0"
        aria-valuemax="100"
        aria-label="跟读进度"
        :class="uploading || !audioUrl ? 'opacity-50 pointer-events-none' : ''"
        @pointerdown="onTrackPointerDown"
        @pointermove="onTrackPointerMove"
        @pointerup="onTrackPointerUp"
        @pointercancel="onTrackPointerUp"
      >
        <div
          class="absolute inset-y-0 left-0 bg-emerald-400/40 dark:bg-emerald-500/30 pointer-events-none"
          :style="{ width: `${progress}%` }"
        />
        <div
          class="absolute top-1.5 bottom-1.5 w-0.5 rounded-full bg-emerald-800 dark:bg-emerald-100 pointer-events-none"
          :style="{ left: `calc(${Math.min(97, Math.max(1, progress))}% - 1px)` }"
        />
      </div>

      <span
        v-if="uploading"
        class="shrink-0 text-[10px] font-medium text-emerald-700 dark:text-emerald-300 animate-pulse w-12 text-right"
      >
        上传中
      </span>
      <span
        v-else-if="aligning && !playing"
        class="shrink-0 text-[10px] font-medium text-emerald-700 dark:text-emerald-300 w-12 text-right"
      >
        对齐中
      </span>
      <span
        v-else-if="displayDuration"
        class="shrink-0 text-[11px] font-semibold tabular-nums text-emerald-800 dark:text-emerald-200 w-10 text-right"
      >
        {{ displayDuration }}
      </span>

      <button
        type="button"
        class="shrink-0 min-h-9 min-w-9 inline-flex items-center justify-center rounded-lg text-emerald-800 dark:text-emerald-200 hover:bg-emerald-100/80 dark:hover:bg-emerald-900/50 touch-manipulation disabled:opacity-50"
        aria-label="更多操作"
        :aria-expanded="menuOpen"
        :disabled="uploading"
        @click="menuOpen = !menuOpen"
      >
        <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
          <circle cx="5" cy="12" r="1.6" />
          <circle cx="12" cy="12" r="1.6" />
          <circle cx="19" cy="12" r="1.6" />
        </svg>
      </button>
    </div>

    <div
      v-if="menuOpen"
      class="absolute right-1.5 top-full mt-0.5 z-20 min-w-[8.5rem] rounded-xl border border-emerald-200/80 bg-white py-1 shadow-lg dark:border-emerald-800 dark:bg-neutral-900"
      role="menu"
    >
      <button
        type="button"
        role="menuitem"
        class="w-full px-3 py-2.5 text-left text-[12px] font-semibold text-emerald-950 hover:bg-emerald-50 dark:text-emerald-50 dark:hover:bg-emerald-950/50 touch-manipulation disabled:opacity-50"
        :disabled="aligning"
        @click="onAlignReference"
      >
        对齐原声
      </button>
      <button
        type="button"
        role="menuitem"
        class="w-full px-3 py-2.5 text-left text-[12px] font-semibold text-emerald-950 hover:bg-emerald-50 dark:text-emerald-50 dark:hover:bg-emerald-950/50 touch-manipulation"
        @click="onRerecord"
      >
        重录
      </button>
      <button
        type="button"
        role="menuitem"
        class="w-full px-3 py-2.5 text-left text-[12px] font-semibold text-emerald-700 hover:bg-emerald-50 dark:text-emerald-300 dark:hover:bg-emerald-950/50 touch-manipulation"
        @click="onScore"
      >
        去打分
      </button>
    </div>
  </div>
</template>
