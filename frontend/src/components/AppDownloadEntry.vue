<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { useAppDownloadAvailability } from '@/composables/useAppDownloadAvailability'
import { isMobileAppBuild, isNativePlatform } from '@/utils/platform'
import AppIcon from '@/components/AppIcon.vue'

withDefaults(
  defineProps<{
    /** header：顶栏紧凑；auth：登录/注册页文案链接 */
    variant?: 'header' | 'auth'
  }>(),
  { variant: 'header' },
)

const { showEntry, ensureLoaded } = useAppDownloadAvailability()

/** App 壳内不展示；网页按设备与是否有对应安装包决定 */
const visible = computed(
  () => !isNativePlatform() && !isMobileAppBuild() && showEntry.value,
)

onMounted(() => {
  void ensureLoaded()
})
</script>

<template>
  <RouterLink
    v-if="visible"
    to="/download"
    :class="
      variant === 'auth'
        ? 'inline-flex items-center justify-center gap-1.5 text-sm font-medium text-neutral-500 transition-colors duration-200 hover:text-neutral-900'
        : 'inline-flex items-center gap-1 rounded-lg text-brand hover:text-teal-900 hover:bg-teal-50 dark:hover:text-teal-100 dark:hover:bg-teal-950/40 transition p-2 sm:px-2.5 sm:py-1.5'
    "
    title="下载 App"
    aria-label="下载 App"
  >
    <AppIcon name="clipboard" class="w-5 h-5 shrink-0" />
    <span v-if="variant === 'auth'">下载 App，随时学</span>
    <span v-else class="hidden sm:inline text-sm font-medium">下载 App</span>
  </RouterLink>
</template>
