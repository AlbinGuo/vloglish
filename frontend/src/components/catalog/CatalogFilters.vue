<script setup lang="ts">
import { computed, watch } from 'vue'
import DifficultyStarsFilter from '@/components/catalog/DifficultyStarsFilter.vue'
import { useAuthStore } from '@/stores/auth'
import { useCatalogStore, type CatalogDurationFilter } from '@/stores/catalog'

const store = useCatalogStore()
const auth = useAuthStore()

const showFavoriteFilter = computed(() => auth.isMember)

const durationOptions: { value: Exclude<CatalogDurationFilter, ''>; label: string }[] = [
  { value: 'lt3', label: '小于3分钟' },
  { value: 'lt8', label: '3–8分钟' },
  { value: 'gt8', label: '大于8分钟' },
]

const pillIdle =
  'border-line bg-neutral-50 text-ink-soft hover:border-neutral-300 dark:bg-neutral-800/80 dark:hover:border-neutral-600'
const pillActive =
  'border-neutral-900 bg-ink text-ink-inverse dark:border-neutral-200'

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
  <div class="rounded-2xl border border-line-soft bg-card p-4 space-y-5">
    <div class="flex items-center justify-between gap-2">
      <div class="flex items-center gap-2 min-w-0">
        <span class="text-sm font-medium text-neutral-800 dark:text-neutral-100">筛选</span>
        <button
          v-if="store.hasActiveFilters"
          type="button"
          class="text-xs text-neutral-500 hover:text-ink-soft underline-offset-2 hover:underline"
          @click="store.clearFilters()"
        >
          清除
        </button>
      </div>
    </div>

    <div v-if="showFavoriteFilter" class="space-y-2">
      <div class="text-xs text-neutral-500">收藏</div>
      <div class="flex flex-wrap gap-1.5">
        <button
          type="button"
          class="text-xs px-2.5 py-1.5 rounded-full border transition cursor-pointer"
          :class="store.filters.learningStatus === 'favorite' ? pillActive : pillIdle"
          @click="store.setLearningStatus('favorite')"
        >
          收藏
        </button>
      </div>
    </div>

    <div class="space-y-2">
      <div class="text-xs text-neutral-500">难度</div>
      <DifficultyStarsFilter
        :active-level="store.filters.stars"
        @select="store.toggleStars"
      />
    </div>

    <div class="space-y-2">
      <div class="text-xs text-neutral-500">时长</div>
      <div class="flex flex-wrap gap-1.5">
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
    </div>
  </div>
</template>
