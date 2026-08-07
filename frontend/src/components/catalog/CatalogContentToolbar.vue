<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { RouterLink } from 'vue-router'
import DifficultyStarsFilter from '@/components/catalog/DifficultyStarsFilter.vue'
import { useCatalogBrowseMode, type CatalogBrowseMode } from '@/composables/useCatalogBrowseMode'
import { useCatalogViewMode, type CatalogViewMode } from '@/composables/useCatalogViewMode'
import { useIsMobile } from '@/composables/useBreakpoint'
import { useAuthStore } from '@/stores/auth'
import { useCatalogStore, type CatalogDurationFilter } from '@/stores/catalog'
import { useMyCorpusBadgeStore } from '@/stores/myCorpusBadge'
import { isMobileAppBuild } from '@/utils/platform'

const props = withDefaults(
  defineProps<{
    showSubmitEntry?: boolean
  }>(),
  { showSubmitEntry: true },
)

const auth = useAuthStore()
const store = useCatalogStore()
const corpusBadge = useMyCorpusBadgeStore()
const isMobile = useIsMobile()
const { browseMode, setBrowseMode } = useCatalogBrowseMode()
const { viewMode, setViewMode } = useCatalogViewMode()

const searchQuery = ref(store.filters.search)
let searchTimer: ReturnType<typeof setTimeout> | undefined

const browseOptions: { value: CatalogBrowseMode; label: string }[] = [
  { value: 'all', label: '全部视频' },
  { value: 'author', label: '按作者' },
]

const viewOptions: { value: CatalogViewMode; label: string }[] = [
  { value: 'card', label: '卡片' },
  { value: 'list', label: '列表' },
]

const durationOptions: { value: Exclude<CatalogDurationFilter, ''>; label: string }[] = [
  { value: 'lt3', label: '小于3分钟' },
  { value: 'lt8', label: '3–8分钟' },
  { value: 'gt8', label: '大于8分钟' },
]

const durationAsSelect = computed(() => isMobile.value)

const showViewToggle = computed(
  () => auth.isLoggedIn && !isMobile.value && browseMode.value === 'all',
)

const showSearch = computed(() => browseMode.value === 'all')

const showFavoriteFilter = computed(() => auth.isMember)
const showSubmitActions = computed(
  () => auth.isLoggedIn && props.showSubmitEntry && !isMobileAppBuild(),
)
const submitLink = computed(() => (auth.isMember ? '/english/submit' : '/pricing'))
const submitArticleLink = computed(() => (auth.isMember ? '/english/submit-article' : '/pricing'))
const mySubmissionsLink = computed(() => (auth.isMember ? '/english/my-submissions' : '/pricing'))

const durationSelectValue = computed({
  get: () => store.filters.duration,
  set: (value: CatalogDurationFilter) => {
    void store.setDuration(value)
  },
})

const segmentIdle =
  'text-neutral-500 dark:text-neutral-400 hover:text-neutral-800 dark:hover:text-neutral-200'
const segmentActive =
  'bg-white dark:bg-neutral-900 text-neutral-900 dark:text-white shadow-sm'
const pillIdle =
  'border-black/10 bg-white text-neutral-700 hover:border-neutral-300 dark:border-white/10 dark:bg-neutral-900 dark:text-neutral-300 dark:hover:border-neutral-600'
const pillActive =
  'border-neutral-900 bg-neutral-900 text-white dark:border-neutral-200 dark:bg-neutral-100 dark:text-neutral-900'

watch(searchQuery, (value) => {
  clearTimeout(searchTimer)
  searchTimer = setTimeout(() => {
    const trimmed = value.trim()
    if (trimmed === store.filters.search) return
    void store.setSearch(trimmed)
  }, 300)
})

watch(
  () => store.filters.search,
  (value) => {
    if (value !== searchQuery.value.trim()) searchQuery.value = value
  },
)

watch(
  () => auth.isMember,
  (member) => {
    if (!member && store.filters.learningStatus === 'favorite') {
      store.filters.learningStatus = ''
      void store.loadEpisodes(true)
    }
    if (member) void corpusBadge.refresh()
    else corpusBadge.clear()
  },
)

onMounted(() => {
  if (store.filters.learningStatus === 'learned' || store.filters.learningStatus === 'unlearned') {
    store.filters.learningStatus = ''
    void store.loadEpisodes(true)
  }
  if (auth.isMember) void corpusBadge.refresh()
})
</script>

<template>
  <div class="flex flex-wrap items-center gap-x-2 gap-y-2">
    <div
      v-if="showSearch"
      class="w-full sm:w-auto sm:min-w-[14rem] sm:max-w-xs sm:flex-1"
    >
      <label class="sr-only" for="catalog-episode-search">搜索视频或作者</label>
      <input
        id="catalog-episode-search"
        v-model="searchQuery"
        type="search"
        placeholder="搜索视频名称或作者"
        class="w-full rounded-xl border border-black/10 dark:border-white/10 bg-white dark:bg-neutral-900 dark:text-white px-3 sm:px-4 py-2 text-sm placeholder:text-neutral-400 focus:outline-none focus:ring-2 focus:ring-neutral-900/10 dark:focus:ring-white/10"
      />
    </div>

    <div
      class="inline-flex items-center gap-0.5 p-1 rounded-xl bg-neutral-100 dark:bg-neutral-800/80 border border-black/5 dark:border-white/10"
      role="group"
      aria-label="浏览方式"
    >
      <button
        v-for="opt in browseOptions"
        :key="opt.value"
        type="button"
        class="px-3 py-1.5 rounded-lg text-sm font-medium transition cursor-pointer"
        :class="browseMode === opt.value ? segmentActive : segmentIdle"
        @click="setBrowseMode(opt.value)"
      >
        {{ opt.label }}
      </button>
    </div>

    <div
      v-if="showViewToggle"
      class="inline-flex items-center gap-0.5 p-1 rounded-xl bg-neutral-100 dark:bg-neutral-800/80 border border-black/5 dark:border-white/10"
      role="group"
      aria-label="列表样式"
    >
      <button
        v-for="opt in viewOptions"
        :key="opt.value"
        type="button"
        class="px-3 py-1.5 rounded-lg text-sm font-medium transition cursor-pointer"
        :class="viewMode === opt.value ? segmentActive : segmentIdle"
        @click="setViewMode(opt.value)"
      >
        {{ opt.label }}
      </button>
    </div>

    <div
      v-if="showFavoriteFilter"
      class="flex flex-wrap items-center gap-1.5"
      role="group"
      aria-label="收藏"
    >
      <button
        type="button"
        class="text-xs px-2.5 py-1.5 rounded-full border transition cursor-pointer"
        :class="store.filters.learningStatus === 'favorite' ? pillActive : pillIdle"
        @click="store.setLearningStatus('favorite')"
      >
        收藏
      </button>
    </div>

    <div class="flex items-center" aria-label="难度">
      <DifficultyStarsFilter
        :active-level="store.filters.stars"
        @select="store.toggleStars"
      />
    </div>

    <!-- 手机：时长下拉 + 右侧上传入口 -->
    <div
      v-if="durationAsSelect"
      class="flex items-center gap-2 w-full min-w-0"
    >
      <label class="sr-only" for="catalog-duration-select">时长</label>
      <select
        id="catalog-duration-select"
        v-model="durationSelectValue"
        class="min-w-0 flex-1 rounded-xl border border-black/10 dark:border-white/10 bg-white dark:bg-neutral-900 dark:text-white px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-neutral-900/10 dark:focus:ring-white/10"
      >
        <option value="">全部时长</option>
        <option
          v-for="opt in durationOptions"
          :key="opt.value"
          :value="opt.value"
        >
          {{ opt.label }}
        </option>
      </select>
      <div
        v-if="showSubmitActions"
        class="flex items-center gap-2 shrink-0"
      >
        <RouterLink
          :to="submitLink"
          class="inline-flex items-center gap-1 rounded-lg bg-amber-500 hover:bg-amber-600 text-white text-xs font-medium px-2.5 py-1.5 transition whitespace-nowrap"
        >
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-3.5 h-3.5 shrink-0" aria-hidden="true">
            <path d="M10.75 4.75a.75.75 0 0 0-1.5 0v4.5h-4.5a.75.75 0 0 0 0 1.5h4.5v4.5a.75.75 0 0 0 1.5 0v-4.5h4.5a.75.75 0 0 0 0-1.5h-4.5v-4.5Z" />
          </svg>
          上传视频
        </RouterLink>
        <RouterLink
          :to="submitArticleLink"
          class="inline-flex items-center gap-1 rounded-lg border border-amber-500/80 text-amber-700 dark:text-amber-400 text-xs font-medium px-2.5 py-1.5 transition whitespace-nowrap hover:bg-amber-50 dark:hover:bg-amber-950/40"
        >
          上传文章
        </RouterLink>
        <RouterLink
          :to="mySubmissionsLink"
          class="relative inline-flex items-center gap-1 text-xs text-neutral-500 hover:text-neutral-800 dark:text-neutral-400 dark:hover:text-neutral-200 transition whitespace-nowrap"
        >
          我的语料库
          <span
            v-if="auth.isMember && corpusBadge.hasNew"
            class="px-1.5 py-0.5 rounded-md text-[10px] font-bold leading-none bg-red-500 text-white"
          >
            新
          </span>
          <span
            v-else-if="auth.isMember && corpusBadge.count > 0"
            class="text-[10px] font-medium text-neutral-400 dark:text-neutral-500"
          >
            {{ corpusBadge.count }}
          </span>
        </RouterLink>
      </div>
    </div>

    <!-- 桌面：时长胶囊按钮 -->
    <div
      v-else
      class="flex flex-wrap items-center gap-1.5"
      role="group"
      aria-label="时长"
    >
      <button
        v-for="opt in durationOptions"
        :key="opt.value"
        type="button"
        class="text-xs px-2.5 py-1.5 rounded-full border transition cursor-pointer"
        :class="store.filters.duration === opt.value ? pillActive : pillIdle"
        @click="store.setDuration(opt.value)"
      >
        {{ opt.label }}
      </button>
    </div>

    <div
      v-if="showSubmitActions && !durationAsSelect"
      class="flex items-center gap-2 ml-auto shrink-0"
    >
      <RouterLink
        :to="submitLink"
        class="inline-flex items-center gap-1 rounded-lg bg-amber-500 hover:bg-amber-600 text-white text-xs font-medium px-2.5 py-1.5 transition"
      >
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-3.5 h-3.5 shrink-0" aria-hidden="true">
          <path d="M10.75 4.75a.75.75 0 0 0-1.5 0v4.5h-4.5a.75.75 0 0 0 0 1.5h4.5v4.5a.75.75 0 0 0 1.5 0v-4.5h4.5a.75.75 0 0 0 0-1.5h-4.5v-4.5Z" />
        </svg>
        上传视频
      </RouterLink>
      <RouterLink
        :to="submitArticleLink"
        class="inline-flex items-center gap-1 rounded-lg border border-amber-500/80 text-amber-700 dark:text-amber-400 text-xs font-medium px-2.5 py-1.5 transition hover:bg-amber-50 dark:hover:bg-amber-950/40"
      >
        上传文章
      </RouterLink>
      <RouterLink
        :to="mySubmissionsLink"
        class="relative inline-flex items-center gap-1 text-xs text-neutral-500 hover:text-neutral-800 dark:text-neutral-400 dark:hover:text-neutral-200 transition whitespace-nowrap"
      >
        我的语料库
        <span
          v-if="auth.isMember && corpusBadge.hasNew"
          class="px-1.5 py-0.5 rounded-md text-[10px] font-bold leading-none bg-red-500 text-white"
        >
          新
        </span>
        <span
          v-else-if="auth.isMember && corpusBadge.count > 0"
          class="text-[10px] font-medium text-neutral-400 dark:text-neutral-500"
        >
          {{ corpusBadge.count }}
        </span>
      </RouterLink>
    </div>
  </div>
</template>
