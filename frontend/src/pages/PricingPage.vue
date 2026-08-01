<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
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
  <div class="min-h-dvh flex items-center justify-center px-4 py-10 sm:py-12 bg-neutral-50 dark:bg-neutral-950">
    <div class="w-full max-w-4xl">
      <div class="mb-6 text-center md:text-left">
        <h1 class="text-xl sm:text-2xl font-semibold">开通永久会员</h1>
        <p class="mt-1 text-sm text-neutral-500 dark:text-neutral-400">一次开通，永久可用</p>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-4 sm:gap-5 items-stretch">
        <!-- 左：价格与扫码 -->
        <section
          class="rounded-2xl border border-black/5 dark:border-white/10 bg-white dark:bg-neutral-900 p-5 sm:p-6 shadow-sm flex flex-col"
        >
          <h2 class="text-sm font-medium text-neutral-500 dark:text-neutral-400 mb-3">获取激活码</h2>

          <p class="text-neutral-800 dark:text-neutral-100 leading-relaxed">
            <span class="text-3xl font-semibold tracking-tight text-neutral-900 dark:text-neutral-50">¥39.9</span>
            <span class="ml-2 text-base text-neutral-400 dark:text-neutral-500">（原价 </span>
            <span class="text-base text-neutral-400 dark:text-neutral-500 line-through">¥79.9</span>
            <span class="text-base text-neutral-400 dark:text-neutral-500">）</span>
            <span class="text-sm sm:text-base text-neutral-600 dark:text-neutral-300"> · 限前 30 名 · 余 8 席</span>
          </p>
          <p class="mt-2 text-sm text-amber-700 dark:text-amber-300">
            优惠截止时间：8 月 8 日
          </p>

          <p class="mt-4 text-sm text-neutral-600 dark:text-neutral-300 leading-relaxed">
            请联系管理员获取激活码（微信ID：vloglish01）。也可扫码加入学习群。
          </p>

          <div class="mt-4 grid grid-cols-2 gap-3 flex-1">
            <div class="text-center space-y-2">
              <img
                src="https://oss.sxakgs.com/vloglish/wx4.png"
                alt="管理员微信二维码"
                class="mx-auto w-full max-w-[11rem] aspect-square rounded-lg object-contain bg-neutral-50 dark:bg-neutral-800 border border-black/5 dark:border-white/10"
              />
              <p class="text-xs text-neutral-500 dark:text-neutral-400">联系管理员</p>
            </div>
            <div class="text-center space-y-2">
              <img
                src="https://oss.sxakgs.com/vloglish/wxqun.png"
                alt="学习群二维码"
                class="mx-auto w-full max-w-[11rem] aspect-square rounded-lg object-contain bg-neutral-50 dark:bg-neutral-800 border border-black/5 dark:border-white/10"
              />
              <p class="text-xs text-neutral-500 dark:text-neutral-400">扫码进群</p>
            </div>
          </div>
        </section>

        <!-- 右：输入激活码 -->
        <section
          class="rounded-2xl border border-black/5 dark:border-white/10 bg-white dark:bg-neutral-900 p-5 sm:p-6 shadow-sm flex flex-col"
        >
          <h2 class="text-sm font-medium text-neutral-500 dark:text-neutral-400 mb-1">填写激活码</h2>
          <p class="text-sm text-neutral-500 dark:text-neutral-400 mb-5 leading-relaxed">
            填写管理员提供的激活码，即可开通永久会员。
          </p>

          <form class="space-y-4 flex-1 flex flex-col" @submit.prevent="submit">
            <div>
              <label class="block text-sm text-neutral-600 dark:text-neutral-400 mb-1.5" for="pricing-activation-code">
                激活码
              </label>
              <input
                id="pricing-activation-code"
                v-model="activationCode"
                type="text"
                autocomplete="off"
                placeholder="请输入激活码"
                class="w-full rounded-lg border border-black/10 dark:border-white/10 dark:bg-neutral-800 dark:text-white px-3 py-2.5 text-sm uppercase tracking-wider focus:outline-none focus:ring-2 focus:ring-neutral-900/10 dark:focus:ring-white/10"
                @input="activationCode = activationCode.toUpperCase()"
              />
            </div>

            <p v-if="error" class="text-sm text-red-600 dark:text-red-400">{{ error }}</p>

            <div class="mt-auto pt-2">
              <button
                type="submit"
                class="w-full rounded-lg bg-neutral-900 text-white py-2.5 text-sm font-medium hover:bg-neutral-800 dark:bg-neutral-100 dark:text-neutral-900 dark:hover:bg-white disabled:opacity-60"
                :disabled="loading"
              >
                {{ loading ? '开通中...' : '确认开通' }}
              </button>
            </div>
          </form>
        </section>
      </div>

      <p class="text-sm text-neutral-500 dark:text-neutral-400 text-center mt-6">
        <RouterLink to="/english" class="text-neutral-900 dark:text-neutral-100 font-medium hover:underline">返回学习</RouterLink>
      </p>
    </div>
  </div>
</template>
