<script setup lang="ts">
import { onMounted, onUnmounted, ref, watch } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import { createPcPaySession, fetchPcPayQr, fetchPcPayStatus } from '@/api/wxpay'
import { getErrorDetail } from '@/api/tokens'
import { useAuthStore } from '@/stores/auth'
import { useCatalogStore } from '@/stores/catalog'

const router = useRouter()
const auth = useAuthStore()
const catalog = useCatalogStore()

type PlanId = 'quarter' | 'year' | 'forever'

const plans: { id: PlanId; name: string; price: string; period: string; note: string; recommend: boolean }[] = [
  { id: 'quarter', name: '季度会员', price: '29', period: '3 个月', note: '约 ¥9.7 / 月', recommend: false },
  { id: 'year', name: '年度会员', price: '59', period: '12 个月', note: '约 ¥4.9 / 月', recommend: true },
  { id: 'forever', name: '永久会员', price: '99', period: '一次买断', note: '不再续费', recommend: false },
]

const selected = ref<PlanId>('year')
const error = ref('')
const loading = ref(false)
const payQr = ref('')
const payHint = ref('')
const paidOk = ref(false)
const activationCode = ref('')
const activating = ref(false)

let pollTimer: ReturnType<typeof setInterval> | undefined
let objectUrl = ''
let paySeq = 0

const benefits = [
  '解锁全部视频与合集精听',
  '上传油管视频到个人语料库',
  '视频语境、词卡、挖空等完整学习工具',
  '电脑扫码，用微信完成支付（未关联会自动绑定）',
]

function stopPay() {
  if (pollTimer) {
    clearInterval(pollTimer)
    pollTimer = undefined
  }
  if (objectUrl) {
    URL.revokeObjectURL(objectUrl)
    objectUrl = ''
  }
  payQr.value = ''
  payHint.value = ''
}

onMounted(async () => {
  if (!auth.isLoggedIn) {
    await router.replace({ path: '/login', query: { next: '/pricing' } })
    return
  }
  if (auth.isMember) {
    await router.replace('/english')
    return
  }
  await startScanPay()
})

onUnmounted(stopPay)

watch(selected, () => {
  void startScanPay()
})

async function startScanPay() {
  const seq = ++paySeq
  const plan = selected.value
  error.value = ''
  paidOk.value = false
  loading.value = true
  stopPay()
  try {
    const sess = await createPcPaySession(plan)
    if (seq !== paySeq) return
    const blob = await fetchPcPayQr(sess.token)
    if (seq !== paySeq) return
    objectUrl = URL.createObjectURL(blob)
    payQr.value = objectUrl
    payHint.value = `微信扫码支付「${sess.plan_name}」¥${(sess.amount_cent / 100).toFixed(0)}`
    pollTimer = setInterval(async () => {
      if (seq !== paySeq) return
      try {
        const st = await fetchPcPayStatus(sess.token)
        if (seq !== paySeq) return
        if (st.paid) {
          stopPay()
          paidOk.value = true
          await auth.fetchMe()
          await catalog.loadEpisodes(true)
          await router.replace('/english')
        } else if (st.status === 'expired') {
          void startScanPay()
        }
      } catch {
        /* keep polling */
      }
    }, 2000)
  } catch (e) {
    if (seq !== paySeq) return
    error.value = getErrorDetail(e) || '无法生成支付码'
  } finally {
    if (seq === paySeq) loading.value = false
  }
}

async function submitCode() {
  error.value = ''
  const code = activationCode.value.trim()
  if (!code) {
    error.value = '请输入激活码'
    return
  }
  activating.value = true
  try {
    await auth.activateMembership(code)
    await catalog.loadEpisodes(true)
    await router.replace('/english')
  } catch (e) {
    error.value = getErrorDetail(e) || '激活失败，请检查激活码后重试'
  } finally {
    activating.value = false
  }
}
</script>

<template>
  <div class="pricing-page min-h-dvh flex items-center justify-center px-4 py-10 sm:py-14">
    <div class="w-full max-w-5xl">
      <header class="mb-7 sm:mb-9 text-center">
        <p
          class="inline-flex items-center px-2.5 py-1 rounded-md text-xs font-bold tracking-wide mb-3"
          style="color: #edd577; background-color: #111111"
        >
          微信扫码支付
        </p>
        <h1 class="pricing-title text-2xl sm:text-3xl font-semibold tracking-tight">
          选套餐，手机微信扫码开通
        </h1>
<!--        <p class="pricing-lead mt-2 text-sm sm:text-base max-w-lg mx-auto leading-relaxed">-->
<!--          选套餐后生成小程序码，微信扫一下即可支付。未关联时会自动绑到当前网页账号。-->
<!--        </p>-->
      </header>

      <div class="grid grid-cols-1 lg:grid-cols-5 gap-4 sm:gap-5 items-stretch">
        <section
          class="lg:col-span-3 rounded-2xl border border-black/8 dark:border-white/10 bg-white/95 dark:bg-neutral-900/95 overflow-hidden flex flex-col"
        >
          <div class="px-5 sm:px-7 pt-6 sm:pt-7 pb-5 grid grid-cols-1 sm:grid-cols-3 gap-3">
            <button
              v-for="p in plans"
              :key="p.id"
              type="button"
              class="rounded-xl border px-4 py-4 text-left transition"
              :class="
                selected === p.id
                  ? 'border-[#edd577] bg-[#111] text-white'
                  : 'border-black/10 dark:border-white/10 bg-white dark:bg-neutral-950'
              "
              @click="selected = p.id"
            >
              <span v-if="p.recommend" class="text-[10px] font-bold" :style="{ color: selected === p.id ? '#edd577' : '#a16207' }">
                推荐
              </span>
              <p class="text-sm font-medium">{{ p.name }}</p>
              <p class="mt-1 text-2xl font-semibold tracking-tight">¥{{ p.price }}</p>
              <p class="mt-1 text-xs opacity-70">{{ p.period }} · {{ p.note }}</p>
            </button>
          </div>

          <div class="px-5 sm:px-7 py-5 sm:py-6 flex-1 flex flex-col border-t border-black/5 dark:border-white/10">
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
          </div>
        </section>

        <section
          class="lg:col-span-2 rounded-2xl border border-black/8 dark:border-white/10 bg-white dark:bg-neutral-900 p-5 sm:p-6 flex flex-col"
        >
          <h2 class="text-lg font-semibold text-neutral-900 dark:text-white mb-1">微信扫码支付</h2>
<!--          <p class="text-sm text-neutral-500 dark:text-neutral-400 mb-4 leading-relaxed">-->
<!--            用微信扫描下方小程序码完成支付。若尚未关联，扫码时会自动绑定到当前网页账号。-->
<!--          </p>-->

          <div class="flex justify-center min-h-[12rem] items-center rounded-xl bg-neutral-50 dark:bg-neutral-950 border border-black/5 dark:border-white/10 p-4">
            <p v-if="loading" class="text-sm text-neutral-400">正在生成支付码…</p>
            <img v-else-if="payQr" :src="payQr" alt="支付小程序码" class="w-48 h-48 object-contain bg-white rounded-lg" />
            <p v-else class="text-sm text-neutral-400 text-center px-4">正在准备支付码…</p>
          </div>
          <p v-if="payHint" class="mt-2 text-center text-xs text-neutral-500">{{ payHint }}</p>
          <p v-if="paidOk" class="mt-2 text-center text-sm text-emerald-600">支付成功，正在进入学习…</p>
          <p v-if="error" class="mt-2 text-sm text-red-600 dark:text-red-400">{{ error }}</p>

<!--          <form class="mt-8 pt-5 border-t border-black/5 dark:border-white/10 space-y-3" @submit.prevent="submitCode">-->
<!--            <p class="text-xs font-medium tracking-wide text-neutral-400">或使用激活码</p>-->
<!--            <input-->
<!--              v-model="activationCode"-->
<!--              type="text"-->
<!--              autocomplete="off"-->
<!--              placeholder="请输入激活码"-->
<!--              class="w-full rounded-xl border border-black/10 dark:border-white/10 dark:bg-neutral-950 dark:text-white px-3.5 py-3 text-sm uppercase tracking-wider focus:outline-none focus:ring-2 focus:ring-[#edd577]/40"-->
<!--              @input="activationCode = activationCode.toUpperCase()"-->
<!--            />-->
<!--            <button-->
<!--              type="submit"-->
<!--              class="w-full rounded-xl py-2.5 text-sm font-medium border border-black/10 dark:border-white/15 disabled:opacity-60"-->
<!--              :disabled="activating"-->
<!--            >-->
<!--              {{ activating ? '开通中…' : '用激活码开通' }}-->
<!--            </button>-->
<!--          </form>-->
        </section>
      </div>

      <p class="text-sm text-neutral-500 dark:text-neutral-400 text-center mt-7">
        <RouterLink to="/english" class="text-neutral-800 dark:text-neutral-200 font-medium hover:underline underline-offset-2">
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
.pricing-title {
  color: #111111;
}
.pricing-lead {
  color: #3f3a32;
}
:global(.dark) .pricing-page {
  background:
    radial-gradient(ellipse 80% 50% at 50% -10%, rgba(237, 213, 119, 0.08), transparent 55%),
    radial-gradient(ellipse 50% 40% at 0% 100%, rgba(255, 255, 255, 0.03), transparent 45%),
    #0a0a0a;
}
:global(.dark) .pricing-title {
  color: #ffffff;
}
:global(.dark) .pricing-lead {
  color: #e7e5e4;
}
</style>
