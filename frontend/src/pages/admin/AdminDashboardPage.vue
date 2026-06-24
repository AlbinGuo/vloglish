<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { adminFetchDashboard, type DashboardStats } from '@/api/admin'

const loading = ref(true)
const stats = ref<DashboardStats | null>(null)

onMounted(async () => {
  try {
    stats.value = await adminFetchDashboard()
  } finally {
    loading.value = false
  }
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
] as const
</script>

<template>
  <div v-if="loading" class="text-neutral-500">加载中...</div>
  <div v-else-if="stats" class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
    <div
      v-for="card in cards"
      :key="card.key"
      class="rounded-xl border border-black/5 bg-white p-5 shadow-sm"
    >
      <p class="text-sm text-neutral-500 mb-2">{{ card.label }}</p>
      <p class="text-3xl font-semibold tabular-nums">{{ stats[card.key] }}</p>
    </div>
  </div>
</template>
