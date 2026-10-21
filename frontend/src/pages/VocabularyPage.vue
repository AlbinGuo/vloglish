<script setup lang="ts">
import { computed, nextTick, onMounted, onUnmounted, ref } from 'vue'
import { storeToRefs } from 'pinia'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import type { VocabularyItem } from '@/api/learning'
import { aiVocabReview, type VocabReviewCard } from '@/api/aiCoach'
import AiShadowingSheet from '@/components/ai/AiShadowingSheet.vue'
import { useVocabularyStore } from '@/stores/vocabulary'
import { playWordPronunciation, stopSpeaking, warmSpeechVoices } from '@/utils/speakWord'
import AppIcon from '@/components/AppIcon.vue'

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

const wordScoreOpen = ref(false)
const wordScoreText = ref('')
const wordScoreIpa = ref('')
const wordScoreChinese = ref('')

function startWordScore(word: string, meta?: { ipa?: string; chinese?: string }) {
  const w = (word || '').trim()
  if (!w) return
  wordScoreText.value = w
  let ipa = (meta?.ipa || '').trim()
  let chinese = (meta?.chinese || '').trim()
  if (!ipa || !chinese) {
    const found = items.value.find((i) => i.word.trim().toLowerCase() === w.toLowerCase())
    if (found) {
      if (!ipa) ipa = (found.ipa || '').trim()
      if (!chinese) chinese = (found.definition_cn || '').trim()
    }
  }
  wordScoreIpa.value = ipa
  wordScoreChinese.value = chinese
  wordScoreOpen.value = true
}

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
    <!-- 页头 -->
    <div class="mb-6 space-y-4">
      <div class="flex items-center gap-3 text-sm min-w-0">
        <RouterLink
          to="/english/learning"
          class="text-ink-faint hover:text-ink shrink-0"
        >
          ← 学习统计
        </RouterLink>
        <span class="text-neutral-300 dark:text-neutral-600">·</span>
        <span class="font-medium tracking-tight">生词本</span>
        <span v-if="items.length" class="text-[11px] tabular-nums text-neutral-400">{{ items.length }} 词</span>
        <span v-if="refreshing" class="text-[11px] text-neutral-400">更新中…</span>
      </div>

      <div v-if="items.length" class="hidden rounded-2xl border border-line-soft bg-card p-3 shadow-sm sm:p-4">
        <div class="grid grid-cols-1 gap-2.5 sm:grid-cols-3">
          <RouterLink
            to="/english/word-practice?source=vocab&limit=15"
            class="inline-flex items-center justify-center gap-2 rounded-xl bg-brand px-4 py-3 text-sm font-semibold text-ink-inverse shadow-sm transition hover:opacity-90 active:scale-[0.98]"
            title="优先抽取错词与未练习的单词"
          >
            <AppIcon name="align-left" :size="16" />
            拼写练习
          </RouterLink>
          <RouterLink
            to="/english/word-practice?source=vocab_wrong&limit=15"
            class="inline-flex items-center justify-center gap-2 rounded-xl border border-warning bg-warning-soft px-4 py-3 text-sm font-medium text-warning transition hover:opacity-90 active:scale-[0.98]"
          >
            <AppIcon name="repeat" :size="16" />
            错词复习
          </RouterLink>
          <button
            ref="reviewBtnRef"
            type="button"
            class="inline-flex items-center justify-center gap-2 rounded-xl bg-warning px-4 py-3 text-sm font-semibold text-ink-inverse transition hover:opacity-90 active:scale-[0.98] disabled:opacity-60"
            :class="highlightReview ? 'ring-2 ring-brand ring-offset-2 ring-offset-card' : ''"
            :disabled="reviewLoading"
            @click="startReview(false)"
          >
            <AppIcon name="sparkles" :size="16" />
            {{ primaryReviewLabel }}
          </button>
        </div>
        <div class="mt-2.5 flex items-center justify-between gap-2">
          <p class="text-[11px] text-ink-faint">拼写练习优先错词与未练习，已掌握会后排</p>
          <button
            v-if="hasCachedReview || reviewCards.length"
            type="button"
            class="shrink-0 rounded-lg border border-line-soft px-3 py-1.5 text-[12px] font-medium text-ink-soft transition hover:bg-sunken disabled:opacity-60"
            :disabled="reviewLoading"
            title="重新调用 AI 生成，会消耗额度"
            @click="startReview(true)"
          >
            重新生成
          </button>
        </div>
      </div>
    </div>

    <p v-if="error" class="text-sm text-red-600 dark:text-red-400 mb-4">{{ error }}</p>
    <p v-if="fromCacheHint && !reviewError" class="text-xs text-neutral-500 dark:text-neutral-400 mb-3">
      {{ fromCacheHint }}
    </p>
    <p v-if="reviewError" class="text-sm text-red-600 dark:text-red-400 mb-4">{{ reviewError }}</p>

    <div
      v-if="reviewCards.length"
      class="mb-6 rounded-2xl border border-amber-200/80 dark:border-amber-900/60 bg-amber-50/60 dark:bg-amber-950/25 p-4 space-y-3"
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
          <AppIcon name="volume-up" :size="18" />
        </button>
        <button
          type="button"
          class="shrink-0 px-2.5 h-9 rounded-full text-xs font-medium border border-sky-200 text-sky-800 bg-sky-50 hover:bg-sky-100 dark:border-sky-800 dark:text-sky-200 dark:bg-sky-950/40"
          @click="startWordScore(reviewCards[reviewIndex]?.answer || '')"
        >
          打分
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
    <div
      v-else-if="!items.length"
      class="rounded-2xl border border-dashed border-black/10 dark:border-white/12 bg-white/60 dark:bg-neutral-900/50 p-12 text-center text-neutral-500 dark:text-neutral-400 text-sm"
    >
      暂无生词，在学习页查词后可加入生词本
    </div>

    <div v-else class="space-y-9">
      <section v-for="group in groupedItems" :key="group.key" class="space-y-3">
        <div class="flex items-center justify-between gap-3 min-w-0">
          <div class="min-w-0 flex items-center gap-2">
            <span
              class="shrink-0 w-1 h-4 rounded-full"
              :class="
                group.sourceType === 'article'
                  ? 'bg-sky-400'
                  : group.sourceType === 'video'
                    ? 'bg-amber-400'
                    : 'bg-neutral-300 dark:bg-neutral-600'
              "
              aria-hidden="true"
            />
            <span
              class="shrink-0 text-[10px] font-medium px-1.5 py-0.5 rounded"
              :class="
                group.sourceType === 'article'
                  ? 'bg-sky-100 text-sky-800 dark:bg-sky-950/50 dark:text-sky-300'
                  : group.sourceType === 'video'
                    ? 'bg-amber-100 text-warning dark:bg-amber-950/40'
                    : 'bg-sunken text-ink-soft'
              "
            >
              {{ sourceTypeLabel(group.sourceType) }}
            </span>
            <h2 class="text-sm font-medium truncate text-neutral-800 dark:text-neutral-100">
              {{ group.title }}
            </h2>
            <span class="shrink-0 text-[11px] text-neutral-400 tabular-nums">{{ group.items.length }}</span>
          </div>
          <RouterLink
            v-if="groupSourcePath(group)"
            :to="groupSourcePath(group)"
            class="shrink-0 text-xs text-amber-700 dark:text-amber-400 hover:underline"
          >
            {{ group.sourceType === 'article' ? '回看本文' : '回看本集' }}
          </RouterLink>
        </div>

        <ul class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-3">
          <li
            v-for="item in group.items"
            :key="item.id"
            class="vocab-card group relative flex flex-col min-h-[8.5rem] rounded-2xl border border-black/[0.05] dark:border-white/[0.07] bg-white/80 dark:bg-neutral-900/70 p-3.5 transition-colors hover:border-teal-500/25 dark:hover:border-teal-400/25 hover:bg-white dark:hover:bg-neutral-900"
          >
            <div class="flex items-start gap-2 min-w-0">
              <button
                type="button"
                class="min-w-0 flex-1 text-left font-semibold text-[15px] leading-snug tracking-tight text-neutral-900 dark:text-neutral-50 break-words hover:text-teal-700 dark:hover:text-teal-300 transition-colors"
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
                    ? 'bg-teal-500 text-white shadow-sm scale-105'
                    : 'bg-brand-soft text-brand ring-1 ring-teal-500/15 hover:bg-teal-500/15 dark:ring-teal-400/20'
                "
                aria-label="朗读"
                @click.stop="speakWord(item.word)"
              >
                <AppIcon name="volume-up" :size="14" />
              </button>
            </div>
            <p v-if="item.ipa" class="mt-1 text-[11px] text-neutral-400 dark:text-neutral-500 truncate tracking-wide">
              /{{ item.ipa.replace(/^\/|\/$/g, '') }}/
            </p>
            <p
              v-if="item.definition_cn"
              class="mt-2 text-[13px] text-neutral-600 dark:text-neutral-300 line-clamp-2 leading-relaxed"
            >
              {{ item.definition_cn }}
            </p>
            <div
              class="mt-auto pt-3 flex items-center gap-1 border-t border-black/[0.04] dark:border-white/[0.06] opacity-80 group-hover:opacity-100 transition-opacity"
            >
              <button
                type="button"
                class="inline-flex items-center gap-1 h-8 px-2 rounded-lg text-[11px] font-medium text-sky-700 bg-sky-50/80 hover:bg-sky-100 dark:text-sky-300 dark:bg-sky-950/40 dark:hover:bg-sky-900/50 transition"
                @click="startWordScore(item.word, { ipa: item.ipa, chinese: item.definition_cn })"
              >
                <AppIcon name="mic" :size="13" />
                打分
              </button>
              <RouterLink
                v-if="sourcePath(item)"
                :to="sourcePath(item)"
                class="inline-flex items-center gap-1 h-8 px-2 rounded-lg text-[11px] font-medium text-amber-800 bg-amber-50/80 hover:bg-amber-100 dark:text-amber-300 dark:bg-amber-950/40 dark:hover:bg-amber-900/50 transition"
              >
                <AppIcon name="external-link" :size="13" />
                回看
              </RouterLink>
              <button
                type="button"
                class="ml-auto inline-flex items-center justify-center w-8 h-8 rounded-lg text-neutral-400 hover:text-rose-600 hover:bg-rose-50 dark:hover:text-rose-400 dark:hover:bg-rose-950/40 transition"
                title="从生词本移除"
                aria-label="从生词本移除"
                @click="remove(item)"
              >
                <AppIcon name="trash-2" :size="14" />
              </button>
            </div>
          </li>
        </ul>
      </section>
    </div>

    <AiShadowingSheet
      :open="wordScoreOpen"
      mode="word"
      :ref-text="wordScoreText"
      :ipa="wordScoreIpa"
      :chinese="wordScoreChinese"
      title="单词打分"
      source-type="vocab"
      :has-next="false"
      @close="wordScoreOpen = false"
      @next="wordScoreOpen = false"
    />
  </div>
</template>
