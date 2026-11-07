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
const aiGenerate = ref(false)

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

function humanSize(bytes: number): string {
  if (!bytes || bytes < 0) return ''
  const mb = bytes / (1024 * 1024)
  if (mb < 1) return `${Math.round(bytes / 1024)} KB`
  return `${mb.toFixed(mb < 10 ? 1 : 0)} MB`
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
      subtitle: subtitleFile.value ?? undefined,
      aiGenerate: aiGenerate.value,
    })
    await router.push(`/english/episode/${result.video_id}`)
  } catch (e: unknown) {
    const detail = (e as { response?: { data?: { detail?: unknown } } })?.response?.data?.detail
    const msg = formatApiDetail(detail)
    if (
      msg.includes('链接') ||
      msg.includes('字幕') ||
      msg.includes('视频') ||
      msg.includes('二选一') ||
      msg.includes('格式')
    ) {
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
    ? '正在从 B 站下载并转码，可能需要几分钟，请勿关闭页面'
    : '本地视频正在转码，可能需要一点时间，请勿关闭页面',
)

const sourceLabel = computed(() =>
  sourceKind.value === 'link' ? 'B 站视频链接' : '本地视频文件',
)
</script>

<template>
  <div class="page-container py-6">
    <div class="mx-auto max-w-5xl">
      <!-- 顶部导航 -->
      <div class="flex items-center gap-3 text-sm mb-6">
        <RouterLink to="/english" class="text-ink-faint hover:text-ink transition-colors">
          ← 返回目录
        </RouterLink>
        <span class="text-neutral-300 dark:text-neutral-600">|</span>
        <span class="font-medium">导入视频</span>
        <span class="flex-1" />
        <RouterLink
          to="/english/my-submissions"
          class="text-ink-faint hover:text-ink transition-colors"
        >
          我的语料库
        </RouterLink>
      </div>

      <p
        v-if="error"
        class="mb-5 text-sm text-red-600 dark:text-red-400 rounded-xl border border-red-200 dark:border-red-900 bg-red-50 dark:bg-red-950/40 px-4 py-3"
      >
        {{ error }}
      </p>

      <div class="grid gap-5 lg:grid-cols-[minmax(0,1fr)_300px] items-start">
        <div class="space-y-5">
          <!-- 标题 -->
          <div class="rounded-2xl border border-line-soft bg-card p-6">
            <div class="flex items-start justify-between gap-4">
              <div class="min-w-0">
                <h1 class="text-xl font-semibold tracking-tight">导入视频</h1>
                <p class="mt-1.5 text-sm text-neutral-600 dark:text-neutral-300 leading-relaxed">
                  导入 B 站视频或本地视频，配合你自己的字幕。导入后立即加入个人语料库。
                </p>
              </div>
              <span
                class="shrink-0 inline-flex items-center gap-1 rounded-full bg-emerald-50 text-emerald-700 dark:bg-emerald-950/40 dark:text-emerald-300 text-xs font-medium px-2.5 py-1"
              >
                <svg viewBox="0 0 20 20" fill="currentColor" class="w-3.5 h-3.5">
                  <path
                    fill-rule="evenodd"
                    d="M10 1.5a4 4 0 00-4 4V7H5.5A1.5 1.5 0 004 8.5v8A1.5 1.5 0 005.5 18h9a1.5 1.5 0 001.5-1.5v-8A1.5 1.5 0 0014.5 7H14V5.5a4 4 0 00-4-4zm2.5 5.5V5.5a2.5 2.5 0 10-5 0V7h5z"
                    clip-rule="evenodd"
                  />
                </svg>
                仅你可见
              </span>
            </div>
          </div>

          <!-- 第一步：来源 -->
          <section class="rounded-2xl border border-line-soft bg-card p-5 sm:p-6 space-y-4">
            <div class="flex items-center gap-2.5">
              <span
                class="w-6 h-6 rounded-full bg-amber-500 text-white text-xs font-bold flex items-center justify-center"
              >
                1
              </span>
              <h2 class="text-sm font-semibold">选择视频来源</h2>
            </div>

            <div class="inline-flex rounded-xl bg-sunken p-1 text-sm">
              <button
                type="button"
                class="px-4 py-1.5 rounded-lg font-medium transition"
                :class="sourceKind === 'link' ? 'bg-card text-ink shadow-sm' : 'text-ink-faint hover:text-ink'"
                :disabled="submitting"
                @click="switchKind('link')"
              >
                B 站链接
              </button>
              <button
                type="button"
                class="px-4 py-1.5 rounded-lg font-medium transition"
                :class="sourceKind === 'local' ? 'bg-card text-ink shadow-sm' : 'text-ink-faint hover:text-ink'"
                :disabled="submitting"
                @click="switchKind('local')"
              >
                本地视频
              </button>
            </div>

            <template v-if="sourceKind === 'link'">
              <label class="block">
                <span class="text-xs font-medium text-ink-faint">{{ sourceLabel }}</span>
                <input
                  v-model="sourceUrl"
                  placeholder="https://www.bilibili.com/video/BV..."
                  class="mt-1.5 w-full rounded-xl border px-3.5 py-2.5 text-sm outline-none transition dark:bg-neutral-800 dark:text-white focus:ring-2 focus:ring-amber-300/50"
                  :class="fieldError ? 'border-red-400 dark:border-red-500' : 'border-line focus:border-amber-400'"
                  :disabled="submitting"
                  @input="fieldError = ''"
                />
              </label>
              <p class="text-xs text-ink-faint">
                粘贴公开视频链接即可；封面与标题会自动识别（B 站风控时可能失败）。
              </p>
            </template>

            <template v-else>
              <label
                class="flex cursor-pointer items-center gap-3 rounded-xl border border-dashed px-4 py-3.5 transition hover:border-amber-400 hover:bg-amber-50/40 dark:hover:bg-amber-950/10"
                :class="fieldError ? 'border-red-400 dark:border-red-500' : 'border-line'"
              >
                <span
                  class="shrink-0 w-9 h-9 rounded-lg bg-sunken flex items-center justify-center text-ink-faint"
                >
                  <svg viewBox="0 0 20 20" fill="currentColor" class="w-5 h-5">
                    <path
                      fill-rule="evenodd"
                      d="M9.25 2.5a.75.75 0 011.5 0v7.19l2.22-2.22a.75.75 0 111.06 1.06l-3.5 3.5a.75.75 0 01-1.06 0l-3.5-3.5a.75.75 0 111.06-1.06l2.22 2.22V2.5zM3 13.25a.75.75 0 011.5 0v1.5c0 .69.56 1.25 1.25 1.25h8.5c.69 0 1.25-.56 1.25-1.25v-1.5a.75.75 0 011.5 0v1.5A2.75 2.75 0 0114.25 17.5h-8.5A2.75 2.75 0 013 14.75v-1.5z"
                      clip-rule="evenodd"
                    />
                  </svg>
                </span>
                <span class="min-w-0 flex-1">
                  <span class="block text-sm font-medium text-ink truncate">
                    {{ videoFile ? videoFile.name : '点击选择视频文件' }}
                  </span>
                  <span class="block text-xs text-ink-faint">
                    {{ videoFile ? humanSize(videoFile.size) : 'mp4 / mov / webm / mkv，建议不超过 100MB' }}
                  </span>
                </span>
                <input
                  type="file"
                  accept="video/*,.mp4,.mov,.webm,.mkv"
                  class="hidden"
                  :disabled="submitting"
                  @change="onVideoChange"
                />
              </label>
            </template>
          </section>

          <!-- 第二步：字幕（可选） -->
          <section class="rounded-2xl border border-line-soft bg-card p-5 sm:p-6 space-y-4">
            <div class="flex items-center gap-2.5">
              <span
                class="w-6 h-6 rounded-full bg-amber-500 text-white text-xs font-bold flex items-center justify-center"
              >
                2
              </span>
              <h2 class="text-sm font-semibold">添加字幕</h2>
              <span
                class="text-[11px] font-medium rounded-full bg-sunken text-ink-faint px-2 py-0.5"
              >
                可选
              </span>
            </div>

            <label
              class="flex cursor-pointer items-center gap-3 rounded-xl border border-dashed px-4 py-3.5 transition hover:border-amber-400 hover:bg-amber-50/40 dark:hover:bg-amber-950/10 border-line"
            >
              <span
                class="shrink-0 w-9 h-9 rounded-lg bg-sunken flex items-center justify-center text-ink-faint"
              >
                <svg viewBox="0 0 20 20" fill="currentColor" class="w-5 h-5">
                  <path
                    d="M3 4.75A1.75 1.75 0 014.75 3h10.5A1.75 1.75 0 0117 4.75v10.5A1.75 1.75 0 0115.25 17H4.75A1.75 1.75 0 013 15.25V4.75zM5.5 9a1 1 0 100 2h4a1 1 0 100-2h-4zm6 3a1 1 0 100 2h3a1 1 0 100-2h-3z"
                  />
                </svg>
              </span>
              <span class="min-w-0 flex-1">
                <span class="block text-sm font-medium text-ink truncate">
                  {{ subtitleFile ? subtitleFile.name : '点击选择字幕文件（可跳过）' }}
                </span>
                <span class="block text-xs text-ink-faint">
                  {{ subtitleFile ? humanSize(subtitleFile.size) : 'SRT / VTT；也可先导入视频，稍后再补充' }}
                </span>
              </span>
              <input
                type="file"
                accept=".srt,.vtt,.txt"
                class="hidden"
                :disabled="submitting"
                @change="onSubtitleChange"
              />
            </label>

            <p class="text-xs text-ink-faint leading-relaxed">
              先不上传也没关系：导入后在视频详情页的字幕区域，点击「导入字幕」即可补传。
            </p>
          </section>

          <!-- 第三步：AI 增强（可选） -->
          <section class="rounded-2xl border border-line-soft bg-card p-5 sm:p-6 space-y-3">
            <div class="flex items-center gap-2.5">
              <span
                class="w-6 h-6 rounded-full bg-amber-500 text-white text-xs font-bold flex items-center justify-center"
              >
                3
              </span>
              <h2 class="text-sm font-semibold">AI 增强</h2>
              <span class="text-[11px] font-medium rounded-full bg-sunken text-ink-faint px-2 py-0.5">
                可选
              </span>
            </div>
            <label
              class="flex items-start gap-3 cursor-pointer rounded-xl border border-line px-4 py-3 transition hover:border-amber-400"
            >
              <input
                v-model="aiGenerate"
                type="checkbox"
                class="mt-0.5 accent-amber-500"
                :disabled="submitting"
              />
              <span class="min-w-0">
                <span class="block text-sm font-medium text-ink">AI 生成字幕与重点词高亮</span>
                <span class="block text-xs text-ink-faint leading-relaxed mt-0.5">
                  后台自动生成中文翻译、音标，并高亮生词/重点短语（视频无字幕时会先语音识别生成英文字幕）。生成需要几分钟，导入后可离开页面，稍后回详情页查看进度。
                </span>
              </span>
            </label>
          </section>

          <p v-if="fieldError" class="text-xs text-red-600 dark:text-red-400">{{ fieldError }}</p>

          <button
            type="button"
            class="w-full text-sm px-5 py-3 rounded-xl bg-amber-500 text-white font-medium disabled:opacity-50 hover:bg-amber-600 transition shadow-sm"
            :disabled="submitting"
            @click="submit"
          >
            {{ submitting ? '导入处理中...' : '导入并发布' }}
          </button>
          <p v-if="submitting" class="text-xs text-ink-faint text-center">{{ processingHint }}</p>
        </div>

        <!-- 侧栏须知 -->
        <aside class="space-y-4">
          <div class="rounded-2xl border border-line-soft bg-card p-5">
            <h3 class="text-sm font-semibold mb-3">导入须知</h3>
            <ul class="space-y-2.5 text-xs text-neutral-600 dark:text-neutral-300">
              <li class="flex gap-2">
                <span class="text-emerald-500 shrink-0">✓</span>
                <span>导入内容仅你本人可见，不会进入公共目录</span>
              </li>
              <li class="flex gap-2">
                <span class="text-emerald-500 shrink-0">✓</span>
                <span>B 站视频由服务器下载，需链接公网可访问</span>
              </li>
              <li class="flex gap-2">
                <span class="text-emerald-500 shrink-0">✓</span>
                <span>视频会自动转码为浏览器可直接播放的格式</span>
              </li>
              <li class="flex gap-2">
                <span class="text-emerald-500 shrink-0">✓</span>
                <span>字幕可后补：先导视频，再到详情页添加</span>
              </li>
              <li class="flex gap-2">
                <span class="text-emerald-500 shrink-0">✓</span>
                <span>本地视频单文件建议不超过 100MB</span>
              </li>
            </ul>
          </div>

          <RouterLink
            to="/english/my-submissions"
            class="block rounded-2xl border border-line-soft bg-card p-5 hover:border-amber-300 transition group"
          >
            <div class="text-sm font-medium text-ink group-hover:text-amber-600 transition">
              我的语料库
            </div>
            <div class="mt-1 text-xs text-ink-faint">查看和管理你已导入的素材</div>
          </RouterLink>
        </aside>
      </div>
    </div>
  </div>
</template>
