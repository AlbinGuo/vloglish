<script setup lang="ts">
import { useCatalogBrowseMode, type CatalogBrowseMode } from '@/composables/useCatalogBrowseMode'

const { browseMode, setBrowseMode } = useCatalogBrowseMode()

const options: { value: CatalogBrowseMode; label: string }[] = [
  { value: 'all', label: '全部视频' },
  { value: 'author', label: '按作者' },
]
</script>

<template>
  <div class="flex gap-2">
    <button
      v-for="opt in options"
      :key="opt.value"
      type="button"
      class="flex-1 text-sm px-3 py-2 rounded-lg border text-center transition cursor-pointer"
      :class="
        browseMode === opt.value
          ? 'border-neutral-900 bg-ink text-ink-inverse dark:border-neutral-300'
          : 'border-line bg-card hover:border-neutral-300 text-ink-soft dark:hover:border-neutral-600'
      "
      @click="setBrowseMode(opt.value)"
    >
      {{ opt.label }}
    </button>
  </div>
</template>
