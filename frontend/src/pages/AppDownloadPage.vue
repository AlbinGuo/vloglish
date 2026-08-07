<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { fetchAppDownload, type PublicAppDownload } from '@/api/appDownload'
import { resolveMediaUrl } from '@/utils/mediaUrl'
import { makeQrDataUrl } from '@/utils/qrcodeDownload'

const loading = ref(true)
const error = ref('')
const data = ref<PublicAppDownload | null>(null)
const qrDataUrl = ref('')

const apkUrl = computed(() => {
  const raw = data.value?.android_apk_url || ''
  return raw ? resolveMediaUrl(raw) : ''
})

const landingUrl = computed(() => {
  if (typeof window === 'undefined') return '/download'
  return `${window.location.origin}/download`
})

/** Android 区二维码：有安装包则指向 APK，否则指向本落地页 */
const androidQrTarget = computed(() => apkUrl.value || landingUrl.value)

const isAndroid = computed(() => /android/i.test(navigator.userAgent))
const isIOS = computed(() => /iphone|ipad|ipod/i.test(navigator.userAgent))

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
})

onMounted(async () => {
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
  <div class="min-h-dvh bg-gradient-to-b from-teal-50 via-white to-neutral-50 dark:from-neutral-950 dark:via-neutral-950 dark:to-neutral-900 text-neutral-900 dark:text-neutral-50">
    <div class="mx-auto max-w-lg px-4 pt-[max(1.5rem,env(safe-area-inset-top))] pb-[max(2rem,env(safe-area-inset-bottom))]">
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
          v-if="!data.enabled"
          class="mb-4 rounded-xl bg-amber-50 dark:bg-amber-950/40 px-3 py-2 text-sm text-amber-900 dark:text-amber-100 text-center"
        >
          下载暂未开放，请稍后再来。
        </p>

        <section class="rounded-2xl border border-teal-200/70 dark:border-teal-800/50 bg-white/90 dark:bg-neutral-900/80 p-5 shadow-sm">
          <div class="flex items-center gap-2">
            <span class="inline-flex h-9 w-9 items-center justify-center rounded-xl bg-teal-600 text-white text-xs font-bold">安</span>
            <div>
              <h2 class="text-base font-semibold">Android</h2>
              <p class="text-xs text-neutral-500">
                <template v-if="data.android_version">版本 {{ data.android_version }}</template>
                <template v-else>APK 安装包</template>
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
              {{ data.has_android ? '扫码下载 Android 安装包' : '扫码打开下载页' }}
            </p>
          </div>

          <a
            v-if="data.has_android && apkUrl"
            :href="apkUrl"
            class="mt-4 flex w-full min-h-12 items-center justify-center rounded-2xl bg-teal-600 text-white text-[15px] font-semibold shadow-[0_8px_20px_rgba(13,148,136,0.28)] active:scale-[0.99]"
          >
            {{ isAndroid ? '下载并安装' : '下载 Android APK' }}
          </a>
          <p v-else class="mt-4 text-sm text-neutral-500 text-center">
            Android 安装包尚未上传
          </p>
          <p v-if="data.has_android" class="mt-2 text-[11px] text-neutral-400 text-center leading-relaxed">
            若无法安装，请在系统设置中允许「未知来源」应用。
          </p>
        </section>

        <section class="mt-4 rounded-2xl border border-black/8 dark:border-white/10 bg-white/80 dark:bg-neutral-900/70 p-5">
          <div class="flex items-center gap-2">
            <span class="inline-flex h-9 w-9 items-center justify-center rounded-xl bg-neutral-800 text-white text-xs font-bold dark:bg-neutral-200 dark:text-neutral-900">iOS</span>
            <div>
              <h2 class="text-base font-semibold">iPhone / iPad</h2>
              <p class="text-xs text-neutral-500">尚未上架 App Store</p>
            </div>
          </div>
          <p class="mt-3 text-sm text-neutral-600 dark:text-neutral-300 leading-relaxed">
            {{ data.ios_note || 'iOS 版尚未上架 App Store，敬请期待。' }}
          </p>
          <a
            v-if="data.ios_link"
            :href="data.ios_link"
            target="_blank"
            rel="noopener"
            class="mt-4 flex w-full min-h-11 items-center justify-center rounded-xl border border-black/10 dark:border-white/15 text-sm font-semibold"
          >
            了解更多
          </a>
          <p v-else-if="isIOS" class="mt-3 text-xs text-neutral-400">
            当前为 iOS 设备，请使用 Android 手机下载，或等待 App Store 上架。
          </p>
        </section>

        <p class="mt-8 text-center text-xs text-neutral-400">
          <RouterLink to="/english" class="underline-offset-2 hover:underline">进入网页版</RouterLink>
        </p>
      </template>
    </div>
  </div>
</template>
