<script setup lang="ts">
import { onMounted, ref } from 'vue'
import LearningHeatmapChart from '@/components/charts/LearningHeatmapChart.vue'
import { adminFetchLearningStats, type AdminLearningStats } from '@/api/admin'

const loading = ref(true)
const stats = ref<AdminLearningStats | null>(null)

function formatHours(hours: number) {
  if (hours >= 1) return `${hours.toFixed(1)} 小时`
  return `${Math.round(hours * 60)} 分钟`
}

onMounted(async () => {
  try {
    stats.value = await adminFetchLearningStats()
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <div v-if="loading" class="text-neutral-500">加载中...</div>
  <div v-else-if="stats" class="space-y-6 max-w-5xl">
    <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
      <div class="rounded-xl border border-black/5 bg-white p-5 shadow-sm">
        <p class="text-sm text-neutral-500 mb-2">7 日活跃学习用户</p>
        <p class="text-3xl font-semibold tabular-nums">{{ stats.active_learners_7d }}</p>
      </div>
      <div class="rounded-xl border border-black/5 bg-white p-5 shadow-sm">
        <p class="text-sm text-neutral-500 mb-2">30 日活跃学习用户</p>
        <p class="text-3xl font-semibold tabular-nums">{{ stats.active_learners_30d }}</p>
      </div>
      <div class="rounded-xl border border-black/5 bg-white p-5 shadow-sm">
        <p class="text-sm text-neutral-500 mb-2">累计学习时长</p>
        <p class="text-3xl font-semibold tabular-nums">{{ formatHours(stats.total_watch_hours) }}</p>
      </div>
      <div class="rounded-xl border border-black/5 bg-white p-5 shadow-sm">
        <p class="text-sm text-neutral-500 mb-2">累计学完期数</p>
        <p class="text-3xl font-semibold tabular-nums">{{ stats.total_completions }}</p>
      </div>
      <div class="rounded-xl border border-black/5 bg-white p-5 shadow-sm">
        <p class="text-sm text-neutral-500 mb-2">累计查词次数</p>
        <p class="text-3xl font-semibold tabular-nums">{{ stats.total_lookups }}</p>
      </div>
      <div class="rounded-xl border border-black/5 bg-white p-5 shadow-sm">
        <p class="text-sm text-neutral-500 mb-2">生词本词条数</p>
        <p class="text-3xl font-semibold tabular-nums">{{ stats.total_vocabulary_items }}</p>
      </div>
    </div>

    <section class="rounded-xl border border-black/5 bg-white p-5 shadow-sm">
      <h2 class="font-medium mb-2">近 30 日学习活跃</h2>
      <p class="text-xs text-neutral-400 mb-4">全站用户每日学习时长汇总</p>
      <LearningHeatmapChart
        :days="stats.daily_activity.map((d) => ({
          date: d.date,
          watch_time_sec: d.watch_time_sec,
          sessions: d.sessions,
        }))"
        :range-days="30"
        theme="blue"
        height="220px"
      />
    </section>

    <section class="rounded-xl border border-black/5 bg-white p-5 shadow-sm">
      <h2 class="font-medium mb-4">学完次数 Top 剧集</h2>
      <div v-if="!stats.top_episodes.length" class="text-sm text-neutral-400">暂无数据</div>
      <table v-else class="w-full text-sm">
        <thead>
          <tr class="text-left text-neutral-500 border-b border-black/5">
            <th class="pb-2 font-medium">剧集</th>
            <th class="pb-2 font-medium text-right">学完次数</th>
            <th class="pb-2 font-medium text-right">学习人数</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="ep in stats.top_episodes" :key="ep.video_id" class="border-b border-black/5 last:border-0">
            <td class="py-2.5 pr-4">
              <p class="font-medium">{{ ep.title }}</p>
              <p class="text-xs text-neutral-400">{{ ep.video_id }}</p>
            </td>
            <td class="py-2.5 text-right tabular-nums">{{ ep.completions }}</td>
            <td class="py-2.5 text-right tabular-nums">{{ ep.learners }}</td>
          </tr>
        </tbody>
      </table>
    </section>
  </div>
</template>
