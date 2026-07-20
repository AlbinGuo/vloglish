<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import DifficultyStarsInput from '@/components/admin/DifficultyStarsInput.vue'
import SubtitleHighlightEditor from '@/components/admin/SubtitleHighlightEditor.vue'
import {
  adminCreateEpisode,
  adminFetchMediaFromUrl,
  adminGetEpisode,
  adminGetNextEpisodeIndex,
  adminImportVtt,
  adminListSeries,
  adminListTags,
  adminUpdateEpisode,
  type AdminEpisodePayload,
  type AdminSeries,
  type AdminSubtitle,
} from '@/api/admin'
import { accentOptions } from '@/constants/accentOptions'
import { nationalityOptions } from '@/constants/nationalityOptions'
import { countHighlights, parseEnglishHtmlTokens } from '@/utils/subtitleHighlightEdit'

const route = useRoute()
const router = useRouter()

const isNew = computed(() => route.name === 'AdminEpisodeNew')
const episodeId = computed(() => (isNew.value ? null : Number(route.params.id)))

const loading = ref(!isNew.value)
const saving = ref(false)
const importing = ref(false)
const fetching = ref(false)
const error = ref('')
const success = ref('')
const tagSuggestions = ref<string[]>([])
const subtitleImportText = ref('')
const sourceUrl = ref('')
const mediaSlug = ref('')

const form = ref<AdminEpisodePayload>({
  video_id: '',
  index: 0,
  short_title: '',
  summary: '',
  remark: '',
  stars: 3,
  voca_size: 0,
  cover: '',
  video_url: '',
  audio_url: '',
  thumbnail_url: '',
  original_video_url: '',
  is_demo: false,
  is_pinned: false,
  status: 'draft',
  rejection_reason: '',
  series_id: null,
  series_index: null,
  author: { name: '', gender: 'm', nationality: '', accent: '美国' },
  tag_names: [],
  subtitles: [],
})

const tagsInput = ref('')
const seriesOptions = ref<AdminSeries[]>([])
/** 展开高亮编辑的字幕行下标 */
const highlightEditIndex = ref<number | null>(null)

function subtitleHighlightCount(sub: AdminSubtitle): number {
  return countHighlights(parseEnglishHtmlTokens(sub.english_html || '', sub.english || ''))
}

function toggleHighlightEdit(index: number) {
  highlightEditIndex.value = highlightEditIndex.value === index ? null : index
}

function syncTagsFromInput() {
  form.value.tag_names = tagsInput.value
    .split(/[,，]/)
    .map((s) => s.trim())
    .filter(Boolean)
}

function syncTagsToInput() {
  tagsInput.value = form.value.tag_names.join('，')
}

function reindexSubtitles() {
  form.value.subtitles.forEach((s, i) => {
    s.index = i
  })
}

function addSubtitle() {
  const last = form.value.subtitles[form.value.subtitles.length - 1]
  form.value.subtitles.push({
    index: form.value.subtitles.length,
    start: last ? last.end : 0,
    end: last ? last.end + 3 : 3,
    english: '',
    chinese: '',
    ipa: '',
    english_html: '',
  })
}

function removeSubtitle(index: number) {
  form.value.subtitles.splice(index, 1)
  reindexSubtitles()
  if (highlightEditIndex.value == null) return
  if (highlightEditIndex.value === index) highlightEditIndex.value = null
  else if (highlightEditIndex.value > index) highlightEditIndex.value -= 1
}

async function loadEpisode() {
  if (!episodeId.value) return
  loading.value = true
  error.value = ''
  try {
    const data = await adminGetEpisode(episodeId.value)
    form.value = {
      video_id: data.video_id,
      index: data.index,
      short_title: data.short_title,
      summary: data.summary,
      remark: data.remark,
      stars: data.stars,
      voca_size: data.voca_size,
      cover: data.cover,
      video_url: data.video_url,
      audio_url: data.audio_url,
      thumbnail_url: data.thumbnail_url,
      original_video_url: data.original_video_url,
      is_demo: data.is_demo,
      is_pinned: Boolean(data.is_pinned),
      status: data.status,
      rejection_reason: data.rejection_reason || '',
      series_id: data.series_id ?? null,
      series_index: data.series_index ?? null,
      author: { ...data.author },
      tag_names: [...data.tag_names],
      subtitles: data.subtitles.map((s) => ({ ...s })),
    }
    syncTagsToInput()
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '加载失败'
  } finally {
    loading.value = false
  }
}

async function loadTags() {
  try {
    const tags = await adminListTags()
    tagSuggestions.value = tags.map((t) => t.name)
  } catch {
    tagSuggestions.value = []
  }
}

async function loadSeriesOptions() {
  try {
    const data = await adminListSeries()
    seriesOptions.value = data.results
  } catch {
    seriesOptions.value = []
  }
}

async function save() {
  syncTagsFromInput()
  if (!form.value.short_title.trim()) {
    error.value = '请填写标题'
    return
  }
  if (!form.value.author.name.trim()) {
    error.value = '请填写作者'
    return
  }
  if (form.value.status === 'rejected' && !form.value.rejection_reason?.trim()) {
    error.value = '驳回时需填写原因'
    return
  }
  if (form.value.series_id != null && !form.value.series_index) {
    error.value = '加入合集时请填写合集内集序号'
    return
  }

  saving.value = true
  error.value = ''
  success.value = ''
  try {
    const payload: AdminEpisodePayload = {
      ...form.value,
      subtitles: form.value.subtitles.map((s) => ({ ...s })),
      clear_series: form.value.series_id == null,
      series_id: form.value.series_id,
      series_index: form.value.series_id != null ? form.value.series_index : null,
    }
    if (isNew.value) {
      if (!payload.video_id?.trim()) delete payload.video_id
      await adminCreateEpisode(payload)
      success.value = '创建成功'
      await router.replace('/gnadmin/episodes')
    } else if (episodeId.value) {
      await adminUpdateEpisode(episodeId.value, payload)
      success.value = '已保存'
      await loadEpisode()
    }
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '保存失败'
  } finally {
    saving.value = false
  }
}

async function importSubtitles() {
  if (!subtitleImportText.value.trim()) {
    error.value = '请粘贴 VTT / SRT 字幕内容'
    return
  }
  importing.value = true
  error.value = ''
  success.value = ''
  try {
    const data = await adminImportVtt(subtitleImportText.value)
    form.value.subtitles = data.subtitles.map((s: AdminSubtitle) => ({ ...s }))
    if (data.stars >= 1 && data.stars <= 5) {
      form.value.stars = data.stars
    }
    if (data.voca_size > 0) {
      form.value.voca_size = data.voca_size
    }
    const parts = [`已导入 ${data.subtitle_count} 条字幕`]
    if (data.had_chinese) {
      parts.push('字幕含中文，未自动翻译')
    } else if (data.translated_count > 0) {
      parts.push(`翻译 ${data.translated_count} 条中文`)
    }
    if (data.ipa_count > 0) {
      parts.push(`生成 ${data.ipa_count} 条音标`)
    }
    if (data.highlight_count > 0) {
      parts.push(`高亮 ${data.highlight_count} 处难词`)
    }
    if (data.voca_size > 0) {
      parts.push(`词汇量 ${data.voca_size}`)
    }
    if (data.stars >= 1) {
      parts.push(`难度 ${data.stars} 星`)
    }
    success.value = parts.join('，')
    subtitleImportText.value = ''
  } catch (e: unknown) {
    const err = e as { response?: { status?: number; data?: { detail?: string | { msg?: string }[] } } }
    const detail = err.response?.data?.detail
    const msg =
      typeof detail === 'string'
        ? detail
        : Array.isArray(detail)
          ? detail.map((item) => item.msg).filter(Boolean).join('；')
          : err.response?.status === 404
            ? '字幕导入接口未找到，请重启后端服务后再试'
            : ''
    error.value = msg || '字幕解析失败'
  } finally {
    importing.value = false
  }
}

async function readSubtitleFile(file: File): Promise<string> {
  const buffer = await file.arrayBuffer()
  const bytes = new Uint8Array(buffer)
  if (bytes.length >= 3 && bytes[0] === 0xef && bytes[1] === 0xbb && bytes[2] === 0xbf) {
    return new TextDecoder('utf-8').decode(bytes.slice(3))
  }
  return new TextDecoder('utf-8').decode(bytes)
}

async function onSubtitleFileChange(event: Event) {
  const input = event.target as HTMLInputElement
  const file = input.files?.[0]
  if (!file) return
  try {
    subtitleImportText.value = await readSubtitleFile(file)
  } catch {
    error.value = '读取字幕文件失败，请确认文件编码为 UTF-8'
    input.value = ''
    return
  }
  input.value = ''
  await importSubtitles()
}

async function fetchFromSourceUrl() {
  const url = sourceUrl.value.trim()
  if (!url) {
    error.value = '请粘贴 YouTube 或 TikTok 链接'
    return
  }
  fetching.value = true
  error.value = ''
  success.value = ''
  try {
    const data = await adminFetchMediaFromUrl({
      url,
      slug: mediaSlug.value.trim() || form.value.video_id.trim() || undefined,
      enrich_subtitles: false,
    })
    form.value.short_title = data.title || form.value.short_title
    if (data.summary) {
      form.value.summary = data.summary
    }
    if (data.author_name) {
      form.value.author.name = data.author_name
    }
    form.value.original_video_url = data.original_video_url
    form.value.cover = data.cover
    form.value.thumbnail_url = data.thumbnail_url
    form.value.video_url = data.video_url
    form.value.audio_url = data.audio_url
    // 抓取时不带字幕；保留已有字幕，避免空数组覆盖
    if (data.subtitles.length) {
      form.value.subtitles = data.subtitles.map((s: AdminSubtitle) => ({ ...s }))
    }
    if (isNew.value) {
      form.value.index = await adminGetNextEpisodeIndex()
    }
    const parts = [
      `已抓取「${data.title}」`,
      data.author_name ? `作者 ${data.author_name}` : null,
      '已上传视频/音频/封面',
      '未抓取字幕（请下方手动导入 SRT）',
    ].filter(Boolean) as string[]
    if (data.warnings.length) parts.push(data.warnings.join('；'))
    success.value = parts.join('，')
    sourceUrl.value = ''
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '抓取失败，请检查链接与 yt-dlp 配置'
  } finally {
    fetching.value = false
  }
}

onMounted(async () => {
  await Promise.all([loadTags(), loadSeriesOptions()])
  await loadEpisode()
})

watch(
  () => form.value.status,
  (status) => {
    if (status !== 'rejected') {
      form.value.rejection_reason = ''
    }
  },
)
</script>

<template>
  <div class="space-y-6 max-w-5xl pb-8">
    <div class="flex flex-wrap items-center justify-between gap-3">
      <div class="flex items-center gap-3 text-sm min-w-0">
        <RouterLink to="/gnadmin/episodes" class="text-neutral-500 hover:text-neutral-900 shrink-0">← 返回列表</RouterLink>
        <span class="text-neutral-300 shrink-0">|</span>
        <span class="font-medium truncate">{{ isNew ? '新建剧集' : '编辑剧集' }}</span>
      </div>
      <div v-if="!loading" class="flex flex-wrap items-center gap-3 shrink-0">
        <a
          v-if="!isNew && form.video_id"
          :href="`/gnadmin/preview/${encodeURIComponent(form.video_id)}`"
          target="_blank"
          class="rounded-lg border px-4 py-2 text-sm hover:bg-neutral-50"
        >
          前台预览
        </a>
        <button
          type="button"
          class="rounded-lg bg-neutral-900 text-white px-5 py-2 text-sm hover:bg-neutral-800 disabled:opacity-50"
          :disabled="saving"
          @click="save"
        >
          {{ saving ? '保存中...' : '保存' }}
        </button>
      </div>
    </div>

    <p v-if="error" class="text-sm text-red-600">{{ error }}</p>
    <p v-if="success" class="text-sm text-green-600">{{ success }}</p>

    <div v-if="loading" class="text-neutral-500">加载中...</div>

    <template v-else>
      <section class="rounded-xl border border-black/5 bg-white p-5 space-y-4">
        <h2 class="font-medium">基本信息</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <label class="block text-sm">
            <span class="text-neutral-500">标题 *</span>
            <input v-model="form.short_title" class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2" />
          </label>
          <label class="block text-sm">
            <span class="text-neutral-500">video_id</span>
            <input
              v-model="form.video_id"
              :readonly="!isNew"
              :placeholder="isNew ? '留空自动生成' : ''"
              class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2"
              :class="{ 'bg-neutral-50': !isNew }"
            />
          </label>
          <label class="block text-sm">
            <span class="text-neutral-500">排序 index</span>
            <input v-model.number="form.index" type="number" class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2" />
          </label>
          <div class="block text-sm md:col-span-2">
            <span class="text-neutral-500">难度</span>
            <div class="mt-2 flex flex-wrap items-center gap-4">
              <DifficultyStarsInput v-model="form.stars" />
              <span class="text-xs text-neutral-400">悬停星星查看各级典型特征，点击选择</span>
            </div>
          </div>
          <label class="block text-sm">
            <span class="text-neutral-500">状态</span>
            <select v-model="form.status" class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2">
              <option value="draft">草稿</option>
              <option value="published">已发布</option>
              <option value="archived">已下架</option>
              <option value="rejected">驳回</option>
            </select>
          </label>
          <label v-if="form.status === 'rejected'" class="block text-sm md:col-span-2">
            <span class="text-neutral-500">驳回原因 *</span>
            <textarea
              v-model="form.rejection_reason"
              rows="3"
              placeholder="请说明驳回原因，用户将在通知中看到"
              class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2"
            />
          </label>
          <label class="block text-sm flex items-end gap-2 pb-2">
            <input v-model="form.is_demo" type="checkbox" class="rounded" />
            <span>Demo 体验内容</span>
          </label>
          <label class="block text-sm flex items-end gap-2 pb-2 md:col-span-2">
            <input v-model="form.is_pinned" type="checkbox" class="rounded" />
            <span>置顶（用户端视频列表固定靠前，并显示置顶角标）</span>
          </label>
          <label class="block text-sm md:col-span-2">
            <span class="text-neutral-500">摘要</span>
            <textarea v-model="form.summary" rows="2" class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2" />
          </label>
          <label class="block text-sm md:col-span-2">
            <span class="text-neutral-500">备注（内部）</span>
            <textarea v-model="form.remark" rows="2" class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2" />
          </label>
          <label class="block text-sm">
            <span class="text-neutral-500">所属合集</span>
            <select
              :value="form.series_id ?? ''"
              class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2"
              @change="
                form.series_id = ($event.target as HTMLSelectElement).value
                  ? Number(($event.target as HTMLSelectElement).value)
                  : null;
                if (!form.series_id) form.series_index = null
              "
            >
              <option value="">无（独立单集）</option>
              <option v-for="s in seriesOptions" :key="s.id" :value="s.id">
                {{ s.title }}（{{ s.status }}）
              </option>
            </select>
          </label>
          <label class="block text-sm">
            <span class="text-neutral-500">合集内集序号</span>
            <input
              v-model.number="form.series_index"
              type="number"
              min="1"
              :disabled="!form.series_id"
              placeholder="如 1、2、3"
              class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2 disabled:bg-neutral-50"
            />
          </label>
          <label class="block text-sm md:col-span-2">
            <span class="text-neutral-500">标签（逗号分隔）</span>
            <input
              v-model="tagsInput"
              list="tag-suggestions"
              placeholder="旅行，知识"
              class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2"
            />
            <datalist id="tag-suggestions">
              <option v-for="name in tagSuggestions" :key="name" :value="name" />
            </datalist>
          </label>
          <label class="block text-sm">
            <span class="text-neutral-500">词汇量</span>
            <input v-model.number="form.voca_size" type="number" min="0" class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2" />
          </label>
        </div>
      </section>

      <section class="rounded-xl border border-black/5 bg-white p-5 space-y-4">
        <h2 class="font-medium">作者</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <label class="block text-sm">
            <span class="text-neutral-500">姓名 *</span>
            <input v-model="form.author.name" class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2" />
          </label>
          <div class="block text-sm">
            <span class="text-neutral-500">口音</span>
            <div class="mt-2 flex flex-wrap gap-4">
              <label
                v-for="opt in accentOptions"
                :key="opt.value"
                class="flex items-center gap-2 cursor-pointer"
              >
                <input
                  v-model="form.author.accent"
                  type="radio"
                  :value="opt.value"
                  class="text-neutral-900 focus:ring-neutral-400"
                />
                <img :src="opt.icon" :alt="opt.label" class="w-5 h-5 shrink-0 object-contain" />
                <span>{{ opt.label }}</span>
              </label>
            </div>
          </div>
          <div class="block text-sm">
            <span class="text-neutral-500">国籍</span>
            <div class="mt-2 flex flex-wrap gap-4">
              <label
                v-for="opt in nationalityOptions"
                :key="opt.value"
                class="flex items-center gap-2 cursor-pointer"
              >
                <input
                  v-model="form.author.nationality"
                  type="radio"
                  :value="opt.value"
                  class="text-neutral-900 focus:ring-neutral-400"
                />
                <span class="text-lg leading-none">{{ opt.value }}</span>
                <span>{{ opt.label }}</span>
              </label>
            </div>
          </div>
          <label class="block text-sm">
            <span class="text-neutral-500">性别</span>
            <select v-model="form.author.gender" class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2">
              <option value="m">男</option>
              <option value="f">女</option>
            </select>
          </label>
        </div>
      </section>

      <section class="rounded-xl border border-black/5 bg-white p-5 space-y-4">
        <h2 class="font-medium">从 YouTube / TikTok 抓取</h2>
        <p class="text-sm text-neutral-600">
          使用本机 yt-dlp 下载视频、封面、音频并上传七牛，回填标题、摘要、作者。不抓取字幕；字幕请在下方手动导入 SRT/VTT（会自动翻译、音标与难词高亮）。
        </p>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <label class="block text-sm md:col-span-2">
            <span class="text-neutral-500">页面链接 *</span>
            <input
              v-model="sourceUrl"
              placeholder="https://www.youtube.com/watch?v=... 或 https://www.tiktok.com/@.../video/..."
              class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2"
            />
          </label>
          <label class="block text-sm">
            <span class="text-neutral-500">七牛目录名（可选）</span>
            <input
              v-model="mediaSlug"
              placeholder="如 tk01，默认用 video_id 或平台 ID"
              class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2"
            />
          </label>
          <div class="flex items-end">
            <button
              type="button"
              class="text-sm px-4 py-2 rounded-lg bg-neutral-900 text-white disabled:opacity-50"
              :disabled="fetching"
              @click="fetchFromSourceUrl"
            >
              {{ fetching ? '下载上传中（可能需要几分钟）...' : '抓取并上传七牛' }}
            </button>
          </div>
        </div>
        <div v-if="form.cover || form.video_url" class="flex flex-wrap gap-4 pt-2">
          <div v-if="form.cover" class="space-y-1">
            <p class="text-xs text-neutral-500">封面预览</p>
            <img :src="form.cover" alt="cover" class="h-24 w-40 object-cover rounded-lg border border-black/10 bg-neutral-50" />
          </div>
          <div v-if="form.video_url" class="space-y-1 flex-1 min-w-[240px]">
            <p class="text-xs text-neutral-500">视频预览</p>
            <video
              :src="form.video_url"
              :poster="form.thumbnail_url || form.cover"
              controls
              preload="metadata"
              class="w-full max-w-md rounded-lg border border-black/10 bg-black"
            />
          </div>
        </div>
      </section>

      <section class="rounded-xl border border-black/5 bg-white p-5 space-y-4">
        <h2 class="font-medium">媒体 URL（可手动修改）</h2>
        <p class="text-sm text-neutral-500">
          video_url 必须是 mp4 直链；original_video_url 填 YouTube/TikTok 原页面。
        </p>
        <div class="grid grid-cols-1 gap-4">
          <label class="block text-sm">
            <span class="text-neutral-500">封面 cover</span>
            <input v-model="form.cover" class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2" />
          </label>
          <label class="block text-sm">
            <span class="text-neutral-500">视频 video_url</span>
            <input v-model="form.video_url" class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2" />
          </label>
          <label class="block text-sm">
            <span class="text-neutral-500">音频 audio_url</span>
            <input v-model="form.audio_url" class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2" />
          </label>
          <label class="block text-sm">
            <span class="text-neutral-500">缩略图 thumbnail_url</span>
            <input v-model="form.thumbnail_url" class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2" />
          </label>
          <label class="block text-sm">
            <span class="text-neutral-500">YouTube 原链</span>
            <input v-model="form.original_video_url" class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2" />
          </label>
        </div>
      </section>

      <section class="rounded-xl border border-black/5 bg-white p-5 space-y-4">
        <div class="flex flex-wrap items-center justify-between gap-3">
          <h2 class="font-medium">字幕（{{ form.subtitles.length }} 条）</h2>
          <div class="flex flex-wrap gap-2">
            <button type="button" class="text-sm px-3 py-1.5 border rounded-lg hover:bg-neutral-50" @click="addSubtitle">
              添加一行
            </button>
          </div>
        </div>

        <div class="rounded-lg border border-black/10 p-4 space-y-3 bg-neutral-50">
          <p class="text-sm text-neutral-600">
            从 VTT / SRT 导入（粘贴内容或选择文件）。SRT 将严格按文件中的每条字幕分段，不会合并相邻英文条目。纯英文将自动翻译中文；所有字幕将自动生成美式 IPA 音标，并对有难度的单词/短语做高亮。导入后将替换当前字幕列表（耗时可能较长，请耐心等待）。
          </p>
          <textarea
            v-model="subtitleImportText"
            rows="4"
            placeholder="WEBVTT 或 SRT 内容&#10;00:00:00.000 --> 00:00:03.000&#10;Hello world."
            class="w-full rounded-lg border border-black/10 px-3 py-2 text-sm font-mono"
          />
          <div class="flex flex-wrap gap-2">
            <label class="text-sm px-3 py-1.5 border rounded-lg bg-white cursor-pointer hover:bg-neutral-50">
              选择 .vtt / .srt 文件
              <input type="file" accept=".vtt,.srt,text/vtt,application/x-subrip" class="hidden" @change="onSubtitleFileChange" />
            </label>
            <button
              type="button"
              class="text-sm px-3 py-1.5 rounded-lg bg-neutral-900 text-white disabled:opacity-50"
              :disabled="importing"
              @click="importSubtitles"
            >
              {{ importing ? '解析/生成中...' : '解析并替换字幕' }}
            </button>
          </div>
        </div>

        <div class="overflow-auto max-h-[640px] border border-black/5 rounded-lg">
          <table class="w-full text-sm min-w-[960px]">
            <thead class="bg-neutral-50 text-neutral-500 sticky top-0 z-[1]">
              <tr>
                <th class="px-2 py-2 text-left w-10">#</th>
                <th class="px-2 py-2 text-left w-20">开始</th>
                <th class="px-2 py-2 text-left w-20">结束</th>
                <th class="px-2 py-2 text-left">英文</th>
                <th class="px-2 py-2 text-left">中文</th>
                <th class="px-2 py-2 text-left w-48">音标 (IPA)</th>
                <th class="px-2 py-2 w-16"></th>
              </tr>
            </thead>
            <tbody>
              <template v-for="(sub, i) in form.subtitles" :key="i">
                <tr class="border-t border-black/5 align-top">
                  <td class="px-2 py-2 text-neutral-400">{{ i + 1 }}</td>
                  <td class="px-2 py-2">
                    <input v-model.number="sub.start" type="number" step="0.001" class="w-full rounded border border-black/10 px-2 py-1" />
                  </td>
                  <td class="px-2 py-2">
                    <input v-model.number="sub.end" type="number" step="0.001" class="w-full rounded border border-black/10 px-2 py-1" />
                  </td>
                  <td class="px-2 py-2">
                    <textarea v-model="sub.english" rows="2" class="w-full rounded border border-black/10 px-2 py-1" />
                    <button
                      type="button"
                      class="mt-1 text-[11px] hover:underline"
                      :class="
                        highlightEditIndex === i || subtitleHighlightCount(sub)
                          ? 'text-amber-700'
                          : 'text-neutral-500'
                      "
                      @click="toggleHighlightEdit(i)"
                    >
                      {{ highlightEditIndex === i ? '收起高亮' : '编辑高亮' }}
                      <span v-if="subtitleHighlightCount(sub)">({{ subtitleHighlightCount(sub) }})</span>
                    </button>
                  </td>
                  <td class="px-2 py-2">
                    <textarea v-model="sub.chinese" rows="2" class="w-full rounded border border-black/10 px-2 py-1" />
                  </td>
                  <td class="px-2 py-2">
                    <textarea
                      v-model="sub.ipa"
                      rows="2"
                      class="w-full rounded border border-black/10 px-2 py-1 font-serif text-xs"
                      placeholder="/音标/"
                    />
                  </td>
                  <td class="px-2 py-2">
                    <button type="button" class="text-red-600 text-xs hover:underline" @click="removeSubtitle(i)">删</button>
                  </td>
                </tr>
                <tr v-if="highlightEditIndex === i" class="bg-amber-50/20">
                  <td colspan="7" class="px-2 pb-3 pt-0">
                    <SubtitleHighlightEditor
                      :english="sub.english"
                      v-model="sub.english_html"
                    />
                  </td>
                </tr>
              </template>
              <tr v-if="!form.subtitles.length">
                <td colspan="7" class="px-4 py-6 text-center text-neutral-400">暂无字幕，可导入 VTT/SRT 或手动添加</td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>
    </template>
  </div>
</template>
