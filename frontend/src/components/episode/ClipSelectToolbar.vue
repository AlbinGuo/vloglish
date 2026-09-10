<script setup lang="ts">
import { computed } from 'vue'
import type { ClipSelectTarget } from '@/composables/useSubtitleClipSelect'

const props = defineProps<{
  target: ClipSelectTarget
  saving?: boolean
}>()

const emit = defineEmits<{
  save: []
  dismiss: []
}>()

const preview = computed(() => {
  const text = props.target.text
  return text.length > 42 ? `${text.slice(0, 40)}…` : text
})
</script>

<template>
  <Teleport to="body">
    <div
      data-clip-select-toolbar
      class="fixed z-[430] -translate-x-1/2 -translate-y-full pointer-events-auto"
      :style="{ top: `${target.top}px`, left: `${target.left}px` }"
    >
      <div
        class="flex items-center gap-1 rounded-full border border-sky-200/80 dark:border-sky-800/70 bg-white/95 dark:bg-neutral-900/95 shadow-lg shadow-sky-900/10 pl-3 pr-1 py-1 sm:py-1 max-w-[min(22rem,calc(100vw-1.5rem))]"
      >
        <span class="text-xs text-neutral-500 dark:text-neutral-400 truncate max-w-[8rem] sm:max-w-[12rem]">
          {{ preview }}
        </span>
        <button
          type="button"
          class="shrink-0 min-h-8 px-3.5 py-1.5 rounded-full text-xs font-semibold bg-sky-600 text-white hover:bg-sky-500 disabled:opacity-60 transition"
          :disabled="saving"
          @click="emit('save')"
        >
          {{ saving ? '保存中' : '加入摘录' }}
        </button>
        <button
          type="button"
          class="shrink-0 w-8 h-8 rounded-full text-neutral-400 hover:text-neutral-700 dark:hover:text-neutral-200 hover:bg-black/5 dark:hover:bg-white/10"
          aria-label="取消"
          @click="emit('dismiss')"
        >
          ×
        </button>
      </div>
    </div>
  </Teleport>
</template>
