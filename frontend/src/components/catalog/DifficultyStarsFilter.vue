<script setup lang="ts">
import StarIcon from '@/components/icons/StarIcon.vue'
import { difficultyLevels } from '@/constants/difficultyStars'

defineProps<{
  activeLevel?: number
}>()

const emit = defineEmits<{
  select: [stars: number]
}>()

function tooltipAlign(stars: number) {
  if (stars <= 1) return 'left-0 translate-x-0'
  if (stars >= 5) return 'right-0 left-auto translate-x-0'
  return 'left-1/2 -translate-x-1/2'
}
</script>

<template>
  <div class="flex items-center justify-center gap-0.5">
    <div
      v-for="level in difficultyLevels"
      :key="level.stars"
      class="relative group"
    >
      <button
        type="button"
        class="p-0.5 rounded-md hover:bg-neutral-100 transition focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400/50"
        :aria-label="`筛选 ${level.stars} 星 ${level.label}`"
        @click="emit('select', level.stars)"
      >
        <StarIcon :active="activeLevel != null && level.stars <= activeLevel" />
      </button>

      <div
        role="tooltip"
        class="pointer-events-none absolute bottom-[calc(100%+8px)] z-50 w-[14rem] opacity-0 invisible translate-y-1 scale-95 transition-all duration-200 group-hover:opacity-100 group-hover:visible group-hover:translate-y-0 group-hover:scale-100"
        :class="tooltipAlign(level.stars)"
      >
        <div class="rounded-xl border border-neutral-800/10 bg-neutral-900 text-white shadow-lg px-3 py-2.5">
          <div class="flex items-center gap-1.5 mb-1.5">
            <span class="text-amber-400 text-xs">{{ '★'.repeat(level.stars) }}</span>
            <span class="text-xs font-semibold">{{ level.label }}</span>
          </div>
          <ul class="space-y-1">
            <li
              v-for="trait in level.traits"
              :key="trait"
              class="flex items-start gap-1.5 text-[11px] leading-snug text-neutral-300"
            >
              <span class="mt-1 h-1 w-1 shrink-0 rounded-full bg-amber-400/80" />
              <span>{{ trait }}</span>
            </li>
          </ul>
        </div>
      </div>
    </div>
  </div>
</template>
