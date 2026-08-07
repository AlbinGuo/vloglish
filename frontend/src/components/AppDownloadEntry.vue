<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { useAppDownloadAvailability } from '@/composables/useAppDownloadAvailability'
import { isMobileAppBuild, isNativePlatform } from '@/utils/platform'

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
        ? 'inline-flex items-center justify-center gap-1.5 text-sm font-medium text-teal-700 hover:text-teal-800 dark:text-teal-300 dark:hover:text-teal-200'
        : 'inline-flex items-center gap-1 rounded-lg text-teal-700 hover:text-teal-900 hover:bg-teal-50 dark:text-teal-300 dark:hover:text-teal-100 dark:hover:bg-teal-950/40 transition p-2 sm:px-2.5 sm:py-1.5'
    "
    title="下载 App"
    aria-label="下载 App"
  >
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="1.75"
      class="w-5 h-5 shrink-0"
      aria-hidden="true"
    >
      <path
        stroke-linecap="round"
        stroke-linejoin="round"
        d="M10.5 1.5H8.25A2.25 2.25 0 0 0 6 3.75v16.5a2.25 2.25 0 0 0 2.25 2.25h7.5A2.25 2.25 0 0 0 18 20.25V3.75a2.25 2.25 0 0 0-2.25-2.25H13.5m-3 0V3h3V1.5m-3 0h3m-3 18.75h3"
      />
    </svg>
    <span v-if="variant === 'auth'">下载 App，随时学</span>
    <span v-else class="hidden sm:inline text-sm font-medium">下载 App</span>
  </RouterLink>
</template>
