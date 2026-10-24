<script setup lang="ts">
import { computed, onUnmounted, watch } from 'vue'
import { RouterLink } from 'vue-router'
import DifficultyStarsFilter from '@/components/catalog/DifficultyStarsFilter.vue'
import { useCatalogBrowseMode, type CatalogBrowseMode } from '@/composables/useCatalogBrowseMode'
import { useAuthStore } from '@/stores/auth'
import { useCatalogStore, type CatalogDurationFilter } from '@/stores/catalog'
import { useMyCorpusBadgeStore } from '@/stores/myCorpusBadge'
import { useSiteConfigStore } from '@/stores/siteConfig'
import { isMobileAppBuild } from '@/utils/platform'
import AppIcon from '@/components/AppIcon.vue'

const props = withDefaults(
  defineProps<{
    open: boolean
    showSubmitEntry?: boolean
    search?: string
    searchPlaceholder?: string
  }>(),
  { showSubmitEntry: true, search: '', searchPlaceholder: '搜索视频名称或作者' },
)

const emit = defineEmits<{ close: []; 'update:search': [value: string] }>()

const auth = useAuthStore()
const siteConfig = useSiteConfigStore()
const store = useCatalogStore()
const corpusBadge = useMyCorpusBadgeStore()
const { browseMode, setBrowseMode } = useCatalogBrowseMode()
const canUseMemberTools = computed(() => auth.isMember || siteConfig.memberToolsOpen)

const browseOptions: { value: CatalogBrowseMode; label: string }[] = [
  { value: 'all', label: '全部视频' },
  { value: 'author', label: '按作者' },
]

const durationOptions: { value: CatalogDurationFilter; label: string }[] = [
  { value: '', label: '全部' },
  { value: 'lt3', label: '小于3分钟' },
  { value: 'lt8', label: '3–8分钟' },
  { value: 'gt8', label: '大于8分钟' },
]

const showFavorite = computed(() => auth.isMember)
const showSubmitActions = computed(
  () => auth.isLoggedIn && props.showSubmitEntry && !isMobileAppBuild(),
)
const submitLink = computed(() => (canUseMemberTools.value ? '/english/submit' : '/pricing'))
const submitArticleLink = computed(() =>
  canUseMemberTools.value ? '/english/submit-article' : '/pricing',
)
const mySubmissionsLink = computed(() =>
  canUseMemberTools.value ? '/english/my-submissions' : '/pricing',
)

const segmentIdle =
  'text-ink-faint'
const segmentActive =
  'bg-card text-ink shadow-sm'
const pillIdle =
  'border-line bg-card text-ink-soft'
const pillActive =
  'border-neutral-900 bg-ink text-ink-inverse dark:border-neutral-200'

watch(
  () => props.open,
  (open) => {
    document.body.style.overflow = open ? 'hidden' : ''
    if (open && canUseMemberTools.value) void corpusBadge.refresh()
  },
)

onUnmounted(() => {
  document.body.style.overflow = ''
})

function onBrowse(mode: CatalogBrowseMode) {
  setBrowseMode(mode)
}

function onClose() {
  document.body.style.overflow = ''
  emit('close')
}

async function onReset() {
  if (browseMode.value !== 'all') setBrowseMode('all')
  await store.clearFilters()
}

function onSearchInput(e: Event) {
  emit('update:search', (e.target as HTMLInputElement).value)
}
</script>

<template>
  <Teleport to="body">
    <div
      v-if="open"
      class="fixed inset-0 z-[280] flex items-end justify-center bg-black/40"
      @click.self="onClose"
    >
      <div
        class="w-full max-w-lg max-h-[85dvh] overflow-y-auto rounded-t-2xl bg-card shadow-2xl pb-[env(safe-area-inset-bottom)]"
        role="dialog"
        aria-modal="true"
        aria-label="筛选"
        @click.stop
      >
        <div class="flex justify-center pt-3 pb-1">
          <div class="w-10 h-1 rounded-full bg-neutral-300 dark:bg-neutral-600" />
        </div>

        <div class="flex items-center justify-between px-4 pb-3 border-b border-black/5 dark:border-white/10">
          <h2 class="text-base font-semibold text-neutral-900 dark:text-neutral-100">筛选</h2>
          <div class="flex items-center gap-3">
            <button
              type="button"
              class="text-sm text-neutral-500 hover:text-ink-soft dark:text-neutral-400"
              @click="onReset"
            >
              重置
            </button>
            <button
              type="button"
              class="text-sm font-medium text-amber-700 dark:text-amber-400"
              @click="onClose"
            >
              完成
            </button>
          </div>
        </div>

        <div class="px-4 py-4 space-y-5">
          <section>
            <p class="text-xs font-medium text-neutral-500 mb-2">搜索</p>
            <div class="relative">
              <AppIcon
                name="search"
                class="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-neutral-400"
              />
              <input
                type="search"
                :value="props.search"
                :placeholder="props.searchPlaceholder"
                class="h-10 w-full rounded-full border border-black/10 bg-white pl-9 pr-3 text-sm text-neutral-900 placeholder:text-neutral-400 focus:outline-none focus:ring-2 focus:ring-neutral-900/10 dark:border-white/10 dark:bg-neutral-900 dark:text-white"
                @input="onSearchInput"
              />
            </div>
          </section>

          <section>
            <p class="text-xs font-medium text-neutral-500 mb-2">浏览方式</p>
            <div
              class="inline-flex w-full items-center gap-0.5 p-1 rounded-xl bg-neutral-100 dark:bg-neutral-800/80 border border-line-soft"
              role="group"
              aria-label="浏览方式"
            >
              <button
                v-for="opt in browseOptions"
                :key="opt.value"
                type="button"
                class="flex-1 px-3 py-2 rounded-lg text-sm font-medium transition"
                :class="browseMode === opt.value ? segmentActive : segmentIdle"
                @click="onBrowse(opt.value)"
              >
                {{ opt.label }}
              </button>
            </div>
          </section>

          <section>
            <p class="text-xs font-medium text-neutral-500 mb-2">难度</p>
            <DifficultyStarsFilter
              :active-level="store.filters.stars"
              @select="store.toggleStars"
            />
          </section>

          <section>
            <p class="text-xs font-medium text-neutral-500 mb-2">时长</p>
            <div class="flex flex-wrap gap-2" role="group" aria-label="时长">
              <button
                v-for="opt in durationOptions"
                :key="opt.label"
                type="button"
                class="text-xs px-3 py-1.5 rounded-full border transition"
                :class="store.filters.duration === opt.value ? pillActive : pillIdle"
                @click="store.setDuration(opt.value)"
              >
                {{ opt.label }}
              </button>
            </div>
          </section>

          <section v-if="showFavorite">
            <p class="text-xs font-medium text-neutral-500 mb-2">收藏</p>
            <button
              type="button"
              class="text-xs px-3 py-1.5 rounded-full border transition"
              :class="store.filters.learningStatus === 'favorite' ? pillActive : pillIdle"
              @click="store.setLearningStatus('favorite')"
            >
              只看收藏
            </button>
          </section>

          <section
            v-if="showSubmitActions"
            class="pt-1 border-t border-black/5 dark:border-white/10"
          >
            <p class="text-xs font-medium text-neutral-500 mb-2">投稿</p>
            <div class="flex items-center gap-3">
              <RouterLink
                :to="submitLink"
                class="inline-flex items-center gap-1 rounded-lg bg-amber-500 hover:bg-amber-600 text-white text-xs font-medium px-3 py-2 transition"
                @click="onClose"
              >
                <AppIcon name="plus" class="w-3.5 h-3.5" />
                上传视频
              </RouterLink>
              <RouterLink
                :to="submitArticleLink"
                class="inline-flex items-center gap-1 rounded-lg border border-amber-500/80 text-amber-700 dark:text-amber-400 text-xs font-medium px-3 py-2 transition"
                @click="onClose"
              >
                上传文章
              </RouterLink>
              <RouterLink
                :to="mySubmissionsLink"
                class="relative inline-flex items-center gap-1 text-sm text-neutral-600 hover:text-neutral-900 dark:text-neutral-400 dark:hover:text-neutral-200"
                @click="onClose"
              >
                我的语料库
                <span
                  v-if="canUseMemberTools && corpusBadge.hasNew"
                  class="px-1.5 py-0.5 rounded-md text-[10px] font-bold leading-none bg-red-500 text-white"
                >
                  新
                </span>
                <span
                  v-else-if="canUseMemberTools && corpusBadge.count > 0"
                  class="text-[11px] text-neutral-400"
                >
                  {{ corpusBadge.count }}
                </span>
              </RouterLink>
            </div>
          </section>
        </div>
      </div>
    </div>
  </Teleport>
</template>
