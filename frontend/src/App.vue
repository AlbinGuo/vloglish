<script setup lang="ts">
import { watch } from 'vue'
import { RouterView } from 'vue-router'
import AppSplash from '@/components/AppSplash.vue'
import AppUpdateDialog from '@/components/app/AppUpdateDialog.vue'
import { useAppUpdateCheck } from '@/composables/useAppUpdateCheck'
import { isMobileAppBuild, isNativePlatform } from '@/utils/platform'
import { useAuthStore } from '@/stores/auth'
import { initPushNotifications } from '@/services/pushNotifications'

const { open, info, later, onUpdateClicked } = useAppUpdateCheck()

// 仅在 App（含原生壳）里展示动画启动页，网页不展示
const showSplash = isMobileAppBuild() || isNativePlatform()

// 登录后注册系统推送（token 上报需要登录态）
const auth = useAuthStore()
watch(
  () => auth.isLoggedIn,
  (ok) => {
    if (ok) void initPushNotifications()
  },
  { immediate: true },
)
</script>

<template>
  <RouterView />
  <AppSplash v-if="showSplash" />
  <AppUpdateDialog :open="open" :info="info" @later="later" @update="onUpdateClicked" />
</template>

