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
  /** 手机端固定高度紧凑样式 */
  compact?: boolean
  /** Pad：实时字幕顶对齐（margin: 0） */
  topAlign?: boolean
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
    class="current-subtitle-bar relative rounded-2xl border bg-white dark:bg-neutral-900 dark:border-white/10 cursor-pointer shadow-sm transition-shadow hover:shadow-md overflow-hidden"
    :class="[
      compact ? 'current-subtitle-bar--compact h-[7.25rem] shrink-0' : 'min-h-0 flex-1',
      topAlign ? 'current-subtitle-bar--top-align' : '',
      showBarProgress ? 'border-black/8 border-t-0 dark:border-white/10' : 'border-black/8 dark:border-white/10',
    ]"
    @click="$emit('seek')"
  >
    <div
      v-if="showBarProgress"
      class="sentence-progress-track absolute inset-x-0 top-0 z-10 h-[3px] rounded-t-2xl bg-black/8 dark:bg-white/10 pointer-events-none overflow-hidden"
      aria-hidden="true"
    >
      <div class="sentence-progress-fill h-full w-full bg-neutral-700/70 dark:bg-neutral-300/70" :style="progressFillStyle" />
    </div>

    <div class="current-subtitle-bar__viewport">
      <div class="subtitle-focus-light current-subtitle-bar__content">
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
  </div>
</template>

<style scoped>
/* 占满播放器下方剩余高度，内部用 margin:auto 垂直居中（兼容 iPad 1024 等） */
.current-subtitle-bar__viewport {
  position: absolute;
  inset: 0;
  display: flex;
  min-height: 0;
  padding: 0.75rem 1rem;
  box-sizing: border-box;
}

@media (min-width: 640px) {
  .current-subtitle-bar__viewport {
    padding: 0.875rem 1.25rem;
  }
}

.current-subtitle-bar__content {
  margin: auto;
  width: 100%;
  max-height: 100%;
  overflow-y: auto;
  text-align: center;
}

.current-subtitle-bar--top-align .current-subtitle-bar__content {
  margin: 0;
}

.current-subtitle-bar--top-align .current-subtitle-bar__viewport {
  align-items: flex-start;
}

.current-subtitle-bar :deep(.subtitle-english-progress) {
  display: flex;
  width: 100%;
  justify-content: center;
}

.current-subtitle-bar--compact :deep(.subtitle-english),
.current-subtitle-bar--compact :deep(.subtitle-english-dim),
.current-subtitle-bar--compact :deep(.subtitle-english-read) {
  font-size: 1.125rem;
  line-height: 1.4;
}

.current-subtitle-bar--compact :deep(.subtitle-ipa) {
  font-size: 0.875rem;
}

.current-subtitle-bar--compact :deep(.subtitle-chinese) {
  font-size: 0.875rem;
}

.current-subtitle-bar--compact .current-subtitle-bar__viewport {
  padding: 0.625rem 0.75rem;
}

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
