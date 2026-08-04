<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import type { AiClozeResult } from '@/api/aiCoach'

const props = defineProps<{
  open: boolean
  loading?: boolean
  error?: string
  result: AiClozeResult | null
}>()

defineEmits<{ close: []; dictation: []; regenerate: [] }>()

const answers = ref<string[]>([])
const checked = ref(false)

const displayParts = computed(() => {
  const english = props.result?.english || ''
  const blanks = props.result?.blanks || []
  if (!english || !blanks.length) return [{ type: 'text' as const, text: english }]
  // 按首次出现顺序替换
  let rest = english
  const parts: { type: 'text' | 'blank'; text: string; blankIndex?: number }[] = []
  let blankIndex = 0
  for (const blank of blanks) {
    const idx = rest.toLowerCase().indexOf(blank.toLowerCase())
    if (idx < 0) continue
    if (idx > 0) parts.push({ type: 'text', text: rest.slice(0, idx) })
    const actual = rest.slice(idx, idx + blank.length)
    parts.push({ type: 'blank', text: actual, blankIndex: blankIndex++ })
    rest = rest.slice(idx + blank.length)
  }
  if (rest) parts.push({ type: 'text', text: rest })
  return parts
})

watch(
  () => props.result,
  (r) => {
    answers.value = (r?.blanks || []).map(() => '')
    checked.value = false
  },
)

function isCorrect(i: number) {
  const expected = props.result?.blanks[i] || ''
  return (answers.value[i] || '').trim().toLowerCase() === expected.trim().toLowerCase()
}
</script>

<template>
  <Teleport to="body">
    <div
      v-if="open"
      class="fixed inset-0 z-[80] flex items-end sm:items-center justify-center bg-black/40 p-0 sm:p-4"
      @click.self="$emit('close')"
    >
      <div
        class="w-full sm:max-w-lg max-h-[85dvh] overflow-y-auto rounded-t-2xl sm:rounded-2xl bg-white dark:bg-neutral-900 border border-black/5 dark:border-white/10 shadow-xl p-5 sm:p-6 space-y-4"
      >
        <div class="flex items-start justify-between gap-3">
          <div>
            <h2 class="text-base font-semibold">AI 挖空</h2>
            <p class="text-xs text-neutral-500 mt-0.5">根据难点词智能出题</p>
          </div>
          <button type="button" class="text-sm text-neutral-500" @click="$emit('close')">关闭</button>
        </div>

        <p v-if="error && !result" class="text-sm text-red-600">{{ error }}</p>
        <template v-else-if="result">
          <p v-if="loading" class="text-xs text-neutral-500">正在出题，大约需要几秒…</p>
          <p v-else-if="result.hint" class="text-xs text-amber-800 dark:text-amber-300">
            提示：{{ result.hint }}
          </p>
          <div
            v-if="loading && !result.blanks?.length"
            class="text-sm leading-relaxed text-neutral-700 dark:text-neutral-200"
          >
            {{ result.english }}
          </div>
          <div
            v-else
            class="text-sm leading-relaxed flex flex-wrap items-center gap-x-1 gap-y-2"
          >
            <template v-for="(part, i) in displayParts" :key="i">
              <span v-if="part.type === 'text'">{{ part.text }}</span>
              <input
                v-else
                v-model="answers[part.blankIndex!]"
                type="text"
                class="inline-block w-24 px-1.5 py-0.5 rounded border text-sm"
                :class="
                  checked
                    ? isCorrect(part.blankIndex!)
                      ? 'border-emerald-500 bg-emerald-50'
                      : 'border-red-400 bg-red-50'
                    : 'border-black/15 dark:border-white/20 dark:bg-neutral-800'
                "
              />
            </template>
          </div>
          <div v-if="!loading && result.blanks?.length" class="flex flex-wrap gap-2">
            <button
              type="button"
              class="px-3 py-1.5 rounded-lg text-sm bg-neutral-900 text-white dark:bg-neutral-100 dark:text-neutral-900"
              @click="checked = true"
            >
              检查答案
            </button>
            <button
              type="button"
              class="px-3 py-1.5 rounded-lg text-sm border border-black/10 dark:border-white/15"
              @click="$emit('dictation')"
            >
              改用整句听写
            </button>
            <button
              type="button"
              class="px-3 py-1.5 rounded-lg text-sm border border-black/10 dark:border-white/15 disabled:opacity-50"
              :disabled="loading"
              @click="$emit('regenerate')"
            >
              重新生成
            </button>
          </div>
          <p v-if="result.chinese" class="text-xs text-neutral-500">参考译文：{{ result.chinese }}</p>
          <p v-if="error" class="text-sm text-red-600">{{ error }}</p>
          <p v-if="result.from_cache" class="text-xs text-neutral-400">已复用缓存（未消耗额度）</p>
          <p
            v-else-if="!loading && result.quota && !result.quota.is_member"
            class="text-xs text-neutral-400"
          >
            今日 AI 剩余 {{ result.quota.remaining }} / {{ result.quota.limit }} 次
          </p>
        </template>
      </div>
    </div>
  </Teleport>
</template>
