<script setup lang="ts">
import { onMounted, ref, watch } from 'vue'
import {
  adminListFeedback,
  adminUpdateFeedback,
  type AdminFeedback,
} from '@/api/admin'
import { resolveMediaUrl } from '@/utils/mediaUrl'

const loading = ref(true)
const savingId = ref<number | null>(null)
const error = ref('')
const rows = ref<AdminFeedback[]>([])
const total = ref(0)
const page = ref(1)
const statusFilter = ref('')
const previewUrl = ref('')

const statusOptions = [
  { value: '', label: '全部' },
  { value: 'pending', label: '待处理' },
  { value: 'reviewing', label: '处理中' },
  { value: 'done', label: '已完成' },
  { value: 'closed', label: '已关闭' },
]

const statusLabel: Record<string, string> = {
  pending: '待处理',
  reviewing: '处理中',
  done: '已完成',
  closed: '已关闭',
}

async function load() {
  loading.value = true
  error.value = ''
  try {
    const data = await adminListFeedback({
      page: page.value,
      page_size: 20,
      status: statusFilter.value || undefined,
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

async function setStatus(row: AdminFeedback, status: string) {
  savingId.value = row.id
  error.value = ''
  try {
    const updated = await adminUpdateFeedback(row.id, { status })
    const idx = rows.value.findIndex((r) => r.id === row.id)
    if (idx >= 0) rows.value[idx] = updated
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '更新失败'
  } finally {
    savingId.value = null
  }
}

async function saveNote(row: AdminFeedback, note: string) {
  savingId.value = row.id
  error.value = ''
  try {
    const updated = await adminUpdateFeedback(row.id, { admin_note: note })
    const idx = rows.value.findIndex((r) => r.id === row.id)
    if (idx >= 0) rows.value[idx] = updated
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '备注保存失败'
  } finally {
    savingId.value = null
  }
}

watch(statusFilter, () => {
  page.value = 1
  void load()
})

onMounted(load)
</script>

<template>
  <div class="space-y-4">
    <div class="flex flex-wrap items-center justify-between gap-3">
      <p class="text-sm text-neutral-500">共 {{ total }} 条反馈</p>
      <div class="flex flex-wrap gap-1.5">
        <button
          v-for="opt in statusOptions"
          :key="opt.value || 'all'"
          type="button"
          class="text-xs px-2.5 py-1 rounded-full border transition"
          :class="
            statusFilter === opt.value
              ? 'border-neutral-900 bg-neutral-900 text-white'
              : 'border-black/10 bg-white hover:border-neutral-300'
          "
          @click="statusFilter = opt.value"
        >
          {{ opt.label }}
        </button>
      </div>
    </div>

    <p v-if="error" class="text-sm text-red-600">{{ error }}</p>
    <p v-if="loading" class="text-sm text-neutral-500 py-8 text-center">加载中…</p>
    <p v-else-if="!rows.length" class="text-sm text-neutral-400 py-12 text-center">暂无反馈</p>

    <div v-else class="space-y-3">
      <article
        v-for="row in rows"
        :key="row.id"
        class="rounded-xl border border-black/5 bg-white p-4 space-y-3"
      >
        <div class="flex flex-wrap items-start justify-between gap-2">
          <div class="min-w-0">
            <h2 class="font-medium text-neutral-900">{{ row.title }}</h2>
            <p class="text-xs text-neutral-500 mt-1">
              #{{ row.id }} ·
              {{ row.user_nickname || row.user_email || `用户 ${row.user_id}` }}
              <span v-if="row.user_nickname && row.user_email">（{{ row.user_email }}）</span>
              · {{ row.created_at }}
            </p>
          </div>
          <span
            class="text-[11px] px-2 py-0.5 rounded-full font-medium shrink-0"
            :class="{
              'bg-amber-100 text-amber-800': row.status === 'pending',
              'bg-sky-100 text-sky-800': row.status === 'reviewing',
              'bg-emerald-100 text-emerald-800': row.status === 'done',
              'bg-neutral-100 text-neutral-600': row.status === 'closed',
            }"
          >
            {{ statusLabel[row.status] || row.status }}
          </span>
        </div>

        <p class="text-sm text-neutral-700 whitespace-pre-wrap leading-relaxed">{{ row.body }}</p>

        <div v-if="row.image_urls?.length" class="flex flex-wrap gap-2">
          <button
            v-for="url in row.image_urls"
            :key="url"
            type="button"
            class="w-24 h-24 rounded-lg overflow-hidden border border-black/10 hover:opacity-90"
            @click="previewUrl = resolveMediaUrl(url)"
          >
            <img :src="resolveMediaUrl(url)" alt="" class="w-full h-full object-cover" />
          </button>
        </div>

        <div class="flex flex-wrap items-center gap-2 pt-1">
          <button
            v-for="opt in statusOptions.filter((o) => o.value)"
            :key="opt.value"
            type="button"
            class="text-xs px-2.5 py-1 rounded-lg border border-black/10 hover:bg-neutral-50 disabled:opacity-50"
            :disabled="savingId === row.id || row.status === opt.value"
            @click="setStatus(row, opt.value)"
          >
            标为{{ opt.label }}
          </button>
        </div>

        <div>
          <label class="block text-xs text-neutral-500 mb-1">管理员备注（仅后台可见）</label>
          <div class="flex gap-2">
            <input
              :value="row.admin_note"
              type="text"
              class="flex-1 min-w-0 rounded-lg border border-black/10 px-3 py-1.5 text-sm"
              placeholder="处理说明…"
              @change="saveNote(row, ($event.target as HTMLInputElement).value)"
            />
          </div>
        </div>
      </article>
    </div>

    <div v-if="total > 20" class="flex justify-center gap-2 pt-2">
      <button
        type="button"
        class="text-sm px-3 py-1.5 rounded-lg border border-black/10 disabled:opacity-40"
        :disabled="page <= 1 || loading"
        @click="page -= 1; load()"
      >
        上一页
      </button>
      <span class="text-sm text-neutral-500 self-center">第 {{ page }} 页</span>
      <button
        type="button"
        class="text-sm px-3 py-1.5 rounded-lg border border-black/10 disabled:opacity-40"
        :disabled="page * 20 >= total || loading"
        @click="page += 1; load()"
      >
        下一页
      </button>
    </div>

    <Teleport to="body">
      <div
        v-if="previewUrl"
        class="fixed inset-0 z-[90] bg-black/70 flex items-center justify-center p-4"
        @click="previewUrl = ''"
      >
        <img :src="previewUrl" alt="" class="max-w-full max-h-full rounded-lg object-contain" />
      </div>
    </Teleport>
  </div>
</template>
