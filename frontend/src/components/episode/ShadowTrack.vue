<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref, watch } from 'vue'
import { formatAudioClock } from '@/utils/audioDuration'
import { useAudioDuration } from '@/composables/useAudioDuration'
import AppIcon from '@/components/AppIcon.vue'

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

/** 固定伪波形，看起来像语音条而非进度块 */
const WAVE_HEIGHTS = [
  35, 62, 48, 78, 40, 70, 55, 88, 45, 72, 58, 82, 38, 66, 50, 90, 42, 74, 60, 84, 36, 68, 52, 76, 44, 80, 56, 64,
]

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

const playedBars = computed(() => {
  const n = WAVE_HEIGHTS.length
  return Math.round((Math.min(100, Math.max(0, progress.value)) / 100) * n)
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
    class="mt-1 rounded-lg border border-emerald-200/50 bg-emerald-50/50 dark:border-emerald-800/35 dark:bg-emerald-950/25"
    @click.stop
  >
    <div class="flex items-center gap-1 px-1.5 py-1">
      <button
        type="button"
        class="shrink-0 flex h-7 w-7 items-center justify-center rounded-full text-white transition active:scale-95 touch-manipulation disabled:opacity-50"
        :class="playing ? 'bg-emerald-600' : 'bg-emerald-500'"
        :disabled="uploading || !audioUrl"
        :aria-label="playing ? '暂停' : '播放我的跟读'"
        @click="togglePlay"
      >
        <AppIcon name="pause" v-if="playing" :size="10" />
        <AppIcon name="play" class="ml-px" :size="11" />
      </button>

      <!-- 音轨波形进度 -->
      <div
        class="relative flex-1 h-6 flex items-center touch-manipulation select-none"
        role="slider"
        :aria-valuenow="Math.round(progress)"
        aria-valuemin="0"
        aria-valuemax="100"
        aria-label="跟读进度"
        :class="uploading || !audioUrl ? 'opacity-40 pointer-events-none' : ''"
        @pointerdown="onTrackPointerDown"
        @pointermove="onTrackPointerMove"
        @pointerup="onTrackPointerUp"
        @pointercancel="onTrackPointerUp"
      >
        <div class="absolute inset-x-0 inset-y-0.5 flex items-center gap-px" aria-hidden="true">
          <span
            v-for="(h, i) in WAVE_HEIGHTS"
            :key="i"
            class="flex-1 min-w-[2px] max-w-[3px] rounded-full transition-colors duration-75"
            :class="
              i < playedBars
                ? 'bg-emerald-600 dark:bg-emerald-400'
                : 'bg-emerald-300/70 dark:bg-emerald-700/70'
            "
            :style="{ height: `${h}%` }"
          />
        </div>
      </div>

      <span
        class="shrink-0 text-[10px] font-medium tabular-nums text-emerald-800/85 dark:text-emerald-200/85 min-w-[1.75rem] text-right leading-none"
      >
        <template v-if="uploading">…</template>
        <template v-else-if="aligning && !playing">对齐</template>
        <template v-else>{{ displayDuration || '—' }}</template>
      </span>

      <button
        type="button"
        class="shrink-0 h-7 w-7 inline-flex items-center justify-center rounded-md text-emerald-800/80 dark:text-emerald-200/80 hover:bg-emerald-100/70 dark:hover:bg-emerald-900/40 touch-manipulation disabled:opacity-50"
        aria-label="更多操作"
        :aria-expanded="menuOpen"
        :disabled="uploading"
        @click="menuOpen = !menuOpen"
      >
        <AppIcon name="close" v-if="menuOpen" :size="12" />
        <AppIcon name="more-horizontal" :size="14" />
      </button>
    </div>

    <div
      v-if="menuOpen"
      class="grid grid-cols-3 gap-0.5 px-1.5 pb-1.5"
      role="menu"
    >
      <button
        type="button"
        role="menuitem"
        class="min-h-8 rounded-md text-[10px] font-semibold text-emerald-900 bg-white/80 border border-emerald-200/60 dark:text-emerald-100 dark:bg-neutral-900/60 dark:border-emerald-800 touch-manipulation disabled:opacity-50"
        :disabled="aligning"
        @click="onAlignReference"
      >
        对齐原声
      </button>
      <button
        type="button"
        role="menuitem"
        class="min-h-8 rounded-md text-[10px] font-semibold text-emerald-900 bg-white/80 border border-emerald-200/60 dark:text-emerald-100 dark:bg-neutral-900/60 dark:border-emerald-800 touch-manipulation"
        @click="onRerecord"
      >
        重录
      </button>
      <button
        type="button"
        role="menuitem"
        class="min-h-8 rounded-md text-[10px] font-semibold text-white bg-emerald-600 touch-manipulation"
        @click="onScore"
      >
        去打分
      </button>
    </div>
  </div>
</template>
