<script setup lang="ts">
import { ref } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import { submitUserEpisode } from '@/api/episodes'

const router = useRouter()
const sourceUrl = ref('')
const submitting = ref(false)
const error = ref('')
const fieldError = ref('')

function isSupportedSourceUrl(url: string) {
  const lower = url.trim().toLowerCase()
  return Boolean(
    lower &&
      (lower.includes('youtube.com') || lower.includes('youtu.be') || lower.includes('tiktok.com')),
  )
}

function formatApiDetail(detail: unknown): string {
  if (typeof detail === 'string' && detail.trim()) return detail
  if (Array.isArray(detail) && detail.length) {
    const first = detail[0] as { msg?: string; loc?: unknown[] }
    const loc = Array.isArray(first?.loc) ? first.loc.join('.') : ''
    if (loc.includes('original_video_url')) {
      return '请粘贴有效的 YouTube 或 TikTok 链接'
    }
    if (typeof first?.msg === 'string' && first.msg.trim()) {
      return first.msg
    }
  }
  return '提交失败，请稍后重试'
}

async function submit() {
  const url = sourceUrl.value.trim()
  if (!url) {
    fieldError.value = '请粘贴 YouTube 或 TikTok 链接'
    return
  }
  if (!isSupportedSourceUrl(url)) {
    fieldError.value = '仅支持 YouTube 或 TikTok 链接'
    return
  }

  submitting.value = true
  error.value = ''
  fieldError.value = ''
  try {
    await submitUserEpisode({ original_video_url: url })
    await router.push('/english/my-submissions')
  } catch (e: unknown) {
    const detail = (e as { response?: { data?: { detail?: unknown } } })?.response?.data?.detail
    const msg = formatApiDetail(detail)
    // 链接类错误放在输入框下方，其它错误用顶部提示
    if (
      msg.includes('链接') ||
      msg.includes('YouTube') ||
      msg.includes('TikTok') ||
      msg.includes('重复')
    ) {
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
      <RouterLink to="/english" class="text-neutral-500 hover:text-neutral-900 dark:text-neutral-400 dark:hover:text-white">← 返回目录</RouterLink>
      <span class="text-neutral-300 dark:text-neutral-600">|</span>
      <span class="font-medium">上传视频</span>
      <span class="flex-1" />
      <RouterLink
        to="/english/my-submissions"
        class="text-neutral-500 hover:text-neutral-900 dark:text-neutral-400 dark:hover:text-white"
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

    <section class="rounded-xl border border-black/5 dark:border-white/10 bg-white dark:bg-neutral-900 p-5 space-y-4">
      <div>
        <h1 class="text-lg font-semibold">上传视频</h1>
        <p class="mt-1 text-sm text-neutral-600 dark:text-neutral-300">
          粘贴 YouTube / TikTok 链接，审核通过后仅你可见。
        </p>
      </div>

      <label class="block text-sm">
        <span class="text-neutral-500 dark:text-neutral-400">视频链接</span>
        <input
          v-model="sourceUrl"
          placeholder="https://www.youtube.com/watch?v=... 或 https://www.tiktok.com/@.../video/..."
          class="mt-1 w-full rounded-lg border px-3 py-2.5 dark:bg-neutral-800 dark:text-white"
          :class="fieldError
            ? 'border-red-400 dark:border-red-500'
            : 'border-black/10 dark:border-white/10'"
          :disabled="submitting"
          @input="fieldError = ''"
        />
        <p v-if="fieldError" class="mt-1.5 text-xs text-red-600 dark:text-red-400">{{ fieldError }}</p>
      </label>

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
