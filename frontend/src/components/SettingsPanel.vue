<script setup lang="ts">

import { useHighlightStyle, type HighlightStyle } from '@/composables/useHighlightStyle'

import {

  useSentenceProgressStyle,

  type SentenceProgressStyle,

} from '@/composables/useSentenceProgressStyle'



defineEmits<{ close: [] }>()



const { highlightStyle, setHighlightStyle } = useHighlightStyle()

const { sentenceProgressStyle, setSentenceProgressStyle } = useSentenceProgressStyle()



const highlightOptions: { key: HighlightStyle; label: string; desc: string }[] = [

  { key: 'underline', label: '下划线', desc: '彩色下划线标注重点词汇' },

  { key: 'background', label: '背景色', desc: '浅色背景块标注重点词汇' },

]



const progressOptions: { key: SentenceProgressStyle; label: string; desc: string }[] = [

  { key: 'off', label: '关闭', desc: '不显示当前句朗读进度' },

  { key: 'bar', label: '底部进度条', desc: '在当前句卡片底部显示细进度条' },

  { key: 'gradient', label: '文字渐深', desc: '已读部分正常显示，未读部分变浅' },

]

</script>



<template>

  <div class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4" @click.self="$emit('close')">

    <div class="bg-white rounded-2xl shadow-xl w-full max-w-md p-6 max-h-[85vh] overflow-y-auto">

      <div class="flex justify-between items-center mb-5">

        <h3 class="text-lg font-semibold">设置</h3>

        <button

          type="button"

          class="text-neutral-400 hover:text-black text-xl leading-none"

          aria-label="关闭"

          @click="$emit('close')"

        >

          ×

        </button>

      </div>



      <section class="mb-6">

        <h4 class="text-sm font-medium text-neutral-800 mb-3">文字高亮样式</h4>

        <div class="space-y-2">

          <label

            v-for="opt in highlightOptions"

            :key="opt.key"

            class="flex items-start gap-3 p-3 rounded-xl border cursor-pointer transition-colors"

            :class="

              highlightStyle === opt.key

                ? 'border-black bg-neutral-50'

                : 'border-black/8 hover:border-black/15 hover:bg-neutral-50/50'

            "

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

              <span class="block text-xs text-neutral-500 mt-0.5">{{ opt.desc }}</span>

            </span>

          </label>

        </div>

      </section>



      <section>

        <h4 class="text-sm font-medium text-neutral-800 mb-3">当前句朗读进度</h4>

        <div class="space-y-2">

          <label

            v-for="opt in progressOptions"

            :key="opt.key"

            class="flex items-start gap-3 p-3 rounded-xl border cursor-pointer transition-colors"

            :class="

              sentenceProgressStyle === opt.key

                ? 'border-black bg-neutral-50'

                : 'border-black/8 hover:border-black/15 hover:bg-neutral-50/50'

            "

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

              <span class="block text-xs text-neutral-500 mt-0.5">{{ opt.desc }}</span>

            </span>

          </label>

        </div>

      </section>

    </div>

  </div>

</template>

