<script setup lang="ts">
import { onMounted, ref } from 'vue'
import {
  adminListAuthorUrges,
  type AdminAuthorUrgeRow,
  type AdminAuthorUrgeSummary,
} from '@/api/admin'

const loading = ref(true)
const error = ref('')
const rows = ref<AdminAuthorUrgeRow[]>([])
const summary = ref<AdminAuthorUrgeSummary[]>([])
const total = ref(0)
const page = ref(1)
const pageSize = 20

async function load() {
  loading.value = true
  error.value = ''
  try {
    const data = await adminListAuthorUrges(page.value, pageSize)
    rows.value = data.results
    summary.value = data.summary
    total.value = data.count
  } catch (e: unknown) {
    error.value =
      (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail || '加载失败'
  } finally {
    loading.value = false
  }
}

function prev() {
  if (page.value > 1) {
    page.value--
    void load()
  }
}
function next() {
  if (page.value * pageSize < total.value) {
    page.value++
    void load()
  }
}

onMounted(load)
</script>

<template>
  <div class="p-4 sm:p-6">
    <div class="mb-4 flex items-center justify-between">
      <h1 class="text-lg font-semibold">催更管理</h1>
      <button type="button" class="rounded-lg border px-3 py-1.5 text-sm" @click="load">刷新</button>
    </div>
    <p v-if="error" class="mb-3 text-sm text-red-600">{{ error }}</p>

    <section class="mb-6">
      <h2 class="mb-2 text-sm font-medium text-neutral-700">按作者汇总</h2>
      <div v-if="!summary.length" class="text-sm text-neutral-500">暂无催更</div>
      <div v-else class="grid gap-2 sm:grid-cols-2 lg:grid-cols-3">
        <div
          v-for="s in summary"
          :key="s.author_id"
          class="flex items-center justify-between gap-2 rounded-lg border bg-white px-3 py-2 text-sm"
        >
          <span class="truncate font-medium">{{ s.author_name || '# ' + s.author_id }}</span>
          <span class="shrink-0 text-neutral-500">{{ s.user_count }} 人 / 共 {{ s.total_count }} 次</span>
        </div>
      </div>
    </section>

    <section>
      <h2 class="mb-2 text-sm font-medium text-neutral-700">催更明细</h2>
      <div class="overflow-x-auto rounded-lg border bg-white">
        <table class="w-full text-sm">
          <thead class="bg-neutral-50 text-left text-neutral-500">
            <tr>
              <th class="px-3 py-2 font-medium">作者</th>
              <th class="px-3 py-2 font-medium">用户</th>
              <th class="px-3 py-2 font-medium">次数</th>
              <th class="px-3 py-2 font-medium">最近催更</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="loading && !rows.length">
              <td colspan="4" class="px-3 py-6 text-center text-neutral-500">加载中…</td>
            </tr>
            <tr v-else-if="!rows.length">
              <td colspan="4" class="px-3 py-6 text-center text-neutral-500">暂无数据</td>
            </tr>
            <tr v-for="r in rows" :key="r.id" class="border-t align-top">
              <td class="px-3 py-2">{{ r.author_name || '# ' + r.author_id }}</td>
              <td class="px-3 py-2">
                <div class="truncate">{{ r.user_nickname || r.user_email || '用户 ' + r.user_id }}</div>
                <div class="truncate text-xs text-neutral-400">
                  {{ r.user_email }}<span v-if="r.user_no"> · ID {{ r.user_no }}</span>
                </div>
              </td>
              <td class="px-3 py-2">{{ r.count }}</td>
              <td class="px-3 py-2 text-neutral-500">{{ r.last_urged_at }}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="mt-3 flex items-center justify-end gap-2 text-sm">
        <button type="button" class="rounded border px-3 py-1 disabled:opacity-40" :disabled="page <= 1" @click="prev">
          上一页
        </button>
        <span class="text-neutral-500">{{ page }} / {{ Math.max(1, Math.ceil(total / pageSize)) }}</span>
        <button
          type="button"
          class="rounded border px-3 py-1 disabled:opacity-40"
          :disabled="page * pageSize >= total"
          @click="next"
        >
          下一页
        </button>
      </div>
    </section>
  </div>
</template>
