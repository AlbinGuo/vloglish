<script setup lang="ts">
import StarIcon from '@/components/icons/StarIcon.vue'
import { difficultyLevels } from '@/constants/difficultyStars'

const props = withDefaults(
  defineProps<{
    modelValue: number
    readonly?: boolean
    sizeClass?: string
  }>(),
  {
    readonly: false,
    sizeClass: 'w-6 h-6',
  },
)

const emit = defineEmits<{
  'update:modelValue': [value: number]
}>()

function tooltipAlign(stars: number) {
  if (stars <= 1) return 'left-0 translate-x-0'
  if (stars >= 5) return 'right-0 left-auto translate-x-0'
  return 'left-1/2 -translate-x-1/2'
}

function select(stars: number) {
  if (props.readonly) return
  emit('update:modelValue', stars)
}
</script>

<template>
  <div class="flex items-center gap-1">
    <div
      v-for="level in difficultyLevels"
      :key="level.stars"
      class="relative group"
    >
      <button
        type="button"
        class="p-1 rounded-lg transition focus:outline-none focus-visible:ring-2 focus-visible:ring-amber-400/60"
        :class="readonly ? 'cursor-default' : 'hover:bg-amber-50 hover:scale-110'"
        :disabled="readonly"
        :aria-label="`${level.stars} 星 ${level.label}`"
        @click="select(level.stars)"
      >
        <StarIcon
          :active="level.stars <= modelValue"
          :size-class="sizeClass"
          active-class="text-amber-500 drop-shadow-sm"
          inactive-class="text-neutral-300 group-hover:text-amber-300"
        />
      </button>

      <div
        role="tooltip"
        class="pointer-events-none absolute bottom-[calc(100%+10px)] z-50 w-[15.5rem] opacity-0 invisible translate-y-1 scale-95 transition-all duration-200 group-hover:opacity-100 group-hover:visible group-hover:translate-y-0 group-hover:scale-100"
        :class="tooltipAlign(level.stars)"
      >
        <div
          class="rounded-xl border border-neutral-800/10 bg-neutral-900 text-white shadow-xl shadow-black/20 px-3.5 py-3"
        >
          <div class="flex items-center gap-2 mb-2">
            <span class="text-amber-400 text-sm tracking-wide">
              {{ '★'.repeat(level.stars) }}
            </span>
            <span class="text-sm font-semibold">{{ level.label }}</span>
            <span class="text-xs text-neutral-400 ml-auto">{{ level.stars }} 星</span>
          </div>
          <ul class="space-y-1.5">
            <li
              v-for="trait in level.traits"
              :key="trait"
              class="flex items-start gap-2 text-xs leading-relaxed text-neutral-200"
            >
              <span class="mt-1.5 h-1 w-1 shrink-0 rounded-full bg-amber-400/90" />
              <span>{{ trait }}</span>
            </li>
          </ul>
        </div>
        <div
          class="absolute top-full h-2 w-2 rotate-45 bg-neutral-900 border-r border-b border-neutral-800/10"
          :class="level.stars <= 1 ? 'left-4' : level.stars >= 5 ? 'right-4' : 'left-1/2 -translate-x-1/2'"
        />
      </div>
    </div>
  </div>
</template>
