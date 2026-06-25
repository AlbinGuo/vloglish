<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref, watch } from 'vue'
import { RouterLink } from 'vue-router'
import { getRecentEpisodes, type RecentEpisode } from '@/api/learning'
import { useCatalogViewMode } from '@/composables/useCatalogViewMode'
import { useAuthStore } from '@/stores/auth'
import { CARD_INITIAL_SIZE, LIST_INITIAL_SIZE, useCatalogStore } from '@/stores/catalog'
import CatalogCalendar from '@/components/catalog/CatalogCalendar.vue'
import CatalogFilters from '@/components/catalog/CatalogFilters.vue'
import CatalogListToolbar from '@/components/catalog/CatalogListToolbar.vue'
import CatalogViewSettings from '@/components/catalog/CatalogViewSettings.vue'
import CatalogEpisodeSkeletons from '@/components/skeleton/CatalogEpisodeSkeletons.vue'
import EpisodeCard from '@/components/EpisodeCard.vue'
import EpisodeListRow from '@/components/EpisodeListRow.vue'

const store = useCatalogStore()
const auth = useAuthStore()
const { viewMode } = useCatalogViewMode()

const loadMoreSentinel = ref<HTMLElement | null>(null)
const recentLearning = ref<RecentEpisode[]>([])
let loadMoreObserver: IntersectionObserver | null = null

const skeletonCount = computed(() =>
  viewMode.value === 'card' ? CARD_INITIAL_SIZE : LIST_INITIAL_SIZE,
)

const previewBanner = computed(() => {
  if (auth.isMember) return null
  if (auth.isLoggedIn) {
    return {
      text: '当前仅展示 5 期视频，激活会员解锁全量。',
      showLogin: false,
      showSignup: false,
      showActivate: true,
    }
  }
  return {
    text: '当前仅展示 2 期视频，登录后可看 5 期。',
    showLogin: true,
    showSignup: true,
    showActivate: false,
  }
})

function setupLoadMoreObserver() {
  loadMoreObserver?.disconnect()

  loadMoreObserver = new IntersectionObserver(
    (entries) => {
      if (!entries[0]?.isIntersecting) return
      if (store.hasMore && !store.loading && !store.loadingMore) {
        store.loadMoreEpisodes()
      }
    },
    { rootMargin: '240px' },
  )

  if (loadMoreSentinel.value) {
    loadMoreObserver.observe(loadMoreSentinel.value)
  }
}

onMounted(async () => {
  await store.loadFilters()
  store.setListViewMode(viewMode.value)
  await store.loadEpisodes()
  if (auth.isLoggedIn) {
    try {
      recentLearning.value = (await getRecentEpisodes()).filter((e) => !e.is_completed).slice(0, 5)
    } catch {
      recentLearning.value = []
    }
  }
  setupLoadMoreObserver()
})

onUnmounted(() => {
  loadMoreObserver?.disconnect()
})

watch(loadMoreSentinel, () => {
  setupLoadMoreObserver()
})

watch(viewMode, async (mode) => {
  store.setListViewMode(mode)
  await store.loadEpisodes(true)
  setupLoadMoreObserver()
})

function episodePath(videoId: string) {
  return auth.isMember ? `/english/episode/${videoId}` : `/english/demo/${videoId}`
}

watch(
  () => [auth.isMember, auth.isLoggedIn],
  () => {
    store.loadEpisodes(true)
  },
)
</script>

<template>
  <div class="page-container py-6">
    <div class="flex flex-col lg:flex-row gap-6 lg:gap-8">
      <aside class="w-full lg:w-72 xl:w-80 shrink-0 space-y-4">
        <RouterLink
          v-if="auth.isMember"
          to="/english/submit"
          class="flex items-center justify-center gap-2 w-full rounded-xl bg-gradient-to-r from-amber-500 to-orange-500 text-white font-semibold text-sm px-4 py-3.5 shadow-md shadow-amber-500/25 hover:from-amber-600 hover:to-orange-600 hover:shadow-lg hover:shadow-amber-500/30 transition-all"
        >
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-5 h-5 shrink-0">
            <path d="M10.75 4.75a.75.75 0 0 0-1.5 0v4.5h-4.5a.75.75 0 0 0 0 1.5h4.5v4.5a.75.75 0 0 0 1.5 0v-4.5h4.5a.75.75 0 0 0 0-1.5h-4.5v-4.5Z" />
          </svg>
          添加外链视频
        </RouterLink>
        <CatalogCalendar />
        <CatalogFilters />
        <CatalogViewSettings />
      </aside>

      <section class="flex-1 min-w-0">
        <section
          v-if="auth.isLoggedIn && recentLearning.length"
          class="mb-5 rounded-xl border border-black/5 bg-white p-4"
        >
          <div class="flex items-center justify-between mb-3">
            <h2 class="text-sm font-semibold">继续学习</h2>
            <RouterLink to="/english/learning" class="text-xs text-amber-700 hover:underline">全部统计</RouterLink>
          </div>
          <div class="flex gap-3 overflow-x-auto pb-1 -mx-1 px-1">
            <RouterLink
              v-for="item in recentLearning"
              :key="item.video_id"
              :to="episodePath(item.video_id)"
              class="shrink-0 w-40 rounded-lg border border-black/5 overflow-hidden hover:shadow-sm transition"
            >
              <div class="relative aspect-video bg-neutral-200">
                <img :src="item.cover" :alt="item.short_title" class="w-full h-full object-cover" loading="lazy" />
                <span class="absolute bottom-1 right-1 text-[10px] text-white bg-black/60 px-1 rounded">
                  {{ Math.round(item.completion_percent) }}%
                </span>
              </div>
              <p class="p-2 text-xs font-medium line-clamp-2 leading-snug">{{ item.short_title }}</p>
            </RouterLink>
          </div>
        </section>

        <div
          v-if="previewBanner"
          class="mb-4 rounded-xl border border-amber-200 bg-amber-50 px-4 py-3 text-sm text-amber-900 flex flex-wrap items-center gap-x-2 gap-y-1"
        >
          <span>{{ previewBanner.text }}</span>
          <RouterLink v-if="previewBanner.showLogin" to="/login" class="font-medium underline">登录</RouterLink>
          <RouterLink v-if="previewBanner.showSignup" to="/signup" class="font-medium underline">注册</RouterLink>
          <RouterLink v-if="previewBanner.showActivate" to="/activate" class="font-medium underline">激活会员</RouterLink>
        </div>

        <CatalogEpisodeSkeletons v-if="store.loading" :count="skeletonCount" />

        <template v-else>
          <div v-if="viewMode === 'card'">
            <div v-if="!store.episodes.length" class="text-center py-24 text-neutral-500">没有匹配的内容</div>
            <div v-else class="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-3">
              <EpisodeCard
                v-for="ep in store.episodes"
                :key="ep.video_id"
                :episode="ep"
                :to="episodePath(ep.video_id)"
              />
            </div>
          </div>

          <div v-else class="rounded-xl border border-black/5 overflow-hidden bg-white">
            <CatalogListToolbar />
            <div v-if="!store.episodes.length" class="text-center py-16 text-neutral-500">没有匹配的内容</div>
            <EpisodeListRow
              v-for="(ep, i) in store.episodes"
              :key="ep.video_id"
              :episode="ep"
              :row-index="i + 1"
              :to="episodePath(ep.video_id)"
            />
          </div>

          <div ref="loadMoreSentinel" class="h-1" aria-hidden="true" />
          <div v-if="store.loadingMore" class="py-8 text-center text-sm text-neutral-500">加载中...</div>
          <div
            v-else-if="store.episodes.length && !store.hasMore"
            class="py-8 text-center text-sm text-neutral-400"
          >
            已加载全部 {{ store.total }} 期
          </div>
        </template>
      </section>
    </div>
  </div>
</template>
