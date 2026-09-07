<script setup lang="ts">
import { computed, nextTick, onMounted, onUnmounted, provide, ref, watch } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import { getArticleDetail, type ArticleDetail, type ArticleSegment } from '@/api/articles'
import { fetchWordLookup } from '@/composables/useWordLookupCache'
import EntryCard from '@/components/EntryCard.vue'
import ReadingSegmentRow from '@/components/reading/ReadingSegmentRow.vue'
import ReadingContinuousPane from '@/components/reading/ReadingContinuousPane.vue'
import ReadingArticleCover from '@/components/reading/ReadingArticleCover.vue'
import ReadingIntensiveSegmentRow from '@/components/reading/ReadingIntensiveSegmentRow.vue'
import IntensiveReadingStatsBar from '@/components/intensive/IntensiveReadingStatsBar.vue'
import IntensiveCoreVocabPanel from '@/components/intensive/IntensiveCoreVocabPanel.vue'
import IntensiveCoreVocabMobile from '@/components/intensive/IntensiveCoreVocabMobile.vue'
import IntensiveModeToggle from '@/components/intensive/IntensiveModeToggle.vue'
import SettingsButton from '@/components/SettingsButton.vue'
import AiReadingQaSheet from '@/components/ai/AiReadingQaSheet.vue'
import AiShadowingSheet, { type PassagePracticeBlock } from '@/components/ai/AiShadowingSheet.vue'
import ReadingShareCard from '@/components/ai/ReadingShareCard.vue'
import ReadingSettingsPanel from '@/components/reading/ReadingSettingsPanel.vue'
import ReadingWordTooltipHost from '@/components/reading/ReadingWordTooltipHost.vue'
import ReadingArticleVocabSidebar from '@/components/reading/ReadingArticleVocabSidebar.vue'
import ReadingVocabLinkSidebar from '@/components/reading/ReadingVocabLinkSidebar.vue'
import ReadingSegmentsSidebar from '@/components/reading/ReadingSegmentsSidebar.vue'
import { useReadingProgress } from '@/composables/useReadingProgress'
import ReadingTtsBar from '@/components/reading/ReadingTtsBar.vue'
import { useReadingTts, READING_TTS_KEY } from '@/composables/useReadingTts'
import { useReadingSettings } from '@/composables/useReadingSettings'
import { useIntensiveReadingMode } from '@/composables/useIntensiveReadingMode'
import { useVocabLinkMode } from '@/composables/useVocabLinkMode'
import { useReadingDualSplit } from '@/composables/useReadingDualSplit'
import { useCoreVocabulary, type CoreVocabSource } from '@/composables/useCoreVocabulary'
import { ARTICLE_VOCABULARY_KEY, useArticleVocabulary } from '@/composables/useArticleVocabulary'
import { useAuthStore } from '@/stores/auth'
import { useVoiceCloneStore } from '@/stores/voiceClone'
import VoiceCloneSheet from '@/components/voice/VoiceCloneSheet.vue'
import { useSourceFocusPulse } from '@/composables/useSourceFocusPulse'
import { useWordLongPress } from '@/composables/useWordLongPress'
import type { EntryDetail } from '@/types'
import { resolveReadingContext } from '@/utils/readingContext'
import { highlightVocabLinkText, parseVocabSummary, type VocabSummaryGroup, type VocabSummaryItem } from '@/utils/vocabSummary'

const route = useRoute()
const router = useRouter()
const auth = useAuthStore()
const voiceClone = useVoiceCloneStore()
const voiceCloneOpen = ref(false)
const {
  focusId: sourceFocusId,
  focusWord: sourceFocusWord,
  trigger: triggerSourceFocus,
  isFocused: isSourceFocused,
} = useSourceFocusPulse(5000)

const articleId = computed(() => route.params.articleId as string)
const loading = ref(true)
const error = ref('')
const limitError = ref('')
const article = ref<ArticleDetail | null>(null)

const segmentCount = computed(() => article.value?.segment_count ?? 0)
const segments = computed(() => article.value?.segments ?? [])
const { currentIndex, setCurrentIndex, startReporting, stopReporting } = useReadingProgress(
  articleId,
  segmentCount,
)

const showEntry = ref(false)
const entryLoading = ref(false)
const entryError = ref('')
const selectedEntry = ref<EntryDetail | null>(null)
const vocabNotice = ref('')
const vocabNoticeType = ref<'ok' | 'err' | ''>('')
let vocabNoticeTimer: ReturnType<typeof setTimeout> | null = null
const activeSegment = ref<ArticleSegment | null>(null)
const aiQaOpen = ref(false)
const shareOpen = ref(false)

const oralOpen = ref(false)
const oralMode = ref<'passage'>('passage')
const oralText = ref('')
const oralChinese = ref('')
const oralTitle = ref('篇章评测')
const oralSegmentId = ref<number | null>(null)
const oralBlocks = ref<PassagePracticeBlock[]>([])

function startSegmentOral(segment: ArticleSegment) {
  const en = (segment.english || '').trim()
  const zh = (segment.chinese || '').trim()
  oralMode.value = 'passage'
  oralText.value = en
  oralChinese.value = zh
  oralTitle.value = '段落跟读'
  oralSegmentId.value = segment.id
  oralBlocks.value = [{ english: en, chinese: zh, focus: true, segmentIndex: segment.index }]
  setCurrentIndex(segment.index)
  oralOpen.value = true
}

/** 从当前段起向后拼接，做短篇/篇章评测（控制长度） */
function startPassageOral() {
  const list = segments.value
  if (!list.length) return
  const start = Math.max(0, currentIndex.value)
  const blocks: PassagePracticeBlock[] = []
  let chars = 0
  let firstSegId: number | null = null
  for (let i = start; i < list.length; i++) {
    const en = (list[i].english || '').trim()
    if (!en) continue
    if (chars + en.length > 1200 && blocks.length) break
    if (firstSegId == null) firstSegId = list[i].id
    blocks.push({
      english: en,
      chinese: (list[i].chinese || '').trim(),
      focus: blocks.length === 0,
      segmentIndex: list[i].index,
    })
    chars += en.length
  }
  if (!blocks.length) return
  oralMode.value = 'passage'
  oralText.value = blocks.map((b) => b.english).join(' ')
  oralChinese.value = blocks.map((b) => b.chinese).filter(Boolean).join(' ')
  oralTitle.value = blocks.length > 1 ? '篇章评测' : '段落跟读'
  oralSegmentId.value = firstSegId
  oralBlocks.value = blocks
  oralOpen.value = true
}

const shareEnglish = computed(() => {
  const seg = segments.value[currentIndex.value]
  return seg?.english || ''
})
const shareChinese = computed(() => {
  const seg = segments.value[currentIndex.value]
  return seg?.chinese || ''
})
const qaSegmentId = computed(() => segments.value[currentIndex.value]?.id ?? null)

const {
  layoutMode,
  readingPageClass,
} = useReadingSettings()

const { intensiveMode, intensivePageClass } = useIntensiveReadingMode()
const { vocabLinkMode, toggleVocabLinkMode } = useVocabLinkMode()
const { leftPercent, dragging, startDrag } = useReadingDualSplit()
const dualSplitRef = ref<HTMLElement | null>(null)
const segmentsExpanded = ref(true)

const vocabSummaryGroups = computed<VocabSummaryGroup[]>(() => {
  const ep = article.value
  if (!ep) return []
  if (Array.isArray(ep.vocab_summary) && ep.vocab_summary.length) return ep.vocab_summary
  return parseVocabSummary(ep.vocab_summary_text || '')
})

const showVocabLinkUi = computed(() => vocabLinkMode.value && !intensiveMode.value)

const activeVocabEn = ref('')

function vocabLinkHtmlFor(segment: ArticleSegment): string | undefined {
  if (!showVocabLinkUi.value || !vocabSummaryGroups.value.length) return undefined
  return highlightVocabLinkText(segment.english || '', vocabSummaryGroups.value)
}

function onVocabCardSelect(item: VocabSummaryItem) {
  activeVocabEn.value = item.en
  const needle = item.en.trim().toLowerCase()
  if (!needle || !article.value) return
  const idx = article.value.segments.findIndex((s) =>
    (s.english || '').toLowerCase().includes(needle),
  )
  if (idx >= 0) {
    onActivateSegment(article.value.segments[idx].index)
  }
}

const coreVocabSources = computed<CoreVocabSource[]>(() =>
  (article.value?.segments ?? []).map((segment) => ({
    id: segment.id,
    englishHtml: segment.english_html || segment.english,
    context: segment.english,
    meta: { article_id: articleId.value, segment_id: segment.id },
  })),
)
const coreVocab = useCoreVocabulary(coreVocabSources, { enabled: intensiveMode })
const { items: coreVocabItems, loading: coreVocabLoading, count: coreVocabCount } = coreVocab

const showSettings = ref(false)
const segmentRefs = ref<(HTMLElement | null)[]>([])
const leftPaneRef = ref<HTMLElement | null>(null)
const rightPaneRef = ref<HTMLElement | null>(null)

const useDualColumnLayout = computed(() => layoutMode.value === 'dual' && !intensiveMode.value)

const vocabLinkHtmlMap = computed(() => {
  const map: Record<number, string | undefined> = {}
  if (!showVocabLinkUi.value || !article.value) return map
  for (const segment of article.value.segments) {
    map[segment.id] = vocabLinkHtmlFor(segment)
  }
  return map
})

const articleVocabEnabled = computed(() => auth.isLoggedIn)
const articleVocab = useArticleVocabulary(articleId, { enabled: articleVocabEnabled })
provide(ARTICLE_VOCABULARY_KEY, articleVocab)

function setSegmentRef(el: HTMLElement | null, index: number) {
  segmentRefs.value[index] = el
}

function scrollChildIntoPane(pane: HTMLElement | null, index: number, behavior: ScrollBehavior) {
  if (!pane) return
  const child = pane.querySelector<HTMLElement>(`[data-reading-segment="${index}"]`)
  if (!child) return
  const paneRect = pane.getBoundingClientRect()
  const childRect = child.getBoundingClientRect()
  const delta = childRect.top - paneRect.top - paneRect.height / 2 + childRect.height / 2
  pane.scrollBy({ top: delta, behavior })
}

function scrollToSegment(index: number, behavior: ScrollBehavior = 'smooth') {
  if (useDualColumnLayout.value && window.matchMedia('(min-width: 1024px)').matches) {
    scrollChildIntoPane(leftPaneRef.value, index, behavior)
    scrollChildIntoPane(rightPaneRef.value, index, behavior)
    return
  }
  const el = segmentRefs.value[index]
  el?.scrollIntoView({ behavior, block: 'center' })
}

function resolveDeepLinkSegment(segmentsList: ArticleSegment[]): ArticleSegment | null {
  const raw = route.query.segment
  const segmentId = Number(Array.isArray(raw) ? raw[0] : raw)
  if (!Number.isFinite(segmentId) || segmentId <= 0) return null
  return segmentsList.find((s) => s.id === segmentId) ?? null
}

async function loadArticle() {
  loading.value = true
  error.value = ''
  limitError.value = ''
  article.value = null
  try {
    const data = await getArticleDetail(articleId.value)
    article.value = data
    const deepSeg = resolveDeepLinkSegment(data.segments || [])
    const startIndex = deepSeg?.index ?? data.progress?.last_segment_index ?? 0
    currentIndex.value = startIndex
    await nextTick()
    scrollToSegment(startIndex, 'auto')
    // 生词定位时再滚一次，确保双栏/异步渲染后也能对准，并触发高亮脉冲
    if (deepSeg) {
      const wordRaw = route.query.word
      const word = String(Array.isArray(wordRaw) ? wordRaw[0] : wordRaw || '')
      window.setTimeout(() => {
        scrollToSegment(deepSeg.index, 'smooth')
        triggerSourceFocus(deepSeg.id, word)
      }, 120)
    }
    startReporting()
    // 生词本后台加载，不挡住正文首屏
    void articleVocab.reload()
  } catch (e: unknown) {
    const resp = (e as { response?: { status?: number; data?: { detail?: { code?: string; message?: string } } } })
      ?.response
    if (resp?.status === 403) {
      limitError.value = resp.data?.detail?.message || '已达到可读文章上限'
    } else {
      error.value = '文章加载失败'
    }
    stopReporting()
  } finally {
    loading.value = false
  }
}

function onActivateSegment(index: number) {
  setCurrentIndex(index)
  scrollToSegment(index)
}

const readingTts = useReadingTts({
  segments,
  currentIndex,
  setCurrentIndex,
  scrollToSegment,
})
provide(READING_TTS_KEY, readingTts)

watch(
  () => readingTts.error.value,
  (msg) => {
    if (msg) flashQuickVocabToast(msg)
  },
)

function openVoiceClone() {
  if (!auth.isLoggedIn) {
    router.push({ path: '/login', query: { redirect: route.fullPath } })
    return
  }
  voiceCloneOpen.value = true
}

function onClonedVoiceUpdated(voice: import('@/api/voiceClone').ClonedVoiceInfo | null) {
  voiceClone.setLocalVoice(voice)
  if (voice?.voice) {
    voiceClone.persistMode('cloned')
    void voiceClone.setPreferPlayback(true)
    flashQuickVocabToast('复刻成功：阅读页可选用我的声音')
  }
}

function onOralPlay(rate = 1) {
  const indexes = oralBlocks.value
    .map((b) => b.segmentIndex)
    .filter((n): n is number => typeof n === 'number')
  if (indexes.length) {
    readingTts.playRange(Math.min(...indexes), Math.max(...indexes), rate)
    return
  }
  readingTts.playSegment(currentIndex.value, false, rate)
}

function resolveClickedWordSpan(target: HTMLElement, root: HTMLElement): HTMLElement | null {
  let el: HTMLElement | null = target.closest('span')
  while (el && el !== root) {
    const text = el.textContent?.trim()
    if (text && !el.classList.contains('subtitle-english-word-progress')) return el
    el = el.parentElement?.closest('span') ?? null
  }
  return null
}

function resolveSegmentFromEvent(e: Event): ArticleSegment | null {
  const el = (e.target as HTMLElement).closest('[data-reading-segment-id]')
  if (!el) return null
  const id = Number(el.getAttribute('data-reading-segment-id'))
  if (!Number.isFinite(id)) return null
  return segments.value.find((s) => s.id === id) ?? null
}

function resolveReadingWordHit(e: Event, segment?: ArticleSegment | null) {
  const seg = segment ?? resolveSegmentFromEvent(e)
  if (!seg) return null

  const root = (e.target as HTMLElement).closest('.subtitle-english') as HTMLElement | null
  const plainRoot = !root ? (e.target as HTMLElement).closest('p.subtitle-english') : null
  if (!root && !plainRoot) return null

  let word = ''
  let type: 1 | 2 = 1
  const target = root ? resolveClickedWordSpan(e.target as HTMLElement, root) : null

  if (target) {
    word = target.textContent?.trim().replace(/\s+/g, ' ') ?? ''
    const isPhrase =
      Boolean(target.getAttribute('pid')) ||
      target.classList.contains('phrase-token') ||
      (target.classList.contains('vocab-link-hl') && /\s/.test(word))
    type = isPhrase ? 2 : 1
  } else if (plainRoot) {
    const selection = window.getSelection()?.toString().trim()
    word = selection || ''
    type = word.includes(' ') ? 2 : 1
  }
  if (!word) return null
  return { segment: seg, word, type, target }
}

const quickVocabToast = ref('')
let quickVocabToastTimer: ReturnType<typeof setTimeout> | null = null
let quickFavoriteBusy = false

function flashQuickVocabToast(message: string) {
  if (quickVocabToastTimer != null) clearTimeout(quickVocabToastTimer)
  quickVocabToast.value = message
  quickVocabToastTimer = setTimeout(() => {
    quickVocabToast.value = ''
    quickVocabToastTimer = null
  }, 2200)
}

async function quickFavoriteFromPointer(e: PointerEvent) {
  if (!auth.isLoggedIn || quickFavoriteBusy) return
  const hit = resolveReadingWordHit(e)
  if (!hit) return

  quickFavoriteBusy = true
  activeSegment.value = hit.segment
  try {
    const detail = await fetchWordLookup(
      hit.word,
      hit.type,
      resolveReadingContext(e.target as HTMLElement),
      {
        article_id: articleId.value,
        segment_id: hit.segment.id,
      },
    )
    if (!detail) {
      flashQuickVocabToast('收藏失败，请重试')
      return
    }
    const already = articleVocab.isSaved(detail.id) || detail.favorite
    if (already) {
      flashQuickVocabToast(`「${detail.headword}」已在生词本`)
      return
    }
    const saved = await articleVocab.toggle(
      { ...detail, favorite: false },
      {
        segmentId: hit.segment.id,
        tokenType: detail.category === '短语' ? 2 : 1,
      },
    )
    if (saved) {
      hit.target?.classList.add('highlight', 'token-clicked')
      flashQuickVocabToast(`已加入生词本：${detail.headword}`)
      try {
        const { useVocabularyStore } = await import('@/stores/vocabulary')
        useVocabularyStore().invalidate()
      } catch {
        // ignore
      }
    }
  } catch {
    flashQuickVocabToast('收藏失败，请重试')
  } finally {
    quickFavoriteBusy = false
  }
}

const wordLongPress = useWordLongPress({
  enabled: () => auth.isLoggedIn,
  onLongPress: (e) => {
    void quickFavoriteFromPointer(e)
  },
})

const wordLongPressHandlers = {
  pointerdown: wordLongPress.onPointerDown,
  pointermove: wordLongPress.onPointerMove,
  pointerup: wordLongPress.onPointerUp,
  pointercancel: wordLongPress.onPointerCancel,
  contextmenu: wordLongPress.onContextMenu,
}

async function onWordClick(e: MouseEvent, segment?: ArticleSegment) {
  if (wordLongPress.consumeIfFired()) return

  const hit = resolveReadingWordHit(e, segment)
  if (!hit) return

  if (hit.target?.classList.contains('vocab-link-hl')) {
    activeVocabEn.value = hit.word
  }

  activeSegment.value = hit.segment
  showEntry.value = true
  entryLoading.value = true
  entryError.value = ''
  clearVocabNotice()
  selectedEntry.value = null

  try {
    const detail = await fetchWordLookup(
      hit.word,
      hit.type,
      resolveReadingContext(e.target as HTMLElement),
      {
        article_id: articleId.value,
        segment_id: hit.segment.id,
      },
    )
    if (!detail) {
      entryError.value = '查词失败，请稍后重试'
      return
    }
    selectedEntry.value = {
      ...detail,
      favorite: articleVocab.isSaved(detail.id) || detail.favorite,
    }
  } catch {
    entryError.value = '查词失败，请稍后重试'
  } finally {
    entryLoading.value = false
  }
}

function clearVocabNotice() {
  if (vocabNoticeTimer != null) {
    clearTimeout(vocabNoticeTimer)
    vocabNoticeTimer = null
  }
  vocabNotice.value = ''
  vocabNoticeType.value = ''
}

/** persist=true 时不自动消失（加入成功后保留「已加入生词本 / 查看」） */
function flashVocabNotice(message: string, type: 'ok' | 'err', persist = false) {
  if (vocabNoticeTimer != null) clearTimeout(vocabNoticeTimer)
  vocabNoticeTimer = null
  vocabNotice.value = message
  vocabNoticeType.value = type
  if (persist) return
  vocabNoticeTimer = setTimeout(() => {
    vocabNotice.value = ''
    vocabNoticeType.value = ''
    vocabNoticeTimer = null
  }, 2200)
}

function closeEntryPanel() {
  showEntry.value = false
  clearVocabNotice()
}

async function toggleVocabulary(entry: EntryDetail) {
  if (!auth.isLoggedIn) return
  const wasSaved = Boolean(entry.favorite)
  // 先即时反馈，避免等接口才出现「已加入」
  flashVocabNotice(wasSaved ? '移出中…' : '加入中…', 'ok')
  try {
    const saved = await articleVocab.toggle(entry, {
      segmentId: activeSegment.value?.id,
      tokenType: entry.category === '短语' ? 2 : 1,
    })
    selectedEntry.value = { ...entry, favorite: saved }
    flashVocabNotice(saved ? '已加入生词本' : '已移出生词本', 'ok', saved)
    if (saved !== wasSaved) {
      try {
        const { useVocabularyStore } = await import('@/stores/vocabulary')
        useVocabularyStore().invalidate()
      } catch {
        // ignore
      }
    }
  } catch {
    flashVocabNotice('操作失败，请重试', 'err')
  }
}

const backFrom = computed(() => {
  const raw = route.query.from
  return String(Array.isArray(raw) ? raw[0] : raw || '')
})
const fromVocabulary = computed(() => backFrom.value === 'vocab')
const fromLearning = computed(() => backFrom.value === 'learning')

function goBack() {
  if (fromVocabulary.value) {
    router.push('/english/vocabulary')
    return
  }
  if (fromLearning.value) {
    router.push('/english/learning')
    return
  }
  router.push('/english/reading')
}

onMounted(loadArticle)

onUnmounted(() => {
  stopReporting()
  readingTts.stop()
  document.body.style.overflow = ''
  if (quickVocabToastTimer != null) clearTimeout(quickVocabToastTimer)
})

watch(articleId, () => {
  stopReporting()
  loadArticle()
})

watch(showSettings, (open) => {
  document.body.style.overflow = open ? 'hidden' : ''
})

watch(layoutMode, async () => {
  await nextTick()
  articleVocab.syncSavedMarks()
})
</script>

<template>
  <div
    class="reading-page flex flex-col h-full min-h-0 bg-neutral-100 dark:bg-neutral-950"
    :class="[readingPageClass, intensivePageClass]"
  >
    <header class="shrink-0 flex items-center gap-3 px-4 py-3 bg-white dark:bg-neutral-900 border-b border-black/5 dark:border-white/10">
      <button type="button" class="text-sm text-neutral-500 hover:text-black dark:hover:text-white shrink-0" @click="goBack">
        {{ fromVocabulary ? '← 生词本' : fromLearning ? '← 学习统计' : '← 返回' }}
      </button>
      <div v-if="article" class="flex-1 min-w-0">
        <p class="font-semibold truncate">{{ article.title }}</p>
        <p class="text-xs text-neutral-500 truncate">
          {{ article.source }}
          <span v-if="article.published_at"> · {{ article.published_at.slice(0, 10) }}</span>
          <span v-if="article.source_url">
            ·
            <a :href="article.source_url" target="_blank" rel="noopener noreferrer" class="underline">原文</a>
          </span>
        </p>
      </div>
      <RouterLink
        v-if="article"
        :to="`/english/reading/${articleId}/typing`"
        class="shrink-0 rounded-full px-3 py-1 text-xs font-medium border border-teal-500/40 bg-teal-50 text-teal-800 hover:bg-teal-100 dark:bg-teal-950/40 dark:text-teal-200 dark:border-teal-700/60 dark:hover:bg-teal-900/50 transition-colors"
        title="展示全文段落，从第 1 段开始逐句打字"
      >
        打字练习
      </RouterLink>
      <button
        v-if="article && !intensiveMode"
        type="button"
        class="shrink-0 rounded-full px-3 py-1 text-xs font-medium border transition-colors"
        :class="
          vocabLinkMode
            ? 'bg-sky-600 text-white border-sky-600 dark:bg-sky-500 dark:border-sky-500'
            : 'bg-white text-neutral-600 border-black/10 dark:bg-neutral-800 dark:text-neutral-300 dark:border-white/10'
        "
        :aria-pressed="vocabLinkMode"
        @click="toggleVocabLinkMode"
      >
        词文对照
      </button>
      <button
        v-if="article"
        type="button"
        class="shrink-0 rounded-full px-3 py-1 text-xs font-medium border border-black/10 dark:border-white/10 text-neutral-600 dark:text-neutral-300 hover:border-sky-400"
        @click="startPassageOral"
      >
        篇章评测
      </button>
      <button
        v-if="article"
        type="button"
        class="shrink-0 rounded-full px-3 py-1 text-xs font-medium border border-black/10 dark:border-white/10 text-neutral-600 dark:text-neutral-300 hover:border-violet-400"
        @click="aiQaOpen = true"
      >
        AI问答
      </button>
      <button
        v-if="article"
        type="button"
        class="shrink-0 rounded-full px-3 py-1 text-xs font-medium border border-black/10 dark:border-white/10 text-neutral-600 dark:text-neutral-300 hover:border-amber-400"
        @click="shareOpen = true"
      >
        分享
      </button>
      <IntensiveModeToggle />
      <SettingsButton class="shrink-0" @click="showSettings = true" />
    </header>

    <div v-if="loading" class="flex-1 flex items-center justify-center text-neutral-500">加载中...</div>
    <div v-else-if="limitError" class="flex-1 flex flex-col items-center justify-center gap-3 px-6 text-center">
      <p class="text-amber-800 dark:text-amber-200">{{ limitError }}</p>
      <button type="button" class="text-sm underline" @click="goBack">
        {{ fromVocabulary ? '返回生词本' : fromLearning ? '返回学习统计' : '返回列表' }}
      </button>
    </div>
    <div v-else-if="error" class="flex-1 flex items-center justify-center text-red-500">{{ error }}</div>

    <div v-else-if="article" class="flex flex-1 min-h-0 flex-col">
      <IntensiveReadingStatsBar
        v-if="intensiveMode"
        :title="article.title"
        :subtitle="article.source"
        :word-count="article.word_count"
        :highlight-count="coreVocabCount"
        :segment-count="article.segment_count"
      />

      <div class="flex flex-1 min-h-0">
        <ReadingWordTooltipHost
          v-if="!intensiveMode"
          :article-id="articleId"
          class="flex-1 min-h-0 flex flex-col"
        >
          <!-- 桌面三栏：左全文 · 中词文对照 · 右段落（可收起） -->
          <div
            v-if="useDualColumnLayout"
            ref="dualSplitRef"
            class="hidden lg:flex flex-1 min-h-0"
            :class="dragging ? 'select-none' : ''"
          >
            <div
              ref="leftPaneRef"
              class="min-h-0 overflow-y-auto overscroll-contain reading-scroll-hide bg-white dark:bg-neutral-900"
              :style="{ width: `${leftPercent}%`, flex: '0 0 auto' }"
            >
              <ReadingContinuousPane
                :segments="article.segments"
                :current-index="currentIndex"
                :cover="article.cover"
                :title="article.title"
                :vocab-link-html-map="vocabLinkHtmlMap"
                :focus-segment-id="sourceFocusId"
                :emphasize-word="sourceFocusWord"
                v-on="wordLongPressHandlers"
                @activate="onActivateSegment"
                @click="onWordClick"
              />
            </div>

            <div
              role="separator"
              aria-orientation="vertical"
              aria-label="调整全文区域宽度"
              :aria-valuenow="Math.round(leftPercent)"
              aria-valuemin="28"
              aria-valuemax="72"
              tabindex="0"
              class="group relative w-2 shrink-0 cursor-col-resize touch-none bg-transparent hover:bg-sky-500/15 active:bg-sky-500/25 transition-colors"
              @pointerdown="startDrag($event, dualSplitRef)"
            >
              <div
                class="pointer-events-none absolute inset-y-0 left-1/2 w-px -translate-x-1/2 bg-black/10 dark:bg-white/15 group-hover:bg-sky-500/70 group-active:bg-sky-500"
                :class="dragging ? 'bg-sky-500' : ''"
              />
              <div
                class="pointer-events-none absolute top-1/2 left-1/2 h-8 w-1 -translate-x-1/2 -translate-y-1/2 rounded-full bg-neutral-300 dark:bg-neutral-600 opacity-70 group-hover:bg-sky-500 group-hover:opacity-100"
                :class="dragging ? 'bg-sky-500 opacity-100' : ''"
              />
            </div>

            <div class="flex flex-1 min-w-0 min-h-0">
              <ReadingVocabLinkSidebar
                v-if="showVocabLinkUi"
                :groups="vocabSummaryGroups"
                :active-en="activeVocabEn"
                :fill-remaining="!segmentsExpanded"
                :article-id="articleId"
                :can-save="auth.isLoggedIn"
                :vocabulary="articleVocab"
                @select="onVocabCardSelect"
              />

              <ReadingSegmentsSidebar v-model:expanded="segmentsExpanded">
                <div
                  ref="rightPaneRef"
                  class="h-full min-h-0 overflow-y-auto overscroll-contain reading-scroll-hide p-3 space-y-3"
                >
                  <div
                    v-for="segment in article.segments"
                    :key="`right-${segment.id}`"
                    :data-reading-segment="segment.index"
                  >
                    <ReadingSegmentRow
                      :segment="segment"
                      :article-id="articleId"
                      :active="segment.index === currentIndex"
                      :emphasize-word="isSourceFocused(segment.id) ? sourceFocusWord : ''"
                      :vocab-link-html="vocabLinkHtmlFor(segment)"
                      v-on="wordLongPressHandlers"
                      @activate="onActivateSegment(segment.index)"
                      @click="onWordClick($event, segment)"
                      @oral-practice="startSegmentOral(segment)"
                    />
                  </div>
                </div>
              </ReadingSegmentsSidebar>
            </div>
          </div>

          <!-- 手机 / 单栏：封面 + 段落卡片 -->
          <div
            class="flex-1 min-h-0 overflow-y-auto overscroll-contain reading-scroll-hide"
            :class="useDualColumnLayout ? 'lg:hidden' : ''"
          >
            <div class="page-container py-4 max-w-5xl">
              <ReadingArticleCover
                class="mb-4"
                :cover="article.cover"
                :title="article.title"
              />
              <div class="space-y-3">
                <div
                  v-for="segment in article.segments"
                  :key="segment.id"
                  :ref="(el) => setSegmentRef(el as HTMLElement | null, segment.index)"
                >
                  <ReadingSegmentRow
                    :segment="segment"
                    :article-id="articleId"
                    :active="segment.index === currentIndex"
                    :emphasize-word="isSourceFocused(segment.id) ? sourceFocusWord : ''"
                    :vocab-link-html="vocabLinkHtmlFor(segment)"
                    v-on="wordLongPressHandlers"
                    @activate="onActivateSegment(segment.index)"
                    @click="onWordClick($event, segment)"
                    @oral-practice="startSegmentOral(segment)"
                  />
                </div>
              </div>
            </div>
          </div>
        </ReadingWordTooltipHost>

        <div
          v-else
          class="flex-1 min-h-0 overflow-y-auto overscroll-contain reading-scroll-hide"
        >
          <div class="page-container py-4 max-w-3xl">
            <ReadingArticleCover
              class="mb-4"
              :cover="article.cover"
              :title="article.title"
            />
            <div class="space-y-3">
              <div
                v-for="segment in article.segments"
                :key="segment.id"
                :ref="(el) => setSegmentRef(el as HTMLElement | null, segment.index)"
              >
                <ReadingIntensiveSegmentRow
                  :segment="segment"
                  :article-id="articleId"
                  :active="segment.index === currentIndex"
                  :emphasize-word="isSourceFocused(segment.id) ? sourceFocusWord : ''"
                  v-on="wordLongPressHandlers"
                  @activate="onActivateSegment(segment.index)"
                  @click="onWordClick($event, segment)"
                />
              </div>
            </div>
          </div>
        </div>

        <ReadingArticleVocabSidebar v-if="auth.isLoggedIn && !intensiveMode && !showVocabLinkUi" />
        <IntensiveCoreVocabPanel
          v-if="intensiveMode"
          :items="coreVocabItems"
          :loading="coreVocabLoading"
        />
      </div>

      <IntensiveCoreVocabMobile
        v-if="intensiveMode"
        :items="coreVocabItems"
        :loading="coreVocabLoading"
      />
    </div>

    <ReadingTtsBar
      v-if="article && readingTts.hasAudio.value"
      :current-index="currentIndex"
      :segment-count="segmentCount"
      @open-voice-clone="openVoiceClone"
      @need-login="router.push({ path: '/login', query: { redirect: route.fullPath } })"
    />

    <EntryCard
      v-if="showEntry"
      :entry="selectedEntry"
      :loading="entryLoading"
      :error="entryError"
      :can-save-vocabulary="auth.isLoggedIn"
      :vocab-notice="vocabNotice"
      :vocab-notice-type="vocabNoticeType"
      @close="closeEntryPanel"
      @toggle-vocabulary="toggleVocabulary"
    />

    <Teleport to="body">
      <div
        v-if="quickVocabToast"
        class="fixed inset-x-0 bottom-24 z-[420] flex justify-center pointer-events-none px-4"
        role="status"
      >
        <div
          class="rounded-full bg-neutral-900/90 dark:bg-neutral-100/95 text-white dark:text-neutral-900 text-sm px-4 py-2 shadow-lg max-w-sm text-center"
        >
          {{ quickVocabToast }}
        </div>
      </div>
    </Teleport>

    <ReadingSettingsPanel v-if="showSettings" @close="showSettings = false" />
    <AiReadingQaSheet
      :open="aiQaOpen"
      :article-id="articleId"
      :segment-id="qaSegmentId"
      :segment-preview="shareEnglish"
      @close="aiQaOpen = false"
    />
    <AiShadowingSheet
      :open="oralOpen"
      :mode="oralMode"
      :ref-text="oralText"
      :chinese="oralChinese"
      :title="oralTitle"
      :article-id="articleId"
      :segment-id="oralSegmentId"
      :vocab-groups="vocabSummaryGroups"
      :passage-blocks="oralBlocks"
      source-type="article"
      :has-next="false"
      @close="oralOpen = false"
      @play="onOralPlay"
      @pause="readingTts.stop()"
      @next="oralOpen = false"
    />
    <ReadingShareCard
      :open="shareOpen"
      :title="article?.title || ''"
      :english="shareEnglish"
      :chinese="shareChinese"
      @close="shareOpen = false"
    />
    <VoiceCloneSheet
      v-if="auth.isLoggedIn && auth.user"
      :open="voiceCloneOpen"
      :user-id="auth.user.id"
      @close="voiceCloneOpen = false"
      @updated="onClonedVoiceUpdated"
    />
  </div>
</template>

<style scoped>
:deep(.subtitle-english),
:deep(.reading-vocab-en) {
  font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, 'Liberation Mono', 'Courier New',
    monospace;
}

:deep(.subtitle-english span.highlight),
:deep(.subtitle-english span.vocab-link-hl) {
  cursor: pointer;
}
</style>
