<script setup lang="ts">
import { computed, watch } from 'vue'
import type { AiExplainResult } from '@/api/aiCoach'

const props = defineProps<{
  open: boolean
  loading?: boolean
  error?: string
  result: AiExplainResult | null
}>()

defineEmits<{ close: []; regenerate: [] }>()

const hasContent = computed(() => {
  const r = props.result
  if (!r) return false
  return Boolean(
    r.plain_chinese ||
      r.structure ||
      r.paraphrase ||
      r.tip ||
      (r.expressions && r.expressions.length),
  )
})

watch(
  () => props.open,
  (v) => {
    if (v && typeof document !== 'undefined') {
      document.body.style.overflow = 'hidden'
    } else if (typeof document !== 'undefined') {
      document.body.style.overflow = ''
    }
  },
)
</script>

<template>
  <Teleport to="body">
    <div
      v-if="open"
      class="fixed inset-0 z-[80] flex items-end sm:items-center justify-center bg-black/40 p-0 sm:p-4"
      @click.self="$emit('close')"
    >
      <div
        class="w-full sm:max-w-lg max-h-[85dvh] overflow-y-auto rounded-t-2xl sm:rounded-2xl bg-white dark:bg-neutral-900 border border-black/5 dark:border-white/10 shadow-xl p-5 sm:p-6"
      >
        <div class="flex items-start justify-between gap-3 mb-4">
          <div>
            <h2 class="text-base font-semibold">AI 讲解</h2>
            <p class="text-xs text-neutral-500 mt-0.5">
              {{ loading ? '正在生成，内容会陆续出现…' : '针对当前字幕句的精讲' }}
            </p>
          </div>
          <button
            type="button"
            class="text-sm text-neutral-500 hover:text-ink-soft"
            @click="$emit('close')"
          >
            关闭
          </button>
        </div>

        <p v-if="error && !result" class="text-sm text-red-600 dark:text-red-400">{{ error }}</p>
        <div v-else-if="result" class="space-y-4 text-sm">
          <div class="rounded-xl bg-neutral-50 dark:bg-neutral-800/60 px-3 py-2 space-y-1">
            <p class="leading-relaxed">{{ result.english }}</p>
            <p v-if="result.chinese" class="text-xs text-neutral-500 leading-relaxed">
              {{ result.chinese }}
            </p>
          </div>

          <section v-if="result.plain_chinese">
            <h3 class="text-xs font-medium text-neutral-500 mb-1">意译</h3>
            <p class="leading-relaxed">{{ result.plain_chinese }}</p>
          </section>
          <section v-else-if="loading" class="animate-pulse">
            <h3 class="text-xs font-medium text-neutral-400 mb-1">意译</h3>
            <div class="h-4 rounded bg-neutral-100 dark:bg-neutral-800 w-4/5" />
          </section>

          <section v-if="result.structure">
            <h3 class="text-xs font-medium text-neutral-500 mb-1">结构</h3>
            <p class="leading-relaxed">{{ result.structure }}</p>
          </section>
          <section v-else-if="loading && hasContent" class="animate-pulse">
            <h3 class="text-xs font-medium text-neutral-400 mb-1">结构</h3>
            <div class="h-4 rounded bg-neutral-100 dark:bg-neutral-800 w-3/5" />
          </section>

          <section v-if="result.expressions?.length">
            <h3 class="text-xs font-medium text-neutral-500 mb-1">表达</h3>
            <ul class="space-y-1.5">
              <li v-for="(item, i) in result.expressions" :key="i">
                <span class="font-medium text-amber-800 dark:text-amber-300">{{ item.en }}</span>
                <span class="text-neutral-600 dark:text-neutral-300"> — {{ item.zh }}</span>
              </li>
            </ul>
          </section>

          <section v-if="result.paraphrase">
            <h3 class="text-xs font-medium text-neutral-500 mb-1">简单改写</h3>
            <p class="leading-relaxed italic">{{ result.paraphrase }}</p>
          </section>

          <section v-if="result.tip">
            <h3 class="text-xs font-medium text-neutral-500 mb-1">小贴士</h3>
            <p class="leading-relaxed text-amber-900/90 dark:text-amber-200/90">{{ result.tip }}</p>
          </section>

          <p v-if="error" class="text-sm text-red-600 dark:text-red-400">{{ error }}</p>

          <div class="flex flex-wrap items-center justify-between gap-2 pt-1">
            <p class="text-xs text-neutral-400">
              <span v-if="loading && !result.from_cache">生成中…</span>
              <span v-else-if="result.from_cache">已复用缓存（未消耗额度）</span>
              <span v-else-if="result.quota && !result.quota.is_member">
                今日 AI 剩余 {{ result.quota.remaining }} / {{ result.quota.limit }} 次
              </span>
            </p>
            <button
              type="button"
              class="text-xs text-neutral-500 hover:text-neutral-800 dark:hover:text-neutral-200 underline-offset-2 hover:underline disabled:opacity-50"
              :disabled="loading"
              @click="$emit('regenerate')"
            >
              重新生成
            </button>
          </div>
        </div>
        <p v-else-if="loading" class="text-sm text-neutral-500 py-8 text-center">
          正在连接讲解服务…
        </p>
      </div>
    </div>
  </Teleport>
</template>
