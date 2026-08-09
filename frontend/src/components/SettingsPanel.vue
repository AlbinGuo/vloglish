<script setup lang="ts">
import { useHighlightStyle, type HighlightStyle } from '@/composables/useHighlightStyle'
import { useTheme, type ThemeMode } from '@/composables/useTheme'
import { useIntensiveReadingMode } from '@/composables/useIntensiveReadingMode'
import { useVocabDanmaku } from '@/composables/useVocabDanmaku'
import type { SubtitleAlign } from '@/utils/subtitleHtml'

const props = defineProps<{
  subtitleAlign?: SubtitleAlign
}>()

const emit = defineEmits<{
  close: []
  'update:subtitleAlign': [value: SubtitleAlign]
}>()

const { highlightStyle, setHighlightStyle } = useHighlightStyle()
const { themeMode, setThemeMode } = useTheme()
const { intensiveMode, setIntensiveMode } = useIntensiveReadingMode()
const { vocabDanmakuEnabled, setVocabDanmakuEnabled } = useVocabDanmaku()

const themeOptions: { key: ThemeMode; label: string; desc: string }[] = [
  { key: 'light', label: '浅色', desc: '明亮界面，适合白天使用' },
  { key: 'dark', label: '深色', desc: '暗色界面，适合夜间学习' },
  { key: 'system', label: '跟随系统', desc: '自动匹配系统外观设置' },
]

const highlightOptions: { key: HighlightStyle; label: string; desc: string }[] = [
  { key: 'underline', label: '下划线', desc: '彩色下划线标注重点词汇' },
  { key: 'background', label: '背景色', desc: '浅色背景块标注重点词汇' },
]

const alignOptions: { key: SubtitleAlign; label: string; desc: string }[] = [
  { key: 'left', label: '左对齐', desc: '字幕靠左排列，适合对照阅读' },
  { key: 'center', label: '居中', desc: '字幕居中显示，适合沉浸跟读' },
]

const optionSelectedClass = 'border-neutral-900 bg-neutral-50 dark:border-neutral-400 dark:bg-neutral-800'
const optionDefaultClass =
  'border-black/8 hover:border-black/15 hover:bg-neutral-50/50 dark:border-white/10 dark:hover:border-white/20 dark:hover:bg-neutral-800/50'

const currentAlign = () => props.subtitleAlign ?? 'left'
</script>

<template>
  <div class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4" @click.self="emit('close')">
    <div
      class="bg-white dark:bg-neutral-900 rounded-2xl shadow-2xl shadow-black/15 dark:shadow-black/40 ring-1 ring-black/5 dark:ring-white/10 w-full max-w-md p-6 max-h-[85vh] overflow-y-auto settings-panel-scroll-hide"
    >
      <div class="flex justify-between items-center mb-5">
        <h3 class="text-lg font-semibold">设置</h3>
        <button
          type="button"
          class="text-neutral-400 hover:text-black dark:hover:text-white text-xl leading-none"
          aria-label="关闭"
          @click="emit('close')"
        >
          ×
        </button>
      </div>

      <section class="mb-6">
        <h4 class="text-sm font-medium text-neutral-800 dark:text-neutral-200 mb-3">外观主题</h4>
        <div class="space-y-2">
          <label
            v-for="opt in themeOptions"
            :key="opt.key"
            class="flex items-start gap-3 p-3 rounded-xl border cursor-pointer transition-colors"
            :class="themeMode === opt.key ? optionSelectedClass : optionDefaultClass"
          >
            <input
              type="radio"
              name="theme-mode"
              class="mt-1 shrink-0"
              :checked="themeMode === opt.key"
              @change="setThemeMode(opt.key)"
            />
            <span>
              <span class="block text-sm font-medium">{{ opt.label }}</span>
              <span class="block text-xs text-neutral-500 dark:text-neutral-400 mt-0.5">{{ opt.desc }}</span>
            </span>
          </label>
        </div>
      </section>

      <section class="mb-6">
        <h4 class="text-sm font-medium text-neutral-800 dark:text-neutral-200 mb-3">文字高亮样式</h4>
        <div class="space-y-2">
          <label
            v-for="opt in highlightOptions"
            :key="opt.key"
            class="flex items-start gap-3 p-3 rounded-xl border cursor-pointer transition-colors"
            :class="highlightStyle === opt.key ? optionSelectedClass : optionDefaultClass"
          >
            <input
              type="radio"
              name="highlight-style"
              class="mt-1 shrink-0"
              :checked="highlightStyle === opt.key"
              @change="setHighlightStyle(opt.key)"
            />
            <span>
              <span class="block text-sm font-medium">{{ opt.label }}</span>
              <span class="block text-xs text-neutral-500 dark:text-neutral-400 mt-0.5">{{ opt.desc }}</span>
            </span>
          </label>
        </div>
      </section>

      <section class="mb-6">
        <h4 class="text-sm font-medium text-neutral-800 dark:text-neutral-200 mb-3">字幕对齐</h4>
        <div class="space-y-2">
          <label
            v-for="opt in alignOptions"
            :key="opt.key"
            class="flex items-start gap-3 p-3 rounded-xl border cursor-pointer transition-colors"
            :class="currentAlign() === opt.key ? optionSelectedClass : optionDefaultClass"
          >
            <input
              type="radio"
              name="subtitle-align"
              class="mt-1 shrink-0"
              :checked="currentAlign() === opt.key"
              @change="emit('update:subtitleAlign', opt.key)"
            />
            <span>
              <span class="block text-sm font-medium">{{ opt.label }}</span>
              <span class="block text-xs text-neutral-500 dark:text-neutral-400 mt-0.5">{{ opt.desc }}</span>
            </span>
          </label>
        </div>
      </section>

      <section class="mb-6">
        <h4 class="text-sm font-medium text-neutral-800 dark:text-neutral-200 mb-3">精读模式</h4>
        <label
          class="flex items-start gap-3 p-3 rounded-xl border cursor-pointer transition-colors"
          :class="intensiveMode ? optionSelectedClass : optionDefaultClass"
        >
          <input
            type="checkbox"
            class="mt-1 shrink-0"
            :checked="intensiveMode"
            @change="setIntensiveMode(($event.target as HTMLInputElement).checked)"
          />
          <span>
            <span class="block text-sm font-medium">开启精读</span>
            <span class="block text-xs text-neutral-500 dark:text-neutral-400 mt-0.5">
              词下直译、段落译文对照、核心词汇侧栏
            </span>
          </span>
        </label>
      </section>

      <section class="mb-1">
        <h4 class="text-sm font-medium text-neutral-800 dark:text-neutral-200 mb-3">词汇弹幕</h4>
        <label
          class="flex items-start gap-3 p-3 rounded-xl border cursor-pointer transition-colors"
          :class="vocabDanmakuEnabled ? optionSelectedClass : optionDefaultClass"
        >
          <input
            type="checkbox"
            class="mt-1 shrink-0"
            :checked="vocabDanmakuEnabled"
            @change="setVocabDanmakuEnabled(($event.target as HTMLInputElement).checked)"
          />
          <span>
            <span class="block text-sm font-medium">在视频上显示词汇弹幕</span>
            <span class="block text-xs text-neutral-500 dark:text-neutral-400 mt-0.5">
              当前句命中「汇总」中的词汇时从右向左飘过，可一键加入生词本（默认开启）
            </span>
          </span>
        </label>
      </section>
    </div>
  </div>
</template>

<style scoped>
.settings-panel-scroll-hide {
  scrollbar-width: none;
  -ms-overflow-style: none;
}

.settings-panel-scroll-hide::-webkit-scrollbar {
  display: none;
}
</style>
