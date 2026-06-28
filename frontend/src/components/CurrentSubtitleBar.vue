<script setup lang="ts">
import { computed } from 'vue'
import SubtitleBlock from '@/components/SubtitleBlock.vue'
import { useSentenceProgressStyle } from '@/composables/useSentenceProgressStyle'
import type { Subtitle } from '@/types'
import { computeSentenceProgress, isSentenceActive } from '@/utils/sentenceProgress'
import type { SubtitleDisplayMode } from '@/utils/subtitleHtml'
import {
  modeIsChineseOnly,
  modeShowsChinese,
  modeShowsEnglish,
  modeShowsIpa,
} from '@/utils/subtitleHtml'

const props = defineProps<{
  sub: Subtitle
  currentTime: number
  subtitleMode: SubtitleDisplayMode
  showIpa: boolean
  englishHtml: string
}>()

defineEmits<{
  click: [event: MouseEvent]
  seek: []
}>()

const { sentenceProgressStyle } = useSentenceProgressStyle()

const isPlayingSub = computed(() => isSentenceActive(props.sub, props.currentTime))

const progress = computed(() => computeSentenceProgress(props.sub, props.currentTime))

const showBarProgress = computed(
  () => isPlayingSub.value && sentenceProgressStyle.value === 'bar',
)

const gradientProgress = computed(() =>
  isPlayingSub.value && sentenceProgressStyle.value === 'gradient' ? progress.value : undefined,
)

const progressFillStyle = computed(() => ({
  transform: `scaleX(${progress.value})`,
}))

const isChineseOnly = () => modeIsChineseOnly(props.subtitleMode)
</script>

<template>
  <div
    class="current-subtitle-bar relative flex-1 min-h-0 flex flex-col rounded-2xl border bg-white dark:bg-neutral-900 dark:border-white/10 cursor-pointer shadow-sm transition-shadow hover:shadow-md overflow-hidden"
    :class="showBarProgress ? 'border-black/8 border-t-0 dark:border-white/10' : 'border-black/8 dark:border-white/10'"
    @click="$emit('seek')"
  >
    <div
      v-if="showBarProgress"
      class="sentence-progress-track absolute inset-x-0 top-0 z-10 h-[3px] rounded-t-2xl bg-black/8 dark:bg-white/10 pointer-events-none overflow-hidden"
      aria-hidden="true"
    >
      <div class="sentence-progress-fill h-full w-full bg-neutral-700/70 dark:bg-neutral-300/70" :style="progressFillStyle" />
    </div>

    <div
      class="subtitle-focus-light flex flex-1 min-h-0 flex-col justify-center items-center text-center px-4 py-4 sm:px-5 sm:py-5 overflow-y-auto"
    >
      <SubtitleBlock
        class="w-full"
        :english-html="englishHtml"
        :chinese="sub.chinese"
        :ipa="sub.ipa"
        :large="true"
        align="center"
        :chinese-focus="isChineseOnly()"
        :show-english="modeShowsEnglish(subtitleMode)"
        :show-chinese="modeShowsChinese(subtitleMode)"
        :show-ipa="modeShowsIpa(subtitleMode, showIpa)"
        :read-progress="gradientProgress"
        @click.stop="$emit('click', $event)"
      />
    </div>
  </div>
</template>

<style scoped>
.sentence-progress-fill {
  transform-origin: left center;
  transition: transform 0.28s linear;
  will-change: transform;
}

.current-subtitle-bar :deep(.subtitle-english),
.current-subtitle-bar :deep(.subtitle-english-dim),
.current-subtitle-bar :deep(.subtitle-english-read) {
  font-size: 1.375rem;
  line-height: 1.45;
  font-weight: 600;
}

@media (min-width: 640px) {
  .current-subtitle-bar :deep(.subtitle-english),
  .current-subtitle-bar :deep(.subtitle-english-dim),
  .current-subtitle-bar :deep(.subtitle-english-read) {
    font-size: 1.625rem;
  }
}

.current-subtitle-bar :deep(.subtitle-ipa) {
  font-size: 1rem;
  color: #818181;
  opacity: 1;
}

:global(.dark) .current-subtitle-bar :deep(.subtitle-ipa) {
  color: rgb(229 229 229);
}

@media (min-width: 640px) {
  .current-subtitle-bar :deep(.subtitle-ipa) {
    font-size: 1.125rem;
  }
}

.current-subtitle-bar :deep(.subtitle-chinese) {
  font-size: 1rem;
  color: #818181;
  opacity: 1;
}

:global(.dark) .current-subtitle-bar :deep(.subtitle-chinese) {
  color: rgb(212 212 212);
}
</style>
