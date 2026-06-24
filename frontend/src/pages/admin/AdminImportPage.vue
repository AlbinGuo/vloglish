<script setup lang="ts">
import { ref } from 'vue'
import { adminExportEpisodesJson, adminImportEpisodesJson, type ImportResult } from '@/api/admin'

const jsonText = ref('')
const defaultStatus = ref('draft')
const markDemo = ref(false)
const importing = ref(false)
const exporting = ref(false)
const error = ref('')
const result = ref<ImportResult | null>(null)

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
</script>

<template>
  <div class="space-y-6 max-w-3xl">
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
        <h2 class="font-medium">批量导入</h2>
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
