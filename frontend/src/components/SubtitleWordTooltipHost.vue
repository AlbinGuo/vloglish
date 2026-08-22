<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref, useAttrs, watch } from 'vue'
import { fetchWordLookup, getCachedWordLookup, type WordLookupMeta } from '@/composables/useWordLookupCache'
import type { EntryDetail } from '@/types'
import { firstChineseDefinition, firstEnglishDefinition, primaryIpa } from '@/utils/entryDisplay'
import { playWordPronunciation } from '@/utils/speakWord'

defineOptions({ inheritAttrs: false })

const props = withDefaults(
  defineProps<{
    /** 查词上下文（整句英文） */
    context?: string
    lookupMeta?: WordLookupMeta
    /** 仅高亮词可悬停；false 时任意有文字的 span 均可 */
    highlightOnly?: boolean
    /** Teleport 目标；全屏时应指向全屏元素，否则气泡不可见 */
    teleportTo?: string | HTMLElement | null
    /** 打开词条大弹窗时收起悬停气泡，避免叠在全屏层上面 */
    suppressed?: boolean
  }>(),
  {
    highlightOnly: false,
    teleportTo: 'body',
    suppressed: false,
  },
)

const emit = defineEmits<{
  'word-hover-start': []
  'word-hover-end': []
}>()

const attrs = useAttrs()

const hostRef = ref<HTMLElement | null>(null)
const tooltipRef = ref<HTMLElement | null>(null)
const visible = ref(false)
const loading = ref(false)
const entry = ref<EntryDetail | null>(null)
const pos = ref({ top: 0, left: 0 })
const placement = ref<'above' | 'below'>('above')

let showTimer: ReturnType<typeof setTimeout> | null = null
let hideTimer: ReturnType<typeof setTimeout> | null = null
let activeSpan: HTMLElement | null = null
let requestId = 0
let hoveringTooltip = false
let hoverSessionActive = false

const ipa = computed(() => (entry.value ? primaryIpa(entry.value) : ''))
const meaningCn = computed(() => {
  if (manualGloss.value) return manualGloss.value
  return entry.value ? firstChineseDefinition(entry.value) || '暂无释义' : ''
})
const meaningEn = computed(() => (entry.value ? firstEnglishDefinition(entry.value) : ''))
const headword = computed(() => entry.value?.headword || activeWord.value)
const manualGloss = ref('')
const activeWord = ref('')

const teleportTarget = computed(() => props.teleportTo || 'body')

function resolveWordSpan(el: EventTarget | null): HTMLElement | null {
  if (!(el instanceof HTMLElement)) return null
  const root = el.closest('.subtitle-english, .intensive-english')
  if (!(root instanceof HTMLElement)) return null

  const glossCn = el.closest('.intensive-gloss-cn')
  if (glossCn && root.contains(glossCn)) {
    const wordEl = glossCn.parentElement?.querySelector(
      '.intensive-gloss-word span.highlight, .intensive-gloss-word span, .intensive-gloss-word',
    )
    if (wordEl instanceof HTMLElement) return pickWordSpan(wordEl, root)
  }

  const fromTarget = el.closest('span')
  if (!(fromTarget instanceof HTMLElement) || !root.contains(fromTarget)) return null
  return pickWordSpan(fromTarget, root)
}

function pickWordSpan(start: HTMLElement, root: HTMLElement): HTMLElement | null {
  let span: HTMLElement | null = start
  while (span && root.contains(span) && span !== root) {
    if (span.classList.contains('subtitle-word-wrap')) {
      span = (span.querySelector(':scope > span') as HTMLElement | null) ?? span
    }
    if (span.parentElement?.classList.contains('subtitle-word-wrap')) {
      const inner = span.parentElement.querySelector(':scope > span')
      if (inner instanceof HTMLElement) span = inner
    }
    if (span.classList.contains('intensive-gloss-unit')) {
      const inner = span.querySelector('.intensive-gloss-word span, .intensive-gloss-word')
      if (inner instanceof HTMLElement) span = inner
    }
    if (span.classList.contains('intensive-gloss-word')) {
      const inner = span.querySelector('span')
      if (inner instanceof HTMLElement) span = inner
    }

    const text = span.textContent?.trim().replace(/\s+/g, ' ') ?? ''
    if (
      text &&
      /[a-zA-Z]/.test(text) &&
      !span.classList.contains('subtitle-english-word-progress') &&
      !span.classList.contains('intensive-gloss-cn')
    ) {
      if (props.highlightOnly) {
        const highlight = span.classList.contains('highlight')
          ? span
          : (span.closest('span.highlight') as HTMLElement | null)
        return highlight && root.contains(highlight) ? highlight : null
      }
      if (span.classList.contains('highlight')) return span
      const highlight = span.closest('span.highlight') as HTMLElement | null
      if (highlight && root.contains(highlight)) return highlight
      return span
    }

    span = span.parentElement?.closest('span') ?? null
  }
  return null
}

function positionTooltip(span: HTMLElement) {
  const rect = span.getBoundingClientRect()
  const gap = 10
  const preferAbove = rect.top > 120
  placement.value = preferAbove ? 'above' : 'below'
  pos.value = {
    top: preferAbove ? rect.top - gap : rect.bottom + gap,
    left: Math.min(Math.max(rect.left + rect.width / 2, 96), window.innerWidth - 96),
  }
}

function clearTimers() {
  if (showTimer) {
    clearTimeout(showTimer)
    showTimer = null
  }
  if (hideTimer) {
    clearTimeout(hideTimer)
    hideTimer = null
  }
}

function beginHoverSession() {
  if (hoverSessionActive) return
  hoverSessionActive = true
  emit('word-hover-start')
}

function endHoverSession() {
  if (!hoverSessionActive) return
  hoverSessionActive = false
  emit('word-hover-end')
}

function hide() {
  activeSpan = null
  visible.value = false
  loading.value = false
  entry.value = null
  manualGloss.value = ''
  activeWord.value = ''
  requestId += 1
  endHoverSession()
}

async function showFor(span: HTMLElement) {
  if (props.suppressed) return
  const currentRequest = ++requestId
  activeSpan = span
  positionTooltip(span)
  visible.value = true
  beginHoverSession()

  const word = span.textContent?.trim().replace(/\s+/g, ' ') ?? ''
  if (!word) {
    hide()
    return
  }

  activeWord.value = word
  manualGloss.value = (span.getAttribute('data-gloss') || '').trim()

  const isPhrase = span.hasAttribute('pid') || span.classList.contains('phrase-token')
  const type = (isPhrase ? 2 : 1) as 1 | 2
  const context =
    props.context ||
    (span.closest('[data-subtitle-context]') as HTMLElement | null)?.dataset.subtitleContext ||
    ''

  const cached = getCachedWordLookup(word, type, context)
  entry.value = cached ?? null
  loading.value = !cached && !manualGloss.value

  const result = await fetchWordLookup(word, type, context, props.lookupMeta ?? {})

  if (currentRequest !== requestId || activeSpan !== span) return

  loading.value = false
  entry.value = result
  positionTooltip(span)
}

function scheduleHide() {
  clearTimers()
  hideTimer = setTimeout(() => {
    if (!hoveringTooltip) hide()
  }, 140)
}

function onPointerDown(e: PointerEvent) {
  const span = resolveWordSpan(e.target)
  if (!span) return
  const word = span.textContent?.trim().replace(/\s+/g, ' ') ?? ''
  if (!word) return
  const isPhrase = span.hasAttribute('pid') || span.classList.contains('phrase-token')
  const type = (isPhrase ? 2 : 1) as 1 | 2
  const context =
    props.context ||
    (span.closest('[data-subtitle-context]') as HTMLElement | null)?.dataset.subtitleContext ||
    ''
  void fetchWordLookup(word, type, context, props.lookupMeta ?? {})
}

function onMouseOver(e: MouseEvent) {
  if (props.suppressed) return
  if (tooltipRef.value?.contains(e.target as Node)) {
    hoveringTooltip = true
    clearTimers()
    return
  }

  const span = resolveWordSpan(e.target)
  if (!span) return

  hoveringTooltip = false
  if (activeSpan === span) {
    positionTooltip(span)
    clearTimers()
    return
  }

  clearTimers()
  showTimer = setTimeout(() => {
    void showFor(span)
  }, 160)
}

function onMouseOut(e: MouseEvent) {
  if (tooltipRef.value?.contains(e.relatedTarget as Node)) {
    hoveringTooltip = true
    clearTimers()
    return
  }

  const span = resolveWordSpan(e.target)
  if (!span && !tooltipRef.value?.contains(e.target as Node)) return

  const related = e.relatedTarget
  if (related instanceof Node) {
    if (span?.contains(related)) return
    if (tooltipRef.value?.contains(related)) {
      hoveringTooltip = true
      clearTimers()
      return
    }
  }

  hoveringTooltip = false
  if (activeSpan === span || tooltipRef.value?.contains(e.target as Node)) {
    scheduleHide()
  }
}

function onTooltipEnter() {
  hoveringTooltip = true
  clearTimers()
}

function onTooltipLeave() {
  hoveringTooltip = false
  scheduleHide()
}

function speakWord() {
  if (!entry.value?.headword && !activeSpan) return
  const word = entry.value?.headword || activeSpan?.textContent?.trim() || ''
  const url =
    entry.value?.pronunciations?.find((p) => p.is_primary)?.audio_url ??
    entry.value?.pronunciations?.[0]?.audio_url
  playWordPronunciation(word, url)
}

function onScrollOrResize() {
  if (visible.value && activeSpan) positionTooltip(activeSpan)
  else if (visible.value) hide()
}

onMounted(() => {
  const host = hostRef.value
  host?.addEventListener('scroll', onScrollOrResize, { passive: true, capture: true })
  window.addEventListener('scroll', onScrollOrResize, { passive: true, capture: true })
  window.addEventListener('resize', onScrollOrResize, { passive: true })
  document.addEventListener('fullscreenchange', onScrollOrResize)
})

onUnmounted(() => {
  clearTimers()
  hide()
  const host = hostRef.value
  host?.removeEventListener('scroll', onScrollOrResize, true)
  window.removeEventListener('scroll', onScrollOrResize, true)
  window.removeEventListener('resize', onScrollOrResize)
  document.removeEventListener('fullscreenchange', onScrollOrResize)
})

watch(
  () => props.context,
  () => {
    if (visible.value) hide()
  },
)

watch(
  () => props.suppressed,
  (suppressed) => {
    if (suppressed) hide()
  },
)

defineExpose({ hostRef })
</script>

<template>
  <div ref="hostRef" v-bind="attrs" @pointerdown="onPointerDown" @mouseover="onMouseOver" @mouseout="onMouseOut">
    <slot />
  </div>

  <Teleport :to="teleportTarget" :disabled="!teleportTarget">
    <div
      v-if="visible"
      ref="tooltipRef"
      class="subtitle-word-tooltip pointer-events-auto fixed z-[100] w-max max-w-[min(22rem,calc(100vw-1.5rem))] -translate-x-1/2 rounded-xl bg-neutral-900 px-3.5 py-3 text-white shadow-xl shadow-black/30 ring-1 ring-white/10"
      :class="placement === 'above' ? '-translate-y-full' : ''"
      :style="{ top: `${pos.top}px`, left: `${pos.left}px` }"
      role="tooltip"
      @mouseenter="onTooltipEnter"
      @mouseleave="onTooltipLeave"
    >
      <div v-if="loading && !entry && !manualGloss" class="text-xs text-neutral-300 animate-pulse py-0.5">加载中…</div>
      <template v-else-if="entry || manualGloss">
        <div class="flex items-start gap-2.5">
          <div class="min-w-0 flex-1 space-y-1">
            <div class="flex items-center gap-2 min-w-0">
              <p class="text-sm font-semibold truncate">{{ headword }}</p>
              <button
                type="button"
                class="shrink-0 inline-flex items-center justify-center h-7 w-7 rounded-full bg-white/10 text-neutral-200 hover:bg-white/20 hover:text-white transition-colors"
                aria-label="朗读单词"
                @click.stop="speakWord"
              >
                <svg width="15" height="15" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                  <path d="M3 9v6h4l5 5V4L7 9H3zm13.5 3c0-1.77-1.02-3.29-2.5-4.03v8.05c1.48-.73 2.5-2.25 2.5-4.02zM14 3.23v2.06c2.89.86 5 3.54 5 6.71s-2.11 5.85-5 6.71v2.06c4.01-.91 7-4.49 7-8.77s-2.99-7.86-7-8.77z" />
                </svg>
              </button>
            </div>
            <p v-if="ipa" class="text-xs font-mono text-neutral-300 leading-snug">{{ ipa }}</p>
            <p v-if="meaningEn" class="text-xs text-neutral-300 leading-snug">{{ meaningEn }}</p>
            <p class="text-sm leading-snug text-white">{{ meaningCn }}</p>
          </div>
        </div>
      </template>
      <div v-else class="text-xs text-neutral-300 py-0.5">暂无词条</div>

      <div
        class="absolute left-1/2 -translate-x-1/2 border-[6px] border-transparent pointer-events-none"
        :class="
          placement === 'above'
            ? 'top-full border-t-neutral-900'
            : 'bottom-full border-b-neutral-900'
        "
        aria-hidden="true"
      />
    </div>
  </Teleport>
</template>
