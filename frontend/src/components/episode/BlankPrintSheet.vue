<script setup lang="ts">
import { ref, watch } from 'vue'
import {
  DEFAULT_BLANK_PRINT_OPTIONS,
  type BlankPrintHintMode,
  type BlankPrintOptions,
} from '@/utils/blankPrint'

const props = defineProps<{
  open: boolean
}>()

const emit = defineEmits<{
  close: []
  confirm: [options: BlankPrintOptions]
}>()

const hintMode = ref<BlankPrintHintMode>(DEFAULT_BLANK_PRINT_OPTIONS.hintMode)
const includeAnswers = ref(DEFAULT_BLANK_PRINT_OPTIONS.includeAnswers)

watch(
  () => props.open,
  (open) => {
    if (!open) return
    try {
      const raw = localStorage.getItem('blank-print-options')
      if (!raw) return
      const parsed = JSON.parse(raw) as Partial<BlankPrintOptions>
      if (parsed.hintMode === 'en-only' || parsed.hintMode === 'with-chinese') {
        hintMode.value = parsed.hintMode
      }
      if (typeof parsed.includeAnswers === 'boolean') {
        includeAnswers.value = parsed.includeAnswers
      }
    } catch {
      /* ignore */
    }
  },
)

function confirm() {
  const options: BlankPrintOptions = {
    hintMode: hintMode.value,
    includeAnswers: includeAnswers.value,
  }
  try {
    localStorage.setItem('blank-print-options', JSON.stringify(options))
  } catch {
    /* ignore */
  }
  emit('confirm', options)
}
</script>

<template>
  <Teleport to="body">
    <div
      v-if="open"
      class="fixed inset-0 z-[290] flex items-end sm:items-center justify-center bg-black/40 p-0 sm:p-4 no-print"
      @click.self="emit('close')"
    >
      <div
        class="w-full max-w-md rounded-t-2xl sm:rounded-2xl bg-white dark:bg-neutral-900 shadow-2xl pb-[env(safe-area-inset-bottom)] sm:pb-0"
        role="dialog"
        aria-modal="true"
        aria-labelledby="blank-print-title"
        @click.stop
      >
        <div class="flex justify-center pt-3 pb-1 sm:hidden">
          <div class="w-10 h-1 rounded-full bg-neutral-300 dark:bg-neutral-600" />
        </div>
        <div class="px-5 pt-3 pb-5 sm:p-6">
          <h2 id="blank-print-title" class="text-base font-semibold text-neutral-900 dark:text-neutral-100">
            打印挖空练习
          </h2>
          <p class="mt-1 text-sm text-neutral-500 dark:text-neutral-400">
            选择打印内容后，将打开系统打印对话框
          </p>

          <div class="mt-5 space-y-5">
            <fieldset>
              <legend class="text-sm font-medium text-neutral-800 dark:text-neutral-200 mb-2">
                练习页内容
              </legend>
              <div class="space-y-2">
                <label
                  class="flex items-start gap-3 rounded-xl border px-3 py-2.5 cursor-pointer transition-colors"
                  :class="
                    hintMode === 'en-only'
                      ? 'border-neutral-900 dark:border-neutral-100 bg-neutral-50 dark:bg-neutral-800/80'
                      : 'border-line'
                  "
                >
                  <input v-model="hintMode" type="radio" value="en-only" class="mt-1" />
                  <span>
                    <span class="block text-sm font-medium">仅英文挖空</span>
                    <span class="block text-xs text-neutral-500 mt-0.5">只打印挖空英文句</span>
                  </span>
                </label>
                <label
                  class="flex items-start gap-3 rounded-xl border px-3 py-2.5 cursor-pointer transition-colors"
                  :class="
                    hintMode === 'with-chinese'
                      ? 'border-neutral-900 dark:border-neutral-100 bg-neutral-50 dark:bg-neutral-800/80'
                      : 'border-line'
                  "
                >
                  <input v-model="hintMode" type="radio" value="with-chinese" class="mt-1" />
                  <span>
                    <span class="block text-sm font-medium">英文挖空 + 中文提示</span>
                    <span class="block text-xs text-neutral-500 mt-0.5">每句下方附中文翻译作提示</span>
                  </span>
                </label>
              </div>
            </fieldset>

            <label class="flex items-start gap-3 cursor-pointer">
              <input v-model="includeAnswers" type="checkbox" class="mt-1 rounded border-neutral-300" />
              <span>
                <span class="block text-sm font-medium text-neutral-800 dark:text-neutral-200">附带答案页</span>
                <span class="block text-xs text-neutral-500 mt-0.5">
                  练习页之后另起一页打印完整英文与中文答案
                </span>
              </span>
            </label>
          </div>

          <div class="mt-6 flex gap-2">
            <button
              type="button"
              class="flex-1 px-4 py-2.5 rounded-xl text-sm border border-black/10 dark:border-white/10 text-neutral-600 dark:text-neutral-300 hover:bg-neutral-50 dark:hover:bg-neutral-800"
              @click="emit('close')"
            >
              取消
            </button>
            <button
              type="button"
              class="flex-1 px-4 py-2.5 rounded-xl text-sm bg-neutral-900 text-white dark:bg-neutral-100 dark:text-neutral-900 font-medium"
              @click="confirm"
            >
              打印
            </button>
          </div>
        </div>
      </div>
    </div>
  </Teleport>
</template>
