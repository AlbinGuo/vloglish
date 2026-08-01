<script setup lang="ts">
import { computed, onMounted, onUnmounted } from 'vue'
import type { EpisodePublishedPopup } from '@/api/notifications'

const props = defineProps<{
  item: EpisodePublishedPopup | null
  busy?: boolean
}>()

const emit = defineEmits<{
  dismiss: []
  watch: []
}>()

const open = computed(() => Boolean(props.item))

const displayTitle = computed(() => {
  const t = (props.item?.episode_title || '').trim()
  return t || '未命名视频'
})

function onKeydown(e: KeyboardEvent) {
  if (e.key === 'Escape' && open.value && !props.busy) emit('dismiss')
}

onMounted(() => window.addEventListener('keydown', onKeydown))
onUnmounted(() => window.removeEventListener('keydown', onKeydown))
</script>

<template>
  <Teleport to="body">
    <div
      v-if="item"
      class="fixed inset-0 z-[90] flex items-end sm:items-center justify-center p-0 sm:p-4"
      role="dialog"
      aria-modal="true"
      aria-labelledby="episode-published-popup-title"
    >
      <div class="absolute inset-0 bg-black/45 backdrop-blur-[1px]" aria-hidden="true" />
      <div
        class="relative w-full sm:max-w-md rounded-t-2xl sm:rounded-2xl bg-white dark:bg-neutral-900 shadow-xl border border-black/5 dark:border-white/10 p-5 sm:p-6"
      >
        <div class="flex items-start justify-between gap-3 mb-3">
          <div>
            <p class="text-xs font-medium text-emerald-700 dark:text-emerald-400 mb-1">审核通过</p>
            <h2 id="episode-published-popup-title" class="text-base font-semibold leading-snug">
              投稿视频已通过审核
            </h2>
          </div>
          <button
            type="button"
            class="w-8 h-8 shrink-0 rounded-full text-neutral-500 hover:bg-neutral-100 dark:hover:bg-neutral-800 disabled:opacity-50"
            aria-label="关闭"
            :disabled="busy"
            @click="emit('dismiss')"
          >
            ×
          </button>
        </div>

        <p class="text-sm text-neutral-600 dark:text-neutral-300 leading-relaxed">
          你于
          <span class="font-medium text-neutral-800 dark:text-neutral-100">{{
            item.submitted_at || '近期'
          }}</span>
          上传的「{{ displayTitle }}」已通过审核，该视频已放入你的个人语料库。
        </p>

        <div class="mt-5 flex flex-col-reverse sm:flex-row gap-2 sm:justify-end">
          <button
            type="button"
            class="px-4 py-2.5 rounded-xl text-sm text-neutral-600 dark:text-neutral-300 hover:bg-neutral-100 dark:hover:bg-neutral-800 transition disabled:opacity-50"
            :disabled="busy"
            @click="emit('dismiss')"
          >
            知道了
          </button>
          <button
            v-if="item.video_id"
            type="button"
            class="px-4 py-2.5 rounded-xl text-sm font-medium bg-amber-600 text-white hover:bg-amber-700 transition disabled:opacity-50"
            :disabled="busy"
            @click="emit('watch')"
          >
            前往观看
          </button>
        </div>
      </div>
    </div>
  </Teleport>
</template>
