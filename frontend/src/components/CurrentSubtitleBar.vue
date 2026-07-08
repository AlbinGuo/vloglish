<script setup lang="ts">
import SubtitleBlock from '@/components/SubtitleBlock.vue'
import IntensiveReadingBlock from '@/components/intensive/IntensiveReadingBlock.vue'
import type { Subtitle } from '@/types'
import type { WordLookupMeta } from '@/composables/useWordLookupCache'
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
  intensive?: boolean
  lookupMeta?: WordLookupMeta
}>()

defineEmits<{
  click: [event: MouseEvent]
  seek: []
}>()

const isChineseOnly = () => modeIsChineseOnly(props.subtitleMode)
</script>

<template>
  <div
    class="current-subtitle-bar relative rounded-2xl border border-black/8 dark:border-white/10 bg-white dark:bg-neutral-900 dark:border-white/10 cursor-pointer shadow-sm transition-shadow hover:shadow-md"
    :class="[
      compact ? 'current-subtitle-bar--compact shrink-0 overflow-hidden' : 'min-h-0 flex-1 overflow-hidden overflow-x-hidden',
      topAlign ? 'current-subtitle-bar--top-align' : '',
    ]"
    @click="$emit('seek')"
  >
    <div class="current-subtitle-bar__viewport">
      <div class="subtitle-focus-light current-subtitle-bar__content">
        <IntensiveReadingBlock
          v-if="intensive"
          class="w-full min-w-0"
          :english-html="englishHtml"
          :english="sub.english"
          :chinese="sub.chinese"
          :ipa="sub.ipa"
          :large="!compact"
          align="center"
          :show-english="modeShowsEnglish(subtitleMode)"
          :show-chinese="modeShowsChinese(subtitleMode)"
          :show-ipa="modeShowsIpa(subtitleMode, showIpa)"
          :lookup-meta="lookupMeta"
          @click.stop="$emit('click', $event)"
        />
        <SubtitleBlock
          v-else
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

.current-subtitle-bar :deep(.subtitle-english-word-progress) {
  display: block;
  width: 100%;
  min-width: 0;
  max-width: 100%;
  white-space: normal;
  overflow-wrap: anywhere;
  word-break: break-word;
  text-align: center;
  gap: 0 !important;
}

.current-subtitle-bar :deep(.subtitle-english-word-progress .subtitle-word-wrap) {
  display: inline;
  max-width: 100%;
}

/* v-html 模式：flex 折行，词间距与列表区一致（gap-x-1.5），不再叠加额外 gap */
.current-subtitle-bar :deep(.subtitle-english:not(.subtitle-english-word-progress):not(.intensive-english)) {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  align-items: baseline;
  column-gap: 0.375rem;
  row-gap: 0.125rem;
  width: 100%;
  min-width: 0;
  max-width: 100%;
  white-space: normal;
  overflow-wrap: anywhere;
  word-break: break-word;
  text-align: center;
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
