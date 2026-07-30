<script setup lang="ts">
import { onMounted, onUnmounted, ref } from 'vue'
import { RouterLink, useRoute } from 'vue-router'
import {
  getMembershipOrder,
  mockPayMembershipOrder,
  type MembershipOrder,
} from '@/api/membership'
import { copyText } from '@/utils/clipboard'

const route = useRoute()
const order = ref<MembershipOrder | null>(null)
const error = ref('')
const loading = ref(true)
const paying = ref(false)
const copied = ref(false)
let timer: ReturnType<typeof setInterval> | undefined

const orderNo = () => {
  const raw = route.query.order
  return typeof raw === 'string' ? raw.trim() : ''
}

async function refresh() {
  const no = orderNo()
  if (!no) {
    error.value = '缺少订单号'
    loading.value = false
    return
  }
  try {
    order.value = await getMembershipOrder(no)
    error.value = ''
    if (order.value.status === 'paid' && timer) {
      clearInterval(timer)
      timer = undefined
    }
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = typeof msg === 'string' ? msg : '查询订单失败'
  } finally {
    loading.value = false
  }
}

async function doMockPay() {
  const no = orderNo()
  if (!no) return
  paying.value = true
  error.value = ''
  try {
    order.value = await mockPayMembershipOrder(no)
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = typeof msg === 'string' ? msg : '模拟支付失败'
  } finally {
    paying.value = false
  }
}

async function copySignup() {
  const url = order.value?.signup_url
  if (!url) return
  copied.value = await copyText(url)
}

onMounted(async () => {
  await refresh()
  const wantMock = route.query.mock === '1' || route.query.mock === 'true'
  if (wantMock && order.value && order.value.status === 'pending' && order.value.mock) {
    await doMockPay()
  }
  if (order.value?.status !== 'paid') {
    timer = setInterval(() => {
      void refresh()
    }, 2500)
  }
})

onUnmounted(() => {
  if (timer) clearInterval(timer)
})
</script>

<template>
  <div class="min-h-dvh flex items-center justify-center px-4 py-12 bg-neutral-50 dark:bg-neutral-950">
    <div class="w-full max-w-md rounded-2xl border border-black/5 dark:border-white/10 bg-white dark:bg-neutral-900 p-6 sm:p-8 shadow-sm">
      <h1 class="text-xl font-semibold mb-1">支付结果</h1>
      <p class="text-sm text-neutral-500 dark:text-neutral-400 mb-6">订单号 {{ orderNo() || '—' }}</p>

      <div v-if="loading" class="text-sm text-neutral-500 py-8 text-center">查询中...</div>
      <p v-else-if="error" class="text-sm text-red-600 dark:text-red-400 mb-4">{{ error }}</p>

      <template v-else-if="order">
        <div
          v-if="order.status === 'paid'"
          class="rounded-xl border border-green-200 dark:border-green-900 bg-green-50 dark:bg-green-950/40 px-4 py-4 mb-5 space-y-2"
        >
          <p class="text-sm font-medium text-green-800 dark:text-green-200">支付成功</p>
          <p class="text-sm text-green-800/90 dark:text-green-200/90 leading-relaxed">
            已为邮箱 <span class="font-medium">{{ order.email }}</span> 生成注册邀请。请使用下方链接完成注册（建议与付款邮箱一致）。
          </p>
          <p v-if="order.activation_code" class="text-xs text-neutral-600 dark:text-neutral-300">
            激活码：<span class="font-mono">{{ order.activation_code }}</span>
          </p>
        </div>

        <div
          v-else
          class="rounded-xl border border-amber-200 dark:border-amber-900 bg-amber-50 dark:bg-amber-950/40 px-4 py-4 mb-5 space-y-2"
        >
          <p class="text-sm font-medium text-amber-900 dark:text-amber-200">等待支付确认</p>
          <p class="text-sm text-amber-900/90 dark:text-amber-200/90 leading-relaxed">
            若你已在支付宝完成付款，请稍候，本页会自动刷新。也可稍后用同一订单号再打开此页。
          </p>
          <button
            v-if="order.mock"
            type="button"
            class="text-sm px-3 py-1.5 rounded-lg bg-amber-600 text-white hover:bg-amber-700 disabled:opacity-60"
            :disabled="paying"
            @click="doMockPay"
          >
            {{ paying ? '处理中...' : '模拟支付成功' }}
          </button>
        </div>

        <div class="space-y-3">
          <RouterLink
            v-if="order.activation_code"
            :to="`/signup?code=${encodeURIComponent(order.activation_code)}`"
            class="block w-full text-center rounded-lg bg-neutral-900 text-white py-2.5 text-sm font-medium hover:bg-neutral-800 dark:bg-neutral-100 dark:text-neutral-900"
          >
            立即注册开通会员
          </RouterLink>
          <button
            v-if="order.signup_url"
            type="button"
            class="w-full text-sm text-neutral-500 hover:text-neutral-800 dark:hover:text-neutral-200"
            @click="copySignup"
          >
            {{ copied ? '已复制注册链接' : '复制注册链接' }}
          </button>
          <RouterLink
            to="/pricing"
            class="block w-full text-center text-sm text-neutral-500 hover:text-neutral-800 dark:hover:text-neutral-200"
          >
            返回购买页
          </RouterLink>
        </div>
      </template>
    </div>
  </div>
</template>
