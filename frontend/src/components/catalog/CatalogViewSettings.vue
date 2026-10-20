<script setup lang="ts">
import { useCatalogBrowseMode, type CatalogBrowseMode } from '@/composables/useCatalogBrowseMode'
import { useCatalogViewMode, type CatalogViewMode } from '@/composables/useCatalogViewMode'

const { viewMode, setViewMode } = useCatalogViewMode()
const { browseMode, setBrowseMode } = useCatalogBrowseMode()

const browseOptions: { value: CatalogBrowseMode; label: string }[] = [
  { value: 'all', label: '显示全部视频' },
  { value: 'author', label: '按作者分类' },
]

const viewOptions: { value: CatalogViewMode; label: string }[] = [
  { value: 'card', label: '卡片视图' },
  { value: 'list', label: '列表视图' },
]
</script>

<template>
  <div class="rounded-2xl border border-line-soft bg-card p-4 space-y-5">
    <div>
      <span class="text-sm font-medium block mb-3">设置</span>
      <div class="grid grid-cols-1 gap-2">
        <button
          v-for="opt in browseOptions"
          :key="opt.value"
          type="button"
          class="w-full text-sm px-3 py-2 rounded-lg border text-center transition cursor-pointer"
          :class="
            browseMode === opt.value
              ? 'border-neutral-900 bg-ink text-ink-inverse dark:border-neutral-300'
              : 'border-line bg-neutral-50 hover:border-neutral-300 text-ink-soft dark:bg-neutral-800 dark:hover:border-neutral-600'
          "
          @click="setBrowseMode(opt.value)"
        >
          {{ opt.label }}
        </button>
      </div>
    </div>

    <div v-if="browseMode === 'all'">
      <span class="text-xs text-neutral-500 dark:text-neutral-400 block mb-2">列表样式</span>
      <div class="flex gap-2">
        <button
          v-for="opt in viewOptions"
          :key="opt.value"
          type="button"
          class="flex-1 text-sm px-3 py-2 rounded-lg border text-center transition cursor-pointer"
          :class="
            viewMode === opt.value
              ? 'border-neutral-900 bg-ink text-ink-inverse dark:border-neutral-300'
              : 'border-line bg-neutral-50 hover:border-neutral-300 text-ink-soft dark:bg-neutral-800 dark:hover:border-neutral-600'
          "
          @click="setViewMode(opt.value)"
        >
          {{ opt.label }}
        </button>
      </div>
    </div>
  </div>
</template>
