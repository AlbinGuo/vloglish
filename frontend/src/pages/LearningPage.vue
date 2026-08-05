<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref, watch } from 'vue'
import { RouterLink } from 'vue-router'
import LearningHeatmapChart from '@/components/charts/LearningHeatmapChart.vue'
import LearningStatCard from '@/components/learning/LearningStatCard.vue'
import { useIsPhone } from '@/composables/useBreakpoint'
import {
  getLearningCalendar,
  getLearningSummary,
  getLookupHistory,
  saveVocabulary,
  type WordLookupRecord,
} from '@/api/learning'
import {
  deletePracticeRecord,
  listPracticeRecords,
  type PracticeMode,
  type PracticeRecord,
} from '@/api/practiceRecords'
import { useVocabularyStore } from '@/stores/vocabulary'

const isPhone = useIsPhone()

const loading = ref(true)
const summary = ref<Awaited<ReturnType<typeof getLearningSummary>> | null>(null)
const calendar = ref<{ date: string; watch_time_sec: number; sessions: number }[]>([])
const lookupHistory = ref<WordLookupRecord[]>([])
const savingIds = ref<Set<number>>(new Set())
const saveError = ref('')

const practiceLoading = ref(false)
const practiceError = ref('')
const practiceFilter = ref<'' | PracticeMode>('')
const practiceRecords = ref<PracticeRecord[]>([])
const practiceTotal = ref(0)
const deletingIds = ref<Set<number>>(new Set())
const playingId = ref<number | null>(null)
let practiceAudio: HTMLAudioElement | null = null

const LOOKUP_DISPLAY_LIMIT = 12

/** 未收藏优先，最多展示 N 条；若全已收藏则展示最近若干条已收藏 */
const displayLookups = computed(() => {
  const rows = [...lookupHistory.value]
  const unsaved = rows.filter((r) => !r.is_saved)
  if (unsaved.length) return unsaved.slice(0, LOOKUP_DISPLAY_LIMIT)
  return rows.slice(0, Math.min(5, LOOKUP_DISPLAY_LIMIT))
})

const unsavedCount = computed(() => lookupHistory.value.filter((r) => !r.is_saved).length)
const showingUnsavedOnly = computed(() => unsavedCount.value > 0)

function formatDuration(sec: number) {
  const h = Math.floor(sec / 3600)
  const m = Math.floor((sec % 3600) / 60)
  if (h > 0) return `${h} 小时 ${m} 分`
  return `${m} 分钟`
}

const PHONE_HIDDEN_STAT_LABELS = new Set(['连续天数', '本周学习', '查词次数', '生词本'])

const statCards = computed(() => {
  const s = summary.value
  if (!s) return []
  const cards = [
    {
      label: '累计学习',
      value: formatDuration(s.total_watch_time_sec),
      icon: 'clock' as const,
      tone: 'amber' as const,
    },
    {
      label: '已学完',
      value: `${s.completed_episodes} 期`,
      icon: 'check-circle' as const,
      tone: 'emerald' as const,
    },
    {
      label: '学习中',
      value: `${s.in_progress_episodes} 期`,
      icon: 'play-circle' as const,
      tone: 'blue' as const,
    },
    {
      label: '连续天数',
      value: `${s.streak_days} 天`,
      icon: 'fire' as const,
      tone: 'orange' as const,
    },
    {
      label: '今日学习',
      value: formatDuration(s.today_watch_time_sec),
      icon: 'sun' as const,
      tone: 'sky' as const,
    },
    {
      label: '本周学习',
      value: formatDuration(s.week_watch_time_sec),
      icon: 'calendar' as const,
      tone: 'violet' as const,
    },
    {
      label: '查词次数',
      value: String(s.lookup_count),
      icon: 'search' as const,
      tone: 'rose' as const,
    },
    {
      label: '生词本',
      value: `${s.vocabulary_count} 词`,
      icon: 'bookmark' as const,
      tone: 'amber' as const,
    },
  ]
  if (isPhone.value) {
    return cards.filter((card) => !PHONE_HIDDEN_STAT_LABELS.has(card.label))
  }
  return cards
})

function lookupSourcePath(item: WordLookupRecord) {
  const query: Record<string, string> = { from: 'learning' }
  if (item.word) query.word = item.word
  const articleRef = (item.article_ref || '').trim()
  if (articleRef) {
    if (item.segment_id) query.segment = String(item.segment_id)
    return `/english/reading/${articleRef}?${new URLSearchParams(query).toString()}`
  }
  const videoId = (item.video_id || '').trim()
  if (!videoId) return ''
  if (item.subtitle_id) query.subtitle = String(item.subtitle_id)
  return `/english/episode/${videoId}?${new URLSearchParams(query).toString()}`
}

const MODE_LABEL: Record<string, string> = {
  word: '单词',
  sentence: '句子',
  passage: '篇章',
}

function modeLabel(mode: string) {
  return MODE_LABEL[mode] || mode
}

function formatPracticeTime(iso: string | null) {
  if (!iso) return ''
  const d = new Date(iso.endsWith('Z') ? iso : `${iso}Z`)
  if (Number.isNaN(d.getTime())) return ''
  const mm = String(d.getMonth() + 1).padStart(2, '0')
  const dd = String(d.getDate()).padStart(2, '0')
  const hh = String(d.getHours()).padStart(2, '0')
  const mi = String(d.getMinutes()).padStart(2, '0')
  return `${mm}-${dd} ${hh}:${mi}`
}

function practiceSourcePath(item: PracticeRecord) {
  const query: Record<string, string> = { from: 'learning' }
  if (item.article_id) {
    if (item.segment_id) query.segment = String(item.segment_id)
    return `/english/reading/${item.article_id}?${new URLSearchParams(query).toString()}`
  }
  if (item.video_id) {
    if (item.subtitle_id) query.subtitle = String(item.subtitle_id)
    return `/english/episode/${item.video_id}?${new URLSearchParams(query).toString()}`
  }
  return ''
}

function stopPracticeAudio() {
  if (practiceAudio) {
    practiceAudio.pause()
    practiceAudio = null
  }
  playingId.value = null
}

function togglePracticeAudio(item: PracticeRecord) {
  if (!item.audio_url) return
  if (playingId.value === item.id) {
    stopPracticeAudio()
    return
  }
  stopPracticeAudio()
  const audio = new Audio(item.audio_url)
  practiceAudio = audio
  playingId.value = item.id
  audio.onended = () => {
    if (playingId.value === item.id) playingId.value = null
    practiceAudio = null
  }
  audio.onerror = () => {
    if (playingId.value === item.id) playingId.value = null
    practiceAudio = null
  }
  void audio.play().catch(() => {
    playingId.value = null
    practiceAudio = null
  })
}

async function loadPracticeRecords() {
  practiceLoading.value = true
  practiceError.value = ''
  try {
    const data = await listPracticeRecords({
      mode: practiceFilter.value || undefined,
      page: 1,
      page_size: 20,
    })
    practiceRecords.value = data.results
    practiceTotal.value = data.count
  } catch {
    practiceError.value = '练习记录加载失败'
    practiceRecords.value = []
    practiceTotal.value = 0
  } finally {
    practiceLoading.value = false
  }
}

async function removePractice(item: PracticeRecord) {
  if (deletingIds.value.has(item.id)) return
  const next = new Set(deletingIds.value)
  next.add(item.id)
  deletingIds.value = next
  try {
    await deletePracticeRecord(item.id)
    if (playingId.value === item.id) stopPracticeAudio()
    practiceRecords.value = practiceRecords.value.filter((r) => r.id !== item.id)
    practiceTotal.value = Math.max(0, practiceTotal.value - 1)
  } catch {
    practiceError.value = '删除失败，请重试'
  } finally {
    const done = new Set(deletingIds.value)
    done.delete(item.id)
    deletingIds.value = done
  }
}

watch(practiceFilter, () => {
  void loadPracticeRecords()
})

async function addToVocabulary(item: WordLookupRecord) {
  if (item.is_saved || savingIds.value.has(item.id)) return
  saveError.value = ''
  const next = new Set(savingIds.value)
  next.add(item.id)
  savingIds.value = next
  try {
    const articleRef = (item.article_ref || '').trim()
    await saveVocabulary({
      entry_id: item.entry_id,
      word: item.word,
      token_type: item.token_type || 1,
      video_id: articleRef ? undefined : item.video_id || undefined,
      subtitle_id: item.subtitle_id ?? undefined,
      article_ref: articleRef || undefined,
      segment_id: item.segment_id ?? undefined,
      source_type: articleRef ? 'article' : 'video',
    })
    lookupHistory.value = lookupHistory.value.map((row) =>
      row.id === item.id || row.entry_id === item.entry_id ? { ...row, is_saved: true } : row,
    )
    if (summary.value) {
      summary.value = {
        ...summary.value,
        vocabulary_count: summary.value.vocabulary_count + 1,
      }
    }
    useVocabularyStore().invalidate()
  } catch {
    saveError.value = '加入生词本失败，请重试'
  } finally {
    const done = new Set(savingIds.value)
    done.delete(item.id)
    savingIds.value = done
  }
}

onMounted(async () => {
  try {
    const [s, days, lookups] = await Promise.all([
      getLearningSummary(),
      getLearningCalendar(90),
      getLookupHistory(undefined, 1),
    ])
    summary.value = s
    calendar.value = days
    // 未收藏靠前
    lookupHistory.value = [...lookups.results].sort((a, b) => {
      if (a.is_saved === b.is_saved) return 0
      return a.is_saved ? 1 : -1
    })
    await loadPracticeRecords()
  } finally {
    loading.value = false
  }
})

onUnmounted(() => {
  stopPracticeAudio()
})
</script>

<template>
  <div class="page-container py-6 max-w-4xl space-y-6">
    <div class="flex items-center justify-between gap-3">
      <div class="flex items-center gap-3 text-sm">
        <RouterLink to="/english" class="text-neutral-500 hover:text-neutral-900 dark:text-neutral-400 dark:hover:text-white">← 返回目录</RouterLink>
        <span class="text-neutral-300 dark:text-neutral-600">|</span>
        <span class="font-medium">学习统计</span>
      </div>
      <RouterLink
        v-if="!isPhone"
        to="/english/vocabulary"
        class="text-sm text-amber-700 dark:text-amber-400 hover:underline"
      >
        生词本
      </RouterLink>
    </div>

    <div v-if="loading" class="text-neutral-500 text-sm">加载中...</div>

    <template v-else-if="summary">
      <div class="grid grid-cols-2 sm:grid-cols-4 gap-3">
        <LearningStatCard
          v-for="card in statCards"
          :key="card.label"
          :label="card.label"
          :value="card.value"
          :icon="card.icon"
          :tone="card.tone"
        />
      </div>

      <section class="rounded-xl border border-black/5 dark:border-white/10 bg-white dark:bg-neutral-900 p-5">
        <h2 class="font-medium mb-2">近 90 天学习热力</h2>
        <p class="text-xs text-neutral-400 mb-4">颜色越深表示当日学习时长越长，悬停可查看详情</p>
        <LearningHeatmapChart :days="calendar" :range-days="90" theme="amber" height="220px" />
      </section>

      <section class="rounded-xl border border-black/5 dark:border-white/10 bg-white dark:bg-neutral-900 p-5">
        <div class="flex items-start justify-between gap-3 mb-3">
          <div class="min-w-0">
            <h2 class="font-medium">练习记录</h2>
            <p class="text-xs text-neutral-400 mt-1">
              跟读 / 单词打分 / 篇章评测历史，可回听录音
              <span v-if="practiceTotal"> · 共 {{ practiceTotal }} 条</span>
            </p>
          </div>
          <div class="flex shrink-0 gap-1 text-xs">
            <button
              v-for="opt in [
                { value: '', label: '全部' },
                { value: 'word', label: '单词' },
                { value: 'sentence', label: '句子' },
                { value: 'passage', label: '篇章' },
              ]"
              :key="opt.value || 'all'"
              type="button"
              class="px-2 py-1 rounded-md transition-colors"
              :class="
                practiceFilter === opt.value
                  ? 'bg-amber-100 text-amber-900 dark:bg-amber-900/40 dark:text-amber-200'
                  : 'text-neutral-500 hover:bg-neutral-100 dark:hover:bg-neutral-800'
              "
              @click="practiceFilter = opt.value as '' | PracticeMode"
            >
              {{ opt.label }}
            </button>
          </div>
        </div>

        <p v-if="practiceError" class="text-xs text-red-600 dark:text-red-400 mb-2">{{ practiceError }}</p>
        <div v-if="practiceLoading" class="text-sm text-neutral-400 py-6 text-center">加载中...</div>
        <div v-else-if="!practiceRecords.length" class="text-sm text-neutral-400 text-center py-6">
          暂无练习记录，去跟读一句试试看
        </div>
        <ul v-else class="space-y-2.5">
          <li
            v-for="item in practiceRecords"
            :key="item.id"
            class="rounded-xl border border-black/5 dark:border-white/10 bg-neutral-50/80 dark:bg-neutral-950/40 px-3.5 py-3"
          >
            <div class="flex items-start gap-3">
              <div
                class="shrink-0 w-11 h-11 rounded-full flex items-center justify-center text-sm font-semibold tabular-nums"
                :class="
                  item.score >= 80
                    ? 'bg-emerald-100 text-emerald-800 dark:bg-emerald-900/40 dark:text-emerald-200'
                    : item.score >= 60
                      ? 'bg-amber-100 text-amber-900 dark:bg-amber-900/40 dark:text-amber-200'
                      : 'bg-rose-100 text-rose-800 dark:bg-rose-900/40 dark:text-rose-200'
                "
              >
                {{ item.score }}
              </div>
              <div class="min-w-0 flex-1">
                <div class="flex items-center gap-2 flex-wrap text-[11px] text-neutral-400">
                  <span>{{ modeLabel(item.mode) }}</span>
                  <span v-if="item.level">· {{ item.level }}</span>
                  <span v-if="formatPracticeTime(item.created_at)">· {{ formatPracticeTime(item.created_at) }}</span>
                  <span v-if="item.title" class="truncate max-w-[10rem]" :title="item.title">· {{ item.title }}</span>
                </div>
                <p class="mt-1 text-sm text-neutral-800 dark:text-neutral-100 line-clamp-2 leading-relaxed">
                  {{ item.ref_text }}
                </p>
                <p v-if="item.praise" class="mt-1 text-xs text-neutral-500 dark:text-neutral-400 line-clamp-1">
                  {{ item.praise }}
                </p>
                <div class="mt-2 flex items-center gap-3">
                  <button
                    v-if="item.has_audio"
                    type="button"
                    class="text-[11px] font-medium text-emerald-700 dark:text-emerald-300 hover:underline"
                    @click="togglePracticeAudio(item)"
                  >
                    {{ playingId === item.id ? '停止' : '回听' }}
                  </button>
                  <RouterLink
                    v-if="practiceSourcePath(item)"
                    :to="practiceSourcePath(item)"
                    class="text-[11px] text-neutral-500 dark:text-neutral-400 hover:text-amber-700 dark:hover:text-amber-400 hover:underline"
                  >
                    回看
                  </RouterLink>
                  <button
                    type="button"
                    class="text-[11px] text-neutral-400 hover:text-rose-600 dark:hover:text-rose-400 disabled:opacity-50"
                    :disabled="deletingIds.has(item.id)"
                    @click="removePractice(item)"
                  >
                    {{ deletingIds.has(item.id) ? '删除中…' : '删除' }}
                  </button>
                </div>
              </div>
            </div>
          </li>
        </ul>
      </section>

      <section class="rounded-xl border border-black/5 dark:border-white/10 bg-white dark:bg-neutral-900 p-5">
        <div class="flex items-start justify-between gap-3 mb-1">
          <div class="min-w-0">
            <h2 class="font-medium">
              {{ showingUnsavedOnly ? '查过未收藏' : '最近查词' }}
            </h2>
            <p class="text-xs text-neutral-400 mt-1">
              <template v-if="showingUnsavedOnly">
                查过但还没进生词本的词，一键补收藏；共 {{ unsavedCount }} 个
              </template>
              <template v-else>
                最近查过的词都已在生词本
              </template>
            </p>
          </div>
          <RouterLink
            to="/english/vocabulary"
            class="shrink-0 text-xs text-amber-700 dark:text-amber-400 hover:underline"
          >
            生词本
          </RouterLink>
        </div>

        <p v-if="saveError" class="text-xs text-red-600 dark:text-red-400 mt-2 mb-1">{{ saveError }}</p>

        <div v-if="!displayLookups.length" class="text-sm text-neutral-400 text-center py-6">
          暂无查词记录
        </div>
        <ul v-else class="mt-4 grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-2.5">
          <li
            v-for="item in displayLookups"
            :key="item.id"
            class="rounded-xl border border-black/5 dark:border-white/10 bg-neutral-50/80 dark:bg-neutral-950/40 p-3 flex flex-col min-h-[7.5rem]"
            :class="item.is_saved ? 'opacity-70' : ''"
          >
            <div class="flex items-start justify-between gap-1.5 min-w-0">
              <p class="font-medium text-[15px] leading-snug text-neutral-900 dark:text-neutral-100 break-words">
                {{ item.word }}
              </p>
              <span
                v-if="item.is_saved"
                class="shrink-0 text-[10px] text-amber-700 dark:text-amber-400 mt-0.5"
              >已收藏</span>
            </div>
            <p
              v-if="item.context"
              class="mt-1.5 text-xs text-neutral-500 dark:text-neutral-400 line-clamp-2 leading-relaxed"
            >
              {{ item.context }}
            </p>
            <p
              v-if="item.episode_title"
              class="mt-1 text-[11px] text-neutral-400 truncate"
              :title="item.episode_title"
            >
              {{ item.episode_title }}
            </p>
            <div class="mt-auto pt-2.5 flex items-center gap-2.5">
              <button
                v-if="!item.is_saved"
                type="button"
                class="text-[11px] font-medium text-amber-800 dark:text-amber-300 hover:underline disabled:opacity-50"
                :disabled="savingIds.has(item.id)"
                @click="addToVocabulary(item)"
              >
                {{ savingIds.has(item.id) ? '加入中…' : '加入' }}
              </button>
              <RouterLink
                v-if="lookupSourcePath(item)"
                :to="lookupSourcePath(item)"
                class="text-[11px] text-neutral-500 dark:text-neutral-400 hover:text-amber-700 dark:hover:text-amber-400 hover:underline"
              >
                回看
              </RouterLink>
            </div>
          </li>
        </ul>
      </section>
    </template>
  </div>
</template>
