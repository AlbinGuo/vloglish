<script setup lang="ts">
import { computed, inject } from 'vue'
import { READING_TTS_KEY } from '@/composables/useReadingTts'
import AppIcon from '@/components/AppIcon.vue'

const props = defineProps<{
  segmentIndex: number
  hasAudio: boolean
}>()

const tts = inject(READING_TTS_KEY, null)

const playable = computed(() => tts?.canPlaySegment(props.segmentIndex) ?? props.hasAudio)
const active = computed(
  () =>
    tts?.playingIndex.value === props.segmentIndex &&
    Boolean(tts?.isPlaying.value || tts?.synthesizing.value),
)

function onClick() {
  if (!tts || !playable.value) return
  if (tts.isPlaying.value && tts.playingIndex.value === props.segmentIndex) {
    tts.pause()
    return
  }
  tts.playSegment(props.segmentIndex, false)
}
</script>

<template>
  <button
    v-if="playable"
    type="button"
    class="shrink-0 mt-0.5 inline-flex h-7 w-7 items-center justify-center rounded-full border border-line text-ink-faint hover:text-neutral-800 hover:bg-sunken dark:hover:text-neutral-100 transition-colors"
    :class="
      active
        ? 'text-warning border-amber-300/60 bg-amber-50 dark:bg-amber-900/20'
        : ''
    "
    :aria-label="active ? '暂停朗读' : '朗读本段'"
    @click.stop="onClick"
  >
    <AppIcon name="pause" v-if="active" :size="14" />
    <AppIcon name="play" :size="14" />
  </button>
</template>
