<script setup lang="ts">
import { inject } from 'vue'
import { READING_TTS_KEY } from '@/composables/useReadingTts'

const props = defineProps<{
  segmentIndex: number
  hasAudio: boolean
}>()

const tts = inject(READING_TTS_KEY, null)

function onClick() {
  if (!tts || !props.hasAudio) return
  if (tts.isPlaying.value && tts.playingIndex.value === props.segmentIndex) {
    tts.pause()
    return
  }
  tts.playSegment(props.segmentIndex, false)
}
</script>

<template>
  <button
    v-if="hasAudio"
    type="button"
    class="shrink-0 mt-0.5 inline-flex h-7 w-7 items-center justify-center rounded-full border border-black/8 dark:border-white/10 text-neutral-500 hover:text-neutral-800 hover:bg-neutral-100 dark:text-neutral-400 dark:hover:text-neutral-100 dark:hover:bg-neutral-800 transition-colors"
    :class="
      tts?.playingIndex.value === segmentIndex && tts?.isPlaying.value
        ? 'text-amber-600 border-amber-300/60 bg-amber-50 dark:text-amber-400 dark:bg-amber-900/20'
        : ''
    "
    :aria-label="tts?.playingIndex.value === segmentIndex && tts?.isPlaying.value ? '暂停朗读' : '朗读本段'"
    @click.stop="onClick"
  >
    <svg
      v-if="tts?.playingIndex.value === segmentIndex && tts?.isPlaying.value"
      width="14"
      height="14"
      viewBox="0 0 24 24"
      fill="currentColor"
      aria-hidden="true"
    >
      <path d="M6 5h4v14H6V5zm8 0h4v14h-4V5z" />
    </svg>
    <svg
      v-else
      width="14"
      height="14"
      viewBox="0 0 24 24"
      fill="currentColor"
      aria-hidden="true"
    >
      <path d="M8 5v14l11-7L8 5z" />
    </svg>
  </button>
</template>
