<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import {
  adminListTestMembers,
  adminPurgeTestMembers,
  type AdminTestMemberRow,
} from '@/api/admin'

const loading = ref(true)
const purging = ref(false)
const page = ref(1)
const total = ref(0)
const rows = ref<AdminTestMemberRow[]>([])
const error = ref('')
const notice = ref('')

const totalPages = computed(() => Math.max(1, Math.ceil(total.value / 50)))

function sourceLabel(source?: string | null) {
  if (source === 'test_trial') return '外部测试试用'
  if (source === 'apple_iap_sandbox') return 'Apple 沙盒'
  if (source && source.endsWith('_revoked')) return '已撤销'
  return source || '—'
}

function planLabel(plan?: string | null) {
  if (plan === 'quarter') return '季度'
  if (plan === 'year') return '年度'
  if (plan === 'forever') return '永久'
  if (plan === 'custom') return '自定义'
  return plan || '—'
}

async function load() {
  loading.value = true
  error.value = ''
  try {
    const data = await adminListTestMembers({ page: page.value, page_size: 50 })
    rows.value = data.results
    total.value = data.count
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '加载失败'
  } finally {
    loading.value = false
  }
}

async function purgeAll() {
  if (purging.value) return
  const confirmed = window.confirm(
    `确认撤销全部 ${total.value} 个测试/沙盒会员？\n撤销后这些账号将回到普通用户，需要重新购买才能成为会员。此操作不可自动恢复。`,
  )
  if (!confirmed) return
  purging.value = true
  error.value = ''
  notice.value = ''
  try {
    const res = await adminPurgeTestMembers()
    notice.value = `已撤销 ${res.revoked} 个测试会员。${
      res.test_mode_enabled ? '当前后端仍开启外部测试模式（EXTERNAL_TEST_MODE=true）。' : ''
    }`
    page.value = 1
    await load()
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '清理失败'
  } finally {
    purging.value = false
  }
}

onMounted(load)
</script>

<template>
  <div class="space-y-4">
    <div class="flex flex-wrap items-center gap-3">
      <button type="button" class="text-sm px-3 py-2 rounded-lg border border-black/10 hover:bg-neutral-50" @click="load">
        刷新
      </button>
      <button
        type="button"
        class="text-sm px-3 py-2 rounded-lg bg-red-600 text-white hover:bg-red-700 disabled:opacity-50"
        :disabled="purging || loading || !total"
        @click="purgeAll"
      >
        {{ purging ? '清理中...' : `一键清理全部测试会员（${total}）` }}
      </button>
      <span class="text-sm text-neutral-500">共 {{ total }} 个测试会员</span>
    </div>

    <p class="text-xs text-neutral-500">
      列表包含 <span class="font-medium">外部测试试用（test_trial）</span> 与
      <span class="font-medium">Apple 沙盒（apple_iap_sandbox）</span> 会员。
      正式上线前请先关闭后端 <code>EXTERNAL_TEST_MODE</code>，再点「一键清理」。
    </p>

    <p v-if="error" class="text-sm text-red-600">{{ error }}</p>
    <p v-if="notice" class="text-sm text-green-700">{{ notice }}</p>

    <div v-if="loading" class="text-sm text-neutral-500 py-12 text-center">加载中...</div>
    <div v-else class="overflow-x-auto rounded-xl border border-black/5 bg-white">
      <table class="min-w-full text-sm">
        <thead class="bg-neutral-50 text-left text-neutral-500">
          <tr>
            <th class="px-3 py-2 font-medium">用户 ID</th>
            <th class="px-3 py-2 font-medium">邮箱</th>
            <th class="px-3 py-2 font-medium">昵称</th>
            <th class="px-3 py-2 font-medium">来源</th>
            <th class="px-3 py-2 font-medium">套餐</th>
            <th class="px-3 py-2 font-medium">到期时间</th>
            <th class="px-3 py-2 font-medium">会员状态</th>
          </tr>
        </thead>
        <tbody>
          <tr v-if="!rows.length">
            <td colspan="7" class="px-3 py-10 text-center text-neutral-400">暂无测试会员</td>
          </tr>
          <tr v-for="row in rows" :key="row.id" class="border-t border-black/5">
            <td class="px-3 py-2 font-mono text-xs">{{ row.id }}</td>
            <td class="px-3 py-2" :title="row.email">{{ row.email }}</td>
            <td class="px-3 py-2">{{ row.nickname || '—' }}</td>
            <td class="px-3 py-2 whitespace-nowrap">{{ sourceLabel(row.member_source) }}</td>
            <td class="px-3 py-2 whitespace-nowrap">{{ planLabel(row.member_plan) }}</td>
            <td class="px-3 py-2 text-neutral-500 whitespace-nowrap">{{ row.member_until || '—' }}</td>
            <td class="px-3 py-2">
              <span
                class="inline-flex items-center rounded px-2 py-0.5 text-xs"
                :class="row.is_member ? 'bg-green-50 text-green-700' : 'bg-neutral-100 text-neutral-500'"
              >
                {{ row.is_member ? '有效' : '已失效' }}
              </span>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-if="totalPages > 1" class="flex items-center gap-2 justify-end">
      <button
        type="button"
        class="text-sm px-3 py-1.5 rounded border disabled:opacity-40"
        :disabled="page <= 1"
        @click="page -= 1; load()"
      >
        上一页
      </button>
      <span class="text-sm text-neutral-500">{{ page }} / {{ totalPages }}</span>
      <button
        type="button"
        class="text-sm px-3 py-1.5 rounded border disabled:opacity-40"
        :disabled="page >= totalPages"
        @click="page += 1; load()"
      >
        下一页
      </button>
    </div>
  </div>
</template>
