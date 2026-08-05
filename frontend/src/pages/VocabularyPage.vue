<script setup lang="ts">
import { computed, nextTick, onMounted, onUnmounted, ref } from 'vue'
import { storeToRefs } from 'pinia'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import type { VocabularyItem } from '@/api/learning'
import { aiVocabReview, type VocabReviewCard } from '@/api/aiCoach'
import { useVocabularyStore } from '@/stores/vocabulary'
import { playWordPronunciation, stopSpeaking, warmSpeechVoices } from '@/utils/speakWord'

interface VocabSourceGroup {
  key: string
  sourceType: 'video' | 'article' | 'unknown'
  title: string
  sourceRef: string
  items: VocabularyItem[]
  latestAt: number
}

const route = useRoute()
const router = useRouter()
const vocabStore = useVocabularyStore()
const { items, loading, error, refreshing } = storeToRefs(vocabStore)

const reviewLoading = ref(false)
const reviewError = ref('')
const reviewCards = ref<VocabReviewCard[]>([])
const reviewIndex = ref(0)
const showAnswer = ref(false)
const hasCachedReview = ref(false)
const fromCacheHint = ref('')
const highlightReview = ref(false)
const reviewBtnRef = ref<HTMLElement | null>(null)
/** 当前正在朗读的词（用于按钮高亮） */
const speakingKey = ref('')
let speakingClearTimer: ReturnType<typeof setTimeout> | null = null

const primaryReviewLabel = computed(() => {
  if (reviewLoading.value) return '处理中...'
  if (reviewCards.value.length) return '继续复习'
  if (hasCachedReview.value) return '继续复习'
  return '开始 AI 复习'
})

function parseCreatedAt(value: string) {
  const t = Date.parse(value.replace(' ', 'T') + 'Z')
  if (Number.isFinite(t)) return t
  const fallback = Date.parse(value)
  return Number.isFinite(fallback) ? fallback : 0
}

function sourceKind(item: VocabularyItem): 'video' | 'article' | 'unknown' {
  if ((item.source_type || '').toLowerCase() === 'article') return 'article'
  if ((item.source_video_id || '').trim()) return 'video'
  return 'unknown'
}

const groupedItems = computed<VocabSourceGroup[]>(() => {
  const map = new Map<string, VocabSourceGroup>()

  for (const item of items.value) {
    const kind = sourceKind(item)
    const ref = (item.source_video_id || '').trim()
    const key = kind === 'unknown' || !ref ? 'unknown' : `${kind}:${ref}`
    let group = map.get(key)
    if (!group) {
      group = {
        key,
        sourceType: kind === 'unknown' || !ref ? 'unknown' : kind,
        title: (item.source_episode_title || '').trim() || (ref ? ref : '未标注来源'),
        sourceRef: ref,
        items: [],
        latestAt: 0,
      }
      map.set(key, group)
    } else if (!group.title || group.title === group.sourceRef) {
      const title = (item.source_episode_title || '').trim()
      if (title) group.title = title
    }
    group.items.push(item)
    const at = parseCreatedAt(item.created_at)
    if (at > group.latestAt) group.latestAt = at
  }

  const groups = [...map.values()]
  for (const g of groups) {
    g.items.sort((a, b) => parseCreatedAt(b.created_at) - parseCreatedAt(a.created_at))
  }
  groups.sort((a, b) => {
    if (a.sourceType === 'unknown' && b.sourceType !== 'unknown') return 1
    if (b.sourceType === 'unknown' && a.sourceType !== 'unknown') return -1
    return b.latestAt - a.latestAt
  })
  return groups
})

async function peekCache() {
  if (!items.value.length) {
    hasCachedReview.value = false
    return
  }
  try {
    const data = await aiVocabReview(false)
    hasCachedReview.value = Boolean(data.cache_hit && data.cards?.length)
    if (hasCachedReview.value) {
      fromCacheHint.value = '今日已有复习卡，继续复习不消耗额度'
    }
  } catch {
    hasCachedReview.value = false
  }
}

async function remove(item: VocabularyItem) {
  await vocabStore.remove(item.entry_id)
  await peekCache()
}

async function startReview(force = false) {
  if (!force && reviewCards.value.length) {
    reviewIndex.value = 0
    showAnswer.value = false
    return
  }
  reviewLoading.value = true
  reviewError.value = ''
  showAnswer.value = false
  reviewIndex.value = 0
  fromCacheHint.value = ''
  try {
    const data = await aiVocabReview(true, force)
    reviewCards.value = data.cards || []
    hasCachedReview.value = Boolean(reviewCards.value.length)
    if (data.from_cache || data.cache_hit) {
      fromCacheHint.value = data.message || '已复用今日复习卡（未消耗 AI 额度）'
    } else if (data.message) {
      fromCacheHint.value = data.message
    }
    if (!reviewCards.value.length) {
      reviewError.value = data.message || '暂无复习卡'
      hasCachedReview.value = false
    }
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    reviewError.value = typeof msg === 'string' ? msg : '生成复习卡失败'
    reviewCards.value = []
  } finally {
    reviewLoading.value = false
  }
}

function nextCard() {
  showAnswer.value = false
  if (reviewIndex.value + 1 < reviewCards.value.length) reviewIndex.value += 1
  else {
    reviewCards.value = []
    reviewIndex.value = 0
  }
}

function speakWord(word: string | undefined | null) {
  const text = (word || '').trim()
  if (!text) return
  if (speakingClearTimer != null) clearTimeout(speakingClearTimer)
  speakingKey.value = text.toLowerCase()
  const ok = playWordPronunciation(text)
  if (!ok) {
    speakingKey.value = ''
    return
  }
  // 单词朗读一般很短，用定时清状态作视觉反馈
  speakingClearTimer = setTimeout(() => {
    speakingKey.value = ''
    speakingClearTimer = null
  }, 1800)
}

function isSpeaking(word: string | undefined | null) {
  return Boolean(word && speakingKey.value === word.trim().toLowerCase())
}

function revealReviewAnswer() {
  showAnswer.value = true
  speakWord(reviewCards.value[reviewIndex.value]?.answer)
}

function sourcePath(item: VocabularyItem) {
  const ref = (item.source_video_id || '').trim()
  if (!ref) return ''
  const query: Record<string, string> = { from: 'vocab' }
  if (item.word) query.word = item.word
  if ((item.source_type || '').toLowerCase() === 'article') {
    if (item.source_segment_id) query.segment = String(item.source_segment_id)
    const qs = new URLSearchParams(query).toString()
    return `/english/reading/${ref}?${qs}`
  }
  if (item.source_subtitle_id) query.subtitle = String(item.source_subtitle_id)
  const qs = new URLSearchParams(query).toString()
  return `/english/episode/${ref}?${qs}`
}

/** 组头「回看」：优先带定位信息的词，否则打开来源页 */
function groupSourcePath(group: VocabSourceGroup) {
  if (group.sourceType === 'unknown' || !group.sourceRef) return ''
  const withAnchor = group.items.find((item) => sourcePath(item))
  if (withAnchor) return sourcePath(withAnchor)
  if (group.sourceType === 'article') return `/english/reading/${group.sourceRef}?from=vocab`
  return `/english/episode/${group.sourceRef}?from=vocab`
}

function sourceTypeLabel(type: VocabSourceGroup['sourceType']) {
  if (type === 'article') return '文章'
  if (type === 'video') return '视频'
  return '其他'
}

async function focusReviewEntry() {
  highlightReview.value = true
  await nextTick()
  reviewBtnRef.value?.scrollIntoView({ behavior: 'smooth', block: 'center' })
  window.setTimeout(() => {
    highlightReview.value = false
  }, 2200)
  if (route.query.review) {
    const nextQuery = { ...route.query }
    delete nextQuery.review
    void router.replace({ path: route.path, query: nextQuery })
  }
}

onMounted(async () => {
  warmSpeechVoices()
  await vocabStore.load()
  await peekCache()
  if (route.query.review === '1' && items.value.length) {
    await focusReviewEntry()
  }
})

onUnmounted(() => {
  if (speakingClearTimer != null) clearTimeout(speakingClearTimer)
  stopSpeaking()
})
</script>

<template>
  <div class="page-container py-6 max-w-4xl">
    <div class="flex items-center justify-between gap-3 text-sm mb-6">
      <div class="flex items-center gap-3">
        <RouterLink to="/english/learning" class="text-neutral-500 hover:text-neutral-900 dark:text-neutral-400 dark:hover:text-white">← 学习统计</RouterLink>
        <span class="text-neutral-300 dark:text-neutral-600">|</span>
        <span class="font-medium">生词本</span>
        <span v-if="items.length" class="text-[11px] text-neutral-400">{{ items.length }} 词</span>
        <span v-if="refreshing" class="text-[11px] text-neutral-400">更新中…</span>
      </div>
      <div v-if="items.length" class="flex items-center gap-2 shrink-0">
        <button
          ref="reviewBtnRef"
          type="button"
          class="px-3 py-1.5 rounded-lg text-xs font-medium bg-amber-600 text-white hover:bg-amber-700 disabled:opacity-60 transition ring-offset-2 dark:ring-offset-neutral-950"
          :class="highlightReview ? 'ring-2 ring-amber-400' : ''"
          :disabled="reviewLoading"
          @click="startReview(false)"
        >
          {{ primaryReviewLabel }}
        </button>
        <button
          v-if="hasCachedReview || reviewCards.length"
          type="button"
          class="px-3 py-1.5 rounded-lg text-xs font-medium border border-black/10 dark:border-white/15 text-neutral-600 dark:text-neutral-300 hover:bg-black/5 dark:hover:bg-white/5 disabled:opacity-60"
          :disabled="reviewLoading"
          title="重新调用 AI 生成，会消耗额度"
          @click="startReview(true)"
        >
          重新生成
        </button>
      </div>
    </div>

    <p v-if="error" class="text-sm text-red-600 dark:text-red-400 mb-4">{{ error }}</p>
    <p v-if="fromCacheHint && !reviewError" class="text-xs text-neutral-500 dark:text-neutral-400 mb-3">
      {{ fromCacheHint }}
    </p>
    <p v-if="reviewError" class="text-sm text-red-600 dark:text-red-400 mb-4">{{ reviewError }}</p>

    <div
      v-if="reviewCards.length"
      class="mb-6 rounded-xl border border-amber-200 dark:border-amber-900 bg-amber-50/50 dark:bg-amber-950/20 p-4 space-y-3"
    >
      <p class="text-xs text-neutral-500">
        复习 {{ reviewIndex + 1 }} / {{ reviewCards.length }}
      </p>
      <p class="text-sm font-medium">{{ reviewCards[reviewIndex]?.prompt }}</p>
      <div v-if="showAnswer" class="flex items-center gap-2 min-w-0">
        <p class="text-lg font-semibold text-amber-800 dark:text-amber-300 break-words">
          {{ reviewCards[reviewIndex]?.answer }}
        </p>
        <button
          type="button"
          class="shrink-0 inline-flex items-center justify-center w-9 h-9 rounded-full transition"
          :class="
            isSpeaking(reviewCards[reviewIndex]?.answer)
              ? 'bg-amber-500 text-white shadow-sm'
              : 'bg-amber-100 text-amber-800 hover:bg-amber-200 dark:bg-amber-900/50 dark:text-amber-200 dark:hover:bg-amber-900/70'
          "
          aria-label="朗读答案"
          @click="speakWord(reviewCards[reviewIndex]?.answer)"
        >
          <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
            <path d="M3 9v6h4l5 5V4L7 9H3zm13.5 3c0-1.77-1.02-3.29-2.5-4.03v8.05c1.48-.73 2.5-2.25 2.5-4.02z" />
          </svg>
        </button>
      </div>
      <p v-if="showAnswer && reviewCards[reviewIndex]?.example" class="text-sm text-neutral-600 dark:text-neutral-300">
        {{ reviewCards[reviewIndex]?.example }}
        <span v-if="reviewCards[reviewIndex]?.example_zh" class="block text-xs text-neutral-400 mt-1">
          {{ reviewCards[reviewIndex]?.example_zh }}
        </span>
      </p>
      <div class="flex gap-2">
        <button
          v-if="!showAnswer"
          type="button"
          class="px-3 py-1.5 rounded-lg text-sm bg-neutral-900 text-white dark:bg-neutral-100 dark:text-neutral-900"
          @click="revealReviewAnswer"
        >
          看答案
        </button>
        <button
          v-else
          type="button"
          class="px-3 py-1.5 rounded-lg text-sm border border-black/10 dark:border-white/15"
          @click="nextCard"
        >
          {{ reviewIndex + 1 < reviewCards.length ? '下一张' : '完成' }}
        </button>
      </div>
    </div>

    <div v-if="loading && !items.length" class="text-neutral-500 dark:text-neutral-400 text-sm">加载中...</div>
    <div v-else-if="!items.length" class="rounded-xl border border-black/5 dark:border-white/10 bg-white dark:bg-neutral-900 p-12 text-center text-neutral-500 dark:text-neutral-400 text-sm">
      暂无生词，在学习页查词后可加入生词本
    </div>

    <div v-else class="space-y-8">
      <section v-for="group in groupedItems" :key="group.key" class="space-y-3">
        <div class="flex items-center justify-between gap-3 min-w-0">
          <div class="min-w-0 flex items-baseline gap-2">
            <span
              class="shrink-0 text-[10px] font-medium px-1.5 py-0.5 rounded"
              :class="
                group.sourceType === 'article'
                  ? 'bg-sky-100 text-sky-800 dark:bg-sky-950/50 dark:text-sky-300'
                  : group.sourceType === 'video'
                    ? 'bg-amber-100 text-amber-800 dark:bg-amber-950/40 dark:text-amber-300'
                    : 'bg-neutral-100 text-neutral-600 dark:bg-neutral-800 dark:text-neutral-400'
              "
            >
              {{ sourceTypeLabel(group.sourceType) }}
            </span>
            <h2 class="text-sm font-medium truncate text-neutral-800 dark:text-neutral-100">
              {{ group.title }}
            </h2>
            <span class="shrink-0 text-[11px] text-neutral-400">{{ group.items.length }} 词</span>
          </div>
          <RouterLink
            v-if="groupSourcePath(group)"
            :to="groupSourcePath(group)"
            class="shrink-0 text-xs text-amber-700 dark:text-amber-400 hover:underline"
          >
            {{ group.sourceType === 'article' ? '回看本文' : '回看本集' }}
          </RouterLink>
        </div>

        <ul class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-2.5">
          <li
            v-for="item in group.items"
            :key="item.id"
            class="rounded-xl border border-black/5 dark:border-white/10 bg-white dark:bg-neutral-900 p-3 flex flex-col min-h-[7.25rem]"
          >
            <div class="flex items-start gap-2 min-w-0">
              <button
                type="button"
                class="min-w-0 flex-1 text-left font-medium text-[15px] leading-snug text-neutral-900 dark:text-neutral-100 break-words hover:text-amber-800 dark:hover:text-amber-300 transition-colors"
                :aria-label="`朗读 ${item.word}`"
                @click="speakWord(item.word)"
              >
                {{ item.word }}
              </button>
              <button
                type="button"
                class="shrink-0 inline-flex items-center justify-center w-8 h-8 rounded-full transition"
                :class="
                  isSpeaking(item.word)
                    ? 'bg-amber-500 text-white shadow-sm scale-105'
                    : 'bg-amber-50 text-amber-700 ring-1 ring-amber-200/80 hover:bg-amber-100 dark:bg-amber-950/40 dark:text-amber-300 dark:ring-amber-800/60 dark:hover:bg-amber-900/50'
                "
                aria-label="朗读"
                @click.stop="speakWord(item.word)"
              >
                <svg width="15" height="15" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                  <path d="M3 9v6h4l5 5V4L7 9H3zm13.5 3c0-1.77-1.02-3.29-2.5-4.03v8.05c1.48-.73 2.5-2.25 2.5-4.02z" />
                </svg>
              </button>
            </div>
            <p v-if="item.ipa" class="mt-0.5 text-[11px] text-neutral-400 font-serif truncate">
              {{ item.ipa }}
            </p>
            <p
              v-if="item.definition_cn"
              class="mt-1.5 text-xs text-neutral-500 dark:text-neutral-400 line-clamp-2 leading-relaxed"
            >
              {{ item.definition_cn }}
            </p>
            <div class="mt-auto pt-2.5 flex items-center gap-2.5">
              <RouterLink
                v-if="sourcePath(item)"
                :to="sourcePath(item)"
                class="text-[11px] text-amber-700 dark:text-amber-400 hover:underline"
              >
                回看
              </RouterLink>
              <button
                type="button"
                class="text-[11px] text-red-600 dark:text-red-400 hover:underline"
                @click="remove(item)"
              >
                移除
              </button>
            </div>
          </li>
        </ul>
      </section>
    </div>
  </div>
</template>
