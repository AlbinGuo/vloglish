<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { RouterLink } from 'vue-router'
import { adminDeleteArticle, adminListArticles, type AdminArticleListItem } from '@/api/admin'

const loading = ref(true)
const error = ref('')
const rows = ref<AdminArticleListItem[]>([])
const total = ref(0)
const page = ref(1)
const pageSize = 20
const search = ref('')
const status = ref('')
const sourceFilter = ref<'all' | 'user' | 'official'>('all')

const totalPages = computed(() => Math.max(1, Math.ceil(total.value / pageSize)))

const statusLabel: Record<string, string> = {
  draft: '草稿',
  published: '已发布',
  archived: '已下架',
  rejected: '已驳回',
}

async function load() {
  loading.value = true
  error.value = ''
  try {
    const data = await adminListArticles({
      page: page.value,
      page_size: pageSize,
      status: status.value || undefined,
      q: search.value.trim() || undefined,
      user_submitted:
        sourceFilter.value === 'user' ? true : sourceFilter.value === 'official' ? false : undefined,
    })
    rows.value = data.results
    total.value = data.count
  } catch {
    error.value = '加载失败'
  } finally {
    loading.value = false
  }
}

async function remove(row: AdminArticleListItem) {
  if (!confirm(`确定删除「${row.title}」？`)) return
  await adminDeleteArticle(row.id)
  await load()
}

function doSearch() {
  page.value = 1
  load()
}

onMounted(load)
</script>

<template>
  <div class="space-y-4">
    <div class="flex flex-wrap items-center justify-between gap-3">
      <RouterLink
        to="/gnadmin/reading/new"
        class="inline-flex items-center rounded-lg bg-neutral-900 text-white px-4 py-2 text-sm"
      >
        新建文章
      </RouterLink>
      <div class="flex flex-wrap gap-2">
        <select v-model="sourceFilter" class="rounded-lg border px-3 py-2 text-sm" @change="doSearch">
          <option value="all">全部来源</option>
          <option value="user">用户投稿</option>
          <option value="official">官方录入</option>
        </select>
        <select v-model="status" class="rounded-lg border px-3 py-2 text-sm" @change="doSearch">
          <option value="">全部状态</option>
          <option value="draft">草稿</option>
          <option value="published">已发布</option>
          <option value="archived">已下架</option>
          <option value="rejected">已驳回</option>
        </select>
        <input v-model="search" type="search" placeholder="搜索标题" class="rounded-lg border px-3 py-2 text-sm" @keydown.enter="doSearch" />
        <button type="button" class="rounded-lg border px-3 py-2 text-sm" @click="doSearch">搜索</button>
      </div>
    </div>

    <div v-if="loading" class="py-16 text-center text-neutral-500">加载中...</div>
    <div v-else-if="error" class="py-16 text-center text-red-500">{{ error }}</div>
    <div v-else class="rounded-xl border bg-white overflow-hidden">
      <table class="w-full text-sm">
        <thead class="bg-neutral-50 text-left text-neutral-500">
          <tr>
            <th class="px-4 py-3">标题</th>
            <th class="px-4 py-3">来源</th>
            <th class="px-4 py-3">段落</th>
            <th class="px-4 py-3">状态</th>
            <th class="px-4 py-3">发布日期</th>
            <th class="px-4 py-3"></th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in rows" :key="row.id" class="border-t">
            <td class="px-4 py-3">
              <div class="font-medium">{{ row.title }}</div>
              <p v-if="row.is_user_submitted" class="mt-0.5 text-xs text-violet-700">
                用户投稿 · {{ row.is_catalog_public ? '全站可见' : '仅投稿者可见' }}
                <span v-if="row.submitted_by_email"> · {{ row.submitted_by_email }}</span>
              </p>
            </td>
            <td class="px-4 py-3">{{ row.source || '—' }}</td>
            <td class="px-4 py-3">{{ row.segment_count }} / {{ row.word_count }}词</td>
            <td class="px-4 py-3">{{ statusLabel[row.status] || row.status }}</td>
            <td class="px-4 py-3">{{ row.published_at || '—' }}</td>
            <td class="px-4 py-3 text-right space-x-2">
              <RouterLink :to="`/gnadmin/reading/${row.id}`" class="text-blue-600 hover:underline">编辑</RouterLink>
              <button type="button" class="text-red-600 hover:underline" @click="remove(row)">删除</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-if="totalPages > 1" class="flex justify-center gap-2">
      <button type="button" class="px-3 py-1 border rounded" :disabled="page <= 1" @click="page--; load()">上一页</button>
      <span class="px-2 py-1 text-sm">{{ page }} / {{ totalPages }}</span>
      <button type="button" class="px-3 py-1 border rounded" :disabled="page >= totalPages" @click="page++; load()">下一页</button>
    </div>
  </div>
</template>
