<script setup lang="ts">
import { computed, ref } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import { importSelfEpisode } from '@/api/episodes'

const router = useRouter()

type SourceKind = 'link' | 'local'
const sourceKind = ref<SourceKind>('link')

const sourceUrl = ref('')
const videoFile = ref<File | null>(null)
const subtitleFile = ref<File | null>(null)

const submitting = ref(false)
const error = ref('')
const fieldError = ref('')

function isSupportedSourceUrl(url: string) {
  const lower = url.trim().toLowerCase()
  return Boolean(
    lower &&
      (lower.includes('bilibili.com') ||
        lower.includes('b23.tv') ||
        lower.includes('youtube.com') ||
        lower.includes('youtu.be') ||
        lower.includes('tiktok.com')),
  )
}

function formatApiDetail(detail: unknown): string {
  if (typeof detail === 'string' && detail.trim()) return detail
  if (Array.isArray(detail) && detail.length) {
    const first = detail[0] as { msg?: string; loc?: unknown[] }
    if (typeof first?.msg === 'string' && first.msg.trim()) return first.msg
  }
  return '导入失败，请稍后重试'
}

function switchKind(next: SourceKind) {
  if (submitting.value) return
  sourceKind.value = next
  error.value = ''
  fieldError.value = ''
}

function onVideoChange(event: Event) {
  videoFile.value = (event.target as HTMLInputElement).files?.[0] ?? null
  fieldError.value = ''
}

function onSubtitleChange(event: Event) {
  subtitleFile.value = (event.target as HTMLInputElement).files?.[0] ?? null
  fieldError.value = ''
}

async function submit() {
  fieldError.value = ''
  error.value = ''

  if (!subtitleFile.value) {
    fieldError.value = '请上传该视频的 SRT / VTT 字幕文件'
    return
  }

  let url = ''
  if (sourceKind.value === 'link') {
    url = sourceUrl.value.trim()
    if (!url) {
      fieldError.value = '请粘贴 Bilibili 视频链接'
      return
    }
    if (!isSupportedSourceUrl(url)) {
      fieldError.value = '请粘贴有效的 Bilibili 视频链接'
      return
    }
  } else if (!videoFile.value) {
    fieldError.value = '请选择要导入的本地视频文件'
    return
  }

  submitting.value = true
  try {
    const result = await importSelfEpisode({
      url: url || undefined,
      video: sourceKind.value === 'local' ? videoFile.value ?? undefined : undefined,
      subtitle: subtitleFile.value,
    })
    await router.push(`/english/episode/${result.video_id}`)
  } catch (e: unknown) {
    const detail = (e as { response?: { data?: { detail?: unknown } } })?.response?.data?.detail
    const msg = formatApiDetail(detail)
    if (msg.includes('链接') || msg.includes('字幕') || msg.includes('视频') || msg.includes('二选一') || msg.includes('格式')) {
      fieldError.value = msg
    } else {
      error.value = msg
    }
  } finally {
    submitting.value = false
  }
}

const processingHint = computed(() =>
  sourceKind.value === 'link'
    ? '将从 B 站下载视频并转码，可能需要几分钟，请勿关闭页面'
    : '本地视频会自动转码，可能需要一点时间，请勿关闭页面',
)
</script>

<template>
  <div class="page-container py-6 max-w-2xl">
    <div class="flex items-center gap-3 text-sm mb-6">
      <RouterLink to="/english" class="text-ink-faint hover:text-ink">← 返回目录</RouterLink>
      <span class="text-neutral-300 dark:text-neutral-600">|</span>
      <span class="font-medium">导入视频</span>
      <span class="flex-1" />
      <RouterLink to="/english/my-submissions" class="text-ink-faint hover:text-ink">
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
        <h1 class="text-lg font-semibold">导入视频</h1>
        <p class="mt-1 text-sm text-neutral-600 dark:text-neutral-300">
          导入 B 站视频或本地视频，配合你自己的 SRT/VTT 字幕。导入后立即加入你的个人语料库，<strong>仅你可见</strong>。
        </p>
      </div>

      <!-- 来源切换 -->
      <div class="inline-flex rounded-lg bg-sunken p-1 text-sm">
        <button
          type="button"
          class="px-4 py-1.5 rounded-md font-medium transition"
          :class="sourceKind === 'link' ? 'bg-card text-ink shadow-sm' : 'text-ink-faint'"
          :disabled="submitting"
          @click="switchKind('link')"
        >
          B 站链接
        </button>
        <button
          type="button"
          class="px-4 py-1.5 rounded-md font-medium transition"
          :class="sourceKind === 'local' ? 'bg-card text-ink shadow-sm' : 'text-ink-faint'"
          :disabled="submitting"
          @click="switchKind('local')"
        >
          本地视频
        </button>
      </div>

      <!-- 视频来源 -->
      <template v-if="sourceKind === 'link'">
        <label class="block text-sm">
          <span class="text-ink-faint">B 站视频链接</span>
          <input
            v-model="sourceUrl"
            placeholder="https://www.bilibili.com/video/BV..."
            class="mt-1 w-full rounded-lg border px-3 py-2.5 dark:bg-neutral-800 dark:text-white"
            :class="fieldError ? 'border-red-400 dark:border-red-500' : 'border-line'"
            :disabled="submitting"
            @input="fieldError = ''"
          />
        </label>
      </template>
      <template v-else>
        <label class="block text-sm">
          <span class="text-ink-faint">本地视频文件</span>
          <input
            type="file"
            accept="video/*,.mp4,.mov,.webm,.mkv"
            class="mt-1 block w-full text-sm file:mr-3 file:rounded-lg file:border-0 file:bg-sunken file:px-3 file:py-2 file:text-sm file:font-medium file:text-ink"
            :disabled="submitting"
            @change="onVideoChange"
          />
          <span v-if="videoFile" class="mt-1 block text-xs text-ink-faint">
            已选择：{{ videoFile.name }}
          </span>
        </label>
      </template>

      <!-- 字幕（始终需要） -->
      <label class="block text-sm">
        <span class="text-ink-faint">字幕文件（SRT / VTT，必填）</span>
        <input
          type="file"
          accept=".srt,.vtt,.txt"
          class="mt-1 block w-full text-sm file:mr-3 file:rounded-lg file:border-0 file:bg-sunken file:px-3 file:py-2 file:text-sm file:font-medium file:text-ink"
          :disabled="submitting"
          @change="onSubtitleChange"
        />
        <span v-if="subtitleFile" class="mt-1 block text-xs text-ink-faint">
          已选择：{{ subtitleFile.name }}
        </span>
      </label>

      <p v-if="fieldError" class="text-xs text-red-600 dark:text-red-400">{{ fieldError }}</p>
      <p v-if="submitting" class="text-xs text-ink-faint">{{ processingHint }}</p>

      <button
        type="button"
        class="w-full text-sm px-5 py-3 rounded-xl bg-amber-500 text-white font-medium disabled:opacity-50 hover:bg-amber-600 transition shadow-sm"
        :disabled="submitting"
        @click="submit"
      >
        {{ submitting ? '导入处理中...' : '导入并发布' }}
      </button>
    </section>
  </div>
</template>
