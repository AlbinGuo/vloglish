<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import DifficultyStarsInput from '@/components/admin/DifficultyStarsInput.vue'
import SubtitleHighlightEditor from '@/components/admin/SubtitleHighlightEditor.vue'
import {
  adminCreateEpisode,
  adminEnrichSubtitles,
  adminFetchMediaFromUrl,
  adminGetEpisode,
  adminGetNextEpisodeIndex,
  adminGetReleasePopupStats,
  adminImportVtt,
  adminListSeries,
  adminListTags,
  adminUpdateEpisode,
  type AdminEpisodePayload,
  type AdminReleasePopupStats,
  type AdminSeries,
  type AdminSubtitle,
} from '@/api/admin'
import { accentOptions } from '@/constants/accentOptions'
import { nationalityOptions } from '@/constants/nationalityOptions'
import { countHighlights, parseEnglishHtmlTokens } from '@/utils/subtitleHighlightEdit'
import { countVocabSummaryItems, parseVocabSummary } from '@/utils/vocabSummary'

const route = useRoute()
const router = useRouter()

const isNew = computed(() => route.name === 'AdminEpisodeNew')
const episodeId = computed(() => (isNew.value ? null : Number(route.params.id)))

const loading = ref(!isNew.value)
const saving = ref(false)
const importing = ref(false)
const enriching = ref(false)
const fetching = ref(false)
const error = ref('')
const success = ref('')
const tagSuggestions = ref<string[]>([])
const subtitleImportText = ref('')
/** 对当前字幕 AI 增强：keep=不翻译；translate=翻译中文 */
const subtitleEnrichMode = ref<'keep' | 'translate'>('keep')
const sourceUrl = ref('')
const mediaSlug = ref('')
const isUserSubmitted = ref(false)
/** 用户投稿：勾选=全站可见；不勾选=仅投稿者可见 */
const isCatalogPublic = ref(false)
const submitterLabel = ref('')
const releaseStats = ref<AdminReleasePopupStats | null>(null)
const releaseStatsLoading = ref(false)
const releaseStatsTab = ref<'seen' | 'unseen'>('seen')

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
  vocab_summary: '',
  video_context: '',
})

const tagsInput = ref('')
const seriesOptions = ref<AdminSeries[]>([])
/** 展开高亮编辑的字幕行下标 */
const highlightEditIndex = ref<number | null>(null)

const vocabSummaryPreview = computed(() => parseVocabSummary(form.value.vocab_summary || ''))
const vocabSummaryCount = computed(() => countVocabSummaryItems(vocabSummaryPreview.value))

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

async function loadReleaseStats() {
  if (!episodeId.value || isNew.value) {
    releaseStats.value = null
    return
  }
  releaseStatsLoading.value = true
  try {
    releaseStats.value = await adminGetReleasePopupStats(episodeId.value)
  } catch {
    releaseStats.value = null
  } finally {
    releaseStatsLoading.value = false
  }
}

async function loadEpisode() {
  if (!episodeId.value) return
  loading.value = true
  error.value = ''
  try {
    const data = await adminGetEpisode(episodeId.value)
    isUserSubmitted.value = Boolean(data.is_user_submitted)
    isCatalogPublic.value = Boolean(data.is_catalog_public)
    const nick = (data.submitted_by_nickname || '').trim()
    const email = (data.submitted_by_email || '').trim()
    submitterLabel.value = nick && email ? `${nick}（${email}）` : nick || email || (data.submitted_by_user_id ? `#${data.submitted_by_user_id}` : '')
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
      vocab_summary: data.vocab_summary || '',
      video_context: data.video_context || '',
    }
    if (data.original_video_url) {
      sourceUrl.value = data.original_video_url
    }
    syncTagsToInput()
    await loadReleaseStats()
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
  if (
    isUserSubmitted.value &&
    form.value.status === 'published' &&
    (!form.value.video_url?.trim() || !form.value.subtitles.length)
  ) {
    error.value = '用户投稿发布前须手工上传视频直链与字幕'
    return
  }
  if (isCatalogPublic.value && isUserSubmitted.value && form.value.status !== 'published') {
    error.value = '请先将状态设为「已发布」再设为全站可见'
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
      if (isUserSubmitted.value) {
        payload.is_catalog_public = isCatalogPublic.value
      }
      await adminUpdateEpisode(episodeId.value, payload)
      const parsed = parseVocabSummary(payload.vocab_summary || '')
      const n = countVocabSummaryItems(parsed)
      if (isUserSubmitted.value) {
        success.value = isCatalogPublic.value
          ? '已保存（全站可见）'
          : '已保存（仅投稿者可见）'
      } else if ((payload.vocab_summary || '').trim() && n === 0) {
        success.value =
          '已保存，但汇总文本未识别到词条：请用 Tab 分隔英文与中文，或「英文 + 空格 + 中文」；分类名请单独成行'
      } else if (n > 0) {
        success.value = `已保存（汇总 ${n} 条 / ${parsed.length} 组）`
      } else {
        success.value = '已保存'
      }
      await loadEpisode()
    }
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '保存失败'
  } finally {
    saving.value = false
  }
}

function formatImportError(e: unknown): string {
  const err = e as {
    code?: string
    message?: string
    response?: { status?: number; data?: { detail?: string | { msg?: string }[]; message?: string } }
  }
  const detail = err.response?.data?.detail
  const altMessage = err.response?.data?.message
  let msg =
    typeof detail === 'string'
      ? detail
      : Array.isArray(detail)
        ? detail.map((item) => item.msg).filter(Boolean).join('；')
        : typeof altMessage === 'string'
          ? altMessage
          : ''
  if (msg) return msg
  if (err.code === 'ECONNABORTED' || /timeout/i.test(err.message || '')) {
    return '本轮处理超时。已完成部分仍在表单中，可再点「AI 增强」继续，或先保存'
  }
  if (err.response?.status === 404) return '接口未找到，请重启后端服务后再试'
  if (err.response?.status === 502 || err.response?.status === 504) {
    return '网关超时或后端中断，请确认服务仍在运行后重试'
  }
  if (!err.response) return '无法连接后端或请求被中断，请确认服务已启动后重试'
  return `请求失败（HTTP ${err.response.status}）`
}

function applyImportResult(
  data: {
    subtitles: AdminSubtitle[]
    stars: number
    voca_size: number
    subtitle_count: number
    had_chinese: boolean
    translated_count: number
    ipa_count: number
    highlight_count: number
    warnings?: string[]
  },
  opts: { kind: 'import' | 'enrich'; translated: boolean },
) {
  const { kind, translated } = opts
  form.value.subtitles = data.subtitles.map((s) => ({ ...s }))
  if (kind === 'enrich') {
    if (data.stars >= 1 && data.stars <= 5) form.value.stars = data.stars
    if (data.voca_size > 0) form.value.voca_size = data.voca_size
  }
  const parts =
    kind === 'import'
      ? [`已导入 ${data.subtitle_count} 条字幕`, data.had_chinese ? '已保留文件中文' : '未含中文']
      : [`已 AI 增强 ${data.subtitle_count} 条字幕`]
  if (kind === 'enrich') {
    if (translated && data.translated_count > 0) {
      parts.push(`翻译/改写 ${data.translated_count} 条中文`)
    } else if (!translated) {
      parts.push(data.had_chinese ? '已保留现有中文' : '未翻译中文')
    }
    if (data.ipa_count > 0) parts.push(`音标 ${data.ipa_count} 条`)
    if (data.highlight_count > 0) parts.push(`高亮 ${data.highlight_count} 处`)
    if (data.voca_size > 0) parts.push(`词汇量 ${data.voca_size}`)
    if (data.stars >= 1) parts.push(`难度 ${data.stars} 星`)
  }
  success.value = parts.join('，')
  const warnList = (data.warnings || []).filter(Boolean)
  error.value = warnList.length ? warnList.join('；') : ''
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
    const data = await adminImportVtt(subtitleImportText.value, {
      title: form.value.short_title,
      summary: form.value.summary,
      enrichAi: false,
    })
    applyImportResult(data, { kind: 'import', translated: false })
    subtitleImportText.value = ''
  } catch (e: unknown) {
    error.value = formatImportError(e)
  } finally {
    importing.value = false
  }
}

async function enrichCurrentSubtitles() {
  if (!form.value.subtitles.length) {
    error.value = '请先导入或添加字幕'
    return
  }
  enriching.value = true
  error.value = ''
  success.value = ''
  const translateChinese = subtitleEnrichMode.value === 'translate'
  let totalTranslated = 0
  let totalIpa = 0
  let totalHighlight = 0
  let rounds = 0
  try {
    let data = await adminEnrichSubtitles(
      form.value.subtitles.map((s) => ({ ...s })),
      {
        title: form.value.short_title,
        summary: form.value.summary,
        translateChinese,
        maxBatches: 3,
      },
    )
    form.value.subtitles = data.subtitles.map((s) => ({ ...s }))
    totalTranslated += data.translated_count || 0
    totalIpa += data.ipa_count || 0
    totalHighlight += data.highlight_count || 0
    rounds += 1
    success.value = `AI 增强进行中（${data.phase || ''}，剩余约 ${data.remaining ?? '?'}）…`

    while (!data.done && rounds < 200) {
      data = await adminEnrichSubtitles(
        form.value.subtitles.map((s) => ({ ...s })),
        {
          title: form.value.short_title,
          summary: form.value.summary,
          translateChinese,
          maxBatches: 3,
        },
      )
      form.value.subtitles = data.subtitles.map((s) => ({ ...s }))
      totalTranslated += data.translated_count || 0
      totalIpa += data.ipa_count || 0
      totalHighlight += data.highlight_count || 0
      rounds += 1
      success.value = `AI 增强进行中（第 ${rounds} 轮，${data.phase || ''}，剩余约 ${data.remaining ?? '?'}）…`
    }

    if (!data.done) {
      error.value = `已跑 ${rounds} 轮仍未完成（剩余约 ${data.remaining}）。请再点「AI 增强」继续；记得保存`
    } else {
      applyImportResult(
        {
          ...data,
          translated_count: totalTranslated,
          ipa_count: totalIpa,
          highlight_count: totalHighlight,
        },
        { kind: 'enrich', translated: translateChinese },
      )
      if (success.value) {
        success.value = `${success.value}（共 ${rounds} 轮）。请记得保存剧集`
      }
    }
  } catch (e: unknown) {
    error.value = formatImportError(e)
    if (form.value.subtitles.length) {
      success.value = '若本轮已有部分结果，可保存后再次点「AI 增强」继续'
    }
  } finally {
    enriching.value = false
  }
}

function looksLikeSubtitleText(text: string): boolean {
  return /-->/.test(text) || /^WEBVTT/i.test(text.trim())
}

async function readSubtitleFile(file: File): Promise<string> {
  const buffer = await file.arrayBuffer()
  const bytes = new Uint8Array(buffer)

  // UTF-8 BOM
  if (bytes.length >= 3 && bytes[0] === 0xef && bytes[1] === 0xbb && bytes[2] === 0xbf) {
    return new TextDecoder('utf-8').decode(bytes.slice(3))
  }
  // UTF-16 LE BOM
  if (bytes.length >= 2 && bytes[0] === 0xff && bytes[1] === 0xfe) {
    return new TextDecoder('utf-16le').decode(bytes.slice(2))
  }
  // UTF-16 BE BOM
  if (bytes.length >= 2 && bytes[0] === 0xfe && bytes[1] === 0xff) {
    return new TextDecoder('utf-16be').decode(bytes.slice(2))
  }

  const utf8 = new TextDecoder('utf-8').decode(bytes)
  if (looksLikeSubtitleText(utf8) && !utf8.includes('\uFFFD')) {
    return utf8
  }

  // 常见中文 Windows 导出：GBK / GB18030
  try {
    const gbk = new TextDecoder('gbk').decode(bytes)
    if (looksLikeSubtitleText(gbk)) return gbk
  } catch {
    // browser may not support gbk label
  }
  try {
    const gb18030 = new TextDecoder('gb18030').decode(bytes)
    if (looksLikeSubtitleText(gb18030)) return gb18030
  } catch {
    // ignore
  }

  // UTF-16 LE without BOM（大量偶数位 NUL）
  if (bytes.length >= 4 && bytes[1] === 0 && bytes[3] === 0) {
    const utf16 = new TextDecoder('utf-16le').decode(bytes)
    if (looksLikeSubtitleText(utf16)) return utf16
  }

  return utf8
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
      <section
        v-if="!isNew"
        class="rounded-xl border border-amber-200 bg-amber-50 px-5 py-4 space-y-3 text-sm"
      >
        <div class="flex flex-wrap items-start justify-between gap-2">
          <div>
            <p class="font-medium text-amber-950">全站上线弹窗统计</p>
            <p class="text-amber-900/80 text-xs mt-1 leading-relaxed">
              官方视频首次发布，或用户投稿首次设为「全站可见」时，会向所有活跃用户推送弹窗。「已看」以用户点击确认弹窗为准。
            </p>
          </div>
          <button
            type="button"
            class="shrink-0 rounded-lg border border-amber-300 bg-white px-3 py-1.5 text-xs text-amber-900 hover:bg-amber-100 disabled:opacity-50"
            :disabled="releaseStatsLoading"
            @click="loadReleaseStats"
          >
            {{ releaseStatsLoading ? '刷新中...' : '刷新' }}
          </button>
        </div>

        <div v-if="releaseStatsLoading && !releaseStats" class="text-amber-800/70">加载中...</div>
        <template v-else-if="releaseStats">
          <p v-if="!releaseStats.notified" class="text-amber-900">
            尚未推送全站上线弹窗（发布为全站可见后会自动推送一次）。
          </p>
          <template v-else>
            <div class="flex flex-wrap gap-3 text-amber-950">
              <span>触达 <strong>{{ releaseStats.recipient_count }}</strong></span>
              <span>已看 <strong>{{ releaseStats.seen_count }}</strong></span>
              <span>未看 <strong>{{ releaseStats.unseen_count }}</strong></span>
              <span v-if="releaseStats.release_notified_at" class="text-amber-800/70">
                推送于 {{ releaseStats.release_notified_at }}
              </span>
            </div>
            <div class="flex gap-2">
              <button
                type="button"
                class="rounded-lg px-3 py-1.5 text-xs border transition"
                :class="
                  releaseStatsTab === 'seen'
                    ? 'bg-neutral-900 text-white border-neutral-900'
                    : 'bg-white border-amber-200 text-amber-950'
                "
                @click="releaseStatsTab = 'seen'"
              >
                已看（{{ releaseStats.seen_count }}）
              </button>
              <button
                type="button"
                class="rounded-lg px-3 py-1.5 text-xs border transition"
                :class="
                  releaseStatsTab === 'unseen'
                    ? 'bg-neutral-900 text-white border-neutral-900'
                    : 'bg-white border-amber-200 text-amber-950'
                "
                @click="releaseStatsTab = 'unseen'"
              >
                未看（{{ releaseStats.unseen_count }}）
              </button>
            </div>
            <ul class="max-h-52 overflow-y-auto rounded-lg border border-amber-200 bg-white divide-y divide-amber-100">
              <li
                v-for="u in releaseStatsTab === 'seen' ? releaseStats.seen_users : releaseStats.unseen_users"
                :key="u.user_id"
                class="px-3 py-2 flex flex-wrap items-baseline justify-between gap-2 text-xs"
              >
                <span class="text-neutral-800">
                  <span v-if="u.nickname" class="font-medium">{{ u.nickname }} · </span>{{ u.email }}
                </span>
                <span v-if="u.popup_acked_at" class="text-neutral-400">{{ u.popup_acked_at }}</span>
              </li>
              <li
                v-if="(releaseStatsTab === 'seen' ? releaseStats.seen_users : releaseStats.unseen_users).length === 0"
                class="px-3 py-4 text-center text-neutral-400"
              >
                暂无用户
              </li>
            </ul>
          </template>
        </template>
      </section>

      <section
        v-if="isUserSubmitted"
        class="rounded-xl border border-violet-200 bg-violet-50 px-5 py-4 space-y-3 text-sm"
      >
        <div class="space-y-2">
          <p class="font-medium text-violet-900">用户投稿 · 请纯手工上传媒体</p>
          <p class="text-violet-800">
            投稿者：{{ submitterLabel || '未知' }}。勾选「全站可见」后所有用户可在目录看到；不勾选则仅投稿者可见。无论是否勾选，都会保留在投稿者的「我的语料库」。
          </p>
          <p v-if="form.original_video_url" class="break-all">
            原链接：
            <a
              :href="form.original_video_url"
              target="_blank"
              rel="noopener noreferrer"
              class="underline text-violet-900"
            >
              {{ form.original_video_url }}
            </a>
          </p>
        </div>
        <label class="flex items-start gap-2.5 cursor-pointer rounded-lg border border-violet-200 bg-white/70 px-3 py-2.5">
          <input v-model="isCatalogPublic" type="checkbox" class="mt-0.5 rounded" />
          <span>
            <span class="font-medium text-violet-900">全站可见</span>
            <span class="block text-violet-700 text-xs mt-0.5 leading-relaxed">
              勾选：所有用户可在公共目录看到。不勾选：仅投稿者可见。设为全站可见前请先将状态设为「已发布」。
            </span>
          </span>
        </label>
      </section>

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
          使用本机 yt-dlp 下载视频、封面、音频并上传七牛，回填标题、摘要、作者。不抓取字幕；字幕请在下方手动导入 SRT/VTT（可选是否 AI 翻译，并生成音标与难词高亮）。
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
            从 VTT / SRT 导入文本（秒级，不调 AI）。导入后可点下方「AI 增强当前字幕」生成翻译/音标/高亮，无需再选文件。
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
              :disabled="importing || enriching"
              @click="importSubtitles"
            >
              {{ importing ? '解析中...' : '解析并替换字幕' }}
            </button>
          </div>
        </div>

        <div
          v-if="form.subtitles.length"
          class="rounded-lg border border-violet-200 bg-violet-50/60 p-4 space-y-3"
        >
          <p class="text-sm font-medium text-violet-900">AI 增强当前字幕</p>
          <p class="text-xs text-violet-800 leading-relaxed">
            对上方已加载的 {{ form.subtitles.length }} 条字幕调用 DeepSeek（不必重新上传文件）。条目多时会自动分轮处理，完成后请记得保存。
          </p>
          <div class="flex flex-col gap-2 text-sm">
            <label class="flex items-start gap-2 cursor-pointer">
              <input v-model="subtitleEnrichMode" type="radio" value="keep" class="mt-1" />
              <span>
                <span class="font-medium text-neutral-800">保留现有中文</span>
                <span class="block text-neutral-500 text-xs mt-0.5">不翻译；生成音标与难词高亮</span>
              </span>
            </label>
            <label class="flex items-start gap-2 cursor-pointer">
              <input v-model="subtitleEnrichMode" type="radio" value="translate" class="mt-1" />
              <span>
                <span class="font-medium text-neutral-800">AI 翻译中文</span>
                <span class="block text-neutral-500 text-xs mt-0.5">按剧情翻译/改写中文，并生成音标与高亮</span>
              </span>
            </label>
          </div>
          <button
            type="button"
            class="text-sm px-4 py-2 rounded-lg bg-violet-700 text-white hover:bg-violet-800 disabled:opacity-50"
            :disabled="enriching || importing || !form.subtitles.length"
            @click="enrichCurrentSubtitles"
          >
            {{ enriching ? 'AI 增强中（自动分轮，可并行加速）...' : 'AI 增强当前字幕' }}
          </button>
        </div>

        <div class="rounded-lg border border-black/10 p-4 space-y-3 bg-neutral-50">
          <div class="flex flex-wrap items-baseline justify-between gap-2">
            <h3 class="text-sm font-medium text-neutral-800">视频语境</h3>
            <span class="text-xs text-neutral-400">用户端「视频语境」Tab 原样渲染</span>
          </div>
          <p class="text-xs text-neutral-500 leading-relaxed">
            粘贴 HTML 或 Markdown；用户端按对应格式渲染展示（脚本等危险标签会被过滤）。
          </p>
          <textarea
            v-model="form.video_context"
            rows="12"
            placeholder="粘贴视频语境内容（HTML / Markdown）…"
            class="w-full rounded-lg border border-black/10 px-3 py-2 text-sm font-mono"
          />
        </div>

        <div class="rounded-lg border border-black/10 p-4 space-y-3 bg-neutral-50">
          <div class="flex flex-wrap items-baseline justify-between gap-2">
            <h3 class="text-sm font-medium text-neutral-800">词汇与表达汇总</h3>
            <span class="text-xs text-neutral-400">
              {{ vocabSummaryCount > 0 ? `已解析 ${vocabSummaryCount} 条 / ${vocabSummaryPreview.length} 组` : '用户端「汇总」Tab 展示' }}
            </span>
          </div>
          <p class="text-xs text-neutral-500 leading-relaxed">
            分类名单独成行；每条词条可写「剧中含义（或文中含义）/ 例句 / 释义」，也可选填「难度：四级」。示例：
            <code class="block mt-1.5 p-2 rounded bg-white border border-black/5 font-mono text-[11px] whitespace-pre-wrap text-neutral-600">医学术语

CPR (cardiopulmonary resuscitation)
剧中含义：剧中多次出现，指心肺复苏急救操作。
例句："Who knows CPR?"（谁知道心肺复苏怎么做？）
释义：心肺复苏</code>
          </p>
          <textarea
            v-model="form.vocab_summary"
            rows="10"
            placeholder="粘贴汇总内容…"
            class="w-full rounded-lg border border-black/10 px-3 py-2 text-sm font-mono"
          />
          <div v-if="vocabSummaryPreview.length" class="rounded-lg border border-black/5 bg-white p-3 space-y-4 max-h-80 overflow-y-auto">
            <section v-for="(g, i) in vocabSummaryPreview" :key="`${g.title}-${i}`" class="space-y-2">
              <p class="text-xs font-medium text-neutral-700">{{ g.title }}（{{ g.items.length }}）</p>
              <ul class="space-y-2.5">
                <li
                  v-for="(it, j) in g.items"
                  :key="`${it.en}-${j}`"
                  class="text-xs text-neutral-600 leading-relaxed border-t border-black/[0.04] pt-2 first:border-0 first:pt-0"
                >
                  <p class="font-medium text-neutral-800">{{ j + 1 }}. {{ it.en }}</p>
                  <p v-if="it.note" class="mt-0.5"><span class="text-neutral-400">含义：</span>{{ it.note }}</p>
                  <p v-if="it.example" class="mt-0.5"><span class="text-neutral-400">例句：</span>{{ it.example }}</p>
                  <p v-if="it.zh" class="mt-0.5"><span class="text-neutral-400">释义：</span>{{ it.zh }}</p>
                  <p v-if="it.level" class="mt-0.5"><span class="text-neutral-400">难度：</span>{{ it.level }}</p>
                </li>
              </ul>
            </section>
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
                    <div
                      v-if="sub.english_html"
                      class="subtitle-english mt-1.5 text-[13px] leading-relaxed text-neutral-800 flex flex-wrap gap-x-1 gap-y-0.5"
                      v-html="sub.english_html"
                    />
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
