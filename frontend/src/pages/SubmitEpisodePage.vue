<script setup lang="ts">
import { ref } from 'vue'
import { RouterLink } from 'vue-router'
import DifficultyStarsInput from '@/components/admin/DifficultyStarsInput.vue'
import {
  fetchSubmitMediaFromUrl,
  submitUserEpisode,
  type FetchMediaResult,
} from '@/api/episodes'
import { accentOptions } from '@/constants/accentOptions'

const sourceUrl = ref('')
const accent = ref('美国')
const fetching = ref(false)
const submitting = ref(false)
const error = ref('')
const success = ref('')
const fetched = ref<FetchMediaResult | null>(null)

async function fetchFromSourceUrl() {
  const url = sourceUrl.value.trim()
  if (!url) {
    error.value = '请粘贴 YouTube 或 TikTok 链接'
    return
  }
  fetching.value = true
  error.value = ''
  success.value = ''
  fetched.value = null
  try {
    const data = await fetchSubmitMediaFromUrl({ url })
    fetched.value = data
    const parts = [
      `已抓取「${data.title}」`,
      data.author_name ? `作者 ${data.author_name}` : null,
      `${data.subtitle_count} 条字幕`,
    ].filter(Boolean) as string[]
    if (data.translated_count > 0) parts.push(`翻译 ${data.translated_count} 条`)
    if (data.ipa_count > 0) parts.push(`音标 ${data.ipa_count} 条`)
    if (data.stars >= 1) parts.push(`难度 ${data.stars} 星`)
    if (data.warnings.length) parts.push(data.warnings.join('；'))
    success.value = parts.join('，')
    sourceUrl.value = ''
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '抓取失败，请检查链接后重试'
  } finally {
    fetching.value = false
  }
}

async function submit() {
  if (!fetched.value) {
    error.value = '请先抓取视频'
    return
  }
  submitting.value = true
  error.value = ''
  success.value = ''
  try {
    const data = await submitUserEpisode({
      accent: accent.value,
      title: fetched.value.title,
      summary: fetched.value.summary,
      author_name: fetched.value.author_name,
      stars: fetched.value.stars,
      voca_size: fetched.value.voca_size,
      original_video_url: fetched.value.original_video_url,
      cover: fetched.value.cover,
      thumbnail_url: fetched.value.thumbnail_url,
      video_url: fetched.value.video_url,
      audio_url: fetched.value.audio_url,
      subtitles: fetched.value.subtitles,
    })
    success.value = data.message
    fetched.value = null
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
      <span class="font-medium">添加外链视频</span>
    </div>

    <p v-if="error" class="mb-4 text-sm text-red-600 dark:text-red-400 rounded-lg border border-red-200 dark:border-red-900 bg-red-50 dark:bg-red-950/40 px-4 py-3">
      {{ error }}
    </p>
    <p v-if="success" class="mb-4 text-sm text-green-700 dark:text-green-400 rounded-lg border border-green-200 dark:border-green-900 bg-green-50 dark:bg-green-950/40 px-4 py-3">
      {{ success }}
    </p>

    <section class="rounded-xl border border-black/5 dark:border-white/10 bg-white dark:bg-neutral-900 p-5 space-y-4 mb-6">
      <h1 class="text-lg font-semibold">从 YouTube / TikTok 添加</h1>
      <p class="text-sm text-neutral-600 dark:text-neutral-300">
        粘贴视频链接后系统将自动下载、翻译字幕并分析难度。提交后需经审核，通过后将出现在目录中。
      </p>
      <label class="block text-sm">
        <span class="text-neutral-500 dark:text-neutral-400">视频链接</span>
        <input
          v-model="sourceUrl"
          placeholder="https://www.youtube.com/watch?v=... 或 https://www.tiktok.com/@.../video/..."
          class="mt-1 w-full rounded-lg border border-black/10 dark:border-white/10 dark:bg-neutral-800 dark:text-white px-3 py-2.5"
          :disabled="fetching"
        />
      </label>
      <button
        type="button"
        class="w-full sm:w-auto text-sm px-5 py-2.5 rounded-lg bg-neutral-900 text-white disabled:opacity-50 hover:bg-neutral-800 dark:bg-neutral-100 dark:text-neutral-900 dark:hover:bg-white transition"
        :disabled="fetching"
        @click="fetchFromSourceUrl"
      >
        {{ fetching ? '处理中（可能需要几分钟）...' : '开始添加' }}
      </button>
    </section>

    <section v-if="fetched" class="rounded-xl border border-black/5 dark:border-white/10 bg-white dark:bg-neutral-900 p-5 space-y-5">
      <h2 class="font-medium">视频信息</h2>

      <div v-if="fetched.cover" class="space-y-1">
        <p class="text-xs text-neutral-500">封面</p>
        <img
          :src="fetched.cover"
          alt="cover"
          class="h-28 w-48 object-cover rounded-lg border border-black/10 dark:border-white/10 bg-neutral-50 dark:bg-neutral-800"
        />
      </div>

      <div class="space-y-1">
        <p class="text-sm text-neutral-500">标题</p>
        <p class="text-base font-medium text-neutral-900 dark:text-neutral-100">{{ fetched.title }}</p>
      </div>

      <div v-if="fetched.summary" class="space-y-1">
        <p class="text-sm text-neutral-500">摘要</p>
        <p class="text-sm text-neutral-700 dark:text-neutral-300 leading-relaxed">{{ fetched.summary }}</p>
      </div>

      <div class="space-y-2">
        <p class="text-sm text-neutral-500">难度</p>
        <DifficultyStarsInput :model-value="fetched.stars" readonly />
      </div>

      <div class="space-y-2">
        <p class="text-sm text-neutral-500">口音</p>
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
            />
            <img :src="opt.icon" :alt="opt.label" class="w-5 h-5 shrink-0 object-contain" />
            <span class="text-sm">{{ opt.label }}</span>
          </label>
        </div>
      </div>

      <div v-if="fetched.video_url" class="space-y-1">
        <p class="text-xs text-neutral-500">视频预览</p>
        <video
          :src="fetched.video_url"
          :poster="fetched.thumbnail_url || fetched.cover"
          controls
          preload="metadata"
          class="w-full max-w-md rounded-lg border border-black/10 bg-black"
        />
      </div>

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
