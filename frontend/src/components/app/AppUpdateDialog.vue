<script setup lang="ts">
import { computed, onUnmounted, ref } from 'vue'
import { getAndroidApkTrackUrl, type AppVersionCheck } from '@/api/appDownload'
import { openApkDownload } from '@/services/appUpdater'
import { formatFileSize } from '@/utils/formatFileSize'
import { copyText } from '@/utils/clipboard'
import AppIcon from '@/components/AppIcon.vue'

const props = defineProps<{
  open: boolean
  info: AppVersionCheck | null
}>()

const emit = defineEmits<{
  later: []
  update: []
}>()

const isIos = computed(() => props.info?.platform === 'ios')
const blocked = computed(() => Boolean(props.info?.blocked))
const wechatId = computed(() => (props.info?.wechat_id || '').trim())
const storeUrl = computed(() => (props.info?.store_url || '').trim())
const blockMessage = computed(() => (props.info?.block_message || '').trim())
const changelog = computed(
  () => (props.info?.changelog || props.info?.android_changelog || '').trim(),
)
const sizeLabel = computed(() => formatFileSize(props.info?.android_apk_bytes))
const canLater = computed(() => !blocked.value && !props.info?.force_update)
const title = computed(() => {
  if (blocked.value) return '请更新后继续使用'
  if (props.info?.force_update) return '需要更新后才能继续使用'
  return '发现新版本'
})

const copiedWechat = ref(false)
let copiedTimer: ReturnType<typeof setTimeout> | undefined

async function copyWechat() {
  if (!wechatId.value) return
  const ok = await copyText(wechatId.value)
  copiedWechat.value = ok
  if (copiedTimer) clearTimeout(copiedTimer)
  copiedTimer = setTimeout(() => {
    copiedWechat.value = false
  }, 2000)
}

onUnmounted(() => {
  if (copiedTimer) clearTimeout(copiedTimer)
})

function absoluteUrl(path: string) {
  try {
    return new URL(path, window.location.origin).href
  } catch {
    return path
  }
}

async function onUpdate() {
  if (isIos.value) {
    if (storeUrl.value) window.open(storeUrl.value, '_blank', 'noopener')
    emit('update')
    return
  }
  const url = props.info?.android_apk_url
    ? getAndroidApkTrackUrl()
    : absoluteUrl(props.info?.download_page_path || '/download')
  // Android 原生壳里 window.open 不一定会唤起系统浏览器：
  // 交给原生 startActivity 打开下载链接，确保真正下载并进入安装流程。
  const handledByNative = await openApkDownload(url)
  if (!handledByNative) {
    window.open(url, '_blank', 'noopener')
  }
  emit('update')
}
</script>

<template>
  <Teleport to="body">
    <div
      v-if="open && info"
      class="fixed inset-0 z-[400] flex items-end sm:items-center justify-center bg-black/45 px-4 pb-[max(1rem,env(safe-area-inset-bottom))] pt-8"
      @click.self="canLater && emit('later')"
    >
      <div
        class="w-full max-w-sm rounded-2xl bg-white dark:bg-neutral-900 border border-black/8 dark:border-white/10 shadow-xl overflow-hidden"
        role="dialog"
        aria-modal="true"
        :aria-labelledby="'app-update-title'"
        @click.stop
      >
        <div class="px-5 pt-5 pb-3">
          <p id="app-update-title" class="text-base font-semibold text-neutral-900 dark:text-neutral-50">
            {{ title }}
          </p>

          <p
            v-if="blockMessage"
            class="mt-2 rounded-lg bg-rose-50 dark:bg-rose-950/40 px-3 py-2 text-sm text-rose-700 dark:text-rose-200 leading-relaxed"
          >
            {{ blockMessage }}
          </p>

          <p v-if="!blocked" class="mt-1.5 text-sm text-neutral-500 dark:text-neutral-400">
            最新版本
            <span class="font-semibold text-teal-700 dark:text-teal-300">
              {{ info.latest_version || `code ${info.latest_version_code}` }}
            </span>
            <span v-if="info.latest_version_code" class="text-neutral-400">
              （{{ info.latest_version_code }}）
            </span>
            <span v-if="sizeLabel && !isIos" class="text-neutral-400"> · {{ sizeLabel }}</span>
          </p>
          <p
            v-if="changelog"
            class="mt-3 max-h-40 overflow-y-auto text-sm text-neutral-700 dark:text-neutral-200 whitespace-pre-wrap leading-relaxed"
          >
            {{ changelog }}
          </p>
        </div>

        <div class="px-5 pb-5 flex flex-col gap-2">
          <!-- iOS：加作者微信开通 / 咨询 -->
          <div
            v-if="wechatId"
            class="rounded-xl bg-neutral-100 dark:bg-neutral-800 px-3 py-2.5"
          >
            <p class="text-xs text-neutral-500 dark:text-neutral-400">加作者微信开通 / 咨询</p>
            <div class="mt-1.5 flex items-center gap-2">
              <span class="min-w-0 flex-1 truncate font-mono text-sm font-semibold text-neutral-900 dark:text-neutral-50">
                {{ wechatId }}
              </span>
              <button
                type="button"
                class="inline-flex shrink-0 items-center gap-1 rounded-lg bg-ink px-2.5 py-1.5 text-xs font-medium text-ink-inverse transition active:scale-95"
                @click="copyWechat"
              >
                <AppIcon :name="copiedWechat ? 'check-xs' : 'clipboard'" class="h-3.5 w-3.5" />
                {{ copiedWechat ? '已复制' : '复制' }}
              </button>
            </div>
          </div>

          <button
            v-if="isIos ? !!storeUrl : true"
            type="button"
            class="w-full min-h-11 rounded-xl bg-teal-600 text-white text-sm font-semibold hover:bg-teal-500 active:scale-[0.99]"
            @click="onUpdate"
          >
            {{ isIos ? '前往 App Store 更新' : '立即更新' }}
          </button>

          <button
            v-if="canLater"
            type="button"
            class="w-full min-h-10 rounded-xl text-sm font-medium text-neutral-600 dark:text-neutral-300 hover:bg-neutral-100 dark:hover:bg-neutral-800"
            @click="emit('later')"
          >
            稍后提醒
          </button>
        </div>
      </div>
    </div>
  </Teleport>
</template>
