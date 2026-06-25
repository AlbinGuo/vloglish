<script setup lang="ts">
import { accentOptions } from '@/constants/accentOptions'
import DifficultyStarsFilter from '@/components/catalog/DifficultyStarsFilter.vue'
import { useAuthStore } from '@/stores/auth'
import { useCatalogStore } from '@/stores/catalog'

const store = useCatalogStore()
const auth = useAuthStore()

const learningFilters = [
  { key: 'learned' as const, label: '已看' },
  { key: 'unlearned' as const, label: '未看' },
  { key: 'favorite' as const, label: '收藏' },
]
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
        {{ store.filters.ordering === 'created_at' ? '最新优先' : '最早优先' }}
      </button>
    </div>

    <div v-if="auth.isLoggedIn">
      <div class="text-xs text-neutral-500 mb-2">学习状态</div>
      <div class="flex flex-wrap gap-1.5">
        <button
          v-for="f in learningFilters"
          :key="f.key"
          type="button"
          class="text-xs px-2.5 py-1 rounded-full border transition"
          :class="
            store.filters.learningStatus === f.key
              ? 'border-neutral-900 bg-neutral-900 text-white'
              : 'border-black/10 bg-neutral-50 hover:border-neutral-300'
          "
          @click="store.setLearningStatus(f.key)"
        >
          {{ f.label }}
        </button>
      </div>
    </div>

    <div>
      <div class="text-xs text-neutral-500 mb-2">难度</div>
      <DifficultyStarsFilter
        :active-level="store.filters.stars"
        @select="store.toggleStars"
      />
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
