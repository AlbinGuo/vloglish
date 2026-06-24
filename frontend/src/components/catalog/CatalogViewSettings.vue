<script setup lang="ts">
import { useCatalogViewMode, type CatalogViewMode } from '@/composables/useCatalogViewMode'

const { viewMode, setViewMode } = useCatalogViewMode()

const options: { value: CatalogViewMode; label: string }[] = [
  { value: 'card', label: '卡片视图' },
  { value: 'list', label: '列表视图' },
]
</script>

<template>
  <div class="rounded-2xl border border-black/5 bg-white p-4">
    <span class="text-sm font-medium block mb-4">设置</span>
    <div class="flex gap-2">
      <button
        v-for="opt in options"
        :key="opt.value"
        type="button"
        class="flex-1 text-sm px-3 py-2 rounded-lg border text-center transition"
        :class="
          viewMode === opt.value
            ? 'border-neutral-900 bg-neutral-900 text-white'
            : 'border-black/10 bg-neutral-50 hover:border-neutral-300 text-neutral-700'
        "
        @click="setViewMode(opt.value)"
      >
        {{ opt.label }}
      </button>
    </div>
  </div>
</template>
