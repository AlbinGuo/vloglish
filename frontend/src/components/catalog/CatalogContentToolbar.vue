<script setup lang="ts">
import { computed, watch } from 'vue'
import { RouterLink } from 'vue-router'
import { accentOptions } from '@/constants/accentOptions'
import DifficultyStarsFilter from '@/components/catalog/DifficultyStarsFilter.vue'
import { useCatalogBrowseMode, type CatalogBrowseMode } from '@/composables/useCatalogBrowseMode'
import { useCatalogViewMode, type CatalogViewMode } from '@/composables/useCatalogViewMode'
import { useIsMobile } from '@/composables/useBreakpoint'
import { useAuthStore } from '@/stores/auth'
import { useCatalogStore } from '@/stores/catalog'

const props = withDefaults(
  defineProps<{
    showSubmitEntry?: boolean
  }>(),
  { showSubmitEntry: true },
)

const auth = useAuthStore()
const store = useCatalogStore()
const isMobile = useIsMobile()
const { browseMode, setBrowseMode } = useCatalogBrowseMode()
const { viewMode, setViewMode } = useCatalogViewMode()

const browseOptions: { value: CatalogBrowseMode; label: string }[] = [
  { value: 'all', label: '全部视频' },
  { value: 'author', label: '按作者' },
]

const viewOptions: { value: CatalogViewMode; label: string }[] = [
  { value: 'card', label: '卡片' },
  { value: 'list', label: '列表' },
]

const learningFilters = computed(() => {
  const items = [
    { key: 'learned' as const, label: '已看' },
    { key: 'unlearned' as const, label: '未看' },
  ]
  if (auth.isMember) {
    items.push({ key: 'favorite' as const, label: '收藏' })
  }
  return items
})

const showViewToggle = computed(
  () => auth.isLoggedIn && !isMobile.value && browseMode.value === 'all',
)

const showMemberActions = computed(() => auth.isMember && props.showSubmitEntry)

const segmentIdle =
  'text-neutral-500 dark:text-neutral-400 hover:text-neutral-800 dark:hover:text-neutral-200'
const segmentActive =
  'bg-white dark:bg-neutral-900 text-neutral-900 dark:text-white shadow-sm'
const pillIdle =
  'border-black/10 bg-white text-neutral-700 hover:border-neutral-300 dark:border-white/10 dark:bg-neutral-900 dark:text-neutral-300 dark:hover:border-neutral-600'
const pillActive =
  'border-neutral-900 bg-neutral-900 text-white dark:border-neutral-200 dark:bg-neutral-100 dark:text-neutral-900'

watch(
  () => auth.isMember,
  (member) => {
    if (!member && store.filters.learningStatus === 'favorite') {
      store.filters.learningStatus = ''
      void store.loadEpisodes(true)
    }
  },
)
</script>

<template>
  <div class="flex flex-wrap items-center gap-x-2 gap-y-2">
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
      v-if="auth.isLoggedIn"
      class="flex flex-wrap items-center gap-1.5"
      role="group"
      aria-label="学习状态"
    >
      <button
        v-for="f in learningFilters"
        :key="f.key"
        type="button"
        class="text-xs px-2.5 py-1.5 rounded-full border transition cursor-pointer"
        :class="store.filters.learningStatus === f.key ? pillActive : pillIdle"
        @click="store.setLearningStatus(f.key)"
      >
        {{ f.label }}
      </button>
    </div>

    <div class="flex items-center" aria-label="难度">
      <DifficultyStarsFilter
        :active-level="store.filters.stars"
        @select="store.toggleStars"
      />
    </div>

    <div class="flex flex-wrap items-center gap-1.5" role="group" aria-label="口音">
      <button
        v-for="opt in accentOptions"
        :key="opt.value"
        type="button"
        class="inline-flex items-center gap-1.5 text-xs px-2.5 py-1.5 rounded-full border transition cursor-pointer"
        :class="store.filters.accents.includes(opt.value) ? pillActive : pillIdle"
        @click="store.toggleAccent(opt.value)"
      >
        <img :src="opt.icon" :alt="opt.label" class="w-4 h-4 shrink-0 object-contain" />
        <span>{{ opt.label }}</span>
      </button>
    </div>

    <button
      type="button"
      class="text-xs px-2.5 py-1.5 rounded-full border transition cursor-pointer"
      :class="pillIdle"
      :title="store.filters.ordering === 'created_at' ? '当前：最新优先' : '当前：最早优先'"
      @click="store.toggleOrdering()"
    >
      {{ store.filters.ordering === 'created_at' ? '最新' : '最早' }}
    </button>

    <button
      v-if="store.hasActiveFilters"
      type="button"
      class="text-xs text-neutral-500 hover:text-neutral-800 dark:hover:text-neutral-200 underline-offset-2 hover:underline px-1"
      @click="store.clearFilters()"
    >
      清除
    </button>

    <div
      v-if="showMemberActions"
      class="flex items-center gap-2 ml-auto shrink-0"
    >
      <RouterLink
        to="/english/submit"
        class="inline-flex items-center gap-1 rounded-lg bg-amber-500 hover:bg-amber-600 text-white text-xs font-medium px-2.5 py-1.5 transition"
      >
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-3.5 h-3.5 shrink-0" aria-hidden="true">
          <path d="M10.75 4.75a.75.75 0 0 0-1.5 0v4.5h-4.5a.75.75 0 0 0 0 1.5h4.5v4.5a.75.75 0 0 0 1.5 0v-4.5h4.5a.75.75 0 0 0 0-1.5h-4.5v-4.5Z" />
        </svg>
        上传视频
      </RouterLink>
      <RouterLink
        to="/english/my-submissions"
        class="text-xs text-neutral-500 hover:text-neutral-800 dark:text-neutral-400 dark:hover:text-neutral-200 transition whitespace-nowrap"
      >
        我的语料库
      </RouterLink>
    </div>
  </div>
</template>
