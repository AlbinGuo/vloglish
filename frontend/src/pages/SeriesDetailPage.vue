<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import { getSeriesDetail } from '@/api/episodes'
import EnglishCatalogNavBar from '@/components/english/EnglishCatalogNavBar.vue'
import EnglishNavTabs from '@/components/english/EnglishNavTabs.vue'
import { requestEpisodeAutoplay } from '@/composables/useEpisodeAutoplay'
import { useListenPlayerStore } from '@/stores/listenPlayer'
import EpisodeAccessBadge from '@/components/EpisodeAccessBadge.vue'
import { isOpenToFreeUsers } from '@/utils/episodeAccess'
import { resolveMediaUrl } from '@/utils/mediaUrl'
import type { SeriesDetail } from '@/types'

defineOptions({ name: 'SeriesDetailPage' })

const route = useRoute()
const router = useRouter()

const loading = ref(true)
const error = ref('')
const series = ref<SeriesDetail | null>(null)

const slug = computed(() => String(route.params.slug || ''))
const listenPlayer = useListenPlayerStore()

function episodePath(videoId: string) {
  return `/english/episode/${videoId}`
}

function episodeLink(ep: { video_id: string; requires_membership?: boolean }) {
  if (ep.requires_membership) {
    return { path: '/pricing', query: { next: episodePath(ep.video_id) } }
  }
  return episodePath(ep.video_id)
}

function playListen(ep: { video_id: string; requires_membership?: boolean; short_title: string; cover: string; clip_length: number; author?: { name: string } }) {
  if (ep.requires_membership) {
    void router.push({ path: '/pricing', query: { next: `/english/listen/${ep.video_id}` } })
    return
  }
  void listenPlayer.enqueueAndPlay(
    {
      video_id: ep.video_id,
      short_title: ep.short_title,
      cover: ep.cover,
      clip_length: ep.clip_length || 0,
      author_name: ep.author?.name || '',
    },
    true,
  )
}

function formatDuration(sec: number) {
  const m = Math.floor(sec / 60)
  const s = Math.floor(sec % 60)
  return `${m}:${String(s).padStart(2, '0')}`
}

async function load() {
  if (!slug.value) return
  loading.value = true
  error.value = ''
  try {
    series.value = await getSeriesDetail(slug.value)
  } catch (e: unknown) {
    series.value = null
    const status = (e as { response?: { status?: number } })?.response?.status
    if (status === 401) {
      await router.replace({ path: '/login', query: { next: route.fullPath } })
      return
    }
    error.value = status === 403 ? '合集目录暂时无法打开，请稍后重试' : '合集不存在或加载失败'
  } finally {
    loading.value = false
  }
}

onMounted(load)
watch(slug, load)
</script>

<template>
  <div>
    <EnglishCatalogNavBar />

    <div class="page-container pt-3 pb-6 sm:py-6">
    <EnglishNavTabs class="hidden sm:block mb-6" />

    <p v-if="loading" class="py-24 text-center text-neutral-500">加载中...</p>

    <p v-else-if="error" class="py-24 text-center text-red-600">{{ error }}</p>

    <template v-else-if="series">
      <div class="mb-6 flex flex-col sm:flex-row gap-4 sm:gap-6">
        <div class="w-full sm:w-56 shrink-0 aspect-video rounded-xl overflow-hidden bg-neutral-200 dark:bg-neutral-800">
          <img
            v-if="series.cover"
            :src="resolveMediaUrl(series.cover)"
            :alt="series.title"
            class="w-full h-full object-cover"
          />
        </div>
        <div class="min-w-0 flex-1">
          <RouterLink to="/english/series" class="text-xs text-neutral-500 hover:text-neutral-800 dark:hover:text-neutral-200">
            ← 全部合集
          </RouterLink>
          <h1 class="mt-2 text-2xl font-semibold tracking-tight">{{ series.title }}</h1>
          <p class="mt-1 text-sm text-neutral-500">已更新至第 {{ series.episode_count }} 集，持续更新中</p>
          <p v-if="series.summary" class="mt-3 text-sm text-neutral-600 dark:text-neutral-400 leading-relaxed">
            {{ series.summary }}
          </p>
        </div>
      </div>

      <ol class="space-y-2">
        <li v-for="ep in series.episodes" :key="ep.video_id" class="flex items-stretch gap-2">
          <RouterLink
            :to="episodeLink(ep)"
            class="flex flex-1 min-w-0 gap-3 rounded-xl border border-black/5 dark:border-white/10 bg-white dark:bg-neutral-900 p-3 hover:shadow-sm transition group"
            @click="ep.requires_membership ? undefined : requestEpisodeAutoplay"
          >
            <div class="relative w-28 sm:w-36 shrink-0 aspect-video rounded-lg overflow-hidden bg-neutral-200 dark:bg-neutral-800">
              <img
                :src="resolveMediaUrl(ep.cover)"
                :alt="ep.short_title"
                class="w-full h-full object-cover"
                loading="lazy"
              />
              <span class="absolute bottom-1 right-1 text-[10px] text-white bg-black/60 px-1 rounded">
                {{ formatDuration(ep.clip_length) }}
              </span>
              <div class="absolute top-1 left-1 flex flex-wrap items-center gap-1">
                <EpisodeAccessBadge :free="isOpenToFreeUsers(ep)" compact />
                <span
                  v-if="ep.is_learned"
                  class="text-[10px] px-1.5 py-0.5 rounded bg-emerald-600 text-white font-medium leading-none"
                >
                  已学完
                </span>
                <span
                  v-else-if="ep.is_new"
                  class="text-[10px] px-1.5 py-0.5 rounded bg-red-500 text-white font-bold leading-none"
                >
                  新
                </span>
              </div>
            </div>
            <div class="flex-1 min-w-0 py-0.5">
              <p class="text-xs text-neutral-500 mb-1">
                第 {{ ep.series_index ?? ep.index }} 集
                <span :class="isOpenToFreeUsers(ep) ? 'text-emerald-700 dark:text-emerald-400' : 'text-amber-700 dark:text-amber-400'">
                  · {{ isOpenToFreeUsers(ep) ? '免费' : '会员' }}
                </span>
              </p>
              <p class="font-medium leading-snug line-clamp-2 group-hover:text-amber-800 dark:group-hover:text-amber-400 transition-colors">
                {{ ep.short_title }}
              </p>
              <p v-if="ep.summary" class="mt-1 text-xs text-neutral-500 line-clamp-2">{{ ep.summary }}</p>
              <div v-if="ep.progress_percent && ep.progress_percent > 0 && !ep.is_learned" class="mt-2 h-1 rounded-full bg-neutral-100 dark:bg-neutral-800 overflow-hidden">
                <div
                  class="h-full bg-amber-500 rounded-full"
                  :style="{ width: `${Math.min(100, Math.round(ep.progress_percent))}%` }"
                />
              </div>
            </div>
          </RouterLink>
          <button
            type="button"
            class="shrink-0 self-center w-10 h-10 rounded-full border border-black/10 dark:border-white/10 bg-white dark:bg-neutral-900 text-neutral-700 dark:text-neutral-200 flex items-center justify-center"
            aria-label="听这一集"
            @click="playListen(ep)"
          >
            <svg viewBox="0 0 24 24" class="w-4 h-4 ml-0.5" fill="currentColor"><path d="M8 5.5v13l11-6.5L8 5.5Z" /></svg>
          </button>
        </li>
      </ol>
    </template>
    </div>
  </div>
</template>
