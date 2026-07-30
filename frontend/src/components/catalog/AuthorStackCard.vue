<script setup lang="ts">
import { computed, ref } from 'vue'
import { RouterLink } from 'vue-router'
import CoverStack from '@/components/catalog/CoverStack.vue'
import { accentIconFor } from '@/constants/accentOptions'
import type { AuthorCatalogItem } from '@/types'

const props = defineProps<{
  author: AuthorCatalogItem
}>()

const accentIcon = computed(() => accentIconFor(props.author.accent))
const genderLabel = computed(() => (props.author.gender === 'f' ? '女' : '男'))
const stackActive = ref(false)
</script>

<template>
  <RouterLink
    :to="`/english/authors/${author.id}`"
    class="group relative block rounded-xl border border-black/5 dark:border-white/10 bg-white dark:bg-neutral-900 p-2 sm:p-2.5 transition-[box-shadow,border-color,z-index] duration-300 hover:shadow-lg hover:border-black/10 dark:hover:border-white/20 hover:z-20"
    @pointerenter="stackActive = true"
    @pointerleave="stackActive = false"
    @focusin="stackActive = true"
    @focusout="stackActive = false"
  >
    <CoverStack
      :covers="author.covers"
      :count="author.episode_count"
      :alt="author.name"
      :active="stackActive"
    />

    <div class="min-w-0 text-center">
      <h3 class="font-semibold text-sm sm:text-base truncate group-hover:text-amber-800 dark:group-hover:text-amber-400 transition-colors">
        {{ author.name }}
      </h3>
      <p class="mt-1 flex items-center justify-center gap-1.5 text-xs text-neutral-500 dark:text-neutral-400">
        <span v-if="author.nationality" class="text-sm leading-none" title="国籍">{{ author.nationality }}</span>
        <img
          v-if="accentIcon"
          :src="accentIcon"
          :alt="author.accent"
          class="w-3.5 h-3.5 object-contain rounded-full border border-black/10 dark:border-white/20"
        />
        <span>{{ author.accent || '口音未标注' }}</span>
        <span class="text-neutral-300 dark:text-neutral-600">·</span>
        <span>{{ genderLabel }}</span>
      </p>
      <p class="mt-1 text-[11px] text-neutral-400">{{ author.episode_count }} 个视频</p>
    </div>
  </RouterLink>
</template>
