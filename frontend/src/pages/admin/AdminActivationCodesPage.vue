<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import {
  adminDeleteCode,
  adminGenerateCodes,
  adminListActivationCodes,
  type ActivationCodeRow,
} from '@/api/admin'
import { copyText } from '@/utils/clipboard'

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

function inviteLink(code: string) {
  const origin = typeof window !== 'undefined' ? window.location.origin : ''
  return `${origin}/signup?code=${encodeURIComponent(code)}`
}

async function copyInviteLink(code: string) {
  const link = inviteLink(code)
  const ok = await copyText(link)
  if (ok) {
    message.value = `已复制邀请链接：${link}`
    error.value = ''
  } else {
    error.value = `复制失败，请手动复制：${link}`
  }
}

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
    const links = data.codes.map((c) => inviteLink(c))
    message.value =
      data.codes.length === 1
        ? `已生成邀请链接（已复制）：${links[0]}`
        : `已生成 ${data.codes.length} 个邀请链接，可在列表中逐条复制`
    if (data.codes.length === 1) {
      const ok = await copyText(links[0])
      if (!ok) {
        message.value = `已生成邀请链接，请手动复制：${links[0]}`
      }
    }
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
    <div class="rounded-xl border border-black/5 bg-white p-4 flex flex-col sm:flex-row sm:flex-wrap sm:items-end gap-3">
      <div class="flex items-end gap-3">
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
      </div>
      <div class="flex gap-2 sm:ml-auto overflow-x-auto">
        <button
          v-for="opt in [
            ['all', '全部'],
            ['available', '未使用'],
            ['used', '已使用'],
          ]"
          :key="opt[0]"
          type="button"
          class="shrink-0 px-3 py-1.5 rounded-lg text-sm border"
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

    <p v-if="message" class="text-sm text-green-700 break-all">{{ message }}</p>
    <p v-if="error" class="text-sm text-red-600 break-all">{{ error }}</p>

    <div v-if="loading" class="rounded-xl border border-black/5 bg-white p-8 text-center text-neutral-500">
      加载中...
    </div>

    <!-- 手机：卡片列表，突出复制邀请链接 -->
    <div v-else class="md:hidden space-y-3">
      <article
        v-for="row in rows"
        :key="row.id"
        class="rounded-xl border border-black/5 bg-white p-4 space-y-3"
      >
        <div class="flex items-start justify-between gap-3">
          <div>
            <p class="font-mono text-base font-semibold tracking-wide">{{ row.code }}</p>
            <p class="text-xs text-neutral-500 mt-1">
              {{ row.used_by_user_id ? '已使用' : '未使用' }}
              <span v-if="row.used_by_email"> · {{ row.used_by_email }}</span>
            </p>
          </div>
          <span
            class="shrink-0 text-xs px-2 py-0.5 rounded-full"
            :class="row.used_by_user_id ? 'bg-neutral-100 text-neutral-500' : 'bg-emerald-50 text-emerald-700'"
          >
            {{ row.used_by_user_id ? '已用' : '可用' }}
          </span>
        </div>

        <p v-if="!row.used_by_user_id" class="text-xs text-neutral-400 font-mono break-all leading-relaxed">
          {{ inviteLink(row.code) }}
        </p>
        <p v-else class="text-xs text-neutral-400">
          使用时间 {{ row.used_at || '-' }}
        </p>

        <div v-if="!row.used_by_user_id" class="flex gap-2">
          <button
            type="button"
            class="flex-1 rounded-lg bg-neutral-900 text-white py-2.5 text-sm font-medium active:bg-neutral-800"
            @click="copyInviteLink(row.code)"
          >
            复制邀请链接
          </button>
          <button
            type="button"
            class="shrink-0 rounded-lg border border-red-200 text-red-600 px-3 py-2.5 text-sm"
            @click="remove(row.code)"
          >
            删除
          </button>
        </div>
        <p v-else class="text-xs text-neutral-400">创建于 {{ row.created_at }}</p>
      </article>
      <p v-if="!rows.length" class="rounded-xl border border-black/5 bg-white p-8 text-center text-neutral-500">
        暂无数据
      </p>
    </div>

    <!-- 桌面：表格 -->
    <div class="hidden md:block rounded-xl border border-black/5 bg-white overflow-hidden">
      <table class="w-full text-sm">
        <thead class="bg-neutral-50 text-neutral-500">
          <tr>
            <th class="text-left px-4 py-3 font-medium">激活码</th>
            <th class="text-left px-4 py-3 font-medium">邀请链接</th>
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
            <td
              class="px-4 py-3 text-xs text-neutral-500 font-mono max-w-[240px] truncate"
              :title="row.used_by_user_id ? '' : inviteLink(row.code)"
            >
              {{ row.used_by_user_id ? '-' : inviteLink(row.code) }}
            </td>
            <td class="px-4 py-3">{{ row.used_by_user_id ? '已使用' : '未使用' }}</td>
            <td class="px-4 py-3">{{ row.used_by_email || '-' }}</td>
            <td class="px-4 py-3">{{ row.used_at || '-' }}</td>
            <td class="px-4 py-3">{{ row.created_at }}</td>
            <td class="px-4 py-3 text-right space-x-3 whitespace-nowrap">
              <button
                v-if="!row.used_by_user_id"
                type="button"
                class="text-neutral-800 hover:underline"
                @click="copyInviteLink(row.code)"
              >
                复制邀请链接
              </button>
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
            <td colspan="7" class="px-4 py-8 text-center text-neutral-500">暂无数据</td>
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
