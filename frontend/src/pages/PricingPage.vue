<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import { createMembershipOrder, getMembershipPricing, type MembershipPricing } from '@/api/membership'

const router = useRouter()
const pricing = ref<MembershipPricing | null>(null)
const email = ref('')
const loading = ref(false)
const loadingPrice = ref(true)
const error = ref('')

const isMobile = computed(() => {
  if (typeof navigator === 'undefined') return false
  return /Android|iPhone|iPad|iPod|Mobile/i.test(navigator.userAgent)
})

onMounted(async () => {
  try {
    pricing.value = await getMembershipPricing()
  } catch {
    error.value = '加载价格失败，请稍后重试'
  } finally {
    loadingPrice.value = false
  }
})

async function submit() {
  error.value = ''
  const trimmed = email.value.trim()
  if (!trimmed) {
    error.value = '请填写邮箱'
    return
  }
  loading.value = true
  try {
    const order = await createMembershipOrder(trimmed, isMobile.value ? 'wap' : 'page')
    if (order.mock) {
      await router.push(`/pricing/result?order=${encodeURIComponent(order.order_no)}&mock=1`)
      return
    }
    if (order.pay_url) {
      window.location.href = order.pay_url
      return
    }
    error.value = '未获取到支付链接'
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = typeof msg === 'string' ? msg : '创建订单失败，请重试'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-dvh flex items-center justify-center px-4 py-12 bg-neutral-50 dark:bg-neutral-950">
    <div class="w-full max-w-md rounded-2xl border border-black/5 dark:border-white/10 bg-white dark:bg-neutral-900 p-6 sm:p-8 shadow-sm">
      <h1 class="text-xl font-semibold mb-1">开通永久会员</h1>
      <p class="text-sm text-neutral-500 dark:text-neutral-400 mb-6 leading-relaxed">
        支付宝付款成功后，将获得专属注册链接，完成注册即可永久使用全部内容。邀请码注册方式仍然可用。
      </p>

      <div v-if="loadingPrice" class="text-sm text-neutral-500 py-8 text-center">加载中...</div>
      <template v-else-if="pricing">
        <div class="rounded-xl border border-black/5 dark:border-white/10 bg-neutral-50 dark:bg-neutral-800/50 px-4 py-4 mb-5">
          <p class="text-sm text-neutral-500 dark:text-neutral-400">{{ pricing.subject }}</p>
          <p class="mt-1 text-3xl font-semibold tracking-tight">
            ¥{{ pricing.amount_yuan }}
            <span class="text-sm font-normal text-neutral-500 ml-1">一次性</span>
          </p>
          <p class="mt-2 text-xs text-neutral-500">{{ pricing.description }}</p>
          <p v-if="pricing.mock" class="mt-2 text-xs text-amber-700 dark:text-amber-300">
            当前为模拟支付（未配置支付宝密钥），付款不会真实扣款。
          </p>
        </div>

        <form class="space-y-4" @submit.prevent="submit">
          <div>
            <label class="block text-sm text-neutral-600 dark:text-neutral-400 mb-1.5">邮箱</label>
            <input
              v-model="email"
              type="email"
              autocomplete="email"
              required
              placeholder="用于接收注册链接、找回订单"
              class="w-full rounded-lg border border-black/10 dark:border-white/10 dark:bg-neutral-800 dark:text-white px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-neutral-900/10 dark:focus:ring-white/10"
            />
          </div>

          <p v-if="error" class="text-sm text-red-600 dark:text-red-400">{{ error }}</p>

          <button
            type="submit"
            class="w-full rounded-lg bg-[#1677FF] text-white py-2.5 text-sm font-medium hover:bg-[#1468df] disabled:opacity-60"
            :disabled="loading"
          >
            {{ loading ? '创建订单中...' : (pricing.mock ? '模拟支付并继续' : '支付宝支付') }}
          </button>
        </form>
      </template>

      <p class="text-sm text-neutral-500 dark:text-neutral-400 text-center mt-6">
        已有邀请链接？
        <RouterLink to="/signup" class="text-neutral-900 dark:text-neutral-100 font-medium hover:underline">去注册</RouterLink>
        <span class="mx-1">·</span>
        <RouterLink to="/login" class="text-neutral-900 dark:text-neutral-100 font-medium hover:underline">登录</RouterLink>
      </p>
    </div>
  </div>
</template>
