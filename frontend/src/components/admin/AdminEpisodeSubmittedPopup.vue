<script setup lang="ts">
import { computed, onMounted, onUnmounted } from 'vue'
import type { AdminEpisodeSubmittedPopup } from '@/api/admin'

const props = defineProps<{
  item: AdminEpisodeSubmittedPopup | null
  busy?: boolean
}>()

const emit = defineEmits<{
  dismiss: []
  review: []
}>()

const open = computed(() => Boolean(props.item))

const isArticle = computed(() => props.item?.submission_type === 'article_submitted')

const submitterLabel = computed(() => {
  if (!props.item) return ''
  const nick = (props.item.submitter_nickname || '').trim()
  const email = (props.item.submitter_email || '').trim()
  if (nick && email) return `${nick}（${email}）`
  return nick || email || '用户'
})

const contentHint = computed(() => {
  if (!props.item || !isArticle.value) return ''
  const parts: string[] = []
  if ((props.item.source_url || '').trim()) parts.push('原文链接')
  if (props.item.has_submit_body) parts.push('英文正文')
  return parts.length ? `已提供：${parts.join('、')}` : ''
})

const canReview = computed(() => {
  if (!props.item) return false
  if (isArticle.value) return Boolean(props.item.article_id)
  return Boolean(props.item.episode_id)
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
      aria-labelledby="admin-episode-submitted-popup-title"
    >
      <div class="absolute inset-0 bg-black/45 backdrop-blur-[1px]" aria-hidden="true" />
      <div
        class="relative w-full sm:max-w-md rounded-t-2xl sm:rounded-2xl bg-white shadow-xl border border-black/5 p-5 sm:p-6"
      >
        <div class="flex items-start justify-between gap-3 mb-3">
          <div>
            <p class="text-xs font-medium text-amber-700 mb-1">待审核</p>
            <h2 id="admin-episode-submitted-popup-title" class="text-base font-semibold leading-snug">
              {{ isArticle ? '收到新的文章投稿' : '收到新的用户投稿' }}
            </h2>
          </div>
          <button
            type="button"
            class="w-8 h-8 shrink-0 rounded-full text-neutral-500 hover:bg-neutral-100 disabled:opacity-50"
            aria-label="关闭"
            :disabled="busy"
            @click="emit('dismiss')"
          >
            ×
          </button>
        </div>

        <p class="text-sm text-neutral-600 leading-relaxed">
          <span class="font-medium text-neutral-800">{{ submitterLabel }}</span>
          于
          <span class="font-medium text-neutral-800">{{ item.submitted_at || '刚刚' }}</span>
          {{ isArticle ? '提交了文章，请尽快审核处理。' : '提交了视频链接，请尽快审核处理。' }}
        </p>
        <p
          v-if="isArticle && item.article_title"
          class="mt-2 text-sm font-medium text-neutral-800 line-clamp-2"
        >
          {{ item.article_title }}
        </p>
        <p
          v-if="isArticle && contentHint"
          class="mt-1 text-xs text-neutral-500"
        >
          {{ contentHint }}
        </p>
        <p
          v-if="isArticle && item.source_url"
          class="mt-2 text-xs text-neutral-500 break-all leading-relaxed"
        >
          {{ item.source_url }}
        </p>
        <p
          v-else-if="!isArticle && item.original_video_url"
          class="mt-2 text-xs text-neutral-500 break-all leading-relaxed"
        >
          {{ item.original_video_url }}
        </p>

        <div class="mt-5 flex flex-col-reverse sm:flex-row gap-2 sm:justify-end">
          <button
            type="button"
            class="px-4 py-2.5 rounded-xl text-sm text-neutral-600 hover:bg-neutral-100 transition disabled:opacity-50"
            :disabled="busy"
            @click="emit('dismiss')"
          >
            知道了
          </button>
          <button
            v-if="canReview"
            type="button"
            class="px-4 py-2.5 rounded-xl text-sm font-medium bg-neutral-900 text-white hover:bg-neutral-800 transition disabled:opacity-50"
            :disabled="busy"
            @click="emit('review')"
          >
            前往审核
          </button>
        </div>
      </div>
    </div>
  </Teleport>
</template>
