<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import {
  adminAnalyzeArticle,
  adminCreateArticle,
  adminGetArticle,
  adminGenerateArticleTts,
  adminEnrichArticle,
  adminImportArticleText,
  adminUpdateArticle,
  adminUploadArticleCover,
  type AdminArticleDetail,
} from '@/api/admin'
import { resolveMediaUrl } from '@/utils/mediaUrl'
import { countVocabSummaryItems, parseVocabSummary } from '@/utils/vocabSummary'

const route = useRoute()
const router = useRouter()

const isNew = computed(() => route.path.endsWith('/new'))
const refId = computed(() => route.params.id as string | undefined)

const loading = ref(false)
const saving = ref(false)
const importing = ref(false)
const enriching = ref(false)
const generatingTts = ref(false)
const error = ref('')
const message = ref('')

const form = ref({
  title: '',
  summary: '',
  source: '',
  source_url: '',
  topic: '',
  cover: '',
  stars: 3,
  status: 'draft',
  vocab_summary: '',
})
const coverSourceUrl = ref('')
const uploadingCover = ref(false)
const ttsVoice = ref('Ryan')
const ttsForceRegenerate = ref(false)
const englishText = ref('')
const article = ref<AdminArticleDetail | null>(null)

const vocabSummaryPreview = computed(() => parseVocabSummary(form.value.vocab_summary || ''))
const vocabSummaryCount = computed(() => countVocabSummaryItems(vocabSummaryPreview.value))

const ttsVoiceOptions = [
  { value: 'Ryan', label: 'Ryan（男声，新闻感）' },
  { value: 'Katerina', label: 'Katerina（女声）' },
]

const statusOptions = [
  { value: 'draft', label: '草稿' },
  { value: 'published', label: '已发布' },
  { value: 'archived', label: '已下架' },
]

const statusLabel = computed(() => {
  const hit = statusOptions.find((o) => o.value === (article.value?.status || form.value.status))
  return hit?.label || article.value?.status || form.value.status
})

async function load() {
  if (isNew.value || !refId.value) return
  loading.value = true
  error.value = ''
  try {
    article.value = await adminGetArticle(refId.value)
    form.value = {
      title: article.value.title,
      summary: article.value.summary,
      source: article.value.source,
      source_url: article.value.source_url,
      topic: article.value.topic,
      cover: article.value.cover,
      stars: article.value.stars,
      status: article.value.status,
      vocab_summary: article.value.vocab_summary_text || '',
    }
  } catch {
    error.value = '加载失败'
  } finally {
    loading.value = false
  }
}

async function saveMeta() {
  saving.value = true
  message.value = ''
  error.value = ''
  try {
    if (isNew.value) {
      const { vocab_summary: _vocab, ...meta } = form.value
      const created = await adminCreateArticle(meta)
      await router.replace(`/gnadmin/reading/${created.id}`)
      article.value = created
      if (coverSourceUrl.value.trim()) {
        await uploadCover(created.id)
      }
    } else if (refId.value) {
      if (form.value.status === 'published' && article.value && !article.value.segment_count) {
        error.value = '请先导入段落再设为「已发布」'
        return
      }
      const parsed = parseVocabSummary(form.value.vocab_summary || '')
      const n = countVocabSummaryItems(parsed)
      article.value = await adminUpdateArticle(refId.value, {
        ...form.value,
        vocab_summary: form.value.vocab_summary || '',
      })
      form.value.status = article.value.status
      form.value.vocab_summary = article.value.vocab_summary_text || form.value.vocab_summary
      const statusText = statusOptions.find((o) => o.value === article.value?.status)?.label || article.value.status
      if ((form.value.vocab_summary || '').trim() && n === 0) {
        message.value = `已保存（${statusText}），但汇总文本未能解析出词条，请检查格式`
      } else if (n > 0) {
        message.value = `已保存（${statusText}；汇总 ${n} 条 / ${parsed.length} 组）`
      } else {
        message.value = `已保存（${statusText}）`
      }
      return
    }
    message.value = '已保存'
  } catch {
    error.value = '保存失败'
  } finally {
    saving.value = false
  }
}

async function uploadCover(refOverride?: string | number) {
  const ref = refOverride ?? refId.value
  const source = coverSourceUrl.value.trim()
  if (!ref || !source) return
  uploadingCover.value = true
  message.value = ''
  error.value = ''
  try {
    const result = await adminUploadArticleCover(ref, source)
    form.value.cover = result.cover
    if (article.value) article.value.cover = result.cover
    message.value = '封面上传成功'
  } catch (e: unknown) {
    const detail = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = detail || '封面上传失败'
  } finally {
    uploadingCover.value = false
  }
}

async function importText() {
  if (!refId.value || !englishText.value.trim()) return
  importing.value = true
  message.value = ''
  error.value = ''
  try {
    const result = await adminImportArticleText(refId.value, {
      english_text: englishText.value,
      auto_translate: false,
      auto_analyze: false,
    })
    englishText.value = ''
    await load()
    message.value = `已导入 ${result.segment_count} 段（纯文本）。需要译文/高亮时再点「AI 增强段落」`
  } catch (e: unknown) {
    const err = e as { code?: string; message?: string; response?: { data?: { detail?: string } } }
    const detail = err.response?.data?.detail
    if (err.code === 'ECONNABORTED' || /timeout/i.test(err.message || '')) {
      error.value = '导入超时，请刷新后重试；若段落已出现可直接发布或再点 AI 增强'
    } else {
      error.value = detail || '导入失败'
    }
  } finally {
    importing.value = false
  }
}

async function enrichSegments() {
  if (!refId.value || !article.value?.segment_count) return
  enriching.value = true
  message.value = ''
  error.value = ''
  try {
    let rounds = 0
    let last = await adminEnrichArticle(refId.value, {
      translate: true,
      analyze: true,
      max_batches: 3,
      force_analyze: false,
    })
    rounds += 1
    message.value = `AI 增强进行中（${phaseLabel(last.phase)}，剩余约 ${last.remaining}）…`
    while (!last.done && rounds < 200) {
      last = await adminEnrichArticle(refId.value, {
        translate: true,
        analyze: true,
        max_batches: 3,
        force_analyze: false,
      })
      rounds += 1
      message.value = `AI 增强进行中（第 ${rounds} 轮，${phaseLabel(last.phase)}，剩余约 ${last.remaining}）…`
    }
    await load()
    if (!last.done) {
      error.value = `已跑 ${rounds} 轮仍未完成（剩余约 ${last.remaining}）。请再点一次「AI 增强段落」继续`
    } else {
      message.value = `AI 增强完成：${last.segment_count} 段，高亮 ${last.highlight_count || 0} 处（共 ${rounds} 轮）`
    }
  } catch (e: unknown) {
    const err = e as { code?: string; message?: string; response?: { data?: { detail?: string } } }
    const detail = err.response?.data?.detail
    if (err.code === 'ECONNABORTED' || /timeout/i.test(err.message || '')) {
      error.value = '本轮 AI 增强超时。已完成部分已写入，请再点「AI 增强段落」继续'
      try {
        await load()
      } catch {
        /* ignore */
      }
    } else if (/server closed the connection|OperationalError|consuming input failed/i.test(detail || '')) {
      error.value = '数据库连接在长时间 AI 处理后断开。请刷新后重试「AI 增强段落」'
    } else {
      error.value = detail || 'AI 增强失败'
    }
  } finally {
    enriching.value = false
  }
}

function phaseLabel(phase: string) {
  if (phase === 'translate') return '机翻'
  if (phase === 'analyze' || phase === 'enrich') return '音标/高亮'
  return phase || '处理'
}

async function reanalyze() {
  if (!refId.value) return
  importing.value = true
  message.value = ''
  error.value = ''
  try {
    let force = true
    let rounds = 0
    let last = await adminAnalyzeArticle(refId.value, { max_batches: 3, force_analyze: force })
    force = false
    rounds += 1
    while (!last.done && rounds < 200) {
      last = await adminAnalyzeArticle(refId.value, { max_batches: 3, force_analyze: false })
      rounds += 1
      message.value = `词汇分析进行中（第 ${rounds} 轮，剩余约 ${last.remaining}）…`
    }
    await load()
    if (!last.done) {
      error.value = `分析未完成（剩余约 ${last.remaining}），请再点「仅重新分析词汇」继续`
    } else {
      message.value = `词汇分析完成（共 ${rounds} 轮，高亮 ${last.highlight_count || 0} 处）`
    }
  } catch (e: unknown) {
    const err = e as { code?: string; message?: string; response?: { data?: { detail?: string } } }
    const detail = err.response?.data?.detail
    if (err.code === 'ECONNABORTED' || /timeout/i.test(err.message || '')) {
      error.value = '本轮分析超时。已完成部分已写入，请再点「仅重新分析词汇」继续'
      try {
        await load()
      } catch {
        /* ignore */
      }
    } else {
      error.value = detail || '分析失败'
    }
  } finally {
    importing.value = false
  }
}

async function generateTts() {
  if (!refId.value) return
  generatingTts.value = true
  message.value = ''
  error.value = ''
  let totalGenerated = 0
  let totalFailed = 0
  let rounds = 0
  let force = ttsForceRegenerate.value
  try {
    let last = await adminGenerateArticleTts(refId.value, {
      voice: ttsVoice.value,
      max_segments: 8,
      skip_existing: true,
      force,
    })
    force = false
    rounds += 1
    totalGenerated += last.generated || 0
    totalFailed += last.failed || 0
    message.value = `TTS 生成中（第 ${rounds} 轮，本轮 ${last.processed || 0} 段，剩余约 ${last.remaining}）…`

    while (!last.done && rounds < 200) {
      last = await adminGenerateArticleTts(refId.value, {
        voice: ttsVoice.value,
        max_segments: 8,
        skip_existing: true,
        force: false,
      })
      rounds += 1
      totalGenerated += last.generated || 0
      totalFailed += last.failed || 0
      message.value = `TTS 生成中（第 ${rounds} 轮，本轮 ${last.processed || 0} 段，剩余约 ${last.remaining}）…`
    }

    await load()
    if (!last.done) {
      error.value = `已跑 ${rounds} 轮仍有约 ${last.remaining} 段未完成。请再点「生成段落 TTS」继续补全`
    } else if (totalFailed > 0) {
      error.value = last.error_sample
        ? `TTS 完成但有失败：成功 ${totalGenerated}，失败累计 ${totalFailed}（${last.voice || ttsVoice.value}）。${last.error_sample}`
        : `TTS 完成但有失败：成功 ${totalGenerated}，失败累计 ${totalFailed}（状态：${last.tts_status}）`
    } else if (totalGenerated === 0 && (last.skipped || 0) > 0) {
      message.value = `TTS 已就绪：${last.total} 段均有音频，已跳过。若要换音色请勾选「强制重新生成」`
    } else {
      message.value = `TTS 完成：新生成 ${totalGenerated}/${last.total} 段（共 ${rounds} 轮，音色：${last.voice || ttsVoice.value}，状态：${last.tts_status}）`
    }
    if (ttsForceRegenerate.value) ttsForceRegenerate.value = false
  } catch (e: unknown) {
    const err = e as { code?: string; message?: string; response?: { data?: { detail?: string } } }
    const detail = err.response?.data?.detail
    if (err.code === 'ECONNABORTED' || /timeout/i.test(err.message || '')) {
      error.value = '本轮 TTS 超时。已完成部分已保存，请再点「生成段落 TTS」继续补全'
      try {
        await load()
      } catch {
        /* ignore */
      }
    } else {
      error.value = detail || 'TTS 生成失败'
    }
  } finally {
    generatingTts.value = false
  }
}

function previewAudio(url: string) {
  new Audio(url).play()
}

onMounted(load)
</script>

<template>
  <div class="max-w-4xl space-y-6">
    <div v-if="isNew" class="rounded-xl border bg-white p-6 space-y-4">
      <h2 class="font-semibold">新建文章</h2>
      <label class="block text-sm">
        <span class="text-neutral-500">标题</span>
        <input v-model="form.title" class="mt-1 w-full rounded-lg border px-3 py-2" />
      </label>
      <label class="block text-sm">
        <span class="text-neutral-500">封面图片链接（可选）</span>
        <input
          v-model="coverSourceUrl"
          class="mt-1 w-full rounded-lg border px-3 py-2 font-mono text-xs"
          placeholder="//img2.chinadaily.com.cn/images/..."
        />
        <span class="mt-1 block text-xs text-neutral-400">创建后自动从链接下载并上传到七牛</span>
      </label>
      <label class="block text-sm">
        <span class="text-neutral-500">状态</span>
        <select v-model="form.status" class="mt-1 w-full rounded-lg border px-3 py-2 text-sm">
          <option v-for="opt in statusOptions" :key="opt.value" :value="opt.value">{{ opt.label }}</option>
        </select>
      </label>
      <button type="button" class="rounded-lg bg-neutral-900 text-white px-4 py-2 text-sm" :disabled="saving" @click="saveMeta">
        创建
      </button>
    </div>

    <template v-else>
      <div v-if="loading" class="py-12 text-center text-neutral-500">加载中...</div>
      <template v-else-if="article">
        <div v-if="message" class="text-sm text-emerald-700">{{ message }}</div>
        <div v-if="error" class="text-sm text-red-600">{{ error }}</div>

        <div class="rounded-xl border bg-white p-6 space-y-4">
          <div class="flex flex-wrap items-center justify-between gap-2">
            <h2 class="font-semibold">基本信息</h2>
            <span class="text-xs text-neutral-500">{{ article.article_id }} · {{ statusLabel }} · TTS: {{ article.tts_status || 'none' }}</span>
          </div>
          <div class="grid sm:grid-cols-2 gap-4">
            <label class="block text-sm sm:col-span-2">
              <span class="text-neutral-500">标题</span>
              <input v-model="form.title" class="mt-1 w-full rounded-lg border px-3 py-2" />
            </label>
            <label class="block text-sm">
              <span class="text-neutral-500">状态</span>
              <select v-model="form.status" class="mt-1 w-full rounded-lg border px-3 py-2 text-sm">
                <option v-for="opt in statusOptions" :key="opt.value" :value="opt.value">{{ opt.label }}</option>
              </select>
              <span class="mt-1 block text-xs text-neutral-400">改为「已发布」后用户端可见；「已下架」会从前台隐藏</span>
            </label>
            <label class="block text-sm">
              <span class="text-neutral-500">难度 (1-5)</span>
              <input v-model.number="form.stars" type="number" min="1" max="5" class="mt-1 w-full rounded-lg border px-3 py-2" />
            </label>
            <label class="block text-sm">
              <span class="text-neutral-500">来源</span>
              <input v-model="form.source" class="mt-1 w-full rounded-lg border px-3 py-2" placeholder="CGTN / Xinhua" />
            </label>
            <label class="block text-sm">
              <span class="text-neutral-500">主题</span>
              <input v-model="form.topic" class="mt-1 w-full rounded-lg border px-3 py-2" placeholder="politics / tech" />
            </label>
            <label class="block text-sm sm:col-span-2">
              <span class="text-neutral-500">原文链接</span>
              <input v-model="form.source_url" class="mt-1 w-full rounded-lg border px-3 py-2" />
            </label>
            <label class="block text-sm sm:col-span-2">
              <span class="text-neutral-500">摘要</span>
              <textarea v-model="form.summary" rows="2" class="mt-1 w-full rounded-lg border px-3 py-2" />
            </label>
            <div class="block text-sm sm:col-span-2 space-y-3">
              <span class="text-neutral-500">封面</span>
              <input
                v-model="coverSourceUrl"
                class="mt-1 w-full rounded-lg border px-3 py-2 font-mono text-xs"
                placeholder="//img2.chinadaily.com.cn/images/202607/04/xxx.jpeg"
              />
              <div class="flex flex-wrap items-center gap-2">
                <button
                  type="button"
                  class="rounded-lg border px-4 py-2 text-sm"
                  :disabled="uploadingCover || !coverSourceUrl.trim()"
                  @click="uploadCover()"
                >
                  {{ uploadingCover ? '上传中...' : '从链接上传封面' }}
                </button>
                <span v-if="form.cover" class="text-xs text-neutral-500 truncate max-w-full">已保存：{{ form.cover }}</span>
              </div>
              <img
                v-if="form.cover"
                :src="resolveMediaUrl(form.cover)"
                alt="封面预览"
                class="h-28 w-44 object-cover rounded-lg border bg-neutral-50"
              />
            </div>
          </div>
          <div class="flex flex-wrap items-end gap-3">
            <label class="block text-sm">
              <span class="text-neutral-500">朗读音色</span>
              <select v-model="ttsVoice" class="mt-1 rounded-lg border px-3 py-2 text-sm min-w-[12rem]" :disabled="generatingTts">
                <option v-for="opt in ttsVoiceOptions" :key="opt.value" :value="opt.value">
                  {{ opt.label }}
                </option>
              </select>
            </label>
            <button
              type="button"
              class="rounded-lg border px-4 py-2 text-sm"
              :disabled="generatingTts || !article.segment_count"
              @click="generateTts"
            >
              {{ generatingTts ? '生成 TTS 中（自动分轮）...' : '生成段落 TTS' }}
            </button>
            <label class="flex items-center gap-2 text-sm text-neutral-600 pb-2 cursor-pointer">
              <input v-model="ttsForceRegenerate" type="checkbox" class="rounded" :disabled="generatingTts" />
              强制重新生成（覆盖已有）
            </label>
          </div>
          <p class="text-xs text-neutral-500 -mt-1">
            默认跳过已有音频，每轮并行生成约 8 段；长文会自动多轮，中断后可再点继续补全。
          </p>
          <div class="flex flex-wrap gap-2">
            <button type="button" class="rounded-lg bg-neutral-900 text-white px-4 py-2 text-sm" :disabled="saving" @click="saveMeta">保存</button>
            <button
              type="button"
              class="rounded-lg border px-4 py-2 text-sm"
              :disabled="enriching || importing || !article.segment_count"
              @click="enrichSegments"
            >
              {{ enriching ? 'AI 增强中（自动分轮）...' : 'AI 增强段落' }}
            </button>
            <button type="button" class="rounded-lg border px-4 py-2 text-sm" :disabled="importing || enriching || !article.segment_count" @click="reanalyze">
              仅重新分析词汇
            </button>
            <RouterLink
              :to="`/english/reading/${article.article_id}`"
              target="_blank"
              class="rounded-lg border px-4 py-2 text-sm"
            >
              预览
            </RouterLink>
          </div>
        </div>

        <div class="rounded-xl border bg-white p-6 space-y-4">
          <h2 class="font-semibold">导入英文原文</h2>
          <p class="text-sm text-neutral-500">
            粘贴后会<strong>快速分句入库</strong>（不调 AI）。导入成功后即可发布；译文与词汇高亮请点上方「AI 增强段落」。
          </p>
          <textarea v-model="englishText" rows="10" class="w-full rounded-lg border px-3 py-2 text-sm font-mono" placeholder="Paste English article text here..." />
          <button
            type="button"
            class="rounded-lg bg-amber-600 text-white px-4 py-2 text-sm"
            :disabled="importing || enriching || !englishText.trim()"
            @click="importText"
          >
            {{ importing ? '导入中...' : '导入并分句' }}
          </button>
        </div>

        <div class="rounded-xl border bg-white p-6 space-y-3">
          <div class="flex flex-wrap items-baseline justify-between gap-2">
            <h2 class="font-semibold">词汇与表达汇总</h2>
            <span class="text-xs text-neutral-400">
              {{ vocabSummaryCount > 0 ? `已解析 ${vocabSummaryCount} 条 / ${vocabSummaryPreview.length} 组` : '用户端「词文对照」分组来源' }}
            </span>
          </div>
          <p class="text-xs text-neutral-500 leading-relaxed">
            格式与剧集编辑页相同：分类名单独成行；词条可写「文中含义 / 例句 / 释义」，也可选填「难度：四级」。
          </p>
          <textarea
            v-model="form.vocab_summary"
            rows="10"
            placeholder="粘贴汇总内容…"
            class="w-full rounded-lg border border-black/10 px-3 py-2 text-sm font-mono"
          />
          <div v-if="vocabSummaryPreview.length" class="rounded-lg border border-black/5 bg-neutral-50 p-3 space-y-4 max-h-80 overflow-y-auto">
            <section v-for="(g, i) in vocabSummaryPreview" :key="`${g.title}-${i}`" class="space-y-2">
              <p class="text-xs font-medium text-neutral-700">{{ g.title }}（{{ g.items.length }}）</p>
              <ul class="space-y-2.5">
                <li
                  v-for="(it, j) in g.items"
                  :key="`${it.en}-${j}`"
                  class="text-xs text-neutral-600 leading-relaxed border-t border-black/[0.04] pt-2 first:border-0 first:pt-0"
                >
                  <p class="font-medium text-neutral-800">{{ j + 1 }}. {{ it.en }}</p>
                  <p v-if="it.note" class="mt-0.5"><span class="text-neutral-400">文中含义：</span>{{ it.note }}</p>
                  <p v-if="it.example" class="mt-0.5"><span class="text-neutral-400">例句：</span>{{ it.example }}</p>
                  <p v-if="it.zh" class="mt-0.5"><span class="text-neutral-400">释义：</span>{{ it.zh }}</p>
                  <p v-if="it.level" class="mt-0.5"><span class="text-neutral-400">难度：</span>{{ it.level }}</p>
                </li>
              </ul>
            </section>
          </div>
          <button type="button" class="rounded-lg bg-neutral-900 text-white px-4 py-2 text-sm" :disabled="saving" @click="saveMeta">
            保存汇总
          </button>
        </div>

        <div class="rounded-xl border bg-white p-6 space-y-3">
          <h2 class="font-semibold">段落预览 ({{ article.segment_count }})</h2>
          <div v-for="(seg, i) in article.segments" :key="i" class="rounded-lg border p-3 text-sm space-y-1">
            <div class="flex items-start justify-between gap-2">
              <p class="font-medium flex-1">{{ seg.english }}</p>
              <button
                v-if="seg.audio_url"
                type="button"
                class="shrink-0 text-xs text-blue-600 underline"
                @click="previewAudio(seg.audio_url!)"
              >
                试听
              </button>
            </div>
            <p class="text-neutral-600">{{ seg.chinese || '—' }}</p>
          </div>
        </div>
      </template>
    </template>
  </div>
</template>
