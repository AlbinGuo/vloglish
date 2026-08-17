<script setup lang="ts">
import { computed, nextTick, onMounted, onUnmounted, ref, watch } from 'vue'
import SubtitleBlock from '@/components/SubtitleBlock.vue'
import IntensiveReadingBlock from '@/components/intensive/IntensiveReadingBlock.vue'
import type { Subtitle } from '@/types'
import type { WordLookupMeta } from '@/composables/useWordLookupCache'
import type { SubtitleDisplayMode, SubtitleAlign } from '@/utils/subtitleHtml'
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
  /** 全屏等场景：高度随内容；有中文时中文贴底，上方英文可滚动；并按篇幅收缩字号 */
  pinChinese?: boolean
  /** 叠在画面底部的字幕条（手机全屏） */
  overlay?: boolean
  /** 英文对齐，默认居中 */
  align?: SubtitleAlign
  /** 英文使用等宽字体（手机全屏） */
  monoEnglish?: boolean
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
const rootRef = ref<HTMLElement | null>(null)
/** 在流体字号基础上再收缩，尽量让英文同屏无需滚动 */
const fitScale = ref(1)
/** 缩到极限仍装不下时才允许英文区滚动 */
const englishOverflow = ref(false)

const isChineseOnly = () => modeIsChineseOnly(props.subtitleMode)

const showChinese = computed(() => modeShowsChinese(props.subtitleMode))
const showEnglish = computed(() => modeShowsEnglish(props.subtitleMode))
const showIpaLine = computed(() => modeShowsIpa(props.subtitleMode, props.showIpa))

const displayChinese = computed(() => stripSpeakerMarkers(props.sub.chinese || ''))

/** 全屏等：高度随内容；中文可选贴底 */
const usePinLayout = computed(() => Boolean(props.pinChinese) && !props.compact)

const usePinnedChinese = computed(
  () => usePinLayout.value && showChinese.value && Boolean(displayChinese.value),
)

const useOverlay = computed(() => Boolean(props.overlay))

const englishAlign = computed(() => props.align ?? 'center')

/** 按英/中篇幅收缩字号，尽量同屏显示（全屏贴底模式） */
const fluidStyle = computed(() => {
  if (!props.pinChinese && !props.overlay) return undefined
  const en = (props.sub.english || '').trim().length
  const zh = displayChinese.value.trim().length
  const score = en + zh * 0.9
  let enRem = props.overlay ? 1.2 : 1.375
  let zhRem = props.overlay ? 0.85 : 0.9
  if (score > 280) {
    enRem = props.overlay ? 0.82 : 0.875
    zhRem = 0.7
  } else if (score > 220) {
    enRem = props.overlay ? 0.9 : 0.95
    zhRem = 0.75
  } else if (score > 170) {
    enRem = props.overlay ? 1 : 1.05
    zhRem = 0.78
  } else if (score > 120) {
    enRem = props.overlay ? 1.05 : 1.15
    zhRem = 0.82
  } else if (score > 80) {
    enRem = props.overlay ? 1.1 : 1.25
    zhRem = 0.85
  }
  const scale = fitScale.value
  return {
    '--csb-en-size': `${enRem * scale}rem`,
    '--csb-zh-size': `${zhRem * Math.max(0.9, scale)}rem`,
  } as Record<string, string>
})

function panelBudgetPx(): number {
  if (typeof window === 'undefined') return 280
  if (props.overlay) {
    const player = rootRef.value?.closest('.video-panel__player') as HTMLElement | null
    const h = player?.clientHeight || window.innerHeight * 0.72
    // 叠在画面上：最多约占播放器高度 38%，并避开底部进度条
    return Math.min(h * 0.38, 12.5 * 16)
  }
  const panel = rootRef.value?.closest('.video-panel__subtitle') as HTMLElement | null
  if (panel?.clientHeight) return Math.max(panel.clientHeight - 8, 72)
  const h = window.innerHeight
  const landscape = window.matchMedia('(orientation: landscape)').matches
  if (landscape) return Math.min(h * 0.3, 10.5 * 16) - 8
  return Math.min(h * 0.34, 13.5 * 16) - 8
}

async function fitEnglishToViewport() {
  if ((!props.pinChinese && !props.overlay) || (!usePinLayout.value && !useOverlay.value)) {
    fitScale.value = 1
    englishOverflow.value = false
    return
  }
  englishOverflow.value = false
  fitScale.value = 1
  await nextTick()
  await new Promise<void>((resolve) => {
    requestAnimationFrame(() => requestAnimationFrame(() => resolve()))
  })

  const root = rootRef.value
  const scroll = scrollRef.value
  if (!root) return

  const budget = panelBudgetPx()
  for (let i = 0; i < 12; i += 1) {
    const need = root.scrollHeight
    if (need <= budget + 4) break
    const next = Math.max(0.62, Number((fitScale.value - 0.05).toFixed(3)))
    if (next === fitScale.value) break
    fitScale.value = next
    await nextTick()
  }

  await nextTick()
  if (root.scrollHeight > budget + 8) {
    englishOverflow.value = true
    await nextTick()
    if (scroll) {
      for (let i = 0; i < 6; i += 1) {
        if (scroll.scrollHeight <= scroll.clientHeight + 2) break
        const next = Math.max(0.58, Number((fitScale.value - 0.04).toFixed(3)))
        if (next === fitScale.value) break
        fitScale.value = next
        await nextTick()
      }
      scroll.scrollTop = 0
    }
  }
}

watch(
  () => props.sub.id,
  async () => {
    await nextTick()
    if (scrollRef.value) scrollRef.value.scrollTop = 0
    await fitEnglishToViewport()
  },
)

watch(
  () =>
    [props.pinChinese, props.overlay, props.sub.english, props.sub.chinese, props.subtitleMode] as const,
  () => {
    void fitEnglishToViewport()
  },
)

let fitTimer: ReturnType<typeof setTimeout> | null = null
function onViewportChange() {
  if (!props.pinChinese && !props.overlay) return
  if (fitTimer) clearTimeout(fitTimer)
  fitTimer = setTimeout(() => {
    void fitEnglishToViewport()
    fitTimer = null
  }, 120)
}

onMounted(() => {
  window.addEventListener('resize', onViewportChange)
  window.addEventListener('orientationchange', onViewportChange)
  if (props.pinChinese || props.overlay) void fitEnglishToViewport()
})

onUnmounted(() => {
  window.removeEventListener('resize', onViewportChange)
  window.removeEventListener('orientationchange', onViewportChange)
  if (fitTimer) clearTimeout(fitTimer)
})
</script>

<template>
  <div
    ref="rootRef"
    class="current-subtitle-bar relative rounded-2xl border border-black/8 dark:border-white/10 bg-white dark:bg-neutral-900 dark:border-white/10 cursor-pointer shadow-sm transition-shadow hover:shadow-md"
    :class="[
      compact && !overlay ? 'current-subtitle-bar--compact shrink-0 overflow-hidden' : '',
      !compact && !overlay && !pinChinese ? 'min-h-0 flex-1 overflow-hidden overflow-x-hidden' : '',
      overlay ? 'current-subtitle-bar--overlay shrink-0' : '',
      topAlign ? 'current-subtitle-bar--top-align' : '',
      usePinLayout ? 'current-subtitle-bar--pin-chinese' : '',
      usePinnedChinese ? 'current-subtitle-bar--has-chinese-pin' : '',
      pinChinese || overlay ? 'current-subtitle-bar--fluid' : '',
      englishAlign === 'left' ? 'current-subtitle-bar--align-left' : '',
      monoEnglish ? 'current-subtitle-bar--mono-english' : '',
      englishOverflow ? 'is-english-overflow' : '',
    ]"
    :style="fluidStyle"
    @click="$emit('seek')"
  >
    <div class="current-subtitle-bar__viewport">
      <template v-if="usePinLayout">
        <div ref="scrollRef" class="current-subtitle-bar__scroll subtitle-focus-light">
          <IntensiveReadingBlock
            v-if="intensive"
            class="w-full min-w-0"
            :english-html="englishHtml"
            :english="sub.english"
            :chinese="sub.chinese"
            :ipa="sub.ipa"
            :large="!compact"
            :align="englishAlign"
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
            :align="englishAlign"
            :chinese-focus="isChineseOnly()"
            :show-english="showEnglish"
            :show-chinese="false"
            :show-ipa="showIpaLine"
            @click.stop="$emit('click', $event)"
          />
        </div>
        <p
          v-if="usePinnedChinese"
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
          :align="englishAlign"
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
          :align="englishAlign"
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

.current-subtitle-bar--pin-chinese {
  /* 全屏：高度随内容走，避免英文被框死只能滚动 */
  height: auto !important;
  min-height: 0;
  max-height: none;
  flex: 0 0 auto !important;
  overflow: visible;
}

.current-subtitle-bar--pin-chinese .current-subtitle-bar__viewport {
  position: relative;
  inset: auto;
  display: flex;
  flex-direction: column;
  align-items: stretch;
  gap: 0.25rem;
  padding: 0.55rem 0.85rem 0.65rem;
  max-height: none;
  overflow: visible;
}

@media (min-width: 640px) {
  .current-subtitle-bar--pin-chinese .current-subtitle-bar__viewport {
    padding: 0.65rem 1.1rem 0.75rem;
  }
}

.current-subtitle-bar__scroll {
  flex: 0 1 auto;
  min-height: 0;
  width: 100%;
  /* 默认不滚动；极端长句由字号适配，仍溢出时才滚且不显示滚动条 */
  overflow-x: hidden;
  overflow-y: auto;
  overscroll-behavior: contain;
  text-align: center;
  scrollbar-width: none;
  -ms-overflow-style: none;
}
.current-subtitle-bar--align-left .current-subtitle-bar__scroll,
.current-subtitle-bar--align-left .current-subtitle-bar__content {
  text-align: left;
}

.current-subtitle-bar--mono-english :deep(.subtitle-english),
.current-subtitle-bar--mono-english :deep(.intensive-english) {
  font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, 'Liberation Mono', 'Courier New', monospace;
}
.current-subtitle-bar__scroll::-webkit-scrollbar {
  width: 0;
  height: 0;
}

.current-subtitle-bar--pin-chinese .current-subtitle-bar__scroll {
  flex: 0 0 auto;
  overflow: visible;
  max-height: none;
}

.current-subtitle-bar--pin-chinese.is-english-overflow .current-subtitle-bar__scroll {
  flex: 1 1 auto;
  overflow-y: auto;
  max-height: min(38dvh, 16rem);
}

.current-subtitle-bar--overlay.is-english-overflow .current-subtitle-bar__scroll {
  max-height: min(28dvh, 9.5rem);
}

/* 叠在画面底部：去卡片感，半透明可读 */
.current-subtitle-bar--overlay {
  border: none !important;
  border-radius: 0 !important;
  background: transparent !important;
  box-shadow: none !important;
  height: auto !important;
  max-height: none;
  overflow: visible;
}
.current-subtitle-bar--overlay:hover {
  box-shadow: none !important;
}
.current-subtitle-bar--overlay .current-subtitle-bar__viewport {
  position: relative;
  inset: auto;
  padding: 0.35rem 0.75rem 0.2rem;
  gap: 0.15rem;
}
.current-subtitle-bar--overlay .current-subtitle-bar__chinese-pin {
  border-top-color: rgb(255 255 255 / 0.18);
  color: rgb(229 229 229);
  -webkit-line-clamp: 2;
  line-clamp: 2;
}
.current-subtitle-bar--overlay :deep(.subtitle-english),
.current-subtitle-bar--overlay :deep(.intensive-english) {
  text-shadow: 0 1px 2px rgb(0 0 0 / 0.75), 0 0 10px rgb(0 0 0 / 0.35);
  font-weight: 650;
}
.current-subtitle-bar--overlay :deep(.subtitle-chinese),
.current-subtitle-bar--overlay .current-subtitle-bar__chinese-pin {
  text-shadow: 0 1px 2px rgb(0 0 0 / 0.7);
}

.current-subtitle-bar__chinese-pin {
  flex: 0 0 auto;
  width: 100%;
  margin: 0;
  text-align: center;
  padding-top: 0.2rem;
  border-top: 1px solid rgb(0 0 0 / 0.06);
  /* 中文最多两行，把高度优先留给英文 */
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  overflow: hidden;
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
