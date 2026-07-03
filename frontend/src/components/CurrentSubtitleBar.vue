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
  /** 手机端紧凑样式：高度随内容折行，过长可滚动 */
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

const gradientWordHighlight = computed(() => {
  // 手机端实时字幕仅折行展示，不做逐词高亮（与桌面/Pad 区分）
  if (props.compact) return undefined
  if (!isPlayingSub.value || sentenceProgressStyle.value !== 'gradient') return undefined
  return { time: props.currentTime, start: props.sub.start, end: props.sub.end }
})

const progressFillStyle = computed(() => ({
  transform: `scaleX(${progress.value})`,
}))

const isChineseOnly = () => modeIsChineseOnly(props.subtitleMode)
</script>

<template>
  <div
    class="current-subtitle-bar relative rounded-2xl border bg-white dark:bg-neutral-900 dark:border-white/10 cursor-pointer shadow-sm transition-shadow hover:shadow-md"
    :class="[
      compact ? 'current-subtitle-bar--compact shrink-0 overflow-hidden' : 'min-h-0 flex-1 overflow-hidden overflow-x-hidden',
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
          class="w-full min-w-0"
          :english-html="englishHtml"
          :chinese="sub.chinese"
          :ipa="sub.ipa"
          :large="!compact"
          align="center"
          :chinese-focus="isChineseOnly()"
          :show-english="modeShowsEnglish(subtitleMode)"
          :show-chinese="modeShowsChinese(subtitleMode)"
          :show-ipa="modeShowsIpa(subtitleMode, showIpa)"
          :word-highlight="gradientWordHighlight"
          @click.stop="$emit('click', $event)"
        />
      </div>
    </div>
  </div>
</template>

<style scoped>
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
  min-width: 0;
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

/* 手机端：随内容折行，过长时在区域内滚动 */
.current-subtitle-bar--compact {
  min-height: 4.5rem;
  max-height: min(38dvh, 11.5rem);
}

.current-subtitle-bar--compact .current-subtitle-bar__viewport {
  position: relative;
  inset: auto;
  display: block;
  min-height: 0;
  max-height: min(38dvh, 11.5rem);
  padding: 0.625rem 0.75rem;
  overflow-y: auto;
  -webkit-overflow-scrolling: touch;
}

.current-subtitle-bar--compact .current-subtitle-bar__content {
  margin: 0;
  max-height: none;
  overflow: visible;
}

.current-subtitle-bar :deep(.subtitle-english),
.current-subtitle-bar :deep(.subtitle-english-word-progress) {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  align-items: baseline;
  gap: 0.125rem 0.375rem;
  width: 100%;
  min-width: 0;
  max-width: 100%;
  white-space: normal;
  overflow-wrap: anywhere;
  word-break: break-word;
  text-align: center;
}

.current-subtitle-bar :deep(.subtitle-word-wrap) {
  display: inline;
  max-width: 100%;
}

.current-subtitle-bar :deep(.subtitle-chinese),
.current-subtitle-bar :deep(.subtitle-ipa) {
  max-width: 100%;
  white-space: normal;
  overflow-wrap: anywhere;
  word-break: break-word;
}

.current-subtitle-bar--compact :deep(.subtitle-english) {
  font-size: 1.0625rem;
  line-height: 1.45;
}

.current-subtitle-bar--compact :deep(.subtitle-ipa) {
  font-size: 0.875rem;
}

.current-subtitle-bar--compact :deep(.subtitle-chinese) {
  font-size: 0.875rem;
}

.sentence-progress-fill {
  transform-origin: left center;
  transition: transform 0.28s linear;
  will-change: transform;
}

.current-subtitle-bar:not(.current-subtitle-bar--compact) :deep(.subtitle-english) {
  font-size: 1.375rem;
  line-height: 1.45;
  font-weight: 600;
}

@media (min-width: 640px) {
  .current-subtitle-bar:not(.current-subtitle-bar--compact) :deep(.subtitle-english) {
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
