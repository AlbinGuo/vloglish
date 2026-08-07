<script setup lang="ts">
import { computed } from 'vue'
import type { AppVersionCheck } from '@/api/appDownload'
import { resolveMediaUrl } from '@/utils/mediaUrl'

const props = defineProps<{
  open: boolean
  info: AppVersionCheck | null
}>()

const emit = defineEmits<{
  later: []
  update: []
}>()

const changelog = computed(() => (props.info?.android_changelog || '').trim())
const title = computed(() =>
  props.info?.force_update ? '需要更新后才能继续使用' : '发现新版本',
)

function onUpdate() {
  const apk = props.info?.android_apk_url
  if (apk) {
    window.open(resolveMediaUrl(apk), '_blank', 'noopener')
  } else {
    const path = props.info?.download_page_path || '/download'
    window.open(path, '_blank', 'noopener')
  }
  emit('update')
}
</script>

<template>
  <Teleport to="body">
    <div
      v-if="open && info"
      class="fixed inset-0 z-[400] flex items-end sm:items-center justify-center bg-black/45 px-4 pb-[max(1rem,env(safe-area-inset-bottom))] pt-8"
      :class="info.force_update ? '' : ''"
      @click.self="!info.force_update && emit('later')"
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
          <p class="mt-1.5 text-sm text-neutral-500 dark:text-neutral-400">
            最新版本
            <span class="font-semibold text-teal-700 dark:text-teal-300">
              {{ info.latest_version || `code ${info.latest_version_code}` }}
            </span>
            <span v-if="info.latest_version_code" class="text-neutral-400">
              （{{ info.latest_version_code }}）
            </span>
          </p>
          <p
            v-if="changelog"
            class="mt-3 max-h-40 overflow-y-auto text-sm text-neutral-700 dark:text-neutral-200 whitespace-pre-wrap leading-relaxed"
          >
            {{ changelog }}
          </p>
        </div>
        <div class="px-5 pb-5 flex flex-col gap-2">
          <button
            type="button"
            class="w-full min-h-11 rounded-xl bg-teal-600 text-white text-sm font-semibold hover:bg-teal-500 active:scale-[0.99]"
            @click="onUpdate"
          >
            立即更新
          </button>
          <button
            v-if="!info.force_update"
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
