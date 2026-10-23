<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { RouterLink } from 'vue-router'
import { getRecentEpisodes, type RecentEpisode } from '@/api/learning'
import AppIcon from '@/components/AppIcon.vue'

const items = ref<RecentEpisode[]>([])
const loading = ref(true)

function pad(n: number) {
  return String(n).padStart(2, '0')
}

function fmtTime(iso: string): string {
  if (!iso) return ''
  const d = new Date(iso)
  if (isNaN(d.getTime())) return ''
  const now = new Date()
  if (d.toDateString() === now.toDateString()) {
    return pad(d.getHours()) + ':' + pad(d.getMinutes())
  }
  return d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' + pad(d.getDate())
}

onMounted(async () => {
  try {
    items.value = await getRecentEpisodes({ includeCompleted: true, limit: 100 })
  } catch {
    items.value = []
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <div class="page-container py-4 pb-10">
    <div class="mb-4 flex items-center gap-2">
      <RouterLink to="/english/mine" class="inline-flex items-center gap-1 text-sm text-ink-soft">
        <AppIcon name="chevron-left" class="h-4 w-4" />
        返回
      </RouterLink>
      <h1 class="flex-1 text-center text-[16px] font-semibold text-ink">浏览记录</h1>
      <span class="w-12"></span>
    </div>

    <div v-if="loading" class="py-20 text-center text-sm text-neutral-400">加载中…</div>
    <div v-else-if="!items.length" class="py-24 text-center text-sm text-neutral-400">
      还没有浏览记录，去首页看看吧
    </div>

    <ul v-else class="space-y-3">
      <li v-for="ep in items" :key="ep.video_id">
        <RouterLink
          :to="`/english/episode/${ep.video_id}`"
          class="flex items-center gap-3 rounded-xl border border-line-soft bg-card p-2.5 transition hover:bg-sunken"
        >
          <div class="relative aspect-video w-24 shrink-0 overflow-hidden rounded-lg bg-neutral-200 dark:bg-neutral-800">
            <img
              v-if="ep.cover"
              :src="ep.cover"
              :alt="ep.short_title"
              class="h-full w-full object-cover"
              loading="lazy"
            />
          </div>
          <div class="min-w-0 flex-1">
            <div class="line-clamp-2 text-[14px] font-medium text-ink">{{ ep.short_title }}</div>
            <div class="mt-1 flex items-center gap-2 text-[12px] text-ink-faint">
              <span v-if="ep.author_name" class="truncate">{{ ep.author_name }}</span>
              <span v-if="ep.completion_percent > 0" class="shrink-0">
                已看 {{ Math.round(ep.completion_percent) }}%
              </span>
            </div>
          </div>
          <div class="shrink-0 self-start pt-0.5 text-[11px] text-ink-faint">{{ fmtTime(ep.last_watched_at) }}</div>
        </RouterLink>
      </li>
    </ul>
  </div>
</template>