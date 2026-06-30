<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import {
  adminExportEpisodesJson,
  adminImportEpisodesJson,
  adminTecoAuthStatus,
  adminTecoCatalog,
  adminTecoImportEpisode,
  adminTecoSyncDbFromQiniu,
  type AdminTecoCatalogItem,
  type AdminTecoImportEpisodeResult,
  type ImportResult,
} from '@/api/admin'

const jsonText = ref('')
const defaultStatus = ref('draft')
const markDemo = ref(false)
const importing = ref(false)
const exporting = ref(false)
const error = ref('')
const result = ref<ImportResult | null>(null)

// teco-lab import
const tecoAuth = ref<Awaited<ReturnType<typeof adminTecoAuthStatus>> | null>(null)
const indexFrom = ref(150)
const indexTo = ref(190)
const tecoStatus = ref('published')
const skipExisting = ref(true)
const applyBranding = ref(true)
const catalogLoading = ref(false)
const catalog = ref<AdminTecoCatalogItem[]>([])
const tecoImporting = ref(false)
const tecoSyncing = ref(false)
const tecoProgress = ref('')
const tecoResults = ref<AdminTecoImportEpisodeResult[]>([])
const tecoErrors = ref<string[]>([])

const pendingCatalog = computed(() => catalog.value.filter((item) => !item.exists_in_db || !skipExisting.value))
const pendingQiniuSync = computed(() =>
  catalog.value.filter((item) => item.qiniu_has_video && !item.exists_in_db),
)

async function onFileChange(event: Event) {
  const file = (event.target as HTMLInputElement).files?.[0]
  if (!file) return
  jsonText.value = await file.text()
  ;(event.target as HTMLInputElement).value = ''
}

async function doImport() {
  if (!jsonText.value.trim()) {
    error.value = '请粘贴或上传 JSON'
    return
  }
  importing.value = true
  error.value = ''
  result.value = null
  try {
    const parsed = JSON.parse(jsonText.value) as { episodes?: unknown[]; details?: unknown[] }
    result.value = await adminImportEpisodesJson({
      episodes: parsed.episodes ?? [],
      details: parsed.details ?? [],
      default_status: defaultStatus.value,
      mark_demo: markDemo.value,
    })
  } catch (e: unknown) {
    if (e instanceof SyntaxError) {
      error.value = 'JSON 格式无效'
    } else {
      const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
      error.value = msg || '导入失败'
    }
  } finally {
    importing.value = false
  }
}

async function doExport() {
  exporting.value = true
  error.value = ''
  try {
    const data = await adminExportEpisodesJson()
    const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `episodes-export-${new Date().toISOString().slice(0, 10)}.json`
    a.click()
    URL.revokeObjectURL(url)
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '导出失败'
  } finally {
    exporting.value = false
  }
}

function loadSampleHint() {
  jsonText.value = `{
  "episodes": [
    {
      "video_id": "example12345678",
      "index": 100,
      "short_title": "示例标题",
      "summary": "摘要",
      "stars": 3,
      "author": { "name": "Author", "gender": "m", "nationality": "🇺🇸", "accent": "美国" },
      "tags": [{ "name": "旅行" }]
    }
  ],
  "details": []
}`
}

async function refreshTecoAuth() {
  try {
    tecoAuth.value = await adminTecoAuthStatus()
  } catch {
    tecoAuth.value = null
  }
}

async function loadTecoCatalog() {
  catalogLoading.value = true
  error.value = ''
  try {
    const data = await adminTecoCatalog(indexFrom.value, indexTo.value, true)
    catalog.value = data.results
    if (!data.count) {
      error.value = `第 ${data.index_from}–${data.index_to} 期未找到可导入条目`
    }
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '拉取目录失败'
    catalog.value = []
  } finally {
    catalogLoading.value = false
  }
}

async function importTecoRange() {
  if (!catalog.value.length) {
    await loadTecoCatalog()
  }
  const targets = skipExisting.value
    ? catalog.value.filter((item) => !item.exists_in_db)
    : [...catalog.value]
  if (!targets.length) {
    error.value = '没有需要导入的剧集（可能已全部存在）'
    return
  }

  tecoImporting.value = true
  tecoResults.value = []
  tecoErrors.value = []
  error.value = ''

  for (let i = 0; i < targets.length; i += 1) {
    const item = targets[i]
    tecoProgress.value = `正在导入 ${i + 1}/${targets.length}：第 ${item.index ?? '?'} 期 · ${item.short_title}`
    try {
      const row = await adminTecoImportEpisode({
        video_id: item.video_id,
        index: item.index ?? undefined,
        short_title: item.short_title,
        status: tecoStatus.value,
        skip_existing: skipExisting.value,
        apply_branding: applyBranding.value,
      })
      tecoResults.value.push(row)
      if (row.skipped) {
        tecoErrors.value.push(`${item.video_id}：已跳过`)
      }
    } catch (e: unknown) {
      const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
      tecoErrors.value.push(`${item.video_id}：${msg || '导入失败'}`)
    }
  }

  tecoProgress.value = `完成：成功 ${tecoResults.value.filter((r) => !r.skipped).length} 条，跳过/失败见下方`
  tecoImporting.value = false
  await loadTecoCatalog()
}

async function syncDbFromQiniu() {
  if (!tecoAuth.value?.configured) {
    error.value = '请先配置 teco-lab 会员认证'
    return
  }

  tecoSyncing.value = true
  tecoResults.value = []
  tecoErrors.value = []
  error.value = ''
  tecoProgress.value = `正在同步第 ${indexFrom.value}–${indexTo.value} 期（七牛已有则补写数据库，不重新上传）…`

  try {
    const data = await adminTecoSyncDbFromQiniu({
      index_from: indexFrom.value,
      index_to: indexTo.value,
      status: tecoStatus.value,
      skip_existing: true,
    })
    tecoResults.value = data.results
    tecoErrors.value = data.errors
    tecoProgress.value = `同步完成：新建 ${data.created} · 更新 ${data.updated} · 跳过 ${data.skipped} · 失败 ${data.failed}`
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '同步失败'
  } finally {
    tecoSyncing.value = false
    await loadTecoCatalog()
  }
}

onMounted(() => {
  refreshTecoAuth()
})
</script>

<template>
  <div class="space-y-6 max-w-4xl">
    <section class="rounded-xl border border-amber-200 bg-amber-50/80 p-5 space-y-4">
      <div class="flex items-start justify-between gap-3">
        <div>
          <h2 class="font-medium text-amber-950">从 teco-lab.com 导入</h2>
          <p class="text-sm text-amber-900/80 mt-1">
            拉取会员目录剧集，下载视频/音频/字幕，去除左上角原站水印并加上 <strong>vloglish</strong> 标识；
            封面从视频截帧生成（每期不同），不使用 teco-lab 原封面。
          </p>
        </div>
        <button
          type="button"
          class="text-xs text-amber-800 hover:underline shrink-0"
          @click="refreshTecoAuth"
        >
          刷新认证状态
        </button>
      </div>

      <div
        class="rounded-lg border px-3 py-2 text-sm"
        :class="tecoAuth?.configured ? 'border-green-200 bg-green-50 text-green-900' : 'border-red-200 bg-red-50 text-red-800'"
      >
        <template v-if="tecoAuth?.configured">
          已配置 teco-lab 会员认证
          <span v-if="tecoAuth.has_session_file" class="text-green-700">（session 文件）</span>
          <span v-else-if="tecoAuth.has_access_token" class="text-green-700">（TECO_ACCESS_TOKEN）</span>
          <span v-else class="text-green-700">（账号密码）</span>
        </template>
        <template v-else>
          未配置认证。请在 <code class="text-xs">backend/data/teco_session.json</code> 放入浏览器导出的 token，
          或在 <code class="text-xs">backend/.env</code> 配置 TECO_ACCESS_TOKEN / TECO_EMAIL+TECO_PASSWORD。
        </template>
      </div>

      <div
        class="rounded-lg border px-3 py-2 text-sm"
        :class="tecoAuth?.ffmpeg_configured ? 'border-green-200 bg-green-50 text-green-900' : 'border-red-200 bg-red-50 text-red-800'"
      >
        <template v-if="tecoAuth?.ffmpeg_configured">
          已检测到 ffmpeg / ffprobe
          <span class="text-green-700">（{{ tecoAuth.ffmpeg_dir }}）</span>
        </template>
        <template v-else>
          未找到 ffmpeg 或 ffprobe。请在 <code class="text-xs">backend/.env</code> 配置
          <code class="text-xs">VLOGISH_TOOLS_DIR=E:\vloglish</code>（目录内需含 ffmpeg.exe、ffprobe.exe），然后重启 backend。
          <span v-if="tecoAuth?.ffmpeg_dir" class="block mt-1 text-red-700">当前检测目录：{{ tecoAuth.ffmpeg_dir }}</span>
        </template>
      </div>

      <div class="flex flex-wrap gap-4 text-sm items-end">
        <label class="flex flex-col gap-1">
          <span class="text-neutral-600">起始期</span>
          <input v-model.number="indexFrom" type="number" min="1" class="rounded-lg border px-2 py-1.5 w-24" />
        </label>
        <label class="flex flex-col gap-1">
          <span class="text-neutral-600">结束期</span>
          <input v-model.number="indexTo" type="number" min="1" class="rounded-lg border px-2 py-1.5 w-24" />
        </label>
        <label class="flex flex-col gap-1">
          <span class="text-neutral-600">导入后状态</span>
          <select v-model="tecoStatus" class="rounded-lg border px-2 py-1.5">
            <option value="published">已发布</option>
            <option value="draft">草稿</option>
          </select>
        </label>
        <label class="flex items-center gap-2 pb-1.5">
          <input v-model="skipExisting" type="checkbox" class="rounded" />
          <span>跳过已存在 video_id</span>
        </label>
        <label class="flex items-center gap-2 pb-1.5">
          <input v-model="applyBranding" type="checkbox" class="rounded" />
          <span>去原水印 + vloglish 水印 + 自生成封面</span>
        </label>
      </div>

      <div class="flex flex-wrap gap-2">
        <button
          type="button"
          class="rounded-lg border px-4 py-2 text-sm hover:bg-white disabled:opacity-50"
          :disabled="catalogLoading || tecoImporting || tecoSyncing"
          @click="loadTecoCatalog"
        >
          {{ catalogLoading ? '加载中...' : '预览目录' }}
        </button>
        <button
          type="button"
          class="rounded-lg border border-green-700 text-green-900 px-4 py-2 text-sm hover:bg-green-50 disabled:opacity-50"
          :disabled="tecoSyncing || tecoImporting || !tecoAuth?.configured"
          @click="syncDbFromQiniu"
        >
          {{ tecoSyncing ? '同步中...' : '七牛已有 → 补写数据库' }}
        </button>
        <button
          type="button"
          class="rounded-lg bg-amber-900 text-white px-5 py-2 text-sm hover:bg-amber-800 disabled:opacity-50"
          :disabled="tecoImporting || tecoSyncing || !tecoAuth?.configured || !tecoAuth?.ffmpeg_configured"
          @click="importTecoRange"
        >
          {{ tecoImporting ? '导入中...' : `一键导入第 ${indexFrom}–${indexTo} 期` }}
        </button>
      </div>

      <p v-if="tecoProgress" class="text-sm text-amber-900">{{ tecoProgress }}</p>

      <div v-if="catalog.length" class="overflow-x-auto rounded-lg border bg-white">
        <table class="min-w-full text-sm">
          <thead class="bg-neutral-50 text-neutral-500">
            <tr>
              <th class="px-3 py-2 text-left">期数</th>
              <th class="px-3 py-2 text-left">标题</th>
              <th class="px-3 py-2 text-left">字幕</th>
              <th class="px-3 py-2 text-left">七牛</th>
              <th class="px-3 py-2 text-left">库内</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in catalog" :key="item.video_id" class="border-t">
              <td class="px-3 py-2 whitespace-nowrap">{{ item.index ?? '—' }}</td>
              <td class="px-3 py-2 max-w-xs truncate" :title="item.short_title">{{ item.short_title }}</td>
              <td class="px-3 py-2">{{ item.subtitle_count }}</td>
              <td class="px-3 py-2">
                <span v-if="item.qiniu_has_video" class="text-green-700">有视频</span>
                <span v-else class="text-neutral-400">无</span>
              </td>
              <td class="px-3 py-2">
                <span v-if="item.exists_in_db" class="text-neutral-400">已有</span>
                <span v-else class="text-green-700">待导入</span>
              </td>
            </tr>
          </tbody>
        </table>
        <p class="px-3 py-2 text-xs text-neutral-500 border-t">
          共 {{ catalog.length }} 期 · 待导入 {{ pendingCatalog.length }} 期 · 七牛有、库无 {{ pendingQiniuSync.length }} 期
        </p>
      </div>

      <section v-if="tecoResults.length" class="rounded-lg border border-green-200 bg-green-50 p-4 text-sm space-y-2">
        <p class="font-medium text-green-900">导入结果</p>
        <ul class="space-y-1 max-h-48 overflow-y-auto">
          <li v-for="row in tecoResults" :key="row.video_id">
            {{ row.video_id }} · {{ row.message }}
            <span v-if="row.subtitle_count">（{{ row.subtitle_count }} 字幕）</span>
          </li>
        </ul>
        <ul v-if="tecoErrors.length" class="text-amber-800 list-disc pl-5 space-y-1">
          <li v-for="(err, i) in tecoErrors" :key="i">{{ err }}</li>
        </ul>
      </section>
    </section>

    <section class="rounded-xl border border-black/5 bg-white p-5 space-y-4">
      <h2 class="font-medium">导出备份</h2>
      <p class="text-sm text-neutral-500">导出全库剧集为 <code class="text-xs">extra-episodes.json</code> 格式，可用于备份或迁移。</p>
      <button
        type="button"
        class="rounded-lg border px-4 py-2 text-sm hover:bg-neutral-50 disabled:opacity-50"
        :disabled="exporting"
        @click="doExport"
      >
        {{ exporting ? '导出中...' : '下载 JSON' }}
      </button>
    </section>

    <section class="rounded-xl border border-black/5 bg-white p-5 space-y-4">
      <div class="flex items-center justify-between gap-3">
        <h2 class="font-medium">批量导入 JSON</h2>
        <button type="button" class="text-xs text-neutral-500 hover:text-neutral-900" @click="loadSampleHint">
          查看格式示例
        </button>
      </div>
      <p class="text-sm text-neutral-500">
        支持 <code class="text-xs">analysis/extra-episodes.json</code> 同款结构。已存在的 video_id 会更新，新的会创建。
      </p>

      <div class="flex flex-wrap gap-4 text-sm">
        <label class="flex items-center gap-2">
          <span class="text-neutral-500">默认状态</span>
          <select v-model="defaultStatus" class="rounded-lg border px-2 py-1.5">
            <option value="draft">草稿</option>
            <option value="published">已发布</option>
            <option value="archived">已下架</option>
          </select>
        </label>
        <label class="flex items-center gap-2">
          <input v-model="markDemo" type="checkbox" class="rounded" />
          <span>标记为 Demo 内容 (is_demo)</span>
        </label>
      </div>

      <label class="block text-sm">
        <span class="text-neutral-500">选择 JSON 文件</span>
        <input type="file" accept=".json,application/json" class="mt-1 block text-sm" @change="onFileChange" />
      </label>

      <textarea
        v-model="jsonText"
        rows="12"
        placeholder='{ "episodes": [...], "details": [...] }'
        class="w-full rounded-lg border border-black/10 px-3 py-2 text-sm font-mono"
      />

      <button
        type="button"
        class="rounded-lg bg-neutral-900 text-white px-5 py-2 text-sm hover:bg-neutral-800 disabled:opacity-50"
        :disabled="importing"
        @click="doImport"
      >
        {{ importing ? '导入中...' : '开始导入' }}
      </button>
    </section>

    <p v-if="error" class="text-sm text-red-600">{{ error }}</p>

    <section v-if="result" class="rounded-xl border border-green-200 bg-green-50 p-5 text-sm space-y-2">
      <p class="font-medium text-green-900">导入完成</p>
      <p>新建 {{ result.created }} 条 · 更新 {{ result.updated }} 条 · 共处理 {{ result.total }} 个 video_id</p>
      <ul v-if="result.errors.length" class="text-amber-800 list-disc pl-5 space-y-1">
        <li v-for="(err, i) in result.errors" :key="i">{{ err }}</li>
      </ul>
    </section>
  </div>
</template>
