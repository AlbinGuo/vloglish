<script setup lang="ts">
import { ref, watch } from 'vue'
import { useCatalogStore, type CatalogDurationFilter } from '@/stores/catalog'

const store = useCatalogStore()
const query = ref(store.filters.search)

const durationOptions: { value: Exclude<CatalogDurationFilter, ''>; label: string }[] = [
  { value: 'lt3', label: '<3分钟' },
  { value: 'lt8', label: '3–8分钟' },
  { value: 'gt8', label: '>8分钟' },
]

let debounceTimer: ReturnType<typeof setTimeout> | undefined

watch(query, (value) => {
  clearTimeout(debounceTimer)
  debounceTimer = setTimeout(() => {
    const trimmed = value.trim()
    if (trimmed === store.filters.search) return
    store.setSearch(trimmed)
  }, 300)
})

watch(
  () => store.filters.search,
  (value) => {
    if (value !== query.value.trim()) query.value = value
  },
)
</script>

<template>
  <div
    class="flex flex-wrap items-center gap-3 px-4 py-3 border-b border-black/5 dark:border-white/10 bg-neutral-50/80 dark:bg-neutral-800/50 rounded-t-xl"
  >
    <div class="relative flex-1 min-w-[12rem]">
      <input
        v-model="query"
        type="search"
        placeholder="搜索标题或作者"
        class="w-full rounded-lg border border-black/10 dark:border-white/10 bg-white dark:bg-neutral-900 dark:text-white px-3 py-2 text-sm placeholder:text-neutral-400 focus:outline-none focus:ring-2 focus:ring-neutral-900/10 dark:focus:ring-white/10"
      />
    </div>

    <div class="flex flex-wrap items-center gap-1.5 shrink-0" role="group" aria-label="时长">
      <button
        v-for="opt in durationOptions"
        :key="opt.value"
        type="button"
        class="text-xs px-2.5 py-1.5 rounded-full border transition cursor-pointer"
        :class="
          store.filters.duration === opt.value
            ? 'border-neutral-900 bg-neutral-900 text-white dark:border-neutral-200 dark:bg-neutral-100 dark:text-neutral-900'
            : 'border-black/10 bg-white text-neutral-700 hover:border-neutral-300 dark:border-white/10 dark:bg-neutral-900 dark:text-neutral-300 dark:hover:border-neutral-600'
        "
        @click="store.setDuration(opt.value)"
      >
        {{ opt.label }}
      </button>
    </div>
  </div>
</template>
