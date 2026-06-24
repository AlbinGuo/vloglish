<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { RouterLink } from 'vue-router'
import { adminDeleteEpisode, adminListEpisodes, type AdminEpisodeListItem } from '@/api/admin'

const loading = ref(true)
const deletingId = ref<number | null>(null)
const search = ref('')
const status = ref('')
const page = ref(1)
const total = ref(0)
const rows = ref<AdminEpisodeListItem[]>([])
const error = ref('')

const totalPages = computed(() => Math.max(1, Math.ceil(total.value / 20)))

const statusLabel: Record<string, string> = {
  draft: '草稿',
  published: '已发布',
  archived: '已下架',
}

async function load() {
  loading.value = true
  error.value = ''
  try {
    const data = await adminListEpisodes({
      page: page.value,
      page_size: 20,
      search: search.value.trim() || undefined,
      status: status.value || undefined,
    })
    rows.value = data.results
    total.value = data.count
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '加载失败'
  } finally {
    loading.value = false
  }
}

function doSearch() {
  page.value = 1
  load()
}

async function remove(row: AdminEpisodeListItem) {
  if (!confirm(`确定删除「${row.short_title}」？此操作不可恢复。`)) return
  deletingId.value = row.id
  try {
    await adminDeleteEpisode(row.id)
    await load()
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '删除失败'
  } finally {
    deletingId.value = null
  }
}

function formatDuration(seconds: number) {
  const m = Math.floor(seconds / 60)
  const s = Math.floor(seconds % 60)
  return `${m}:${String(s).padStart(2, '0')}`
}

onMounted(load)
</script>

<template>
  <div class="space-y-4">
    <div class="flex flex-wrap items-center gap-3">
      <RouterLink
        to="/gnadmin/episodes/new"
        class="rounded-lg bg-neutral-900 text-white px-4 py-2 text-sm hover:bg-neutral-800"
      >
        新建剧集
      </RouterLink>
    </div>

    <div class="rounded-xl border border-black/5 bg-white p-4 flex flex-wrap gap-3">
      <input
        v-model="search"
        type="search"
        placeholder="搜索标题 / video_id / 作者"
        class="flex-1 min-w-[200px] rounded-lg border border-black/10 px-3 py-2 text-sm"
        @keyup.enter="doSearch"
      />
      <select v-model="status" class="rounded-lg border border-black/10 px-3 py-2 text-sm" @change="doSearch">
        <option value="">全部状态</option>
        <option value="draft">草稿</option>
        <option value="published">已发布</option>
        <option value="archived">已下架</option>
      </select>
      <button
        type="button"
        class="rounded-lg bg-neutral-900 text-white px-4 py-2 text-sm hover:bg-neutral-800"
        @click="doSearch"
      >
        搜索
      </button>
    </div>

    <p v-if="error" class="text-sm text-red-600">{{ error }}</p>

    <div class="rounded-xl border border-black/5 bg-white overflow-hidden">
      <div v-if="loading" class="p-8 text-center text-neutral-500">加载中...</div>
      <table v-else class="w-full text-sm">
        <thead class="bg-neutral-50 text-neutral-500">
          <tr>
            <th class="text-left px-4 py-3 font-medium">标题</th>
            <th class="text-left px-4 py-3 font-medium">作者</th>
            <th class="text-left px-4 py-3 font-medium">难度</th>
            <th class="text-left px-4 py-3 font-medium">字幕</th>
            <th class="text-left px-4 py-3 font-medium">时长</th>
            <th class="text-left px-4 py-3 font-medium">状态</th>
            <th class="text-right px-4 py-3 font-medium">操作</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in rows" :key="row.id" class="border-t border-black/5">
            <td class="px-4 py-3">
              <div class="font-medium">{{ row.short_title }}</div>
              <div class="text-xs text-neutral-400 mt-0.5">{{ row.video_id }}</div>
              <div v-if="row.is_demo" class="text-xs text-amber-600 mt-0.5">Demo</div>
            </td>
            <td class="px-4 py-3">{{ row.author_name }}</td>
            <td class="px-4 py-3">{{ '★'.repeat(row.stars) }}</td>
            <td class="px-4 py-3">{{ row.subtitle_count }}</td>
            <td class="px-4 py-3">{{ formatDuration(row.clip_length) }}</td>
            <td class="px-4 py-3">{{ statusLabel[row.status] ?? row.status }}</td>
            <td class="px-4 py-3 text-right space-x-3">
              <RouterLink :to="`/gnadmin/episodes/${row.id}`" class="text-neutral-900 hover:underline">编辑</RouterLink>
              <a
                v-if="row.status === 'published'"
                :href="`/english/episode/${row.video_id}`"
                target="_blank"
                class="text-neutral-500 hover:underline"
              >
                预览
              </a>
              <button
                type="button"
                class="text-red-600 hover:underline disabled:opacity-50"
                :disabled="deletingId === row.id"
                @click="remove(row)"
              >
                删除
              </button>
            </td>
          </tr>
          <tr v-if="!rows.length">
            <td colspan="7" class="px-4 py-8 text-center text-neutral-500">暂无剧集</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-if="totalPages > 1" class="flex justify-center gap-3">
      <button
        type="button"
        class="px-3 py-1.5 text-sm border rounded-lg disabled:opacity-40"
        :disabled="page <= 1"
        @click="page--; load()"
      >
        上一页
      </button>
      <span class="text-sm text-neutral-500">{{ page }} / {{ totalPages }}</span>
      <button
        type="button"
        class="px-3 py-1.5 text-sm border rounded-lg disabled:opacity-40"
        :disabled="page >= totalPages"
        @click="page++; load()"
      >
        下一页
      </button>
    </div>
  </div>
</template>
