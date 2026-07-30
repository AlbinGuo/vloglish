<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import {
  adminCreateSeries,
  adminDeleteSeries,
  adminListSeries,
  adminUpdateSeries,
  type AdminSeries,
  type AdminSeriesPayload,
} from '@/api/admin'

const loading = ref(true)
const saving = ref(false)
const error = ref('')
const success = ref('')
const rows = ref<AdminSeries[]>([])
const search = ref('')
const statusFilter = ref('')

const showForm = ref(false)
const editing = ref<AdminSeries | null>(null)
const form = ref<AdminSeriesPayload>({
  slug: '',
  title: '',
  summary: '',
  cover: '',
  status: 'draft',
  sort_order: 0,
})

const filtered = computed(() => {
  const q = search.value.trim().toLowerCase()
  return rows.value.filter((row) => {
    if (statusFilter.value && row.status !== statusFilter.value) return false
    if (!q) return true
    return row.title.toLowerCase().includes(q) || row.slug.toLowerCase().includes(q)
  })
})

async function load() {
  loading.value = true
  error.value = ''
  try {
    const data = await adminListSeries()
    rows.value = data.results
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '加载失败'
  } finally {
    loading.value = false
  }
}

function openCreate() {
  editing.value = null
  form.value = {
    slug: '',
    title: '',
    summary: '',
    cover: '',
    status: 'draft',
    sort_order: 0,
  }
  showForm.value = true
  error.value = ''
  success.value = ''
}

function openEdit(row: AdminSeries) {
  editing.value = row
  form.value = {
    slug: row.slug,
    title: row.title,
    summary: row.summary,
    cover: row.cover,
    status: row.status,
    sort_order: row.sort_order,
  }
  showForm.value = true
  error.value = ''
  success.value = ''
}

function slugifyTitle() {
  if (editing.value || form.value.slug.trim()) return
  form.value.slug = form.value.title
    .trim()
    .toLowerCase()
    .replace(/[^\w\u4e00-\u9fff]+/g, '-')
    .replace(/-+/g, '-')
    .replace(/^-|-$/g, '')
    .slice(0, 64)
}

async function save() {
  if (!form.value.title.trim() || !form.value.slug.trim()) {
    error.value = '请填写合集标题和 slug'
    return
  }
  saving.value = true
  error.value = ''
  try {
    if (editing.value) {
      await adminUpdateSeries(editing.value.id, form.value)
      success.value = '合集已更新'
    } else {
      await adminCreateSeries(form.value)
      success.value = '合集已创建'
    }
    showForm.value = false
    await load()
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '保存失败'
  } finally {
    saving.value = false
  }
}

async function remove(row: AdminSeries) {
  if (!confirm(`确定删除合集「${row.title}」？所属剧集将变为独立单集。`)) return
  error.value = ''
  try {
    await adminDeleteSeries(row.id)
    success.value = '合集已删除'
    await load()
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '删除失败'
  }
}

onMounted(load)
</script>

<template>
  <div class="space-y-4">
    <div class="flex flex-wrap items-center justify-between gap-3">
      <div>
        <h1 class="text-lg font-semibold">合集</h1>
        <p class="text-sm text-neutral-500 mt-0.5">强顺序系列课，剧集按集序号连续学习</p>
      </div>
      <button
        type="button"
        class="px-3 py-1.5 rounded-lg bg-neutral-900 text-white text-sm"
        @click="openCreate"
      >
        新建合集
      </button>
    </div>

    <p v-if="error" class="text-sm text-red-600">{{ error }}</p>
    <p v-if="success" class="text-sm text-emerald-700">{{ success }}</p>

    <div class="flex flex-wrap gap-2">
      <input
        v-model="search"
        type="search"
        placeholder="搜索标题 / slug"
        class="px-3 py-1.5 rounded-lg border border-black/10 text-sm bg-white min-w-[12rem]"
      />
      <select v-model="statusFilter" class="px-3 py-1.5 rounded-lg border border-black/10 text-sm bg-white">
        <option value="">全部状态</option>
        <option value="draft">草稿</option>
        <option value="published">已发布</option>
        <option value="archived">已归档</option>
      </select>
    </div>

    <div v-if="loading" class="text-sm text-neutral-500 py-8 text-center">加载中...</div>
    <div v-else class="bg-white rounded-xl border border-black/5 overflow-hidden">
      <table class="w-full text-sm">
        <thead class="bg-neutral-50 text-neutral-500 text-left">
          <tr>
            <th class="px-3 py-2 font-medium">标题</th>
            <th class="px-3 py-2 font-medium">slug</th>
            <th class="px-3 py-2 font-medium">集数</th>
            <th class="px-3 py-2 font-medium">状态</th>
            <th class="px-3 py-2 font-medium">排序</th>
            <th class="px-3 py-2 font-medium w-36">操作</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in filtered" :key="row.id" class="border-t border-black/5">
            <td class="px-3 py-2.5 font-medium">{{ row.title }}</td>
            <td class="px-3 py-2.5 text-neutral-500 font-mono text-xs">{{ row.slug }}</td>
            <td class="px-3 py-2.5">{{ row.episode_count }}</td>
            <td class="px-3 py-2.5">{{ row.status }}</td>
            <td class="px-3 py-2.5">{{ row.sort_order }}</td>
            <td class="px-3 py-2.5 space-x-2">
              <button type="button" class="text-neutral-600 hover:text-black" @click="openEdit(row)">编辑</button>
              <button type="button" class="text-red-600 hover:text-red-700" @click="remove(row)">删除</button>
            </td>
          </tr>
          <tr v-if="!filtered.length">
            <td colspan="6" class="px-3 py-8 text-center text-neutral-400">暂无合集</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div
      v-if="showForm"
      class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4"
      @click.self="showForm = false"
    >
      <div class="bg-white rounded-2xl shadow-xl w-full max-w-lg p-5 space-y-4">
        <h2 class="text-base font-semibold">{{ editing ? '编辑合集' : '新建合集' }}</h2>
        <label class="block space-y-1">
          <span class="text-xs text-neutral-500">标题</span>
          <input
            v-model="form.title"
            class="w-full px-3 py-2 rounded-lg border border-black/10 text-sm"
            @blur="slugifyTitle"
          />
        </label>
        <label class="block space-y-1">
          <span class="text-xs text-neutral-500">slug（URL）</span>
          <input v-model="form.slug" class="w-full px-3 py-2 rounded-lg border border-black/10 text-sm font-mono" />
        </label>
        <label class="block space-y-1">
          <span class="text-xs text-neutral-500">简介</span>
          <textarea v-model="form.summary" rows="3" class="w-full px-3 py-2 rounded-lg border border-black/10 text-sm" />
        </label>
        <label class="block space-y-1">
          <span class="text-xs text-neutral-500">封面 URL</span>
          <input v-model="form.cover" class="w-full px-3 py-2 rounded-lg border border-black/10 text-sm" />
        </label>
        <div class="grid grid-cols-2 gap-3">
          <label class="block space-y-1">
            <span class="text-xs text-neutral-500">状态</span>
            <select v-model="form.status" class="w-full px-3 py-2 rounded-lg border border-black/10 text-sm">
              <option value="draft">草稿</option>
              <option value="published">已发布</option>
              <option value="archived">已归档</option>
            </select>
          </label>
          <label class="block space-y-1">
            <span class="text-xs text-neutral-500">排序</span>
            <input v-model.number="form.sort_order" type="number" class="w-full px-3 py-2 rounded-lg border border-black/10 text-sm" />
          </label>
        </div>
        <div class="flex justify-end gap-2 pt-2">
          <button type="button" class="px-3 py-1.5 rounded-lg border text-sm" @click="showForm = false">取消</button>
          <button
            type="button"
            class="px-3 py-1.5 rounded-lg bg-neutral-900 text-white text-sm disabled:opacity-50"
            :disabled="saving"
            @click="save"
          >
            {{ saving ? '保存中...' : '保存' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
