<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { RouterLink } from 'vue-router'
import AppIcon from '@/components/AppIcon.vue'
import { getRecentEpisodes, type RecentEpisode } from '@/api/learning'
import { getErrorDetail } from '@/api/tokens'
import { resolveMediaUrl } from '@/utils/mediaUrl'
import { formatListenTime } from '@/utils/formatListenTime'

const items = ref<RecentEpisode[]>([])
const loading = ref(true)
const error = ref('')

const completedCount = computed(() => items.value.filter((it) => it.is_completed).length)

async function load() {
  loading.value = true
  error.value = ''
  try {
    items.value = await getRecentEpisodes({ limit: 50, includeCompleted: true })
  } catch (e) {
    error.value = getErrorDetail(e) || '浏览记录加载失败，请稍后重试'
    items.value = []
  } finally {
    loading.value = false
  }
}

function episodeLink(item: RecentEpisode) {
  return `/english/episode/${encodeURIComponent(item.video_id)}?from=history`
}

function progressPercent(item: RecentEpisode) {
  const raw = Number(item.completion_percent) || 0
  return Math.max(0, Math.min(100, Math.round(raw)))
}

function watcherLabel(item: RecentEpisode) {
  if (item.is_completed) return '已看完'
  const pct = progressPercent(item)
  if (pct > 0) return `已看 ${pct}%`
  return '刚开始看'
}

function positionLabel(item: RecentEpisode) {
  const pos = Number(item.last_position_sec) || 0
  if (item.is_completed || pos <= 0) return ''
  const total = Number(item.clip_length) || 0
  const current = formatListenTime(pos)
  return total > 0 ? `上次看到 ${current} / ${formatListenTime(total)}` : `上次看到 ${current}`
}

function parseServerTime(raw: string) {
  if (!raw) return null
  const t = Date.parse(raw.replace(' ', 'T'))
  return Number.isFinite(t) ? t : null
}

function watchedAtLabel(raw: string) {
  const t = parseServerTime(raw)
  if (t == null) return ''
  const diff = Date.now() - t
  if (diff < 60_000) return '刚刚'
  const minutes = Math.floor(diff / 60_000)
  if (minutes < 60) return `${minutes} 分钟前`
  const hours = Math.floor(minutes / 60)
  if (hours < 24) return `${hours} 小时前`
  const days = Math.floor(hours / 24)
  if (days === 1) return '昨天'
  if (days < 7) return `${days} 天前`
  const d = new Date(t)
  return `${d.getMonth() + 1} 月 ${d.getDate()} 日`
}

onMounted(load)
</script>

<template>
  <div class="page-container max-w-3xl py-6">
    <div class="mb-4 flex items-center gap-3 text-sm min-w-0">
      <RouterLink to="/english/mine" class="shrink-0 text-ink-faint hover:text-ink">← 我的</RouterLink>
      <span class="text-neutral-300 dark:text-neutral-600">·</span>
      <span class="font-medium tracking-tight">浏览记录</span>
      <span v-if="items.length" class="text-[11px] tabular-nums text-neutral-400">
        {{ items.length }} 期
        <template v-if="completedCount">· 已看完 {{ completedCount }}</template>
      </span>
      <span class="flex-1" />
      <button
        type="button"
        class="shrink-0 text-[12px] text-ink-faint transition hover:text-ink disabled:opacity-50"
        :disabled="loading"
        @click="load"
      >
        刷新
      </button>
    </div>

    <p class="mb-5 text-[13px] text-neutral-500 dark:text-neutral-400">
      这里按时间倒序记录你看过的剧集，点一下就能接着上次的进度继续看。只保留账号内的学习进度，换设备登录也还在。
    </p>

    <p v-if="error" class="mb-4 text-sm text-red-600 dark:text-red-400">{{ error }}</p>

    <div v-if="loading && !items.length" class="py-16 text-center text-sm text-neutral-500 dark:text-neutral-400">
      加载中…
    </div>

    <div
      v-else-if="!items.length"
      class="rounded-2xl border border-line-soft bg-card px-5 py-14 text-center"
    >
      <AppIcon name="history" class="mx-auto h-8 w-8 text-ink-faint" />
      <p class="mt-3 text-sm text-ink-soft">还没有浏览记录</p>
      <p class="mt-1 text-[12px] text-ink-faint">打开任意一期视频，看过的剧集就会出现在这里</p>
      <RouterLink
        to="/english"
        class="mt-4 inline-flex items-center gap-1 rounded-lg bg-amber-500 px-3.5 py-1.5 text-[13px] font-medium text-white transition hover:bg-amber-600"
      >
        去首页看看
        <AppIcon name="chevron-right" class="h-3.5 w-3.5" />
      </RouterLink>
    </div>

    <ul v-else class="space-y-3">
      <li v-for="item in items" :key="item.video_id">
        <RouterLink
          :to="episodeLink(item)"
          class="flex items-stretch gap-3 rounded-2xl border border-line-soft bg-card p-3 transition hover:bg-sunken"
        >
          <div class="relative aspect-video w-28 shrink-0 overflow-hidden rounded-lg bg-sunken sm:w-32">
            <img
              v-if="item.cover"
              :src="resolveMediaUrl(item.cover)"
              :alt="item.short_title"
              class="h-full w-full object-cover"
              loading="lazy"
            />
            <div v-else class="flex h-full w-full items-center justify-center text-[11px] text-ink-faint">
              暂无封面
            </div>
            <span
              v-if="item.is_completed"
              class="absolute left-1.5 top-1.5 rounded-md bg-emerald-500 px-1.5 py-0.5 text-[10px] font-medium leading-none text-white shadow"
            >
              已看完
            </span>
            <span
              v-if="item.clip_length"
              class="absolute bottom-1 right-1 rounded bg-black/60 px-1 py-0.5 text-[10px] text-white"
            >
              {{ formatListenTime(item.clip_length) }}
            </span>
          </div>

          <div class="flex min-w-0 flex-1 flex-col justify-between gap-2 py-0.5">
            <div class="min-w-0 space-y-1">
              <h3 class="line-clamp-2 text-[14px] font-medium leading-snug text-ink">
                {{ item.short_title || '未命名视频' }}
              </h3>
              <p class="flex flex-wrap items-center gap-x-2 gap-y-0.5 text-[11px] text-ink-faint">
                <span v-if="item.author_name" class="truncate">{{ item.author_name }}</span>
                <span>{{ watchedAtLabel(item.last_watched_at) }}</span>
                <span v-if="positionLabel(item)" class="tabular-nums">{{ positionLabel(item) }}</span>
              </p>
            </div>

            <div class="space-y-1">
              <div class="flex items-center justify-between text-[11px]">
                <span :class="item.is_completed ? 'text-emerald-600 dark:text-emerald-400' : 'text-ink-faint'">
                  {{ watcherLabel(item) }}
                </span>
                <AppIcon name="chevron-right" class="h-3.5 w-3.5 text-ink-faint" />
              </div>
              <div class="h-1 overflow-hidden rounded-full bg-sunken">
                <div
                  class="h-full rounded-full transition-all"
                  :class="item.is_completed ? 'bg-emerald-500' : 'bg-amber-500'"
                  :style="{ width: `${item.is_completed ? 100 : progressPercent(item)}%` }"
                />
              </div>
            </div>
          </div>
        </RouterLink>
      </li>
    </ul>
  </div>
</template>
