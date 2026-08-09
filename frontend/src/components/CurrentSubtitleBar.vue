<script setup lang="ts">
import { computed, nextTick, ref, watch } from 'vue'
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
  stripSpeakerMarkers,
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
  /** 全屏等场景：中文固定在底部，上方英文可滚动；并按篇幅收缩字号 */
  pinChinese?: boolean
  intensive?: boolean
  lookupMeta?: WordLookupMeta
  /** 听写中：毛玻璃遮罩 */
  dictationFrost?: boolean
}>()

defineEmits<{
  click: [event: MouseEvent]
  seek: []
}>()

const scrollRef = ref<HTMLElement | null>(null)

const isChineseOnly = () => modeIsChineseOnly(props.subtitleMode)

const showChinese = computed(() => modeShowsChinese(props.subtitleMode))
const showEnglish = computed(() => modeShowsEnglish(props.subtitleMode))
const showIpaLine = computed(() => modeShowsIpa(props.subtitleMode, props.showIpa))

const displayChinese = computed(() => stripSpeakerMarkers(props.sub.chinese || ''))

const usePinnedChinese = computed(
  () =>
    Boolean(props.pinChinese) &&
    !props.compact &&
    showChinese.value &&
    Boolean(displayChinese.value),
)

/** 按英/中篇幅收缩字号，尽量同屏显示（全屏贴底模式） */
const fluidStyle = computed(() => {
  if (!props.pinChinese) return undefined
  const en = (props.sub.english || '').trim().length
  const zh = displayChinese.value.trim().length
  const score = en + zh * 0.9
  let enRem = 1.625
  let zhRem = 1
  if (score > 220) {
    enRem = 1.125
    zhRem = 0.8125
  } else if (score > 160) {
    enRem = 1.25
    zhRem = 0.875
  } else if (score > 100) {
    enRem = 1.375
    zhRem = 0.9375
  } else if (score > 60) {
    enRem = 1.5
    zhRem = 1
  }
  return {
    '--csb-en-size': `${enRem}rem`,
    '--csb-zh-size': `${zhRem}rem`,
  } as Record<string, string>
})

watch(
  () => props.sub.id,
  async () => {
    await nextTick()
    if (scrollRef.value) scrollRef.value.scrollTop = 0
  },
)
</script>

<template>
  <div
    class="current-subtitle-bar relative rounded-2xl border border-black/8 dark:border-white/10 bg-white dark:bg-neutral-900 dark:border-white/10 cursor-pointer shadow-sm transition-shadow hover:shadow-md"
    :class="[
      compact ? 'current-subtitle-bar--compact shrink-0 overflow-hidden' : 'min-h-0 flex-1 overflow-hidden overflow-x-hidden',
      topAlign ? 'current-subtitle-bar--top-align' : '',
      usePinnedChinese ? 'current-subtitle-bar--pin-chinese' : '',
      pinChinese ? 'current-subtitle-bar--fluid' : '',
    ]"
    :style="fluidStyle"
    @click="$emit('seek')"
  >
    <div class="current-subtitle-bar__viewport">
      <template v-if="usePinnedChinese">
        <div ref="scrollRef" class="current-subtitle-bar__scroll subtitle-focus-light">
          <IntensiveReadingBlock
            v-if="intensive"
            class="w-full min-w-0"
            :english-html="englishHtml"
            :english="sub.english"
            :chinese="sub.chinese"
            :ipa="sub.ipa"
            :large="!compact"
            align="center"
            :show-english="showEnglish"
            :show-chinese="false"
            :show-ipa="showIpaLine"
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
            :show-english="showEnglish"
            :show-chinese="false"
            :show-ipa="showIpaLine"
            @click.stop="$emit('click', $event)"
          />
        </div>
        <p
          class="subtitle-chinese current-subtitle-bar__chinese-pin max-w-full break-words"
          :class="intensive ? 'intensive-chinese-block' : ''"
        >
          {{ displayChinese }}
        </p>
      </template>
      <div v-else class="subtitle-focus-light current-subtitle-bar__content">
        <IntensiveReadingBlock
          v-if="intensive"
          class="w-full min-w-0"
          :english-html="englishHtml"
          :english="sub.english"
          :chinese="sub.chinese"
          :ipa="sub.ipa"
          :large="!compact"
          align="center"
          :show-english="showEnglish"
          :show-chinese="showChinese"
          :show-ipa="showIpaLine"
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
          :show-english="showEnglish"
          :show-chinese="showChinese"
          :show-ipa="showIpaLine"
          @click.stop="$emit('click', $event)"
        />
      </div>
    </div>
    <div
      v-if="dictationFrost"
      class="absolute inset-0 z-[6] rounded-2xl pointer-events-none bg-white/50 dark:bg-neutral-950/55 backdrop-blur-[7px] shadow-[inset_0_0_0_1px_rgba(255,255,255,0.28)] dark:shadow-[inset_0_0_0_1px_rgba(255,255,255,0.06)]"
      aria-hidden="true"
    />
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

/* 中文贴底：上方英文可滚，中文始终可见 */
.current-subtitle-bar--pin-chinese .current-subtitle-bar__viewport {
  flex-direction: column;
  align-items: stretch;
  gap: 0.375rem;
}

.current-subtitle-bar__scroll {
  flex: 1 1 auto;
  min-height: 0;
  width: 100%;
  overflow-x: hidden;
  overflow-y: auto;
  overscroll-behavior: contain;
  text-align: center;
}

.current-subtitle-bar__chinese-pin {
  flex: 0 0 auto;
  width: 100%;
  margin: 0;
  text-align: center;
  padding-top: 0.25rem;
  border-top: 1px solid rgb(0 0 0 / 0.06);
}

:global(.dark) .current-subtitle-bar__chinese-pin {
  border-top-color: rgb(255 255 255 / 0.1);
}

.current-subtitle-bar__chinese-pin.intensive-chinese-block {
  border-top: none;
  padding-top: 0;
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

.current-subtitle-bar :deep(.subtitle-chinese),
.current-subtitle-bar__chinese-pin {
  font-size: 1rem;
  color: #818181;
  opacity: 1;
}

:global(.dark) .current-subtitle-bar :deep(.subtitle-chinese),
:global(.dark) .current-subtitle-bar__chinese-pin {
  color: rgb(212 212 212);
}

/* 流体字号：覆盖固定 rem，随篇幅收缩 */
.current-subtitle-bar--fluid:not(.current-subtitle-bar--compact) :deep(.subtitle-english),
.current-subtitle-bar--fluid:not(.current-subtitle-bar--compact) :deep(.intensive-english) {
  font-size: var(--csb-en-size, 1.625rem) !important;
  line-height: 1.4;
}

.current-subtitle-bar--fluid:not(.current-subtitle-bar--compact) :deep(.subtitle-chinese),
.current-subtitle-bar--fluid:not(.current-subtitle-bar--compact) .current-subtitle-bar__chinese-pin {
  font-size: var(--csb-zh-size, 1rem) !important;
  line-height: 1.45;
}

.current-subtitle-bar--fluid:not(.current-subtitle-bar--compact) :deep(.subtitle-ipa),
.current-subtitle-bar--fluid:not(.current-subtitle-bar--compact) :deep(.intensive-ipa) {
  font-size: calc(var(--csb-zh-size, 1rem) * 0.95) !important;
}
</style>
