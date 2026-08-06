<script setup lang="ts">
import { computed, onUnmounted, ref, watch } from 'vue'
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
const { label: durationLabel, durationSec } = useAudioDuration(() => props.audioUrl)

let audio: HTMLAudioElement | null = null
let alignTimer: ReturnType<typeof setTimeout> | null = null
let seeking = false

const displayDuration = computed(() => {
  if (durationLabel.value) return durationLabel.value
  if (props.sentenceDurationSec > 0) return formatAudioClock(props.sentenceDurationSec)
  return ''
})

const waveHeights = [40, 70, 55, 90, 45, 75, 60, 85, 50, 95, 65, 80, 42, 88, 58, 72, 48, 92, 62, 78, 52, 84, 46, 76]

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
  if (playing.value) {
    stopAudio()
    return
  }
  stopAudio()
  bindAudio(new Audio(props.audioUrl))
}

function onAlignReference() {
  if (!props.audioUrl || props.uploading) return
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

watch(
  () => props.audioUrl,
  () => stopAudio(),
)

onUnmounted(stopAudio)
</script>

<template>
  <div
    class="mt-2 rounded-2xl border border-emerald-200/70 bg-gradient-to-b from-emerald-50 to-white shadow-sm dark:border-emerald-800/40 dark:from-emerald-950/45 dark:to-neutral-900/80 overflow-hidden"
    @click.stop
  >
    <div class="px-3 pt-2.5 pb-1 flex items-center gap-2 min-h-8">
      <p class="text-[12px] font-semibold text-emerald-950 dark:text-emerald-50">
        我的跟读
      </p>
      <span
        v-if="displayDuration"
        class="inline-flex items-center rounded-md bg-emerald-100/90 px-1.5 py-0.5 text-[11px] font-semibold tabular-nums text-emerald-800 dark:bg-emerald-900/50 dark:text-emerald-200"
      >
        {{ displayDuration }}
      </span>
      <span
        v-if="uploading"
        class="ml-auto text-[11px] text-emerald-700 dark:text-emerald-300 animate-pulse"
      >
        上传中…
      </span>
      <span
        v-else-if="playing && currentLabel"
        class="ml-auto text-[11px] tabular-nums text-emerald-700/80 dark:text-emerald-300/80"
      >
        {{ currentLabel }}
      </span>
    </div>

    <!-- Transport + waveform -->
    <div class="px-3 py-2 flex items-center gap-2.5">
      <button
        type="button"
        class="shrink-0 flex h-12 w-12 items-center justify-center rounded-full text-white shadow-[0_6px_14px_rgba(16,185,129,0.35)] transition active:scale-95 touch-manipulation disabled:opacity-50"
        :class="playing ? 'bg-emerald-600' : 'bg-emerald-500 hover:bg-emerald-400'"
        :disabled="uploading || !audioUrl"
        :aria-label="playing ? '暂停' : '播放我的跟读'"
        @click="togglePlay"
      >
        <svg v-if="playing" width="15" height="15" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
          <rect x="6" y="5" width="4" height="14" rx="1" />
          <rect x="14" y="5" width="4" height="14" rx="1" />
        </svg>
        <svg v-else class="ml-0.5" width="16" height="16" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
          <path d="M8 5v14l11-7L8 5z" />
        </svg>
      </button>

      <div
        class="relative flex-1 h-12 rounded-xl bg-emerald-100/90 dark:bg-emerald-900/35 overflow-hidden touch-manipulation select-none"
        role="slider"
        :aria-valuenow="Math.round(progress)"
        aria-valuemin="0"
        aria-valuemax="100"
        aria-label="跟读进度，拖动可跳转"
        :class="uploading || !audioUrl ? 'opacity-50 pointer-events-none' : ''"
        @pointerdown="onTrackPointerDown"
        @pointermove="onTrackPointerMove"
        @pointerup="onTrackPointerUp"
        @pointercancel="onTrackPointerUp"
      >
        <div class="absolute inset-x-2 inset-y-2 flex items-end gap-[2px] sm:gap-[3px] opacity-35 pointer-events-none" aria-hidden="true">
          <span
            v-for="(h, i) in waveHeights"
            :key="i"
            class="flex-1 rounded-full bg-emerald-700 dark:bg-emerald-300"
            :style="{ height: `${h}%` }"
          />
        </div>
        <div
          class="absolute inset-y-0 left-0 bg-emerald-400/45 dark:bg-emerald-500/30 pointer-events-none"
          :style="{ width: `${progress}%` }"
        />
        <div
          class="absolute top-1.5 bottom-1.5 w-1 rounded-full bg-emerald-800 dark:bg-emerald-100 shadow pointer-events-none"
          :style="{ left: `calc(${Math.min(97, Math.max(1, progress))}% - 2px)` }"
        />
      </div>
    </div>

    <!-- Actions: icon + label, 3 equal columns -->
    <div class="px-3 pb-3 grid grid-cols-3 gap-1.5">
      <button
        type="button"
        class="min-h-11 rounded-xl px-1 text-[11px] sm:text-[12px] font-semibold border border-emerald-200/90 bg-white text-emerald-900 hover:bg-emerald-50 dark:border-emerald-800 dark:bg-neutral-900/60 dark:text-emerald-100 dark:hover:bg-emerald-950/40 touch-manipulation active:scale-[0.98] disabled:opacity-50 inline-flex flex-col sm:flex-row items-center justify-center gap-0.5 sm:gap-1"
        :disabled="uploading || aligning"
        title="先播原声，再播自己的录音"
        @click="onAlignReference"
      >
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true" class="opacity-80">
          <path d="M8 5v14l11-7L8 5z" stroke-linejoin="round" />
          <path d="M4 19V5" stroke-linecap="round" />
        </svg>
        <span>{{ aligning && !playing ? '对齐中' : '对齐原声' }}</span>
      </button>
      <button
        type="button"
        class="min-h-11 rounded-xl px-1 text-[11px] sm:text-[12px] font-semibold border border-emerald-200/90 bg-white text-emerald-900 hover:bg-emerald-50 dark:border-emerald-800 dark:bg-neutral-900/60 dark:text-emerald-100 dark:hover:bg-emerald-950/40 touch-manipulation active:scale-[0.98] disabled:opacity-50 inline-flex flex-col sm:flex-row items-center justify-center gap-0.5 sm:gap-1"
        :disabled="uploading"
        @click="emit('rerecord')"
      >
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true" class="opacity-80">
          <path d="M4 12a8 8 0 0 1 13.7-5.6" stroke-linecap="round" />
          <path d="M18 4v4h-4" stroke-linecap="round" stroke-linejoin="round" />
          <path d="M20 12a8 8 0 0 1-13.7 5.6" stroke-linecap="round" />
          <path d="M6 20v-4h4" stroke-linecap="round" stroke-linejoin="round" />
        </svg>
        <span>重录</span>
      </button>
      <button
        type="button"
        class="min-h-11 rounded-xl px-1 text-[11px] sm:text-[12px] font-semibold bg-emerald-600 text-white hover:bg-emerald-500 shadow-sm touch-manipulation active:scale-[0.98] disabled:opacity-50 inline-flex flex-col sm:flex-row items-center justify-center gap-0.5 sm:gap-1"
        :disabled="uploading"
        @click="emit('score')"
      >
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
          <path d="M12 3l2.2 4.5 5 .7-3.6 3.5.9 5.1L12 14.8 7.5 16.8l.9-5.1L4.8 8.2l5-.7L12 3z" stroke-linejoin="round" />
        </svg>
        <span>去打分</span>
      </button>
    </div>
  </div>
</template>
