<script setup lang="ts">

import { useHighlightStyle, type HighlightStyle } from '@/composables/useHighlightStyle'

import {

  useSentenceProgressStyle,

  type SentenceProgressStyle,

} from '@/composables/useSentenceProgressStyle'

import { useTheme, type ThemeMode } from '@/composables/useTheme'



defineEmits<{ close: [] }>()



const { highlightStyle, setHighlightStyle } = useHighlightStyle()

const { sentenceProgressStyle, setSentenceProgressStyle } = useSentenceProgressStyle()

const { themeMode, setThemeMode } = useTheme()



const themeOptions: { key: ThemeMode; label: string; desc: string }[] = [

  { key: 'light', label: '浅色', desc: '明亮界面，适合白天使用' },

  { key: 'dark', label: '深色', desc: '暗色界面，适合夜间学习' },

  { key: 'system', label: '跟随系统', desc: '自动匹配系统外观设置' },

]



const highlightOptions: { key: HighlightStyle; label: string; desc: string }[] = [

  { key: 'underline', label: '下划线', desc: '彩色下划线标注重点词汇' },

  { key: 'background', label: '背景色', desc: '浅色背景块标注重点词汇' },

]



const progressOptions: { key: SentenceProgressStyle; label: string; desc: string }[] = [

  { key: 'off', label: '关闭', desc: '不显示当前句朗读进度' },

  { key: 'bar', label: '底部进度条', desc: '在当前句卡片底部显示细进度条' },

  { key: 'gradient', label: '颜色跟读', desc: '未读保持原色；视频下方 #0fbb35，右侧字幕 #34e95c' },

]



const optionSelectedClass = 'border-neutral-900 bg-neutral-50 dark:border-neutral-400 dark:bg-neutral-800'

const optionDefaultClass = 'border-black/8 hover:border-black/15 hover:bg-neutral-50/50 dark:border-white/10 dark:hover:border-white/20 dark:hover:bg-neutral-800/50'

</script>



<template>

  <div class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4" @click.self="$emit('close')">

    <div class="bg-white dark:bg-neutral-900 rounded-2xl shadow-2xl shadow-black/15 dark:shadow-black/40 ring-1 ring-black/5 dark:ring-white/10 w-full max-w-md p-6 max-h-[85vh] overflow-y-auto settings-panel-scroll-hide">

      <div class="flex justify-between items-center mb-5">

        <h3 class="text-lg font-semibold">设置</h3>

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



      <section>

        <h4 class="text-sm font-medium text-neutral-800 dark:text-neutral-200 mb-3">当前句朗读进度</h4>

        <div class="space-y-2">

          <label

            v-for="opt in progressOptions"

            :key="opt.key"

            class="flex items-start gap-3 p-3 rounded-xl border cursor-pointer transition-colors"

            :class="sentenceProgressStyle === opt.key ? optionSelectedClass : optionDefaultClass"

          >

            <input

              type="radio"

              name="sentence-progress-style"

              class="mt-1 shrink-0"

              :checked="sentenceProgressStyle === opt.key"

              @change="setSentenceProgressStyle(opt.key)"

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
.settings-panel-scroll-hide {
  scrollbar-width: none;
  -ms-overflow-style: none;
}

.settings-panel-scroll-hide::-webkit-scrollbar {
  display: none;
}
</style>
