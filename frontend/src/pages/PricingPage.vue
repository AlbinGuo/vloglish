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

const benefits = [
  '解锁全部视频与合集精听',
  '上传油管视频到个人语料库',
  '视频语境、词卡、挖空等完整学习工具',
  '一次开通，永久可用，不再续费',
]

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
  <div
    class="pricing-page min-h-dvh flex items-center justify-center px-4 py-10 sm:py-14"
  >
    <div class="w-full max-w-5xl">
      <!-- 顶部主张 -->
      <header class="mb-7 sm:mb-9 text-center">
        <p
          class="inline-flex items-center px-2.5 py-1 rounded-md text-xs font-bold tracking-wide mb-3"
          style="color: #edd577; background-color: #111111"
        >
          永久会员 · 限时特惠
        </p>
        <h1 class="text-2xl sm:text-3xl font-semibold tracking-tight text-neutral-900 dark:text-white">
          开通后，学完全部内容
        </h1>
        <p class="mt-2 text-sm sm:text-base text-neutral-500 dark:text-neutral-400 max-w-lg mx-auto leading-relaxed">
          一次开通，永久可用。先联系管理员拿激活码，再在本页填写开通。
        </p>
      </header>

      <div class="grid grid-cols-1 lg:grid-cols-5 gap-4 sm:gap-5 items-stretch">
        <!-- 左：价值与价格（主视觉） -->
        <section
          class="lg:col-span-3 rounded-2xl border border-black/8 dark:border-white/10 bg-white/95 dark:bg-neutral-900/95 backdrop-blur-sm overflow-hidden flex flex-col"
        >
          <div
            class="px-5 sm:px-7 pt-6 sm:pt-7 pb-5 border-b border-black/5 dark:border-white/10"
            style="background: linear-gradient(135deg, #141414 0%, #2a2418 55%, #1a1a1a 100%)"
          >
            <div class="flex flex-wrap items-end gap-x-3 gap-y-2">
              <span class="text-4xl sm:text-5xl font-semibold tracking-tight text-white leading-none">
                ¥39.9
              </span>
              <span
                class="mb-1 inline-flex items-center px-2 py-0.5 rounded-md text-xs sm:text-sm font-bold tracking-wide"
                style="color: #edd577; background-color: #000000"
              >
                永久会员
              </span>
            </div>
            <p class="mt-3 flex flex-wrap items-center gap-x-2 gap-y-1 text-sm text-white/70">
              <span>原价 <span class="line-through decoration-white/40">¥99.9/年</span></span>
              <span class="text-white/30">·</span>
              <span style="color: #edd577" class="font-medium">立省 ¥60</span>
            </p>
            <div
              class="mt-4 inline-flex flex-wrap items-center gap-x-3 gap-y-1 rounded-lg px-3 py-2 text-sm"
              style="background: rgba(237, 213, 119, 0.12); color: #edd577"
            >
              <span class="font-medium">仅限前 30 名</span>
              <span class="text-white/25">|</span>
              <span>还剩 <strong class="text-white">6</strong> 席</span>
              <span class="text-white/25">|</span>
              <span>截止 8 月 8 日</span>
            </div>
          </div>

          <div class="px-5 sm:px-7 py-5 sm:py-6 flex-1 flex flex-col">
            <h2 class="text-sm font-medium text-neutral-500 dark:text-neutral-400 mb-3">开通后你将获得</h2>
            <ul class="space-y-2.5 mb-6">
              <li
                v-for="item in benefits"
                :key="item"
                class="flex items-start gap-2.5 text-sm text-neutral-700 dark:text-neutral-200 leading-relaxed"
              >
                <span
                  class="mt-0.5 shrink-0 w-5 h-5 rounded-full flex items-center justify-center text-[11px] font-bold"
                  style="background: #111; color: #edd577"
                  aria-hidden="true"
                >
                  ✓
                </span>
                {{ item }}
              </li>
            </ul>

            <div class="mt-auto pt-1">
              <p class="text-sm font-medium text-neutral-800 dark:text-neutral-100 mb-1">
                第一步：联系管理员获取激活码
              </p>
              <p class="text-sm text-neutral-500 dark:text-neutral-400 mb-4 leading-relaxed">
                微信 ID：
                <span class="font-medium text-neutral-800 dark:text-neutral-200">vloglish01</span>
                ，也可扫码添加或进群咨询。
              </p>
              <div class="grid grid-cols-2 gap-3 sm:gap-4">
                <div class="rounded-xl bg-neutral-50 dark:bg-neutral-800/60 border border-black/5 dark:border-white/10 p-3 text-center">
                  <img
                    src="https://oss.sxakgs.com/vloglish/wx4.png"
                    alt="管理员微信二维码"
                    class="mx-auto w-full max-w-[9.5rem] aspect-square rounded-lg object-contain bg-white dark:bg-neutral-900"
                  />
                  <p class="mt-2 text-xs font-medium text-neutral-700 dark:text-neutral-300">联系管理员</p>
                </div>
                <div class="rounded-xl bg-neutral-50 dark:bg-neutral-800/60 border border-black/5 dark:border-white/10 p-3 text-center">
                  <img
                    src="https://oss.sxakgs.com/vloglish/douyinqun.png"
                    alt="学习群二维码"
                    class="mx-auto w-full max-w-[9.5rem] aspect-square rounded-lg object-contain bg-white dark:bg-neutral-900"
                  />
                  <p class="mt-2 text-xs font-medium text-neutral-700 dark:text-neutral-300">抖音扫码进群</p>
                </div>
              </div>
            </div>
          </div>
        </section>

        <!-- 右：开通动作 -->
        <section
          class="lg:col-span-2 rounded-2xl border border-black/8 dark:border-white/10 bg-white dark:bg-neutral-900 p-5 sm:p-6 flex flex-col"
        >
          <p class="text-xs font-medium tracking-wide text-neutral-400 dark:text-neutral-500 mb-1">
            第二步
          </p>
          <h2 class="text-lg font-semibold text-neutral-900 dark:text-white mb-1">填写激活码开通</h2>
          <p class="text-sm text-neutral-500 dark:text-neutral-400 mb-5 leading-relaxed">
            拿到激活码后填在下方，立刻开通永久会员。
          </p>

          <form class="space-y-4 flex-1 flex flex-col" @submit.prevent="submit">
            <div>
              <label
                class="block text-sm text-neutral-600 dark:text-neutral-400 mb-1.5"
                for="pricing-activation-code"
              >
                激活码
              </label>
              <input
                id="pricing-activation-code"
                v-model="activationCode"
                type="text"
                autocomplete="off"
                placeholder="请输入激活码"
                class="w-full rounded-xl border border-black/10 dark:border-white/10 dark:bg-neutral-950 dark:text-white px-3.5 py-3 text-sm uppercase tracking-wider focus:outline-none focus:ring-2 focus:ring-[#edd577]/40 focus:border-[#edd577]/60"
                @input="activationCode = activationCode.toUpperCase()"
              />
            </div>

            <p v-if="error" class="text-sm text-red-600 dark:text-red-400">{{ error }}</p>

            <div class="mt-auto space-y-3 pt-2">
              <button
                type="submit"
                class="w-full rounded-xl py-3 text-sm font-semibold transition disabled:opacity-60"
                style="background-color: #111111; color: #edd577"
                :disabled="loading"
              >
                {{ loading ? '开通中...' : '确认开通永久会员' }}
              </button>
              <p class="text-center text-xs text-neutral-400 dark:text-neutral-500 leading-relaxed">
                开通后立即生效，可学习全部内容
              </p>
            </div>
          </form>
        </section>
      </div>

      <p class="text-sm text-neutral-500 dark:text-neutral-400 text-center mt-7">
        <RouterLink
          to="/english"
          class="text-neutral-800 dark:text-neutral-200 font-medium hover:underline underline-offset-2"
        >
          返回学习
        </RouterLink>
      </p>
    </div>
  </div>
</template>

<style scoped>
.pricing-page {
  background:
    radial-gradient(ellipse 80% 50% at 50% -10%, rgba(237, 213, 119, 0.18), transparent 55%),
    radial-gradient(ellipse 60% 40% at 100% 100%, rgba(0, 0, 0, 0.04), transparent 50%),
    #fafaf9;
}
:global(.dark) .pricing-page {
  background:
    radial-gradient(ellipse 80% 50% at 50% -10%, rgba(237, 213, 119, 0.08), transparent 55%),
    radial-gradient(ellipse 50% 40% at 0% 100%, rgba(255, 255, 255, 0.03), transparent 45%),
    #0a0a0a;
}
</style>
