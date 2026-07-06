<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import {
  adminAnalyzeArticle,
  adminCreateArticle,
  adminGetArticle,
  adminImportArticleText,
  adminPublishArticle,
  adminUpdateArticle,
  type AdminArticleDetail,
} from '@/api/admin'

const route = useRoute()
const router = useRouter()

const isNew = computed(() => route.path.endsWith('/new'))
const refId = computed(() => route.params.id as string | undefined)

const loading = ref(false)
const saving = ref(false)
const importing = ref(false)
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
})
const englishText = ref('')
const article = ref<AdminArticleDetail | null>(null)

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
      const created = await adminCreateArticle(form.value)
      await router.replace(`/gnadmin/reading/${created.id}`)
      article.value = created
    } else if (refId.value) {
      article.value = await adminUpdateArticle(refId.value, form.value)
    }
    message.value = '已保存'
  } catch {
    error.value = '保存失败'
  } finally {
    saving.value = false
  }
}

async function importText() {
  if (!refId.value || !englishText.value.trim()) return
  importing.value = true
  message.value = ''
  error.value = ''
  try {
    await adminImportArticleText(refId.value, {
      english_text: englishText.value,
      auto_translate: true,
      auto_analyze: true,
    })
    englishText.value = ''
    await load()
    message.value = '导入成功'
  } catch (e: unknown) {
    const detail = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = detail || '导入失败'
  } finally {
    importing.value = false
  }
}

async function reanalyze() {
  if (!refId.value) return
  importing.value = true
  try {
    await adminAnalyzeArticle(refId.value)
    await load()
    message.value = '词汇分析完成'
  } catch {
    error.value = '分析失败'
  } finally {
    importing.value = false
  }
}

async function publish() {
  if (!refId.value) return
  try {
    await adminPublishArticle(refId.value)
    await load()
    message.value = '已发布'
  } catch (e: unknown) {
    const detail = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = detail || '发布失败'
  }
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
            <span class="text-xs text-neutral-500">{{ article.article_id }} · {{ article.status }}</span>
          </div>
          <div class="grid sm:grid-cols-2 gap-4">
            <label class="block text-sm sm:col-span-2">
              <span class="text-neutral-500">标题</span>
              <input v-model="form.title" class="mt-1 w-full rounded-lg border px-3 py-2" />
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
            <label class="block text-sm">
              <span class="text-neutral-500">难度 (1-5)</span>
              <input v-model.number="form.stars" type="number" min="1" max="5" class="mt-1 w-full rounded-lg border px-3 py-2" />
            </label>
          </div>
          <div class="flex flex-wrap gap-2">
            <button type="button" class="rounded-lg bg-neutral-900 text-white px-4 py-2 text-sm" :disabled="saving" @click="saveMeta">保存</button>
            <button type="button" class="rounded-lg border px-4 py-2 text-sm" @click="reanalyze">重新分析词汇</button>
            <button
              v-if="article.status !== 'published'"
              type="button"
              class="rounded-lg bg-emerald-600 text-white px-4 py-2 text-sm"
              @click="publish"
            >
              发布
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
          <p class="text-sm text-neutral-500">粘贴后会自动分句、机翻、词汇高亮（需配置 DeepSeek）</p>
          <textarea v-model="englishText" rows="10" class="w-full rounded-lg border px-3 py-2 text-sm font-mono" placeholder="Paste English article text here..." />
          <button
            type="button"
            class="rounded-lg bg-amber-600 text-white px-4 py-2 text-sm"
            :disabled="importing || !englishText.trim()"
            @click="importText"
          >
            {{ importing ? '处理中...' : '导入并处理' }}
          </button>
        </div>

        <div class="rounded-xl border bg-white p-6 space-y-3">
          <h2 class="font-semibold">段落预览 ({{ article.segment_count }})</h2>
          <div v-for="(seg, i) in article.segments" :key="i" class="rounded-lg border p-3 text-sm space-y-1">
            <p class="font-medium">{{ seg.english }}</p>
            <p class="text-neutral-600">{{ seg.chinese || '—' }}</p>
          </div>
        </div>
      </template>
    </template>
  </div>
</template>
