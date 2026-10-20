<script setup lang="ts">
import { ref } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import { submitUserArticle } from '@/api/articles'

const router = useRouter()
const sourceUrl = ref('')
const bodyText = ref('')
const submitting = ref(false)
const error = ref('')
const fieldError = ref('')

function isHttpUrl(url: string) {
  try {
    const parsed = new URL(url.trim())
    return parsed.protocol === 'http:' || parsed.protocol === 'https:'
  } catch {
    return false
  }
}

function formatApiDetail(detail: unknown): string {
  if (typeof detail === 'string' && detail.trim()) return detail
  if (Array.isArray(detail) && detail.length) {
    const first = detail[0] as { msg?: string }
    if (typeof first?.msg === 'string' && first.msg.trim()) return first.msg
  }
  return '提交失败，请稍后重试'
}

async function submit() {
  const url = sourceUrl.value.trim()
  const body = bodyText.value.trim()
  if (!url && !body) {
    fieldError.value = '请填写文章链接或粘贴英文正文（至少一项）'
    return
  }
  if (url && !isHttpUrl(url)) {
    fieldError.value = '请填写有效的 http(s) 文章链接'
    return
  }

  submitting.value = true
  error.value = ''
  fieldError.value = ''
  try {
    await submitUserArticle({ source_url: url, body })
    await router.push({ path: '/english/my-submissions', query: { tab: 'articles' } })
  } catch (e: unknown) {
    const detail = (e as { response?: { data?: { detail?: unknown } } })?.response?.data?.detail
    const msg = formatApiDetail(detail)
    if (msg.includes('链接') || msg.includes('正文') || msg.includes('重复')) {
      fieldError.value = msg
    } else {
      error.value = msg
    }
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <div class="page-container py-6 max-w-2xl">
    <div class="flex items-center gap-3 text-sm mb-6">
      <RouterLink to="/english/reading" class="text-ink-faint hover:text-ink">← 返回读报</RouterLink>
      <span class="text-neutral-300 dark:text-neutral-600">|</span>
      <span class="font-medium">上传文章</span>
      <span class="flex-1" />
      <RouterLink
        to="/english/my-submissions?tab=articles"
        class="text-ink-faint hover:text-ink"
      >
        我的语料库
      </RouterLink>
    </div>

    <p
      v-if="error"
      class="mb-4 text-sm text-red-600 dark:text-red-400 rounded-lg border border-red-200 dark:border-red-900 bg-red-50 dark:bg-red-950/40 px-4 py-3"
    >
      {{ error }}
    </p>

    <section class="rounded-xl border border-line-soft bg-card p-5 space-y-4">
      <div>
        <h1 class="text-lg font-semibold">上传文章</h1>
        <p class="mt-1 text-sm text-neutral-600 dark:text-neutral-300">
          填写原文链接，或粘贴英文正文（可同时提供）。审核通过后默认仅你可见。
        </p>
      </div>

      <label class="block text-sm">
        <span class="text-ink-faint">文章链接（可选）</span>
        <input
          v-model="sourceUrl"
          placeholder="https://..."
          class="mt-1 w-full rounded-lg border px-3 py-2.5 dark:bg-neutral-800 dark:text-white"
          :class="fieldError
            ? 'border-red-400 dark:border-red-500'
            : 'border-line'"
          :disabled="submitting"
          @input="fieldError = ''"
        />
      </label>

      <label class="block text-sm">
        <span class="text-neutral-500 dark:text-neutral-400">英文正文（可选）</span>
        <textarea
          v-model="bodyText"
          rows="10"
          placeholder="粘贴英文全文，便于审核导入…"
          class="mt-1 w-full rounded-lg border px-3 py-2.5 dark:bg-neutral-800 dark:text-white font-mono text-sm leading-relaxed"
          :class="fieldError
            ? 'border-red-400 dark:border-red-500'
            : 'border-line'"
          :disabled="submitting"
          @input="fieldError = ''"
        />
      </label>

      <p v-if="fieldError" class="text-xs text-red-600 dark:text-red-400 -mt-2">{{ fieldError }}</p>

      <button
        type="button"
        class="w-full text-sm px-5 py-3 rounded-xl bg-amber-500 text-white font-medium disabled:opacity-50 hover:bg-amber-600 transition shadow-sm"
        :disabled="submitting"
        @click="submit"
      >
        {{ submitting ? '提交中...' : '提交审核' }}
      </button>
    </section>
  </div>
</template>
