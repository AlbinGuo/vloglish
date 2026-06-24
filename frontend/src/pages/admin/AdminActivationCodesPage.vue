<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import {
  adminDeleteCode,
  adminGenerateCodes,
  adminListActivationCodes,
  type ActivationCodeRow,
} from '@/api/admin'

const loading = ref(true)
const generating = ref(false)
const count = ref(10)
const status = ref<'all' | 'available' | 'used'>('all')
const page = ref(1)
const total = ref(0)
const rows = ref<ActivationCodeRow[]>([])
const message = ref('')
const error = ref('')

const totalPages = computed(() => Math.max(1, Math.ceil(total.value / 20)))

async function load() {
  loading.value = true
  error.value = ''
  try {
    const data = await adminListActivationCodes({
      status: status.value,
      page: page.value,
      page_size: 20,
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

async function generate() {
  generating.value = true
  message.value = ''
  error.value = ''
  try {
    const data = await adminGenerateCodes(count.value)
    message.value = `已生成 ${data.codes.length} 个：${data.codes.join('、')}`
    page.value = 1
    await load()
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '生成失败'
  } finally {
    generating.value = false
  }
}

async function remove(code: string) {
  if (!confirm(`确定删除激活码 ${code}？`)) return
  try {
    await adminDeleteCode(code)
    await load()
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '删除失败'
  }
}

function changeStatus(next: 'all' | 'available' | 'used') {
  status.value = next
  page.value = 1
  load()
}

onMounted(load)
</script>

<template>
  <div class="space-y-4">
    <div class="rounded-xl border border-black/5 bg-white p-4 flex flex-wrap items-end gap-3">
      <div>
        <label class="block text-xs text-neutral-500 mb-1">生成数量</label>
        <input
          v-model.number="count"
          type="number"
          min="1"
          max="500"
          class="w-28 rounded-lg border border-black/10 px-3 py-2 text-sm"
        />
      </div>
      <button
        type="button"
        class="rounded-lg bg-neutral-900 text-white px-4 py-2 text-sm hover:bg-neutral-800 disabled:opacity-60"
        :disabled="generating"
        @click="generate"
      >
        {{ generating ? '生成中...' : '批量生成' }}
      </button>
      <div class="flex gap-2 ml-auto">
        <button
          v-for="opt in [
            ['all', '全部'],
            ['available', '未使用'],
            ['used', '已使用'],
          ]"
          :key="opt[0]"
          type="button"
          class="px-3 py-1.5 rounded-lg text-sm border"
          :class="
            status === opt[0]
              ? 'border-neutral-900 bg-neutral-900 text-white'
              : 'border-black/10 hover:bg-neutral-50'
          "
          @click="changeStatus(opt[0] as 'all' | 'available' | 'used')"
        >
          {{ opt[1] }}
        </button>
      </div>
    </div>

    <p v-if="message" class="text-sm text-green-700">{{ message }}</p>
    <p v-if="error" class="text-sm text-red-600">{{ error }}</p>

    <div class="rounded-xl border border-black/5 bg-white overflow-hidden">
      <div v-if="loading" class="p-8 text-center text-neutral-500">加载中...</div>
      <table v-else class="w-full text-sm">
        <thead class="bg-neutral-50 text-neutral-500">
          <tr>
            <th class="text-left px-4 py-3 font-medium">激活码</th>
            <th class="text-left px-4 py-3 font-medium">状态</th>
            <th class="text-left px-4 py-3 font-medium">使用者</th>
            <th class="text-left px-4 py-3 font-medium">使用时间</th>
            <th class="text-left px-4 py-3 font-medium">创建时间</th>
            <th class="text-right px-4 py-3 font-medium">操作</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in rows" :key="row.id" class="border-t border-black/5">
            <td class="px-4 py-3 font-mono">{{ row.code }}</td>
            <td class="px-4 py-3">{{ row.used_by_user_id ? '已使用' : '未使用' }}</td>
            <td class="px-4 py-3">{{ row.used_by_email || '-' }}</td>
            <td class="px-4 py-3">{{ row.used_at || '-' }}</td>
            <td class="px-4 py-3">{{ row.created_at }}</td>
            <td class="px-4 py-3 text-right">
              <button
                v-if="!row.used_by_user_id"
                type="button"
                class="text-red-600 hover:underline"
                @click="remove(row.code)"
              >
                删除
              </button>
            </td>
          </tr>
          <tr v-if="!rows.length">
            <td colspan="6" class="px-4 py-8 text-center text-neutral-500">暂无数据</td>
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
