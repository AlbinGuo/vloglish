<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { adminListMembershipOrders, type MembershipOrderRow } from '@/api/admin'

const loading = ref(true)
const status = ref<'all' | 'pending' | 'paid' | 'closed' | 'refunded'>('all')
const page = ref(1)
const total = ref(0)
const rows = ref<MembershipOrderRow[]>([])
const error = ref('')

const totalPages = computed(() => Math.max(1, Math.ceil(total.value / 20)))

const statusLabel: Record<string, string> = {
  pending: '待支付',
  paid: '已支付',
  closed: '已关闭',
  refunded: '已退款',
}

function planLabel(plan?: string) {
  if (plan === 'quarter') return '季度'
  if (plan === 'year') return '年度'
  if (plan === 'test') return '测试'
  return '永久'
}

function channelLabel(row: MembershipOrderRow) {
  if (row.channel === 'wx_virtual') return '小程序'
  if (row.channel === 'alipay') return '支付宝'
  return row.channel || '—'
}

function paySourceLabel(row: MembershipOrderRow) {
  const client = (row.pay_client || '').toLowerCase()
  if (client === 'ios') return 'iOS'
  if (client === 'android') return 'Android'
  if (client === 'devtools') return '开发者工具'
  if (client === 'windows') return 'Windows'
  if (client === 'mac') return 'Mac'
  if (client === 'wap') return '手机浏览器'
  if (client === 'web') return '浏览器'
  if (row.via_pc) return '网页扫码'
  if (row.channel === 'wx_virtual') return '小程序'
  if (row.channel === 'alipay') return '浏览器'
  return '—'
}

function tradeNo(row: MembershipOrderRow) {
  return row.alipay_trade_no || row.wx_order_id || ''
}

async function load() {
  loading.value = true
  error.value = ''
  try {
    const data = await adminListMembershipOrders({
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

onMounted(load)
</script>

<template>
  <div class="space-y-4">
    <div class="flex flex-wrap items-center gap-3">
      <select
        v-model="status"
        class="rounded-lg border border-black/10 px-3 py-2 text-sm bg-white"
        @change="page = 1; load()"
      >
        <option value="all">全部状态</option>
        <option value="pending">待支付</option>
        <option value="paid">已支付</option>
        <option value="closed">已关闭</option>
        <option value="refunded">已退款</option>
      </select>
      <button type="button" class="text-sm px-3 py-2 rounded-lg border border-black/10 hover:bg-neutral-50" @click="load">
        刷新
      </button>
      <span class="text-sm text-neutral-500">共 {{ total }} 单</span>
    </div>

    <p v-if="error" class="text-sm text-red-600">{{ error }}</p>
    <div v-if="loading" class="text-sm text-neutral-500 py-12 text-center">加载中...</div>
    <div v-else class="overflow-x-auto rounded-xl border border-black/5 bg-white">
      <table class="min-w-full text-sm">
        <thead class="bg-neutral-50 text-left text-neutral-500">
          <tr>
            <th class="px-3 py-2 font-medium">订单号</th>
            <th class="px-3 py-2 font-medium">账号</th>
            <th class="px-3 py-2 font-medium">套餐</th>
            <th class="px-3 py-2 font-medium">金额</th>
            <th class="px-3 py-2 font-medium">状态</th>
            <th class="px-3 py-2 font-medium">渠道</th>
            <th class="px-3 py-2 font-medium">访问端</th>
            <th class="px-3 py-2 font-medium">激活码</th>
            <th class="px-3 py-2 font-medium">支付单号</th>
            <th class="px-3 py-2 font-medium">支付时间</th>
            <th class="px-3 py-2 font-medium">创建时间</th>
          </tr>
        </thead>
        <tbody>
          <tr v-if="!rows.length">
            <td colspan="11" class="px-3 py-10 text-center text-neutral-400">暂无订单</td>
          </tr>
          <tr v-for="row in rows" :key="row.id" class="border-t border-black/5">
            <td class="px-3 py-2 font-mono text-xs">{{ row.order_no }}</td>
            <td class="px-3 py-2">
              <div :title="row.email">{{ row.email_display || row.email }}</div>
              <div v-if="row.wechat_only" class="text-[11px] text-neutral-400">未绑网页邮箱</div>
            </td>
            <td class="px-3 py-2 whitespace-nowrap">{{ planLabel(row.plan) }}</td>
            <td class="px-3 py-2">¥{{ row.amount_yuan }}</td>
            <td class="px-3 py-2">{{ statusLabel[row.status] || row.status }}</td>
            <td class="px-3 py-2 whitespace-nowrap">{{ channelLabel(row) }}</td>
            <td class="px-3 py-2 whitespace-nowrap">{{ paySourceLabel(row) }}</td>
            <td class="px-3 py-2 font-mono">{{ row.activation_code || '—' }}</td>
            <td class="px-3 py-2 font-mono text-xs" :title="tradeNo(row)">
              {{ tradeNo(row) || '—' }}
            </td>
            <td class="px-3 py-2 text-neutral-500 whitespace-nowrap">{{ row.paid_at || '—' }}</td>
            <td class="px-3 py-2 text-neutral-500 whitespace-nowrap">{{ row.created_at }}</td>
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
