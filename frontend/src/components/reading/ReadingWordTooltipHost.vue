<script setup lang="ts">
import { computed, inject, onMounted, onUnmounted, ref, useAttrs } from 'vue'
import { ARTICLE_VOCABULARY_KEY } from '@/composables/useArticleVocabulary'
import { fetchWordLookup } from '@/composables/useWordLookupCache'
import { useAuthStore } from '@/stores/auth'
import type { EntryDetail } from '@/types'
import { firstChineseDefinition, primaryIpa } from '@/utils/entryDisplay'
import { READING_TTS_KEY } from '@/composables/useReadingTts'
import { examTagClass, formatExamTags } from '@/utils/examTags'
import { playWordPronunciation } from '@/utils/speakWord'
import { resolveReadingContext, resolveReadingSegmentId } from '@/utils/readingContext'
import AppIcon from '@/components/AppIcon.vue'

defineOptions({ inheritAttrs: false })

const props = defineProps<{ articleId: string }>()
const attrs = useAttrs()
const auth = useAuthStore()
const articleVocab = inject(ARTICLE_VOCABULARY_KEY, null)
const readingTts = inject(READING_TTS_KEY, null)

const hostRef = ref<HTMLElement | null>(null)
const tooltipRef = ref<HTMLElement | null>(null)
const visible = ref(false)
const loading = ref(false)
const saving = ref(false)
const entry = ref<EntryDetail | null>(null)
const pos = ref({ top: 0, left: 0 })
const activeMeta = ref<{ segmentId?: number; tokenType: 1 | 2 }>({ tokenType: 1 })

let showTimer: ReturnType<typeof setTimeout> | null = null
let hideTimer: ReturnType<typeof setTimeout> | null = null
let activeSpan: HTMLElement | null = null
let requestId = 0
let hoveringTooltip = false

const ipa = computed(() => (entry.value ? primaryIpa(entry.value) : ''))
const meaning = computed(() => (entry.value ? firstChineseDefinition(entry.value) || '暂无释义' : ''))
const examTags = computed(() => formatExamTags(entry.value?.exam_tags ?? []))
const isSaved = computed(() => (entry.value ? articleVocab?.isSaved(entry.value.id) ?? entry.value.favorite : false))
const canSave = computed(() => auth.isLoggedIn && Boolean(articleVocab))

function resolveHighlightSpan(el: EventTarget | null): HTMLElement | null {
  if (!(el instanceof HTMLElement)) return null
  return el.closest('.subtitle-english span.highlight') as HTMLElement | null
}

function resolveSegmentMeta(span: HTMLElement) {
  return {
    segmentId: resolveReadingSegmentId(span),
    context: resolveReadingContext(span),
  }
}

function positionTooltip(span: HTMLElement) {
  const rect = span.getBoundingClientRect()
  pos.value = {
    top: rect.top - 8,
    left: rect.left + rect.width / 2,
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

function hide() {
  activeSpan = null
  visible.value = false
  loading.value = false
  entry.value = null
  requestId += 1
}

async function showFor(span: HTMLElement) {
  const currentRequest = ++requestId
  activeSpan = span
  positionTooltip(span)
  visible.value = true
  loading.value = true
  entry.value = null

  const word = span.textContent?.trim().replace(/\s+/g, ' ') ?? ''
  if (!word) {
    hide()
    return
  }

  const isPhrase = span.hasAttribute('pid') || span.classList.contains('phrase-token')
  const type = (isPhrase ? 2 : 1) as 1 | 2
  const { segmentId, context } = resolveSegmentMeta(span)
  activeMeta.value = { segmentId, tokenType: type }

  const result = await fetchWordLookup(word, type, context, {
    article_id: props.articleId,
    segment_id: segmentId,
  })

  if (currentRequest !== requestId || activeSpan !== span) return

  loading.value = false
  entry.value = result
  if (result && articleVocab) {
    entry.value = { ...result, favorite: articleVocab.isSaved(result.id) }
  }
}

function scheduleHide() {
  clearTimers()
  hideTimer = setTimeout(() => {
    if (!hoveringTooltip) hide()
  }, 120)
}

function onMouseOver(e: MouseEvent) {
  if (tooltipRef.value?.contains(e.target as Node)) {
    hoveringTooltip = true
    clearTimers()
    return
  }

  const span = resolveHighlightSpan(e.target)
  if (!span) return

  hoveringTooltip = false
  if (activeSpan === span) {
    positionTooltip(span)
    clearTimers()
    return
  }

  clearTimers()
  showTimer = setTimeout(() => {
    showFor(span)
  }, 180)
}

function onMouseOut(e: MouseEvent) {
  if (tooltipRef.value?.contains(e.relatedTarget as Node)) {
    hoveringTooltip = true
    clearTimers()
    return
  }

  const span = resolveHighlightSpan(e.target)
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

async function toggleFavorite() {
  if (!entry.value || !articleVocab || saving.value) return
  saving.value = true
  try {
    const saved = await articleVocab.toggle(entry.value, {
      segmentId: activeMeta.value.segmentId,
      tokenType: activeMeta.value.tokenType,
    })
    entry.value = { ...entry.value, favorite: saved }
  } finally {
    saving.value = false
  }
}

function speakWord() {
  if (!entry.value?.headword) return
  readingTts?.pause()
  const url = entry.value.pronunciations?.find((p) => p.is_primary)?.audio_url
    ?? entry.value.pronunciations?.[0]?.audio_url
  playWordPronunciation(entry.value.headword, url)
}

function onScroll() {
  if (visible.value) hide()
}

onMounted(() => {
  const host = hostRef.value
  if (!host) return
  host.addEventListener('scroll', onScroll, { passive: true, capture: true })
  window.addEventListener('scroll', onScroll, { passive: true, capture: true })
  window.addEventListener('resize', onScroll, { passive: true })
})

onUnmounted(() => {
  clearTimers()
  hide()
  const host = hostRef.value
  if (host) host.removeEventListener('scroll', onScroll, true)
  window.removeEventListener('scroll', onScroll, true)
  window.removeEventListener('resize', onScroll)
})
</script>

<template>
  <div ref="hostRef" v-bind="attrs" @mouseover="onMouseOver" @mouseout="onMouseOut">
    <slot />
  </div>

  <Teleport to="body">
    <div
      v-if="visible"
      ref="tooltipRef"
      class="reading-word-tooltip pointer-events-auto fixed z-40 w-max max-w-[min(20rem,calc(100vw-2rem))] -translate-x-1/2 -translate-y-full rounded-lg bg-neutral-900 px-3 py-2.5 text-white shadow-lg shadow-black/20 dark:bg-neutral-800 dark:ring-1 dark:ring-white/10"
      :style="{ top: `${pos.top}px`, left: `${pos.left}px` }"
      role="tooltip"
      @mouseenter="onTooltipEnter"
      @mouseleave="onTooltipLeave"
    >
      <div v-if="loading" class="text-xs text-neutral-300 animate-pulse py-0.5">加载中…</div>
      <template v-else>
        <div class="flex items-start gap-2">
          <div class="min-w-0 flex-1">
            <div v-if="examTags.length" class="flex flex-wrap gap-1 mb-1.5">
              <span
                v-for="tag in examTags"
                :key="tag.key"
                class="text-[10px] leading-none px-1.5 py-0.5 rounded font-medium"
                :class="examTagClass(tag.key)"
              >
                {{ tag.label }}
              </span>
            </div>
            <p v-if="ipa" class="text-xs font-mono text-neutral-300 leading-snug flex items-center gap-1.5">
              <span>{{ ipa }}</span>
              <button
                type="button"
                class="inline-flex p-0.5 rounded text-neutral-400 hover:text-white transition-colors"
                aria-label="朗读单词"
                @click.stop="speakWord"
              >
                <AppIcon name="volume-up" :size="14" />
              </button>
            </p>
            <p v-else-if="entry" class="text-xs leading-snug">
              <button
                type="button"
                class="inline-flex items-center gap-1 text-neutral-400 hover:text-white transition-colors"
                @click.stop="speakWord"
              >
                <AppIcon name="volume-up" :size="14" />
                朗读
              </button>
            </p>
            <p class="text-sm leading-snug" :class="ipa || entry ? 'mt-0.5' : ''">{{ meaning }}</p>
          </div>
          <button
            v-if="canSave"
            type="button"
            class="shrink-0 p-0.5 rounded transition-colors disabled:opacity-50"
            :class="isSaved ? 'text-amber-400 hover:text-amber-300' : 'text-neutral-400 hover:text-amber-400'"
            :disabled="saving"
            :aria-label="isSaved ? '移出生词本' : '加入本篇生词本'"
            @click.stop="toggleFavorite"
          >
            <AppIcon name="star" :size="18" :fill="isSaved ? 'currentColor' : 'none'" />
          </button>
        </div>
      </template>
      <div
        class="absolute left-1/2 top-full -translate-x-1/2 border-[6px] border-transparent border-t-neutral-900 dark:border-t-neutral-800 pointer-events-none"
        aria-hidden="true"
      />
    </div>
  </Teleport>
</template>
