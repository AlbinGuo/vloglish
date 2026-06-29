<script setup lang="ts">
import type { SubtitleAlign, SubtitleDisplayMode } from '@/utils/subtitleHtml'

defineProps<{
  open: boolean
  subtitleMode: SubtitleDisplayMode
  subtitleAlign: SubtitleAlign
  modeButtons: { key: SubtitleDisplayMode; label: string }[]
  alignButtons: { key: SubtitleAlign; label: string }[]
}>()

const emit = defineEmits<{
  close: []
  'update:subtitleMode': [value: SubtitleDisplayMode]
  'update:subtitleAlign': [value: SubtitleAlign]
}>()
</script>

<template>
  <Teleport to="body">
    <div
      v-if="open"
      class="fixed inset-0 z-[280] flex items-end justify-center bg-black/40"
      @click.self="emit('close')"
    >
      <div
        class="w-full max-w-lg rounded-t-2xl bg-white dark:bg-neutral-900 shadow-2xl pb-[env(safe-area-inset-bottom)]"
        role="dialog"
        aria-modal="true"
        @click.stop
      >
        <div class="flex justify-center pt-3 pb-2">
          <div class="w-10 h-1 rounded-full bg-neutral-300 dark:bg-neutral-600" />
        </div>
        <div class="px-4 pb-4">
          <p class="text-sm font-medium mb-3">字幕模式</p>
          <div class="grid grid-cols-3 gap-2 mb-4">
            <button
              v-for="m in modeButtons"
              :key="m.key"
              type="button"
              class="px-3 py-2.5 rounded-xl text-sm border transition-colors"
              :class="
                subtitleMode === m.key
                  ? 'bg-neutral-900 text-white border-neutral-900 dark:bg-neutral-100 dark:text-neutral-900 dark:border-neutral-100'
                  : 'border-black/10 dark:border-white/10 hover:bg-neutral-50 dark:hover:bg-neutral-800'
              "
              @click="emit('update:subtitleMode', m.key)"
            >
              {{ m.label }}
            </button>
          </div>
          <p class="text-sm font-medium mb-2">对齐</p>
          <div class="flex gap-2">
            <button
              v-for="a in alignButtons"
              :key="a.key"
              type="button"
              class="flex-1 px-3 py-2.5 rounded-xl text-sm border transition-colors"
              :class="
                subtitleAlign === a.key
                  ? 'bg-neutral-800 text-white border-neutral-800 dark:bg-neutral-200 dark:text-neutral-900'
                  : 'border-black/10 dark:border-white/10'
              "
              @click="emit('update:subtitleAlign', a.key)"
            >
              {{ a.label }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </Teleport>
</template>
