<script setup lang="ts">
import StarIcon from '@/components/icons/StarIcon.vue'
import { accentOptions } from '@/constants/accentOptions'
import { useCatalogStore } from '@/stores/catalog'

const store = useCatalogStore()
</script>
<template>
  <div class="rounded-2xl border border-black/5 bg-white p-4 space-y-4">
    <div class="flex items-center justify-between">
      <span class="text-sm font-medium">筛选条件</span>
      <button
        type="button"
        class="text-xs px-2 py-1 rounded-lg border border-black/10 hover:bg-neutral-50"
        @click="store.toggleOrdering()"
      >
        {{ store.filters.ordering === 'index' ? '倒序' : '正序' }}
      </button>
    </div>

    <div>
      <div class="text-xs text-neutral-500 mb-2">难度</div>
      <div class="flex items-center justify-center gap-0.5">
        <button
          v-for="n in 5"
          :key="n"
          type="button"
          class="p-0.5 rounded-md hover:bg-neutral-100 transition"
          :title="`${n} 星`"
          @click="store.toggleStars(n)"
        >
          <StarIcon :active="store.filters.stars != null && n <= store.filters.stars" />
        </button>
      </div>
    </div>

    <div>
      <div class="text-xs text-neutral-500 mb-2">口音</div>
      <div class="flex flex-wrap items-center justify-center gap-4">
        <label
          v-for="opt in accentOptions"
          :key="opt.value"
          class="flex items-center gap-2 text-sm cursor-pointer"
        >
          <img :src="opt.icon" :alt="opt.label" class="w-5 h-5 shrink-0 object-contain" />
          <input
            type="checkbox"
            class="rounded border-neutral-300 text-neutral-900 focus:ring-neutral-400"
            :checked="store.filters.accents.includes(opt.value)"
            @change="store.toggleAccent(opt.value)"
          />
          <span>{{ opt.label }}</span>
        </label>
      </div>
    </div>
    <div>
      <div class="text-xs text-neutral-500 mb-2">主题标签</div>
      <div class="flex flex-wrap gap-1.5 max-h-48 overflow-y-auto pr-1">
        <button
          v-for="t in store.tags"
          :key="t.id"
          type="button"
          class="text-xs px-2 py-1 rounded-full border transition"
          :class="
            store.filters.tagIds.includes(t.id)
              ? 'border-neutral-900 bg-neutral-900 text-white'
              : 'border-black/10 bg-neutral-50 hover:border-neutral-300'
          "
          @click="store.toggleTag(t.id)"
        >
          {{ t.name }}
        </button>
      </div>
    </div>
  </div>
</template>
