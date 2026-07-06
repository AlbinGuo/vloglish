<script setup lang="ts">
import {
  useReadingSettings,
  type ReadingLayoutMode,
  type ReadingWordHighlightStyle,
} from '@/composables/useReadingSettings'

defineEmits<{ close: [] }>()

const { wordHighlightStyle, layoutMode, setWordHighlightStyle, setLayoutMode } = useReadingSettings()

const highlightOptions: { key: ReadingWordHighlightStyle; label: string; desc: string }[] = [
  { key: 'color', label: '纯文字颜色', desc: '仅改变词汇文字颜色，不加下划线' },
  { key: 'color-underline', label: '颜色 + 下划线', desc: '彩色文字并带下划线标注' },
]

const layoutOptions: { key: ReadingLayoutMode; label: string; desc: string }[] = [
  { key: 'dual', label: '双栏对照', desc: '英文与中文左右分列显示（桌面端）' },
  { key: 'single', label: '单栏堆叠', desc: '英文在上、中文在下，逐段阅读' },
]

const optionSelectedClass = 'border-neutral-900 bg-neutral-50 dark:border-neutral-400 dark:bg-neutral-800'
const optionDefaultClass =
  'border-black/8 hover:border-black/15 hover:bg-neutral-50/50 dark:border-white/10 dark:hover:border-white/20 dark:hover:bg-neutral-800/50'
</script>

<template>
  <div class="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-black/40 p-0 sm:p-4" @click.self="$emit('close')">
    <div
      class="bg-white dark:bg-neutral-900 rounded-t-2xl sm:rounded-2xl shadow-2xl shadow-black/15 dark:shadow-black/40 ring-1 ring-black/5 dark:ring-white/10 w-full sm:max-w-md p-6 max-h-[85vh] overflow-y-auto reading-settings-scroll-hide pb-[calc(1.5rem+env(safe-area-inset-bottom))]"
      role="dialog"
      aria-modal="true"
      aria-labelledby="reading-settings-title"
    >
      <div class="flex justify-between items-center mb-5">
        <h3 id="reading-settings-title" class="text-lg font-semibold">阅读设置</h3>
        <button
          type="button"
          class="text-neutral-400 hover:text-black dark:hover:text-white text-xl leading-none"
          aria-label="关闭"
          @click="$emit('close')"
        >
          ×
        </button>
      </div>

      <section class="mb-6">
        <h4 class="text-sm font-medium text-neutral-800 dark:text-neutral-200 mb-3">词汇高亮</h4>
        <div class="space-y-2">
          <label
            v-for="opt in highlightOptions"
            :key="opt.key"
            class="flex items-start gap-3 p-3 rounded-xl border cursor-pointer transition-colors"
            :class="wordHighlightStyle === opt.key ? optionSelectedClass : optionDefaultClass"
          >
            <input
              type="radio"
              name="reading-word-highlight"
              class="mt-1 shrink-0"
              :checked="wordHighlightStyle === opt.key"
              @change="setWordHighlightStyle(opt.key)"
            />
            <span>
              <span class="block text-sm font-medium">{{ opt.label }}</span>
              <span class="block text-xs text-neutral-500 dark:text-neutral-400 mt-0.5">{{ opt.desc }}</span>
            </span>
          </label>
        </div>
      </section>

      <section>
        <h4 class="text-sm font-medium text-neutral-800 dark:text-neutral-200 mb-3">阅读布局</h4>
        <div class="space-y-2">
          <label
            v-for="opt in layoutOptions"
            :key="opt.key"
            class="flex items-start gap-3 p-3 rounded-xl border cursor-pointer transition-colors"
            :class="layoutMode === opt.key ? optionSelectedClass : optionDefaultClass"
          >
            <input
              type="radio"
              name="reading-layout-mode"
              class="mt-1 shrink-0"
              :checked="layoutMode === opt.key"
              @change="setLayoutMode(opt.key)"
            />
            <span>
              <span class="block text-sm font-medium">{{ opt.label }}</span>
              <span class="block text-xs text-neutral-500 dark:text-neutral-400 mt-0.5">{{ opt.desc }}</span>
            </span>
          </label>
        </div>
      </section>
    </div>
  </div>
</template>

<style scoped>
.reading-settings-scroll-hide {
  scrollbar-width: none;
  -ms-overflow-style: none;
}

.reading-settings-scroll-hide::-webkit-scrollbar {
  display: none;
}
</style>
