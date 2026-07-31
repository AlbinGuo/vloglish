<script setup lang="ts">
import { computed, ref } from 'vue'
import { RouterLink } from 'vue-router'
import CoverStack from '@/components/catalog/CoverStack.vue'
import type { SeriesSummary } from '@/types'

const props = defineProps<{
  series: SeriesSummary
}>()

const covers = computed(() => {
  if (props.series.covers?.length) return props.series.covers
  return props.series.cover ? [props.series.cover] : []
})

const stackActive = ref(false)
</script>

<template>
  <RouterLink
    :to="`/english/series/${series.slug}`"
    class="group relative block rounded-xl border border-black/5 dark:border-white/10 bg-white dark:bg-neutral-900 p-2 sm:p-2.5 transition-[box-shadow,border-color,z-index] duration-300 hover:shadow-lg hover:border-black/10 dark:hover:border-white/20 hover:z-20"
    @pointerenter="stackActive = true"
    @pointerleave="stackActive = false"
    @focusin="stackActive = true"
    @focusout="stackActive = false"
  >
    <CoverStack
      :covers="covers"
      :count="series.episode_count"
      :alt="series.title"
      :active="stackActive"
    />

    <div class="min-w-0 text-center">
      <h3 class="font-semibold text-sm sm:text-base truncate group-hover:text-amber-800 dark:group-hover:text-amber-400 transition-colors">
        {{ series.title }}
      </h3>
      <p class="mt-1 text-xs text-neutral-500 dark:text-neutral-400">
        共 {{ series.episode_count }} 集 · 按序学习
        <span v-if="series.requires_membership" class="text-amber-700 dark:text-amber-400"> · 会员</span>
      </p>
      <p
        v-if="series.summary"
        class="mt-1.5 text-[11px] text-neutral-500 dark:text-neutral-400 line-clamp-2 leading-relaxed"
      >
        {{ series.summary }}
      </p>
    </div>
  </RouterLink>
</template>
