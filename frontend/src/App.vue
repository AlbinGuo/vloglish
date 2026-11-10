<script setup lang="ts">
import { ref, watch } from 'vue'
import { RouterView, useRouter } from 'vue-router'
import AppSplash from '@/components/AppSplash.vue'
import AppUpdateDialog from '@/components/app/AppUpdateDialog.vue'
import BilibiliImportDialog from '@/components/bilibili/BilibiliImportDialog.vue'
import { useAppUpdateCheck } from '@/composables/useAppUpdateCheck'
import { useBilibiliClipboardWatcher } from '@/composables/useBilibiliClipboardWatcher'
import { importBilibili } from '@/api/bilibili'
import { isMobileAppBuild, isNativePlatform } from '@/utils/platform'
import { useAuthStore } from '@/stores/auth'
import { initPushNotifications, setupPushNotificationRouting, syncPushToken } from '@/services/pushNotifications'

const { open, info, later, onUpdateClicked } = useAppUpdateCheck()

// 仅在 App（含原生壳）里展示动画启动页，网页不展示
const showSplash = isMobileAppBuild() || isNativePlatform()

// App 启动即挂载"点击通知跳转"监听（支持冷启动点通知进入详情页）
void setupPushNotificationRouting()

// 登录后注册系统推送（token 上报需要登录态）
const auth = useAuthStore()

const router = useRouter()
const {
  open: biliOpen,
  data: biliData,
  loading: biliResolving,
  error: biliError,
  start: startBiliWatcher,
  reset: resetBili,
  markImported: markBiliImported,
} = useBilibiliClipboardWatcher()
const biliImporting = ref(false)

async function onBiliConfirm() {
  const meta = biliData.value
  if (!meta) return
  biliImporting.value = true
  biliError.value = ''
  try {
    const res = await importBilibili(meta.bvid, meta.page)
    markBiliImported(meta.bvid)
    resetBili()
    await router.push(`/english/episode/${res.video_id}`)
  } catch (e: unknown) {
    biliError.value =
      (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail ||
      '导入失败，请稍后再试'
  } finally {
    biliImporting.value = false
  }
}

// 登录后註冊系统推送（token 上报需要登录态），并开始监听剪贴板里的 B 站链接
watch(
  () => auth.isLoggedIn,
  (ok) => {
    if (ok) {
      void initPushNotifications()
      void syncPushToken()
      startBiliWatcher()
    }
  },
  { immediate: true },
)

// 回到前台再补报一次 token（token 可能变化，或上次上报时未登录/网络失败）
if (isNativePlatform()) {
  void import('@capacitor/app')
    .then(({ App }) => {
      void App.addListener('resume', () => {
        if (auth.isLoggedIn) {
          void syncPushToken()
          // 从后台回到 App（例如在微信里完成支付后）刷新账号，及时同步会员状态
          void auth.fetchMe().catch(() => {})
        }
      })
    })
    .catch(() => {})
}
</script>

<template>
  <RouterView />
  <AppSplash v-if="showSplash" />
  <AppUpdateDialog :open="open" :info="info" @later="later" @update="onUpdateClicked" />
  <BilibiliImportDialog
    :open="biliOpen"
    :data="biliData"
    :resolving="biliResolving"
    :importing="biliImporting"
    :error="biliError"
    @confirm="onBiliConfirm"
    @close="resetBili"
  />
</template>

