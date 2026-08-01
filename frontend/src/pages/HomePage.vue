<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref, watch } from 'vue'
import { RouterLink } from 'vue-router'
import { getAuthorsCatalog } from '@/api/episodes'
import { useCatalogBrowseMode } from '@/composables/useCatalogBrowseMode'
import { useCatalogScrollMemory } from '@/composables/useCatalogScrollMemory'
import { useCatalogViewMode } from '@/composables/useCatalogViewMode'
import { useIsMobile } from '@/composables/useBreakpoint'
import { useAuthStore } from '@/stores/auth'
import { CARD_INITIAL_SIZE, LIST_INITIAL_SIZE, useCatalogStore } from '@/stores/catalog'
import EnglishNavTabs from '@/components/english/EnglishNavTabs.vue'
import EnglishHotTagsBar from '@/components/english/EnglishHotTagsBar.vue'
import AuthorStackCard from '@/components/catalog/AuthorStackCard.vue'
import CatalogContentToolbar from '@/components/catalog/CatalogContentToolbar.vue'
import CatalogListToolbar from '@/components/catalog/CatalogListToolbar.vue'
import CatalogEpisodeSkeletons from '@/components/skeleton/CatalogEpisodeSkeletons.vue'
import EpisodeCard from '@/components/EpisodeCard.vue'
import EpisodeListRow from '@/components/EpisodeListRow.vue'
import type { AuthorCatalogItem } from '@/types'

defineOptions({ name: 'HomePage' })

const store = useCatalogStore()
const auth = useAuthStore()
const { viewMode } = useCatalogViewMode()
const { browseMode } = useCatalogBrowseMode()
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
  if (!auth.isLoggedIn || auth.isMember) return null
  return {
    text: '当前为普通用户，首页仅展示部分视频；开通会员后可学习全部内容与合集。',
    showLogin: false,
    showSignup: false,
    showPricing: true,
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
  } else {
    // 始终重拉：支付页在 Layout 外会卸载首页，但 Pinia 仍可能缓存免费限额列表
    await store.loadEpisodes(true)
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
    <div class="mb-3 flex items-center gap-2 sm:gap-3 min-w-0">
      <EnglishNavTabs class="shrink-0" />
      <EnglishHotTagsBar />
      <div v-if="browseMode === 'author'" class="flex-1 min-w-0 max-w-xs sm:max-w-sm ml-auto">
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

    <CatalogContentToolbar class="mb-4" :show-submit-entry="showSubmitEpisodeEntry" />

    <div
      v-if="previewBanner"
      class="mb-4 rounded-xl border border-amber-200 dark:border-amber-800 bg-amber-50 dark:bg-amber-950/40 px-4 py-3 text-sm text-amber-900 dark:text-amber-200 flex flex-wrap items-center gap-x-2 gap-y-1"
    >
      <span>{{ previewBanner.text }}</span>
      <RouterLink v-if="previewBanner.showLogin" to="/login" class="font-medium underline">登录</RouterLink>
      <RouterLink v-if="previewBanner.showSignup" to="/signup" class="font-medium underline">注册</RouterLink>
      <RouterLink v-if="previewBanner.showPricing" to="/pricing" class="font-medium underline">开通会员</RouterLink>
    </div>

    <!-- 按作者分类 -->
    <template v-if="browseMode === 'author'">
      <div v-if="authorsLoading && !authors.length" class="py-24 text-center text-neutral-500">加载中...</div>
      <div v-else-if="!authors.length" class="text-center py-24 text-neutral-500">没有匹配的作者</div>
      <div v-else class="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-4 2xl:grid-cols-5 gap-3">
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
          <div v-else class="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-4 2xl:grid-cols-5 gap-3">
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
          {{
            auth.isLoggedIn && !auth.isMember
              ? `普通用户只展示 ${store.total} 期，会员可看全部视频`
              : `已加载全部 ${store.total} 期`
          }}
        </div>
      </template>
    </template>
  </div>
</template>
