<script setup lang="ts">
import { onMounted, ref, watch } from 'vue'
import {
  adminListWishes,
  adminUpdateWish,
  type AdminWish,
} from '@/api/admin'

const loading = ref(true)
const savingId = ref<number | null>(null)
const error = ref('')
const rows = ref<AdminWish[]>([])
const total = ref(0)
const page = ref(1)
const statusFilter = ref('')
const hiddenFilter = ref('')
const draftReply = ref<Record<number, string>>({})

const statusOptions = [
  { value: '', label: '全部' },
  { value: 'pending', label: '待回复' },
  { value: 'replied', label: '已回复' },
  { value: 'done', label: '已实现' },
]

const statusLabel: Record<string, string> = {
  pending: '待回复',
  replied: '已回复',
  done: '已实现',
}

async function load() {
  loading.value = true
  error.value = ''
  try {
    const data = await adminListWishes({
      page: page.value,
      page_size: 20,
      status: statusFilter.value || undefined,
      hidden: hiddenFilter.value || undefined,
    })
    rows.value = data.results
    total.value = data.count
    const next: Record<number, string> = {}
    for (const row of data.results) next[row.id] = row.admin_reply
    draftReply.value = next
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '加载失败'
  } finally {
    loading.value = false
  }
}

function replaceRow(updated: AdminWish) {
  const idx = rows.value.findIndex((r) => r.id === updated.id)
  if (idx >= 0) rows.value[idx] = updated
  draftReply.value[updated.id] = updated.admin_reply
}

async function setStatus(row: AdminWish, status: string) {
  savingId.value = row.id
  error.value = ''
  try {
    replaceRow(await adminUpdateWish(row.id, { status }))
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '更新失败'
  } finally {
    savingId.value = null
  }
}

async function saveReply(row: AdminWish) {
  savingId.value = row.id
  error.value = ''
  try {
    replaceRow(await adminUpdateWish(row.id, { admin_reply: draftReply.value[row.id] || '' }))
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '回复保存失败'
  } finally {
    savingId.value = null
  }
}

async function setHidden(row: AdminWish, hidden: boolean) {
  savingId.value = row.id
  error.value = ''
  try {
    replaceRow(await adminUpdateWish(row.id, { hidden }))
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '更新失败'
  } finally {
    savingId.value = null
  }
}

watch([statusFilter, hiddenFilter], () => {
  page.value = 1
  void load()
})

onMounted(load)
</script>

<template>
  <div class="space-y-4">
    <div class="flex flex-wrap items-center justify-between gap-3">
      <p class="text-sm text-neutral-500">共 {{ total }} 条需求</p>
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
        <button
          type="button"
          class="text-xs px-2.5 py-1 rounded-full border transition"
          :class="
            hiddenFilter === 'true'
              ? 'border-red-700 bg-red-700 text-white'
              : 'border-black/10 bg-white hover:border-neutral-300'
          "
          @click="hiddenFilter = hiddenFilter === 'true' ? '' : 'true'"
        >
          已隐藏
        </button>
      </div>
    </div>

    <p v-if="error" class="text-sm text-red-600">{{ error }}</p>
    <p v-if="loading" class="text-sm text-neutral-500 py-8 text-center">加载中…</p>
    <p v-else-if="!rows.length" class="text-sm text-neutral-400 py-12 text-center">暂无需求</p>

    <div v-else class="space-y-3">
      <article
        v-for="row in rows"
        :key="row.id"
        class="rounded-xl border border-black/5 bg-white p-4 space-y-3"
        :class="row.hidden ? 'opacity-70' : ''"
      >
        <div class="flex flex-wrap items-start justify-between gap-2">
          <div class="min-w-0">
            <h2 class="font-medium text-neutral-900">{{ row.title }}</h2>
            <p class="text-xs text-neutral-500 mt-1">
              #{{ row.id }} ·
              {{ row.user_nickname || row.user_email || `用户 ${row.user_id}` }}
              <span v-if="row.user_nickname && row.user_email">（{{ row.user_email }}）</span>
              · 赞 {{ row.like_count }}
              · {{ row.created_at }}
            </p>
          </div>
          <span
            class="text-[11px] px-2 py-0.5 rounded-full font-medium shrink-0"
            :class="{
              'bg-amber-100 text-amber-800': row.status === 'pending',
              'bg-sky-100 text-sky-800': row.status === 'replied',
              'bg-emerald-100 text-emerald-800': row.status === 'done',
            }"
          >
            {{ statusLabel[row.status] || row.status }}
          </span>
        </div>

        <p class="text-sm text-neutral-700 whitespace-pre-wrap leading-relaxed">{{ row.body }}</p>

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
          <button
            type="button"
            class="text-xs px-2.5 py-1 rounded-lg border border-black/10 hover:bg-neutral-50 disabled:opacity-50"
            :disabled="savingId === row.id"
            @click="setHidden(row, !row.hidden)"
          >
            {{ row.hidden ? '取消隐藏' : '从墙上隐藏' }}
          </button>
        </div>

        <div>
          <label class="block text-xs text-neutral-500 mb-1">公开回复（会出现在便利贴上）</label>
          <div class="flex gap-2">
            <textarea
              v-model="draftReply[row.id]"
              rows="2"
              class="flex-1 min-w-0 rounded-lg border border-black/10 px-3 py-1.5 text-sm"
              placeholder="您好，我们已经记下了…"
            />
            <button
              type="button"
              class="self-end text-xs px-3 py-1.5 rounded-lg bg-neutral-900 text-white disabled:opacity-50"
              :disabled="savingId === row.id"
              @click="saveReply(row)"
            >
              保存
            </button>
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
  </div>
</template>
