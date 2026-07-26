<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref, watch } from 'vue'
import { RouterLink } from 'vue-router'
import { getAuthorsCatalog } from '@/api/episodes'
import { useCatalogBrowseMode } from '@/composables/useCatalogBrowseMode'
import { useCatalogScrollMemory } from '@/composables/useCatalogScrollMemory'
import { useCatalogSidebar } from '@/composables/useCatalogSidebar'
import { useCatalogViewMode } from '@/composables/useCatalogViewMode'
import { useIsMobile } from '@/composables/useBreakpoint'
import { useAuthStore } from '@/stores/auth'
import { CARD_INITIAL_SIZE, LIST_INITIAL_SIZE, useCatalogStore } from '@/stores/catalog'
import EnglishNavTabs from '@/components/english/EnglishNavTabs.vue'
import AuthorStackCard from '@/components/catalog/AuthorStackCard.vue'
import CatalogBrowseModeBar from '@/components/catalog/CatalogBrowseModeBar.vue'
import CatalogFilters from '@/components/catalog/CatalogFilters.vue'
import CatalogListToolbar from '@/components/catalog/CatalogListToolbar.vue'
import CatalogViewSettings from '@/components/catalog/CatalogViewSettings.vue'
import CatalogEpisodeSkeletons from '@/components/skeleton/CatalogEpisodeSkeletons.vue'
import EpisodeCard from '@/components/EpisodeCard.vue'
import EpisodeListRow from '@/components/EpisodeListRow.vue'
import type { AuthorCatalogItem } from '@/types'

defineOptions({ name: 'HomePage' })

const store = useCatalogStore()
const auth = useAuthStore()
const { viewMode } = useCatalogViewMode()
const { browseMode } = useCatalogBrowseMode()
const { collapsed: sidebarCollapsed, toggle: toggleSidebar } = useCatalogSidebar()
const isMobile = useIsMobile()

/** 未登录与手机端固定卡片视图 */
const displayViewMode = computed(() => (isMobile.value || !auth.isLoggedIn ? 'card' : viewMode.value))

/** 用户端「添加外链视频」入口（暂隐藏，改 true 即可重新开放） */
const showSubmitEpisodeEntry = true

const loadMoreSentinel = ref<HTMLElement | null>(null)
const authors = ref<AuthorCatalogItem[]>([])
const authorsLoading = ref(false)
const authorSearchQuery = ref(store.filters.search)
let loadMoreObserver: IntersectionObserver | null = null
let authorSearchTimer: ReturnType<typeof setTimeout> | undefined

const { restore: restoreCatalogScroll } = useCatalogScrollMemory()

const skeletonCount = computed(() =>
  displayViewMode.value === 'card' ? CARD_INITIAL_SIZE : LIST_INITIAL_SIZE,
)

const previewBanner = computed(() => {
  if (auth.isLoggedIn) return null
  return {
    text: '当前仅展示 8 期视频，登录后可看全部视频。',
    showLogin: true,
    showSignup: true,
  }
})

const filterKey = computed(() =>
  [
    store.filters.stars ?? '',
    store.filters.accents.join(','),
    store.filters.tagIds.join(','),
    store.filters.date ?? '',
    store.filters.search,
    store.filters.learningStatus,
    store.filters.ordering,
  ].join('|'),
)

function setupLoadMoreObserver() {
  loadMoreObserver?.disconnect()

  if (browseMode.value === 'author') return

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

async function loadAuthors() {
  authorsLoading.value = true
  try {
    const params: Parameters<typeof getAuthorsCatalog>[0] = {}
    if (store.filters.stars) params.stars = store.filters.stars
    if (store.filters.accents.length) params.accents = store.filters.accents.join(',')
    if (store.filters.tagIds.length) params.tags = store.filters.tagIds.join(',')
    if (store.filters.date) params.date = store.filters.date
    if (store.filters.search) params.search = store.filters.search
    if (store.filters.learningStatus) params.status = store.filters.learningStatus
    const data = await getAuthorsCatalog(params)
    authors.value = data.results
  } catch {
    authors.value = []
  } finally {
    authorsLoading.value = false
  }
}

async function loadCatalogContent() {
  if (browseMode.value === 'author') {
    await loadAuthors()
  } else {
    await store.loadEpisodes(true)
  }
  setupLoadMoreObserver()
}

onMounted(async () => {
  await store.loadFilters()
  store.setListViewMode(displayViewMode.value)
  if (browseMode.value === 'author') {
    await loadAuthors()
  } else if (!store.episodes.length) {
    await store.loadEpisodes()
  }
  setupLoadMoreObserver()
  await restoreCatalogScroll()
})

onUnmounted(() => {
  loadMoreObserver?.disconnect()
})

watch(loadMoreSentinel, () => {
  setupLoadMoreObserver()
})

watch(displayViewMode, async (mode) => {
  if (browseMode.value === 'author') return
  store.setListViewMode(mode)
  await store.loadEpisodes(true)
  setupLoadMoreObserver()
})

watch(browseMode, () => {
  authorSearchQuery.value = store.filters.search
  loadCatalogContent()
})

watch(filterKey, () => {
  if (browseMode.value === 'author') {
    loadAuthors()
  }
})

watch(authorSearchQuery, (value) => {
  if (browseMode.value !== 'author') return
  clearTimeout(authorSearchTimer)
  authorSearchTimer = setTimeout(() => {
    const trimmed = value.trim()
    if (trimmed === store.filters.search) return
    store.setSearch(trimmed)
  }, 300)
})

watch(
  () => store.filters.search,
  (value) => {
    if (browseMode.value === 'author' && value !== authorSearchQuery.value.trim()) {
      authorSearchQuery.value = value
    }
  },
)

function episodePath(videoId: string) {
  if (!auth.isLoggedIn) {
    return `/login?next=${encodeURIComponent(`/english/episode/${videoId}`)}`
  }
  return `/english/episode/${videoId}`
}

watch(
  () => [auth.isMember, auth.isLoggedIn],
  () => {
    loadCatalogContent()
  },
)
</script>

<template>
  <div class="page-container py-6">
    <div class="flex flex-col lg:flex-row gap-6 lg:gap-8">
      <!-- 收起后：窄条展开按钮 -->
      <aside
        v-if="auth.isLoggedIn && sidebarCollapsed"
        class="hidden lg:flex shrink-0 flex-col items-stretch"
      >
        <button
          type="button"
          class="sticky top-20 w-10 rounded-xl border border-black/5 dark:border-white/10 bg-white dark:bg-neutral-900 py-3 text-neutral-600 dark:text-neutral-300 hover:bg-neutral-50 dark:hover:bg-neutral-800 hover:text-neutral-900 dark:hover:text-white transition flex flex-col items-center gap-2 shadow-sm"
          aria-label="显示筛选与设置"
          title="显示筛选与设置"
          @click="toggleSidebar"
        >
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-4 h-4" aria-hidden="true">
            <path fill-rule="evenodd" d="M7.21 14.77a.75.75 0 0 1 .02-1.06L11.168 10 7.23 6.29a.75.75 0 1 1 1.04-1.08l4.5 4.25a.75.75 0 0 1 0 1.08l-4.5 4.25a.75.75 0 0 1-1.06-.02Z" clip-rule="evenodd" />
          </svg>
          <span
            class="text-[11px] font-medium tracking-wider leading-none py-1"
            style="writing-mode: vertical-rl"
          >筛选</span>
        </button>
      </aside>

      <!-- 展开：筛选 + 设置 -->
      <aside
        v-else-if="auth.isLoggedIn"
        class="hidden lg:block w-full lg:w-72 xl:w-80 shrink-0 space-y-4"
      >
        <div class="flex items-center justify-between gap-2">
          <span class="text-sm font-medium text-neutral-700 dark:text-neutral-200">筛选与设置</span>
          <button
            type="button"
            class="inline-flex items-center gap-1 rounded-lg border border-black/10 dark:border-white/10 px-2.5 py-1.5 text-xs text-neutral-600 dark:text-neutral-300 hover:bg-neutral-100 dark:hover:bg-neutral-800 transition"
            aria-label="收起筛选与设置"
            title="收起"
            @click="toggleSidebar"
          >
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-3.5 h-3.5" aria-hidden="true">
              <path fill-rule="evenodd" d="M12.79 5.23a.75.75 0 0 1-.02 1.06L8.832 10l3.938 3.71a.75.75 0 1 1-1.04 1.08l-4.5-4.25a.75.75 0 0 1 0-1.08l4.5-4.25a.75.75 0 0 1 1.06.02Z" clip-rule="evenodd" />
            </svg>
            收起
          </button>
        </div>
        <RouterLink
          v-if="showSubmitEpisodeEntry && auth.isMember"
          to="/english/submit"
          class="flex items-center justify-center gap-2 w-full rounded-xl bg-gradient-to-r from-amber-500 to-orange-500 text-white font-semibold text-sm px-4 py-3.5 shadow-md shadow-amber-500/25 hover:from-amber-600 hover:to-orange-600 hover:shadow-lg hover:shadow-amber-500/30 transition-all"
        >
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-5 h-5 shrink-0">
            <path d="M10.75 4.75a.75.75 0 0 0-1.5 0v4.5h-4.5a.75.75 0 0 0 0 1.5h4.5v4.5a.75.75 0 0 0 1.5 0v-4.5h4.5a.75.75 0 0 0 0-1.5h-4.5v-4.5Z" />
          </svg>
          投稿外链视频
        </RouterLink>
        <RouterLink
          v-if="showSubmitEpisodeEntry && auth.isMember"
          to="/english/my-submissions"
          class="flex items-center justify-center w-full rounded-xl border border-black/10 dark:border-white/10 text-sm text-neutral-600 dark:text-neutral-300 px-4 py-2.5 hover:bg-neutral-50 dark:hover:bg-neutral-800 transition"
        >
          我的语料库
        </RouterLink>
        <CatalogFilters />
        <CatalogViewSettings />
      </aside>

      <section class="flex-1 min-w-0">
        <div class="mb-4 flex items-center gap-2 sm:gap-3 min-w-0">
          <EnglishNavTabs class="shrink-0" />
          <div v-if="browseMode === 'author'" class="flex-1 min-w-0">
            <label class="sr-only" for="author-catalog-search">搜索作者或视频标题</label>
            <input
              id="author-catalog-search"
              v-model="authorSearchQuery"
              type="search"
              placeholder="搜索作者或标题"
              class="w-full rounded-xl border border-black/10 dark:border-white/10 bg-white dark:bg-neutral-900 dark:text-white px-3 sm:px-4 py-2 text-sm placeholder:text-neutral-400 focus:outline-none focus:ring-2 focus:ring-neutral-900/10 dark:focus:ring-white/10"
            />
          </div>
        </div>

        <CatalogBrowseModeBar class="lg:hidden mb-4" />

        <div
          v-if="previewBanner"
          class="mb-4 rounded-xl border border-amber-200 dark:border-amber-800 bg-amber-50 dark:bg-amber-950/40 px-4 py-3 text-sm text-amber-900 dark:text-amber-200 flex flex-wrap items-center gap-x-2 gap-y-1"
        >
          <span>{{ previewBanner.text }}</span>
          <RouterLink v-if="previewBanner.showLogin" to="/login" class="font-medium underline">登录</RouterLink>
          <RouterLink v-if="previewBanner.showSignup" to="/signup" class="font-medium underline">注册</RouterLink>
        </div>

        <!-- 按作者分类 -->
        <template v-if="browseMode === 'author'">
          <div v-if="authorsLoading && !authors.length" class="py-24 text-center text-neutral-500">加载中...</div>
          <div v-else-if="!authors.length" class="text-center py-24 text-neutral-500">没有匹配的作者</div>
          <div v-else class="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-3">
            <AuthorStackCard v-for="item in authors" :key="item.id" :author="item" />
          </div>
          <div v-if="authors.length" class="py-8 text-center text-sm text-neutral-400">
            共 {{ authors.length }} 位作者
          </div>
        </template>

        <!-- 全部视频 -->
        <template v-else>
          <CatalogEpisodeSkeletons v-if="store.loading && !store.episodes.length" :count="skeletonCount" />

          <template v-else>
            <div v-if="displayViewMode === 'card'">
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

            <div v-else class="rounded-xl border border-black/5 dark:border-white/10 overflow-hidden bg-white dark:bg-neutral-900">
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
        </template>
      </section>
    </div>
  </div>
</template>
