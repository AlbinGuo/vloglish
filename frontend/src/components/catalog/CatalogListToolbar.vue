<script setup lang="ts">
import { ref, watch } from 'vue'
import { accentOptions } from '@/constants/accentOptions'
import { useCatalogStore } from '@/stores/catalog'

const store = useCatalogStore()
const query = ref(store.filters.search)

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
    class="flex flex-wrap items-center gap-3 px-4 py-3 border-b border-black/5 bg-neutral-50/80 rounded-t-xl"
  >
    <div class="relative flex-1 min-w-[12rem]">
      <input
        v-model="query"
        type="search"
        placeholder="搜索标题或作者"
        class="w-full rounded-lg border border-black/10 bg-white px-3 py-2 text-sm placeholder:text-neutral-400 focus:outline-none focus:ring-2 focus:ring-neutral-900/10"
      />
    </div>

    <div class="flex items-center gap-1.5 shrink-0">
      <button
        v-for="opt in accentOptions"
        :key="opt.value"
        type="button"
        class="p-1.5 rounded-lg transition"
        :class="
          store.filters.accents.includes(opt.value)
            ? 'bg-neutral-900/10 ring-1 ring-neutral-900/15'
            : 'opacity-50 hover:opacity-100 hover:bg-neutral-100'
        "
        :title="opt.label"
        @click="store.toggleAccent(opt.value)"
      >
        <img :src="opt.icon" :alt="opt.label" class="w-6 h-6 object-contain" />
      </button>
    </div>
  </div>
</template>
