<script setup lang="ts">
import { ref } from 'vue'
import { RouterLink } from 'vue-router'
import { submitUserEpisode } from '@/api/episodes'
import { accentOptions } from '@/constants/accentOptions'

const sourceUrl = ref('')
const accent = ref('美国')
const note = ref('')
const submitting = ref(false)
const error = ref('')
const success = ref('')

async function submit() {
  const url = sourceUrl.value.trim()
  if (!url) {
    error.value = '请粘贴 YouTube 或 TikTok 链接'
    return
  }
  submitting.value = true
  error.value = ''
  success.value = ''
  try {
    const data = await submitUserEpisode({
      original_video_url: url,
      accent: accent.value,
      note: note.value.trim(),
    })
    success.value = data.message
    sourceUrl.value = ''
    note.value = ''
    accent.value = '美国'
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '提交失败，请稍后重试'
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
      <span class="font-medium">投稿外链视频</span>
      <span class="flex-1" />
      <RouterLink
        to="/english/my-submissions"
        class="text-neutral-500 hover:text-neutral-900 dark:text-neutral-400 dark:hover:text-white"
      >
        我的语料库
      </RouterLink>
    </div>

    <p v-if="error" class="mb-4 text-sm text-red-600 dark:text-red-400 rounded-lg border border-red-200 dark:border-red-900 bg-red-50 dark:bg-red-950/40 px-4 py-3">
      {{ error }}
    </p>
    <p v-if="success" class="mb-4 text-sm text-green-700 dark:text-green-400 rounded-lg border border-green-200 dark:border-green-900 bg-green-50 dark:bg-green-950/40 px-4 py-3">
      {{ success }}
    </p>

    <section class="rounded-xl border border-black/5 dark:border-white/10 bg-white dark:bg-neutral-900 p-5 space-y-4">
      <h1 class="text-lg font-semibold">提交 YouTube / TikTok 链接</h1>
      <p class="text-sm text-neutral-600 dark:text-neutral-300 leading-relaxed">
        只需粘贴视频链接。管理员审核后将手工上传视频与字幕；通过后仅你可见，进入个人语料库。
      </p>

      <label class="block text-sm">
        <span class="text-neutral-500 dark:text-neutral-400">视频链接 *</span>
        <input
          v-model="sourceUrl"
          placeholder="https://www.youtube.com/watch?v=... 或 https://www.tiktok.com/@.../video/..."
          class="mt-1 w-full rounded-lg border border-black/10 dark:border-white/10 dark:bg-neutral-800 dark:text-white px-3 py-2.5"
          :disabled="submitting"
        />
      </label>

      <div class="space-y-2">
        <p class="text-sm text-neutral-500 dark:text-neutral-400">口音偏好（可选）</p>
        <div class="flex flex-wrap gap-4">
          <label
            v-for="opt in accentOptions"
            :key="opt.value"
            class="flex items-center gap-2 cursor-pointer rounded-lg border px-4 py-2.5 transition"
            :class="accent === opt.value ? 'border-neutral-900 bg-neutral-50 dark:border-neutral-300 dark:bg-neutral-800' : 'border-black/10 hover:bg-neutral-50 dark:border-white/10 dark:hover:bg-neutral-800'"
          >
            <input
              v-model="accent"
              type="radio"
              :value="opt.value"
              class="text-neutral-900 focus:ring-neutral-400"
              :disabled="submitting"
            />
            <img :src="opt.icon" :alt="opt.label" class="w-5 h-5 shrink-0 object-contain" />
            <span class="text-sm">{{ opt.label }}</span>
          </label>
        </div>
      </div>

      <label class="block text-sm">
        <span class="text-neutral-500 dark:text-neutral-400">备注（可选）</span>
        <textarea
          v-model="note"
          rows="3"
          maxlength="500"
          placeholder="例如：希望保留原字幕 / 某段特别想练听写"
          class="mt-1 w-full rounded-lg border border-black/10 dark:border-white/10 dark:bg-neutral-800 dark:text-white px-3 py-2.5"
          :disabled="submitting"
        />
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
