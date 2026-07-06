<script setup lang="ts">
import { computed, inject } from 'vue'
import { READING_TTS_KEY } from '@/composables/useReadingTts'
import { useReadingSettings } from '@/composables/useReadingSettings'

const props = defineProps<{
  currentIndex: number
  segmentCount: number
}>()

const tts = inject(READING_TTS_KEY, null)
const { ttsRate, setTtsRate, autoAdvance } = useReadingSettings()

const hasAudio = computed(() => tts?.hasAudio.value ?? false)
const isPlaying = computed(() => tts?.isPlaying.value ?? false)
const playingIndex = computed(() => tts?.playingIndex.value ?? null)

const rateOptions = [0.75, 1, 1.25] as const

const progressLabel = computed(() => {
  if (props.segmentCount <= 0) return ''
  return `${props.currentIndex + 1} / ${props.segmentCount}`
})

function togglePlay() {
  if (!tts) return
  if (isPlaying.value && playingIndex.value === props.currentIndex) {
    tts.pause()
    return
  }
  tts.playContinuous()
}

function onPrev() {
  tts?.prevSegment()
}

function onNext() {
  tts?.nextSegment()
}
</script>

<template>
  <div
    v-if="hasAudio"
    class="shrink-0 border-t border-black/5 dark:border-white/10 bg-white/95 dark:bg-neutral-900/95 backdrop-blur-sm px-4 py-2.5 pb-[calc(0.625rem+env(safe-area-inset-bottom))]"
  >
    <div class="mx-auto max-w-3xl flex items-center gap-3">
      <button
        type="button"
        class="shrink-0 p-1.5 rounded-lg text-neutral-500 hover:text-neutral-800 hover:bg-neutral-100 dark:hover:text-neutral-200 dark:hover:bg-neutral-800 disabled:opacity-30"
        :disabled="currentIndex <= 0"
        aria-label="上一段"
        @click="onPrev"
      >
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="m15 18-6-6 6-6" />
        </svg>
      </button>

      <button
        type="button"
        class="shrink-0 inline-flex h-9 w-9 items-center justify-center rounded-full bg-neutral-900 text-white dark:bg-neutral-100 dark:text-neutral-900"
        :aria-label="isPlaying ? '暂停朗读' : '从当前段连续朗读'"
        @click="togglePlay"
      >
        <svg v-if="isPlaying" width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
          <path d="M6 5h4v14H6V5zm8 0h4v14h-4V5z" />
        </svg>
        <svg v-else width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
          <path d="M8 5v14l11-7L8 5z" />
        </svg>
      </button>

      <button
        type="button"
        class="shrink-0 p-1.5 rounded-lg text-neutral-500 hover:text-neutral-800 hover:bg-neutral-100 dark:hover:text-neutral-200 dark:hover:bg-neutral-800 disabled:opacity-30"
        :disabled="currentIndex >= segmentCount - 1"
        aria-label="下一段"
        @click="onNext"
      >
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="m9 18 6-6-6-6" />
        </svg>
      </button>

      <span class="text-xs text-neutral-500 tabular-nums shrink-0">{{ progressLabel }}</span>

      <div class="flex-1" />

      <div class="flex items-center gap-1 shrink-0">
        <button
          v-for="rate in rateOptions"
          :key="rate"
          type="button"
          class="px-2 py-1 rounded-md text-xs transition-colors"
          :class="
            ttsRate === rate
              ? 'bg-neutral-900 text-white dark:bg-neutral-100 dark:text-neutral-900'
              : 'text-neutral-500 hover:bg-neutral-100 dark:hover:bg-neutral-800'
          "
          @click="setTtsRate(rate)"
        >
          {{ rate }}x
        </button>
      </div>

      <label class="hidden sm:flex items-center gap-1.5 text-xs text-neutral-500 shrink-0 cursor-pointer">
        <input v-model="autoAdvance" type="checkbox" class="rounded" />
        自动下一段
      </label>
    </div>
  </div>
</template>
