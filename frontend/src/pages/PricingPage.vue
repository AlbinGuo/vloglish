<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import wechatQr from '@/assets/wechat.png'
import { useAuthStore } from '@/stores/auth'
import { useCatalogStore } from '@/stores/catalog'

const router = useRouter()
const auth = useAuthStore()
const catalog = useCatalogStore()

const activationCode = ref('')
const error = ref('')
const loading = ref(false)

onMounted(async () => {
  if (!auth.isLoggedIn) {
    await router.replace({ path: '/login', query: { next: '/pricing' } })
    return
  }
  if (auth.isMember) {
    await router.replace('/english')
  }
})

async function submit() {
  error.value = ''
  const code = activationCode.value.trim()
  if (!code) {
    error.value = '请输入激活码'
    return
  }
  loading.value = true
  try {
    await auth.activateMembership(code)
    await catalog.loadEpisodes(true)
    await router.replace('/english')
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = typeof msg === 'string' ? msg : '激活失败，请检查激活码后重试'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-dvh flex items-center justify-center px-4 py-12 bg-neutral-50 dark:bg-neutral-950">
    <div class="w-full max-w-md rounded-2xl border border-black/5 dark:border-white/10 bg-white dark:bg-neutral-900 p-6 sm:p-8 shadow-sm">
      <h1 class="text-xl font-semibold mb-1">开通永久会员</h1>
      <p class="text-sm text-neutral-500 dark:text-neutral-400 mb-5">一次开通，永久可用</p>

      <div class="mb-5">
        <div class="flex items-baseline gap-3">
          <span class="text-3xl font-semibold tracking-tight text-neutral-900 dark:text-neutral-50">
            ¥39.9
          </span>
          <span class="text-base text-neutral-400 dark:text-neutral-500 line-through">¥79.9</span>
          <span class="text-xs text-neutral-500 dark:text-neutral-400">永久</span>
        </div>
        <p class="mt-2 text-sm text-amber-700 dark:text-amber-300">
          优惠截止时间：8 月 15 日
        </p>
      </div>

      <div
        class="rounded-xl border border-amber-200 dark:border-amber-900 bg-amber-50 dark:bg-amber-950/40 px-4 py-4 mb-5 space-y-2"
      >
<!--        <p class="text-sm font-medium text-amber-900 dark:text-amber-200">支付即将接入</p>-->
        <p class="text-sm text-amber-900/90 dark:text-amber-200/90 leading-relaxed">
          请联系管理员获取激活码（微信ID:vloglish01）。
        </p>
        <img
          :src="wechatQr"
          alt="微信二维码"
          class="mx-auto mt-3 w-44 h-44 rounded-lg object-contain bg-white"
        />
      </div>

      <form class="space-y-4" @submit.prevent="submit">
        <div>
          <label class="block text-sm text-neutral-600 dark:text-neutral-400 mb-1.5" for="pricing-activation-code">
            激活码
          </label>
          <input
            id="pricing-activation-code"
            v-model="activationCode"
            type="text"
            autocomplete="off"
            placeholder="请输入管理员提供的激活码"
            class="w-full rounded-lg border border-black/10 dark:border-white/10 dark:bg-neutral-800 dark:text-white px-3 py-2 text-sm uppercase tracking-wider focus:outline-none focus:ring-2 focus:ring-neutral-900/10 dark:focus:ring-white/10"
            @input="activationCode = activationCode.toUpperCase()"
          />
        </div>

        <p v-if="error" class="text-sm text-red-600 dark:text-red-400">{{ error }}</p>

        <button
          type="submit"
          class="w-full rounded-lg bg-neutral-900 text-white py-2.5 text-sm font-medium hover:bg-neutral-800 dark:bg-neutral-100 dark:text-neutral-900 dark:hover:bg-white disabled:opacity-60"
          :disabled="loading"
        >
          {{ loading ? '开通中...' : '确认开通' }}
        </button>
      </form>

      <p class="text-sm text-neutral-500 dark:text-neutral-400 text-center mt-6">
        <RouterLink to="/english" class="text-neutral-900 dark:text-neutral-100 font-medium hover:underline">返回学习</RouterLink>
      </p>
    </div>
  </div>
</template>
