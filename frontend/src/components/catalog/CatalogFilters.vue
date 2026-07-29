<script setup lang="ts">
import { computed, watch } from 'vue'
import { accentOptions } from '@/constants/accentOptions'
import DifficultyStarsFilter from '@/components/catalog/DifficultyStarsFilter.vue'
import { useAuthStore } from '@/stores/auth'
import { useCatalogStore } from '@/stores/catalog'

const store = useCatalogStore()
const auth = useAuthStore()

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

const pillIdle =
  'border-black/10 bg-neutral-50 text-neutral-700 hover:border-neutral-300 dark:border-white/10 dark:bg-neutral-800/80 dark:text-neutral-300 dark:hover:border-neutral-600'
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
  <div class="rounded-2xl border border-black/5 dark:border-white/10 bg-white dark:bg-neutral-900 p-4 space-y-5">
    <div class="flex items-center justify-between gap-2">
      <div class="flex items-center gap-2 min-w-0">
        <span class="text-sm font-medium text-neutral-800 dark:text-neutral-100">筛选</span>
        <button
          v-if="store.hasActiveFilters"
          type="button"
          class="text-xs text-neutral-500 hover:text-neutral-800 dark:hover:text-neutral-200 underline-offset-2 hover:underline"
          @click="store.clearFilters()"
        >
          清除
        </button>
      </div>
      <button
        type="button"
        class="shrink-0 text-xs px-2.5 py-1 rounded-lg text-neutral-600 dark:text-neutral-300 hover:bg-neutral-100 dark:hover:bg-neutral-800 transition"
        :title="store.filters.ordering === 'created_at' ? '当前：最新优先' : '当前：最早优先'"
        @click="store.toggleOrdering()"
      >
        {{ store.filters.ordering === 'created_at' ? '最新' : '最早' }}
      </button>
    </div>

    <div v-if="auth.isLoggedIn" class="space-y-2">
      <div class="text-xs text-neutral-500">学习状态</div>
      <div class="flex flex-wrap gap-1.5">
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
    </div>

    <div class="space-y-2">
      <div class="text-xs text-neutral-500">难度</div>
      <DifficultyStarsFilter
        :active-level="store.filters.stars"
        @select="store.toggleStars"
      />
    </div>

    <div class="space-y-2">
      <div class="text-xs text-neutral-500">口音</div>
      <div class="flex flex-wrap gap-1.5">
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
    </div>
  </div>
</template>
