<script setup lang="ts">
import { onMounted, onUnmounted, ref } from 'vue'
import { RouterLink } from 'vue-router'
import UserGeoBarChart from '@/components/charts/UserGeoBarChart.vue'
import {
  adminFetchDashboard,
  adminFetchOnlineUsers,
  adminFetchUserGeoStats,
  type AdminUserGeoStats,
  type DashboardStats,
} from '@/api/admin'

const loading = ref(true)
const stats = ref<DashboardStats | null>(null)
const geoStats = ref<AdminUserGeoStats | null>(null)
const onlineUsers = ref(0)
const onlineWindowSec = ref(90)

let onlinePollTimer: ReturnType<typeof setInterval> | null = null

async function refreshOnlineUsers() {
  try {
    const data = await adminFetchOnlineUsers()
    onlineUsers.value = data.online_users
    onlineWindowSec.value = data.window_sec
  } catch {
    // 保持上次数值
  }
}

onMounted(async () => {
  try {
    const [dashboard, geo] = await Promise.all([
      adminFetchDashboard(),
      adminFetchUserGeoStats().catch(() => null),
    ])
    stats.value = dashboard
    geoStats.value = geo
    onlineUsers.value = dashboard.online_users_now
    await refreshOnlineUsers()
  } finally {
    loading.value = false
  }
  onlinePollTimer = setInterval(refreshOnlineUsers, 30000)
})

onUnmounted(() => {
  if (onlinePollTimer) clearInterval(onlinePollTimer)
})

const cards = [
  { key: 'users_total', label: '用户总数' },
  { key: 'users_today', label: '今日注册' },
  { key: 'members_total', label: '会员数' },
  { key: 'episodes_total', label: '剧集总数' },
  { key: 'episodes_published', label: '已发布' },
  { key: 'episodes_draft', label: '草稿' },
  { key: 'episodes_missing_media', label: '缺媒体 URL' },
  { key: 'activation_codes_total', label: '激活码总数' },
  { key: 'activation_codes_available', label: '未使用激活码' },
  { key: 'activation_codes_used', label: '已使用激活码' },
  { key: 'learning_active_7d', label: '7 日活跃学习用户' },
  { key: 'learning_completions_total', label: '累计学完期数' },
  { key: 'learning_lookups_total', label: '累计查词次数' },
] as const
</script>

<template>
  <div v-if="loading" class="text-neutral-500">加载中...</div>
  <div v-else-if="stats" class="space-y-4">
    <div
      class="rounded-xl border border-emerald-200 bg-gradient-to-br from-emerald-50 to-white p-5 shadow-sm"
    >
      <div class="flex items-start justify-between gap-3">
        <div>
          <p class="text-sm text-emerald-700 mb-1 flex items-center gap-2">
            <span class="inline-block w-2 h-2 rounded-full bg-emerald-500 animate-pulse" aria-hidden="true" />
            当前在线用户
          </p>
          <p class="text-4xl font-semibold tabular-nums text-emerald-900">{{ onlineUsers }}</p>
        </div>
        <p class="text-xs text-neutral-500 text-right max-w-[10rem]">
          最近 {{ onlineWindowSec }} 秒内有活动视为在线，每 30 秒自动刷新
        </p>
      </div>
    </div>

    <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
      <div
        v-for="card in cards"
        :key="card.key"
        class="rounded-xl border border-black/5 bg-white p-5 shadow-sm"
      >
        <p class="text-sm text-neutral-500 mb-2">{{ card.label }}</p>
        <p class="text-3xl font-semibold tabular-nums">{{ stats[card.key] }}</p>
      </div>
    </div>

    <section
      v-if="geoStats?.by_region.length"
      class="rounded-xl border border-black/5 bg-white p-5 shadow-sm"
    >
      <div class="flex flex-wrap items-start justify-between gap-3 mb-4">
        <div>
          <h2 class="font-medium">注册用户地区 Top</h2>
          <p class="text-xs text-neutral-400 mt-1">按省份/国家统计，未知 {{ geoStats.unknown_users }} 人</p>
        </div>
        <RouterLink
          to="/gnadmin/geo"
          class="text-sm text-amber-700 hover:underline shrink-0"
        >
          查看地图 →
        </RouterLink>
      </div>
      <UserGeoBarChart :items="geoStats.by_region" height="240px" />
    </section>
  </div>
</template>
