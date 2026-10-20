<script setup lang="ts">
import { onMounted, onUnmounted, ref, watch } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import { createPcPaySession, fetchPcPayQr, fetchPcPayStatus } from '@/api/wxpay'
import { getErrorDetail } from '@/api/tokens'
import { useAuthStore } from '@/stores/auth'
import { useCatalogStore } from '@/stores/catalog'
import { copyText } from '@/utils/clipboard'
import { isMobileAppBuild, isNativePlatform } from '@/utils/platform'

const router = useRouter()
const auth = useAuthStore()
const catalog = useCatalogStore()

type PlanId = 'quarter' | 'year' | 'forever' | 'test'
type PayChoice = PlanId | 'author'

const AUTHOR_QR = '/author-wechat-qr.png'

const plans: { id: PlanId; name: string; price: string; period: string; note: string; recommend: boolean }[] = [
  { id: 'quarter', name: '季度会员', price: '29', period: '3 个月', note: '约 ¥9.7 / 月', recommend: false },
  { id: 'year', name: '年度会员', price: '59', period: '12 个月', note: '约 ¥4.9 / 月', recommend: false },
  { id: 'forever', name: '永久会员', price: '99', period: '一次买断', note: '不再续费', recommend: false },
  // { id: 'test', name: '测试会员', price: '1', period: '1 天', note: '联调付款', recommend: false },
]

const selected = ref<PayChoice>('author')
const error = ref('')
const loading = ref(false)
const payQr = ref('')
const payHint = ref('')
const paidOk = ref(false)
const payOnComputer = ref(false)

const WEB_PAY_URL = 'https://en.yunankexun.com/'
const copiedUrl = ref(false)
let copiedTimer: ReturnType<typeof setTimeout> | undefined

function isAppClient() {
  return isMobileAppBuild() || isNativePlatform()
}

async function copyWebPayUrl() {
  const ok = await copyText(WEB_PAY_URL)
  copiedUrl.value = ok
  if (copiedTimer) clearTimeout(copiedTimer)
  copiedTimer = setTimeout(() => {
    copiedUrl.value = false
  }, 2000)
}

async function syncIfPaidOnWeb() {
  await auth.fetchMe()
  if (!auth.isMember) return false
  stopPay()
  paidOk.value = true
  await catalog.loadEpisodes(true)
  await router.replace('/english')
  return true
}

let pollTimer: ReturnType<typeof setInterval> | undefined
let objectUrl = ''
let paySeq = 0

const benefits = [
  '解锁全部视频与合集精听',
  '读报文章不限量',
  // 油管上传上线后再加回：'上传油管视频到个人语料库',
  'AI 讲解、挖空、跟读、问答不限次数',
  '生词本、词卡与视频语境完整工具',
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
  if (selected.value !== 'author') await startScanPay()
})

onUnmounted(() => {
  stopPay()
  if (copiedTimer) clearTimeout(copiedTimer)
})

watch(selected, (choice) => {
  if (choice === 'author') {
    stopPay()
    error.value = ''
    loading.value = false
    payOnComputer.value = false
    return
  }
  void startScanPay()
})

async function startScanPay() {
  if (selected.value === 'author') return
  const seq = ++paySeq
  const plan = selected.value
  error.value = ''
  paidOk.value = false
  payOnComputer.value = false
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
          await syncIfPaidOnWeb()
        } else if (st.status === 'expired') {
          void startScanPay()
        }
      } catch {
        /* keep polling */
      }
    }, 2000)
  } catch (e) {
    if (seq !== paySeq) return
    if (isAppClient()) {
      payOnComputer.value = true
      error.value = ''
      pollTimer = setInterval(async () => {
        if (seq !== paySeq) return
        try {
          await syncIfPaidOnWeb()
        } catch {
          /* keep waiting for web payment */
        }
      }, 4000)
    } else {
      error.value = getErrorDetail(e) || '无法生成支付码'
    }
  } finally {
    if (seq === paySeq) loading.value = false
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
          class="lg:col-span-3 rounded-2xl border border-line bg-white/95 dark:bg-neutral-900/95 overflow-hidden flex flex-col"
        >
          <div class="px-5 sm:px-7 pt-6 sm:pt-7 pb-5 grid grid-cols-1 sm:grid-cols-2 gap-3">
            <button
              v-for="p in plans"
              :key="p.id"
              type="button"
              class="rounded-xl border px-4 py-4 text-left transition"
              :class="
                selected === p.id
                  ? 'border-[#edd577] bg-[#111] text-white'
                  : 'border-line bg-white dark:bg-neutral-950'
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
            <button
              type="button"
              class="rounded-xl border px-4 py-4 text-left transition h-full min-h-[7.25rem] flex flex-col justify-between"
              :class="
                selected === 'author'
                  ? 'border-[#edd577] bg-[#111] text-white'
                  : 'border-[#edd577]/70 bg-[#fffaf0] dark:border-[#edd577]/30 dark:bg-[#1a1814]'
              "
              @click="selected = 'author'"
            >
              <span
                class="text-[10px] font-bold"
                :style="{ color: selected === 'author' ? '#edd577' : '#a16207' }"
              >
                推荐
              </span>
              <div class="flex items-start justify-between gap-3 mt-1">
                <div class="min-w-0">
                  <p
                    class="text-[11px] font-medium tracking-wide"
                    :class="selected === 'author' ? 'text-white/70' : 'text-ink-faint'"
                  >
                    加作者微信
                  </p>
                  <p
                    class="mt-1 text-lg font-bold tracking-tight leading-snug"
                    :class="selected === 'author' ? 'text-[#edd577]' : 'text-neutral-900 dark:text-[#edd577]'"
                  >
                    开通永久会员
                  </p>
                </div>
                <p class="shrink-0 flex items-start leading-none">
                  <span class="mt-1 mr-0.5 text-sm font-semibold">¥</span>
                  <span class="text-[1.75rem] font-semibold tracking-tight">79</span>
                </p>
              </div>
              <p
                class="mt-3 text-xs leading-relaxed"
                :class="selected === 'author' ? 'text-white/55' : 'text-ink-faint'"
              >
                付款后请备注登录邮箱
              </p>
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
          <h2 class="text-lg font-semibold text-neutral-900 dark:text-white mb-1">
            {{ selected === 'author' ? '加作者微信' : payOnComputer ? '请在电脑上支付' : '微信扫码支付' }}
          </h2>
<!--          <p class="text-sm text-neutral-500 dark:text-neutral-400 mb-4 leading-relaxed">-->
<!--            用微信扫描下方小程序码完成支付。若尚未关联，扫码时会自动绑定到当前网页账号。-->
<!--          </p>-->

          <div class="flex justify-center min-h-[12rem] items-center rounded-xl bg-canvas border border-line-soft p-4">
            <img
              v-if="selected === 'author'"
              :src="AUTHOR_QR"
              alt="作者微信二维码"
              class="w-48 h-48 object-contain bg-white rounded-lg"
            />
            <p v-else-if="loading" class="text-sm text-neutral-400">正在生成支付码…</p>
            <img v-else-if="payQr" :src="payQr" alt="支付小程序码" class="w-48 h-48 object-contain bg-white rounded-lg" />
            <div
              v-else-if="payOnComputer"
              class="w-full max-w-[18rem] text-center text-sm leading-relaxed text-neutral-600 dark:text-neutral-300 px-1"
            >
              <p class="font-medium text-neutral-800 dark:text-white">App 内暂时无法生成支付码</p>
              <p class="mt-2">请用当前账号在电脑浏览器打开下面网址，进入开通页扫码支付。</p>
              <div class="mt-3 flex items-center gap-2 rounded-lg bg-white dark:bg-neutral-900 border border-black/8 dark:border-white/10 px-2.5 py-2">
                <span class="min-w-0 flex-1 text-left text-xs font-medium text-neutral-800 dark:text-white break-all">
                  {{ WEB_PAY_URL }}
                </span>
                <button
                  type="button"
                  class="shrink-0 rounded-md px-2 py-1 text-xs font-medium border border-black/10 dark:border-white/15 text-neutral-700 dark:text-neutral-200"
                  @click="copyWebPayUrl"
                >
                  {{ copiedUrl ? '已复制' : '复制' }}
                </button>
              </div>
              <p class="mt-2 text-xs text-neutral-500 dark:text-neutral-400">
                电脑开通后，手机 App 会同步成为会员，无需再买一次。
              </p>
            </div>
            <p v-else class="text-sm text-neutral-400 text-center px-4">正在准备支付码…</p>
          </div>
          <p v-if="selected === 'author'" class="mt-2 text-center text-xs text-neutral-500 leading-relaxed">
            微信扫码添加作者，¥79
            <span class="font-bold text-neutral-800 dark:text-neutral-200">开通永久会员</span>
            ，付款后请备注登录邮箱
          </p>
          <p v-else-if="payHint" class="mt-2 text-center text-xs text-neutral-500">{{ payHint }}</p>
          <p v-if="selected !== 'author' && paidOk" class="mt-2 text-center text-sm text-emerald-600">支付成功，正在进入学习…</p>
          <p v-if="selected !== 'author' && error" class="mt-2 text-sm text-red-600 dark:text-red-400">{{ error }}</p>

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
        <RouterLink style="color: #333;" to="/english" class="text-ink-soft font-medium hover:underline underline-offset-2">
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
