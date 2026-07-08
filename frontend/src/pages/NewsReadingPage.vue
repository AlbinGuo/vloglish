<script setup lang="ts">
import { computed, nextTick, onMounted, onUnmounted, provide, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { getArticleDetail, type ArticleDetail, type ArticleSegment } from '@/api/articles'
import { fetchWordLookup } from '@/composables/useWordLookupCache'
import EntryCard from '@/components/EntryCard.vue'
import ReadingSegmentRow from '@/components/reading/ReadingSegmentRow.vue'
import ReadingSegmentDesktopRow from '@/components/reading/ReadingSegmentDesktopRow.vue'
import ReadingIntensiveSegmentRow from '@/components/reading/ReadingIntensiveSegmentRow.vue'
import IntensiveReadingStatsBar from '@/components/intensive/IntensiveReadingStatsBar.vue'
import IntensiveCoreVocabPanel from '@/components/intensive/IntensiveCoreVocabPanel.vue'
import IntensiveCoreVocabMobile from '@/components/intensive/IntensiveCoreVocabMobile.vue'
import IntensiveModeToggle from '@/components/intensive/IntensiveModeToggle.vue'
import SettingsButton from '@/components/SettingsButton.vue'
import ReadingSettingsPanel from '@/components/reading/ReadingSettingsPanel.vue'
import ReadingWordTooltipHost from '@/components/reading/ReadingWordTooltipHost.vue'
import ReadingArticleVocabSidebar from '@/components/reading/ReadingArticleVocabSidebar.vue'
import { useReadingProgress } from '@/composables/useReadingProgress'
import ReadingTtsBar from '@/components/reading/ReadingTtsBar.vue'
import { useReadingTts, READING_TTS_KEY } from '@/composables/useReadingTts'
import { useReadingSettings } from '@/composables/useReadingSettings'
import { useIntensiveReadingMode } from '@/composables/useIntensiveReadingMode'
import { useCoreVocabulary, type CoreVocabSource } from '@/composables/useCoreVocabulary'
import { ARTICLE_VOCABULARY_KEY, useArticleVocabulary } from '@/composables/useArticleVocabulary'
import { useAuthStore } from '@/stores/auth'
import type { EntryDetail } from '@/types'
import { resolveReadingContext } from '@/utils/readingContext'

const route = useRoute()
const router = useRouter()
const auth = useAuthStore()

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
const activeSegment = ref<ArticleSegment | null>(null)

const {
  layoutMode,
  readingPageClass,
} = useReadingSettings()

const { intensiveMode, intensivePageClass } = useIntensiveReadingMode()

const coreVocabSources = computed<CoreVocabSource[]>(() =>
  (article.value?.segments ?? []).map((segment) => ({
    id: segment.id,
    englishHtml: segment.english_html || segment.english,
    context: segment.english,
    meta: { article_id: articleId.value, segment_id: segment.id },
  })),
)
const coreVocab = useCoreVocabulary(coreVocabSources)
const { items: coreVocabItems, loading: coreVocabLoading, count: coreVocabCount } = coreVocab

const showSettings = ref(false)
const segmentRefs = ref<(HTMLElement | null)[]>([])

const useDualColumnLayout = computed(() => layoutMode.value === 'dual' && !intensiveMode.value)

const articleVocabEnabled = computed(() => auth.isLoggedIn)
const articleVocab = useArticleVocabulary(articleId, { enabled: articleVocabEnabled })
provide(ARTICLE_VOCABULARY_KEY, articleVocab)

function setSegmentRef(el: HTMLElement | null, index: number) {
  segmentRefs.value[index] = el
}

async function loadArticle() {
  loading.value = true
  error.value = ''
  limitError.value = ''
  article.value = null
  try {
    const data = await getArticleDetail(articleId.value)
    article.value = data
    const startIndex = data.progress?.last_segment_index ?? 0
    currentIndex.value = startIndex
    await nextTick()
    scrollToSegment(startIndex, 'auto')
    await articleVocab.reload()
    startReporting()
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

function scrollToSegment(index: number, behavior: ScrollBehavior = 'smooth') {
  if (useDualColumnLayout.value && window.matchMedia('(min-width: 1024px)').matches) {
    const cells = document.querySelectorAll(`[data-reading-segment="${index}"]`)
    cells[0]?.scrollIntoView({ behavior, block: 'center' })
    return
  }
  const el = segmentRefs.value[index]
  el?.scrollIntoView({ behavior, block: 'center' })
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

function resolveClickedWordSpan(target: HTMLElement, root: HTMLElement): HTMLElement | null {
  let el: HTMLElement | null = target.closest('span')
  while (el && el !== root) {
    const text = el.textContent?.trim()
    if (text && !el.classList.contains('subtitle-english-word-progress')) return el
    el = el.parentElement?.closest('span') ?? null
  }
  return null
}

async function onWordClick(e: MouseEvent, segment: ArticleSegment) {
  const root = (e.target as HTMLElement).closest('.subtitle-english') as HTMLElement | null
  const plainRoot = !root ? (e.target as HTMLElement).closest('p.subtitle-english') : null
  const container = root || plainRoot
  if (!container) return

  let word = ''
  let type: 1 | 2 = 1
  const target = root ? resolveClickedWordSpan(e.target as HTMLElement, root) : null

  if (target) {
    word = target.textContent?.trim().replace(/\s+/g, ' ') ?? ''
    const isPhrase = Boolean(target.getAttribute('pid')) || target.classList.contains('phrase-token')
    type = isPhrase ? 2 : 1
  } else if (plainRoot) {
    const selection = window.getSelection()?.toString().trim()
    word = selection || ''
    type = word.includes(' ') ? 2 : 1
  }
  if (!word) return

  activeSegment.value = segment
  showEntry.value = true
  entryLoading.value = true
  entryError.value = ''
  selectedEntry.value = null

  try {
    const detail = await fetchWordLookup(word, type, resolveReadingContext(e.target as HTMLElement), {
      article_id: articleId.value,
      segment_id: segment.id,
    })
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

async function toggleVocabulary(entry: EntryDetail) {
  if (!auth.isLoggedIn) return
  try {
    const saved = await articleVocab.toggle(entry, {
      segmentId: activeSegment.value?.id,
      tokenType: entry.category === '短语' ? 2 : 1,
    })
    selectedEntry.value = { ...entry, favorite: saved }
  } catch {
    entryError.value = '生词本操作失败'
  }
}

function goBack() {
  router.push('/english/reading')
}

onMounted(loadArticle)

onUnmounted(() => {
  stopReporting()
  readingTts.stop()
  document.body.style.overflow = ''
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
      <button type="button" class="text-sm text-neutral-500 hover:text-black dark:hover:text-white shrink-0" @click="goBack">← 返回</button>
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
      <IntensiveModeToggle />
      <SettingsButton class="shrink-0" @click="showSettings = true" />
    </header>

    <div v-if="loading" class="flex-1 flex items-center justify-center text-neutral-500">加载中...</div>
    <div v-else-if="limitError" class="flex-1 flex flex-col items-center justify-center gap-3 px-6 text-center">
      <p class="text-amber-800 dark:text-amber-200">{{ limitError }}</p>
      <button type="button" class="text-sm underline" @click="goBack">返回列表</button>
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
          class="flex-1 min-h-0 overflow-y-auto overscroll-contain reading-scroll-hide"
        >
          <div class="page-container py-4 max-w-5xl lg:max-w-none">
            <div v-if="useDualColumnLayout" class="hidden lg:block space-y-3">
              <ReadingSegmentDesktopRow
                v-for="segment in article.segments"
                :key="segment.id"
                :segment="segment"
                :article-id="articleId"
                :active="segment.index === currentIndex"
                @activate="onActivateSegment(segment.index)"
                @click="onWordClick($event, segment)"
              />
            </div>

            <div class="space-y-3" :class="useDualColumnLayout ? 'lg:hidden' : ''">
              <div
                v-for="segment in article.segments"
                :key="segment.id"
                :ref="(el) => setSegmentRef(el as HTMLElement | null, segment.index)"
              >
                <ReadingSegmentRow
                  :segment="segment"
                  :article-id="articleId"
                  :active="segment.index === currentIndex"
                  @activate="onActivateSegment(segment.index)"
                  @click="onWordClick($event, segment)"
                />
              </div>
            </div>
          </div>
        </ReadingWordTooltipHost>

        <div
          v-else
          class="flex-1 min-h-0 overflow-y-auto overscroll-contain reading-scroll-hide"
        >
          <div class="page-container py-4 max-w-3xl">
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
                  @activate="onActivateSegment(segment.index)"
                  @click="onWordClick($event, segment)"
                />
              </div>
            </div>
          </div>
        </div>

        <ReadingArticleVocabSidebar v-if="auth.isLoggedIn && !intensiveMode" />
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
    />

    <EntryCard
      v-if="showEntry"
      :entry="selectedEntry"
      :loading="entryLoading"
      :error="entryError"
      :can-save-vocabulary="auth.isLoggedIn"
      @close="showEntry = false"
      @toggle-vocabulary="toggleVocabulary"
    />

    <ReadingSettingsPanel v-if="showSettings" @close="showSettings = false" />
  </div>
</template>

<style scoped>
:deep(.subtitle-english span.highlight) {
  cursor: pointer;
}
</style>
