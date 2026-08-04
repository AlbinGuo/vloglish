<script setup lang="ts">
import { ref, watch } from 'vue'
import { aiReadingQa, type ReadingQaResult } from '@/api/aiCoach'

const props = defineProps<{
  open: boolean
  articleId: string
  segmentId?: number | null
  segmentPreview?: string
}>()

const emit = defineEmits<{ close: [] }>()

const question = ref('')
const loading = ref(false)
const error = ref('')
const result = ref<ReadingQaResult | null>(null)

async function ask(custom?: string) {
  loading.value = true
  error.value = ''
  try {
    result.value = await aiReadingQa({
      article_id: props.articleId,
      segment_id: props.segmentId,
      question: custom ?? question.value,
    })
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = typeof msg === 'string' ? msg : '提问失败'
  } finally {
    loading.value = false
  }
}

watch(
  () => props.open,
  (v) => {
    if (!v) {
      question.value = ''
      result.value = null
      error.value = ''
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
        class="w-full sm:max-w-lg max-h-[85dvh] overflow-y-auto rounded-t-2xl sm:rounded-2xl bg-white dark:bg-neutral-900 border border-black/5 dark:border-white/10 shadow-xl p-5 sm:p-6 space-y-4"
      >
        <div class="flex items-start justify-between gap-3">
          <div>
            <h2 class="text-base font-semibold">AI 读报问答</h2>
            <p class="text-xs text-neutral-500 mt-0.5">针对当前段落提问，或一键出理解题</p>
          </div>
          <button type="button" class="text-sm text-neutral-500" @click="$emit('close')">关闭</button>
        </div>

        <p
          v-if="segmentPreview"
          class="text-xs text-neutral-500 line-clamp-3 rounded-lg bg-neutral-50 dark:bg-neutral-800/50 px-3 py-2"
        >
          {{ segmentPreview }}
        </p>

        <textarea
          v-model="question"
          rows="2"
          class="w-full rounded-lg border border-black/10 dark:border-white/10 dark:bg-neutral-800 px-3 py-2 text-sm"
          placeholder="例如：这段的主旨是什么？作者态度如何？"
        />

        <div class="flex flex-wrap gap-2">
          <button
            type="button"
            class="px-3 py-1.5 rounded-lg text-sm bg-neutral-900 text-white dark:bg-neutral-100 dark:text-neutral-900 disabled:opacity-60"
            :disabled="loading"
            @click="ask()"
          >
            {{ loading ? '思考中...' : '提问' }}
          </button>
          <button
            type="button"
            class="px-3 py-1.5 rounded-lg text-sm border border-black/10 dark:border-white/15 disabled:opacity-60"
            :disabled="loading"
            @click="ask('')"
          >
            出理解题
          </button>
        </div>

        <p v-if="error" class="text-sm text-red-600">{{ error }}</p>

        <div v-if="result" class="space-y-3 text-sm">
          <section v-if="result.answer">
            <h3 class="text-xs text-neutral-500 mb-1">回答</h3>
            <p class="leading-relaxed whitespace-pre-wrap">{{ result.answer }}</p>
          </section>
          <section v-if="result.quiz?.length">
            <h3 class="text-xs text-neutral-500 mb-1">理解题</h3>
            <div v-for="(item, i) in result.quiz" :key="i" class="mb-2 rounded-lg border border-black/5 dark:border-white/10 p-3">
              <p class="font-medium">{{ i + 1 }}. {{ item.q }}</p>
              <p class="text-neutral-500 mt-1 text-xs">参考：{{ item.a }}</p>
            </div>
          </section>
          <section v-if="result.key_phrases?.length">
            <h3 class="text-xs text-neutral-500 mb-1">关键表达</h3>
            <ul class="space-y-1">
              <li v-for="(p, i) in result.key_phrases" :key="i">
                <span class="text-amber-800 dark:text-amber-300 font-medium">{{ p.en }}</span>
                — {{ p.zh }}
              </li>
            </ul>
          </section>
        </div>
      </div>
    </div>
  </Teleport>
</template>
