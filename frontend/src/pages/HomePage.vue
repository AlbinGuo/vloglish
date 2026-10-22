<script setup lang="ts">
import { computed, onActivated, onMounted, onUnmounted, ref, watch } from 'vue'
import { RouterLink } from 'vue-router'
import { getAuthorsCatalog } from '@/api/episodes'
import { useCatalogBrowseMode } from '@/composables/useCatalogBrowseMode'
import { useCatalogScrollMemory } from '@/composables/useCatalogScrollMemory'
import { useCatalogViewMode } from '@/composables/useCatalogViewMode'
import { useIsMobile } from '@/composables/useBreakpoint'
import { useAuthStore } from '@/stores/auth'
import { CARD_INITIAL_SIZE, LIST_INITIAL_SIZE, useCatalogStore } from '@/stores/catalog'
import { useSiteConfigStore } from '@/stores/siteConfig'
import EnglishCatalogNavBar from '@/components/english/EnglishCatalogNavBar.vue'
import EnglishNavTabs from '@/components/english/EnglishNavTabs.vue'
import EnglishHotTagsBar from '@/components/english/EnglishHotTagsBar.vue'
import AuthorStackCard from '@/components/catalog/AuthorStackCard.vue'
import CatalogContentToolbar from '@/components/catalog/CatalogContentToolbar.vue'
import CatalogFilterSheet from '@/components/catalog/CatalogFilterSheet.vue'
import CatalogEpisodeSkeletons from '@/components/skeleton/CatalogEpisodeSkeletons.vue'
import EpisodeCard from '@/components/EpisodeCard.vue'
import EpisodeListRow from '@/components/EpisodeListRow.vue'
import type { AuthorCatalogItem } from '@/types'
import AppIcon from '@/components/AppIcon.vue'

defineOptions({ name: 'HomePage' })

const store = useCatalogStore()
const auth = useAuthStore()
const siteConfig = useSiteConfigStore()
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
const mobileSearchQuery = ref(store.filters.search)
const filterSheetOpen = ref(false)
let loadMoreObserver: IntersectionObserver | null = null
let authorSearchTimer: ReturnType<typeof setTimeout> | undefined
let mobileSearchTimer: ReturnType<typeof setTimeout> | undefined

/** 筛选按钮角标：Sheet 内可改项（不含标签/搜索） */
const mobileSheetFilterCount = computed(() => {
  let n = 0
  if (browseMode.value === 'author') n += 1
  if (store.filters.stars) n += 1
  if (store.filters.duration) n += 1
  if (store.filters.learningStatus === 'favorite') n += 1
  return n
})

const mobileSearchPlaceholder = computed(() =>
  browseMode.value === 'author' ? '搜索作者或标题' : '搜索视频名称或作者',
)

const { restore: restoreCatalogScroll } = useCatalogScrollMemory()

const skeletonCount = computed(() =>
  displayViewMode.value === 'card' ? CARD_INITIAL_SIZE : LIST_INITIAL_SIZE,
)

/** 与定价页限时特惠对齐；过期后不再展示优惠句 */
const MEMBERSHIP_PROMO_END = new Date('2026-08-08T23:59:59+08:00')

const membershipPromoText = computed(() => {
  if (Date.now() > MEMBERSHIP_PROMO_END.getTime()) return ''
  return '永久会员限时 ¥39.9，优惠至 8 月 8 日'
})

const previewBanner = computed(() => {
  if (!auth.isLoggedIn || auth.isMember) return null
  // 关会员内容门槛期间：已登录即可看全部视频/合集，不展示限量引导
  if (!siteConfig.isContentGated) return null
  return {
    text: '开通会员可观看全部视频内容及合集。',
    showLogin: false,
    showSignup: false,
    showPricing: true,
    promo: membershipPromoText.value,
  }
})

const filterKey = computed(() =>
  [
    store.filters.stars ?? '',
    store.filters.duration,
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
    if (store.filters.duration) params.duration = store.filters.duration
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
  await siteConfig.hydrate()
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

// 首页被 KeepAlive 缓存：从详情页/通知等返回时不会重新 mount，
// 这里在“再次激活”时刷新列表，确保管理端新发布的视频能出现在首页。
let _homeActivatedBefore = false
onActivated(async () => {
  // 首次激活紧跟在 onMounted 之后（onMounted 已加载过），跳过避免重复请求
  if (!_homeActivatedBefore) {
    _homeActivatedBefore = true
    return
  }
  try {
    if (browseMode.value === 'author') {
      await loadAuthors()
    } else {
      await store.loadEpisodes(true)
    }
    setupLoadMoreObserver()
  } catch {
    /* ignore */
  }
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
  if (browseMode.value !== 'author' || isMobile.value) return
  clearTimeout(authorSearchTimer)
  authorSearchTimer = setTimeout(() => {
    const trimmed = value.trim()
    if (trimmed === store.filters.search) return
    store.setSearch(trimmed)
  }, 300)
})

watch(mobileSearchQuery, (value) => {
  if (!isMobile.value) return
  clearTimeout(mobileSearchTimer)
  mobileSearchTimer = setTimeout(() => {
    const trimmed = value.trim()
    if (trimmed === store.filters.search) return
    void store.setSearch(trimmed)
  }, 300)
})

watch(
  () => store.filters.search,
  (value) => {
    if (browseMode.value === 'author' && !isMobile.value && value !== authorSearchQuery.value.trim()) {
      authorSearchQuery.value = value
    }
    if (isMobile.value && value !== mobileSearchQuery.value.trim()) {
      mobileSearchQuery.value = value
    }
  },
)

function episodePath(ep: { video_id: string; requires_membership?: boolean }) {
  if (!auth.isLoggedIn) {
    return `/login?next=${encodeURIComponent(`/english/episode/${ep.video_id}`)}`
  }
  if (ep.requires_membership) return '/pricing'
  return `/english/episode/${ep.video_id}`
}

watch(
  () => [auth.isMember, auth.isLoggedIn, siteConfig.isContentGated],
  () => {
    loadCatalogContent()
  },
)
</script>

<template>
  <div>
    <EnglishCatalogNavBar />

    <div class="page-container pb-6" :class="isMobile ? 'pt-3' : 'py-6'">
      <!-- 手机端：搜索+筛选 / 标签（Tab 在顶栏条） -->
      <template v-if="isMobile">
        <div class="mb-3 flex items-center gap-2 min-w-0">
          <div class="flex-1 min-w-0">
            <label class="sr-only" for="mobile-catalog-search">搜索</label>
            <input
              id="mobile-catalog-search"
              v-model="mobileSearchQuery"
              type="search"
              :placeholder="mobileSearchPlaceholder"
              class="w-full rounded-xl border border-black/10 dark:border-white/10 bg-white dark:bg-neutral-900 dark:text-white px-3 py-2.5 text-sm placeholder:text-neutral-400 focus:outline-none focus:ring-2 focus:ring-neutral-900/10 dark:focus:ring-white/10"
            />
          </div>
          <button
            type="button"
            class="relative shrink-0 inline-flex items-center gap-1 rounded-xl border border-black/10 dark:border-white/10 bg-white dark:bg-neutral-900 px-3 py-2.5 text-sm font-medium text-neutral-700 dark:text-neutral-200"
            :class="mobileSheetFilterCount > 0 ? 'border-amber-400 text-amber-800 dark:border-amber-500 dark:text-amber-200' : ''"
            aria-label="筛选"
            @click="filterSheetOpen = true"
          >
            <AppIcon name="sliders" class="w-[1.125rem] h-[1.125rem]" />
            筛选
            <span
              v-if="mobileSheetFilterCount > 0"
              class="absolute -top-1.5 -right-1.5 min-w-[1.125rem] h-[1.125rem] px-1 rounded-full bg-amber-500 text-white text-[10px] font-semibold flex items-center justify-center leading-none"
            >
              {{ mobileSheetFilterCount }}
            </span>
          </button>
        </div>

        <EnglishHotTagsBar class="mb-4 w-full !flex-none" />

        <CatalogFilterSheet
          :open="filterSheetOpen"
          :show-submit-entry="showSubmitEpisodeEntry"
          @close="filterSheetOpen = false"
        />
      </template>

      <!-- 桌面端：保持原样（Tab + 标签同行） -->
      <template v-else>
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
      </template>

      <div
        v-if="previewBanner"
        class="mb-4 rounded-xl border border-amber-200 dark:border-amber-800 bg-amber-50 dark:bg-amber-950/40 px-4 py-3 text-sm text-amber-900 dark:text-amber-200 flex flex-wrap items-center gap-x-2 gap-y-1"
      >
        <span>{{ previewBanner.text }}</span>
        <RouterLink v-if="previewBanner.showLogin" to="/login" class="font-medium underline">登录</RouterLink>
        <RouterLink v-if="previewBanner.showSignup" to="/signup" class="font-medium underline">注册</RouterLink>
        <template v-if="previewBanner.showPricing">
          <RouterLink to="/pricing" class="font-medium underline">开通会员</RouterLink>
          <span v-if="previewBanner.promo" class="text-amber-800/90 dark:text-amber-200/90">
            （{{ previewBanner.promo }}）
          </span>
        </template>
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
                :to="episodePath(ep)"
              />
            </div>
          </div>

          <div v-else class="rounded-xl border border-black/5 dark:border-white/10 overflow-hidden bg-white dark:bg-neutral-900">
            <div v-if="!store.episodes.length" class="text-center py-16 text-neutral-500">没有匹配的内容</div>
            <EpisodeListRow
              v-for="(ep, i) in store.episodes"
              :key="ep.video_id"
              :episode="ep"
              :row-index="i + 1"
              :to="episodePath(ep)"
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
    </div>
  </div>
</template>
