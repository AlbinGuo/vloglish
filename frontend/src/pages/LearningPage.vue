<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { RouterLink } from 'vue-router'
import LearningHeatmapChart from '@/components/charts/LearningHeatmapChart.vue'
import LearningStatCard from '@/components/learning/LearningStatCard.vue'
import { getLearningCalendar, getLearningSummary, getLookupHistory, type WordLookupRecord } from '@/api/learning'

const loading = ref(true)
const summary = ref<Awaited<ReturnType<typeof getLearningSummary>> | null>(null)
const calendar = ref<{ date: string; watch_time_sec: number; sessions: number }[]>([])
const lookupHistory = ref<WordLookupRecord[]>([])

function formatDuration(sec: number) {
  const h = Math.floor(sec / 3600)
  const m = Math.floor((sec % 3600) / 60)
  if (h > 0) return `${h} 小时 ${m} 分`
  return `${m} 分钟`
}

const statCards = computed(() => {
  const s = summary.value
  if (!s) return []
  return [
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
})

onMounted(async () => {
  try {
    const [s, days, lookups] = await Promise.all([
      getLearningSummary(),
      getLearningCalendar(90),
      getLookupHistory(undefined, 1),
    ])
    summary.value = s
    calendar.value = days
    lookupHistory.value = lookups.results.slice(0, 30)
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <div class="page-container py-6 max-w-3xl space-y-6">
    <div class="flex items-center justify-between gap-3">
      <div class="flex items-center gap-3 text-sm">
        <RouterLink to="/english" class="text-neutral-500 hover:text-neutral-900">← 返回目录</RouterLink>
        <span class="text-neutral-300">|</span>
        <span class="font-medium">学习统计</span>
      </div>
      <RouterLink to="/english/vocabulary" class="text-sm text-amber-700 hover:underline">生词本</RouterLink>
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

      <section class="rounded-xl border border-black/5 bg-white p-5">
        <h2 class="font-medium mb-2">近 90 天学习热力</h2>
        <p class="text-xs text-neutral-400 mb-4">颜色越深表示当日学习时长越长，悬停可查看详情</p>
        <LearningHeatmapChart :days="calendar" :range-days="90" theme="amber" height="220px" />
      </section>

      <section class="rounded-xl border border-black/5 bg-white p-5">
        <h2 class="font-medium mb-4">最近查词</h2>
        <div v-if="!lookupHistory.length" class="text-sm text-neutral-400 text-center py-6">暂无查词记录</div>
        <ul v-else class="space-y-2">
          <li
            v-for="item in lookupHistory"
            :key="item.id"
            class="flex items-start justify-between gap-3 rounded-lg border border-black/5 px-3 py-2"
          >
            <div class="min-w-0">
              <div class="flex items-center gap-2">
                <span class="font-medium text-sm">{{ item.word }}</span>
                <span v-if="item.is_saved" class="text-[10px] text-amber-700">生词</span>
              </div>
              <p class="text-xs text-neutral-400 line-clamp-1 mt-0.5">{{ item.context }}</p>
              <p v-if="item.episode_title" class="text-[11px] text-neutral-400 mt-0.5">{{ item.episode_title }}</p>
            </div>
            <RouterLink
              v-if="item.video_id"
              :to="`/english/episode/${item.video_id}`"
              class="shrink-0 text-xs text-amber-700 hover:underline"
            >
              回看
            </RouterLink>
          </li>
        </ul>
      </section>
    </template>
  </div>
</template>
