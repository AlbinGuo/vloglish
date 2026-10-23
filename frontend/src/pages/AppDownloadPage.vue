<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import {
  fetchAppDownload,
  getAndroidApkTrackUrl,
  type PublicAppDownload,
} from '@/api/appDownload'
import { formatFileSize } from '@/utils/formatFileSize'
import { makeQrDataUrl } from '@/utils/qrcodeDownload'

const loading = ref(true)
const error = ref('')
const data = ref<PublicAppDownload | null>(null)
const qrDataUrl = ref('')
const iosQrDataUrl = ref('')

type Client = 'ios' | 'android' | 'other'
const client = ref<Client>('other')

/** 走后端中转，便于统计下载量 */
const apkTrackUrl = computed(() => {
  if (!data.value?.has_android || !data.value.android_apk_url) return ''
  return getAndroidApkTrackUrl()
})

const apkSizeLabel = computed(() => formatFileSize(data.value?.android_apk_bytes))

const iosLink = computed(() => (data.value?.ios_link || '').trim())

const iosNote = computed(() => {
  const note = (data.value?.ios_note || '').trim()
  return note || '应用即将上架 App Store，敬请期待。'
})

const showAndroid = computed(() => {
  if (!data.value?.enabled) return false
  return Boolean(data.value.has_android && apkTrackUrl.value)
})

/** 下载开放时始终展示 iOS 区；无外链时显示即将上架提示 */
const showIos = computed(() => Boolean(data.value?.enabled))

/** 两个区块同时展示时，PC 端横向两列排版 */
const bothSections = computed(() => showAndroid.value && showIos.value)

const emptyHint = computed(() => {
  if (!data.value) return ''
  if (!data.value.enabled) return '下载暂未开放，请稍后再来。'
  if (!showAndroid.value && !iosLink.value) {
    return '当前暂无 Android 安装包；iOS 即将上架 App Store，可先使用网页版。'
  }
  if (!showAndroid.value) {
    return 'Android 安装包尚未上线，请稍后再来，或先使用网页版。'
  }
  return ''
})

const androidQrTarget = computed(() => (showAndroid.value ? apkTrackUrl.value : ''))

async function refreshAndroidQr() {
  const target = androidQrTarget.value
  if (!target) {
    qrDataUrl.value = ''
    return
  }
  try {
    qrDataUrl.value = await makeQrDataUrl(target, 200)
  } catch {
    qrDataUrl.value = ''
  }
}

watch(androidQrTarget, () => {
  void refreshAndroidQr()
  void refreshIosQr()
})

const iosQrTarget = computed(() => iosLink.value)

async function refreshIosQr() {
  const target = iosQrTarget.value
  if (!target) {
    iosQrDataUrl.value = ''
    return
  }
  try {
    iosQrDataUrl.value = await makeQrDataUrl(target, 200)
  } catch {
    iosQrDataUrl.value = ''
  }
}

watch(iosQrTarget, () => {
  void refreshIosQr()
})

onMounted(async () => {
  const ua = navigator.userAgent
  if (/iphone|ipad|ipod/i.test(ua)) client.value = 'ios'
  else if (/android/i.test(ua)) client.value = 'android'
  else client.value = 'other'

  loading.value = true
  error.value = ''
  try {
    data.value = await fetchAppDownload()
  } catch {
    error.value = '加载失败，请稍后重试'
  } finally {
    loading.value = false
  }
  void refreshAndroidQr()
})
</script>

<template>
  <div class="min-h-dvh bg-gradient-to-b from-teal-50 via-white to-neutral-50 dark:from-neutral-950 dark:via-neutral-950 dark:to-neutral-900 text-ink">
    <div class="mx-auto max-w-lg lg:max-w-4xl px-4 pt-[max(1.5rem,env(safe-area-inset-top))] pb-[max(2rem,env(safe-area-inset-bottom))]">
      <header class="pt-6 pb-8 text-center">
        <p class="text-sm font-semibold tracking-wide text-teal-700 dark:text-teal-300">Vloglish</p>
        <h1 class="mt-2 text-2xl font-bold tracking-tight">下载 App</h1>
        <p class="mt-2 text-sm text-neutral-500 dark:text-neutral-400">用手机学英语，跟读更方便</p>
      </header>

      <p v-if="loading" class="text-center text-sm text-neutral-500">加载中…</p>
      <p v-else-if="error" class="rounded-xl bg-rose-50 dark:bg-rose-950/40 px-3 py-2 text-sm text-rose-700 dark:text-rose-200 text-center">
        {{ error }}
      </p>

      <template v-else-if="data">
        <p
          v-if="emptyHint"
          class="mb-4 rounded-xl bg-warning-soft px-3 py-2 text-sm text-amber-900 dark:text-amber-100 text-center leading-relaxed"
        >
          {{ emptyHint }}
        </p>

        <div :class="bothSections ? 'lg:grid lg:grid-cols-2 lg:gap-5 lg:items-start' : ''">
        <section
          v-if="showAndroid"
          class="rounded-2xl border border-teal-200/70 dark:border-teal-800/50 bg-white/90 dark:bg-neutral-900/80 p-5 shadow-sm"
        >
          <div class="flex items-center gap-2">
            <span class="inline-flex h-9 w-9 items-center justify-center rounded-xl bg-teal-600 text-white text-xs font-bold">安</span>
            <div>
              <h2 class="text-base font-semibold">Android</h2>
              <p class="text-xs text-neutral-500">
                <template v-if="data.android_version">
                  版本 {{ data.android_version }}
                  <template v-if="data.android_version_code">（{{ data.android_version_code }}）</template>
                </template>
                <template v-else-if="data.android_version_code">版本码 {{ data.android_version_code }}</template>
                <template v-else>APK 安装包</template>
                <template v-if="apkSizeLabel"> · {{ apkSizeLabel }}</template>
              </p>
            </div>
          </div>

          <p v-if="data.android_changelog" class="mt-3 text-sm text-neutral-600 dark:text-neutral-300 whitespace-pre-wrap">
            {{ data.android_changelog }}
          </p>

          <div class="mt-4 flex flex-col items-center">
            <div class="rounded-2xl border border-teal-200/80 dark:border-teal-800/50 bg-white p-2.5">
              <img
                v-if="qrDataUrl"
                :src="qrDataUrl"
                alt="Android 下载二维码"
                class="w-[160px] h-[160px]"
                width="160"
                height="160"
              />
              <div
                v-else
                class="w-[160px] h-[160px] flex items-center justify-center text-xs text-neutral-400"
              >
                二维码生成中…
              </div>
            </div>
            <p class="mt-2 text-[11px] text-neutral-500 dark:text-neutral-400 text-center">
              扫码下载 Android 安装包
            </p>
          </div>

          <a
            :href="apkTrackUrl"
            class="mt-4 flex w-full min-h-12 items-center justify-center rounded-2xl bg-teal-600 text-white text-[15px] font-semibold shadow-[0_8px_20px_rgba(13,148,136,0.28)] active:scale-[0.99]"
          >
            {{ client === 'android' ? '下载并安装' : '下载 Android APK' }}
            <template v-if="apkSizeLabel">（{{ apkSizeLabel }}）</template>
          </a>
          <div class="mt-3 rounded-xl bg-neutral-50 dark:bg-neutral-800/60 px-3 py-2.5 text-[11px] leading-relaxed text-neutral-500 dark:text-neutral-400">
            <p class="font-medium text-neutral-600 dark:text-neutral-300">安装提示</p>
            <ol class="mt-1 list-decimal space-y-0.5 pl-4">
              <li>点击下载后，若浏览器提示“此类型文件可能损害设备”，选择「仍要下载 / 继续」。</li>
              <li>打开安装包时若提示“未知来源 / 未经安全检测”，选择「允许此来源」或「仍要安装」。</li>
              <li>小米需关闭“纯净模式”；华为 / 荣耀需允许“外部来源应用”安装。</li>
            </ol>
            <p class="mt-1.5 text-neutral-400">为保障安全，请务必从官网等官方渠道下载，谨防仿冒安装包。</p>
          </div>
        </section>

        <section
          v-if="showIos"
          class="rounded-2xl border border-line bg-white/80 dark:bg-neutral-900/70 p-5"
          :class="showAndroid ? 'mt-4 lg:mt-0' : ''"
        >
          <div class="flex items-center gap-2">
            <span class="inline-flex h-9 w-9 items-center justify-center rounded-xl bg-neutral-800 text-white text-xs font-bold dark:bg-neutral-200 dark:text-neutral-900">iOS</span>
            <div>
              <h2 class="text-base font-semibold">iPhone / iPad</h2>
              <p class="text-xs text-neutral-500">内测中，即将上架 Apple Store</p>
            </div>
          </div>

          <p class="mt-3 text-sm text-neutral-600 dark:text-neutral-300 leading-relaxed">
            {{ iosNote }}
          </p>

          <div v-if="iosQrTarget" class="mt-4 flex flex-col items-center">
            <div class="rounded-2xl border border-line bg-white p-2.5">
              <img
                v-if="iosQrDataUrl"
                :src="iosQrDataUrl"
                alt="iOS 内测下载二维码"
                class="w-[160px] h-[160px]"
                width="160"
                height="160"
              />
              <div
                v-else
                class="w-[160px] h-[160px] flex items-center justify-center text-xs text-neutral-400"
              >
                二维码生成中…
              </div>
            </div>
            <p class="mt-2 text-[11px] text-neutral-500 dark:text-neutral-400 text-center">
              使用相机扫码
            </p>
          </div>

          <div class="mt-4 rounded-xl bg-neutral-50 dark:bg-neutral-800/60 px-3 py-3">
            <p class="text-[12px] font-medium text-neutral-600 dark:text-neutral-300">iOS 内测安装步骤（TestFlight）</p>
            <ol class="mt-2 space-y-2">
              <li class="flex gap-2">
                <span class="mt-0.5 inline-flex h-5 w-5 shrink-0 items-center justify-center rounded-full bg-neutral-800 text-[11px] font-bold text-white dark:bg-neutral-200 dark:text-neutral-900">1</span>
                <span class="text-[12px] leading-relaxed text-neutral-600 dark:text-neutral-300">在 App Store 搜索并下载「TestFlight」应用。</span>
              </li>
              <li class="flex gap-2">
                <span class="mt-0.5 inline-flex h-5 w-5 shrink-0 items-center justify-center rounded-full bg-neutral-800 text-[11px] font-bold text-white dark:bg-neutral-200 dark:text-neutral-900">2</span>
                <span class="text-[12px] leading-relaxed text-neutral-600 dark:text-neutral-300">打开 TestFlight，用相机扫描上方二维码（或点击邀请链接），即可领取并安装 Vloglish 内测版。</span>
              </li>
            </ol>
          </div>

          <a
            v-if="iosLink"
            :href="iosLink"
            target="_blank"
            rel="noopener"
            class="mt-4 flex w-full min-h-12 items-center justify-center rounded-2xl bg-ink text-white text-[15px] font-semibold dark:text-neutral-900 active:scale-[0.99]"
          >
            {{ client === 'ios' ? '打开 TestFlight 邀请' : '打开 iOS 内测链接' }}
          </a>
          <div
            v-else
            class="mt-4 flex w-full min-h-12 items-center justify-center rounded-2xl border border-dashed border-neutral-300 dark:border-neutral-600 bg-neutral-50 dark:bg-neutral-800/60 text-[15px] font-semibold text-neutral-500 dark:text-neutral-400"
            aria-disabled="true"
          >
            内测中，即将上架 Apple Store
          </div>
        </section>
        </div>

        <p class="mt-8 text-center text-xs text-neutral-400">
          <RouterLink to="/english" class="underline-offset-2 hover:underline">进入网页版</RouterLink>
        </p>
      </template>
    </div>
  </div>
</template>
