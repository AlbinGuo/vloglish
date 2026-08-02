<script setup lang="ts">
import { computed, onMounted, onUnmounted } from 'vue'
import type { EpisodePublishedPopup } from '@/api/notifications'
import { resolveMediaUrl } from '@/utils/mediaUrl'

const props = defineProps<{
  item: EpisodePublishedPopup | null
  items?: EpisodePublishedPopup[] | null
  busy?: boolean
}>()

const emit = defineEmits<{
  dismiss: []
  open: [payload: { videoId?: string; articleId?: string }]
}>()

const multiItems = computed(() => {
  const list = props.items ?? []
  return list.length >= 2 ? list : []
})

const isMulti = computed(() => multiItems.value.length >= 2)
const open = computed(() => isMulti.value || Boolean(props.item))

const single = computed(() => (isMulti.value ? null : props.item))
const isNewRelease = computed(
  () =>
    single.value?.type === 'episode_new_release' || single.value?.type === 'article_new_release',
)
const isArticle = computed(() => single.value?.type === 'article_new_release')

const displayTitle = computed(() => {
  const t = (single.value?.episode_title || '').trim()
  return t || (isArticle.value ? '未命名文章' : '未命名视频')
})

const coverSrc = computed(() => {
  const url = (single.value?.cover_url || '').trim()
  return url ? resolveMediaUrl(url) : ''
})

function itemCover(item: EpisodePublishedPopup) {
  const url = (item.cover_url || '').trim()
  return url ? resolveMediaUrl(url) : ''
}

function itemTitle(item: EpisodePublishedPopup) {
  const t = (item.episode_title || '').trim()
  if (t) return t
  return item.type === 'article_new_release' ? '未命名文章' : '未命名视频'
}

function itemKindLabel(item: EpisodePublishedPopup) {
  return item.type === 'article_new_release' ? '文章' : '视频'
}

function onOpenItem(item: EpisodePublishedPopup) {
  if (props.busy) return
  emit('open', {
    videoId: item.video_id || undefined,
    articleId: item.article_id || undefined,
  })
}

function onOpenSingle() {
  if (!single.value || props.busy) return
  onOpenItem(single.value)
}

function onKeydown(e: KeyboardEvent) {
  if (e.key === 'Escape' && open.value && !props.busy) emit('dismiss')
}

onMounted(() => window.addEventListener('keydown', onKeydown))
onUnmounted(() => window.removeEventListener('keydown', onKeydown))
</script>

<template>
  <Teleport to="body">
    <div
      v-if="isMulti"
      class="fixed inset-0 z-[90] flex items-end sm:items-center justify-center p-0 sm:p-4"
      role="dialog"
      aria-modal="true"
      aria-labelledby="content-release-multi-title"
    >
      <div class="absolute inset-0 bg-black/45 backdrop-blur-[1px]" aria-hidden="true" />
      <div
        class="relative w-full sm:max-w-lg rounded-t-2xl sm:rounded-2xl bg-white dark:bg-neutral-900 shadow-xl border border-black/5 dark:border-white/10 overflow-hidden max-h-[90vh] flex flex-col"
      >
        <div class="p-5 sm:p-6 pb-3 flex items-start justify-between gap-3 shrink-0">
          <div>
            <p class="text-xs font-medium mb-1 text-amber-700 dark:text-amber-400">新内容上线</p>
            <h2 id="content-release-multi-title" class="text-base font-semibold leading-snug">
              有 {{ multiItems.length }} 个新内容发布了
            </h2>
            <p class="mt-1 text-sm text-neutral-500 dark:text-neutral-400">点击封面即可前往</p>
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

        <ul class="px-5 sm:px-6 pb-2 space-y-3 overflow-y-auto min-h-0">
          <li v-for="row in multiItems" :key="row.id">
            <button
              type="button"
              class="w-full flex gap-3 text-left rounded-xl overflow-hidden border border-black/5 dark:border-white/10 hover:bg-neutral-50 dark:hover:bg-neutral-800/60 transition disabled:opacity-60"
              :disabled="busy"
              @click="onOpenItem(row)"
            >
              <span
                class="relative w-28 sm:w-32 shrink-0 aspect-video bg-neutral-200 dark:bg-neutral-800"
              >
                <img
                  v-if="itemCover(row)"
                  :src="itemCover(row)"
                  :alt="itemTitle(row)"
                  class="absolute inset-0 w-full h-full object-cover"
                />
                <span
                  v-else
                  class="absolute inset-0 flex items-center justify-center text-xs text-neutral-400"
                >
                  {{ itemKindLabel(row) }}
                </span>
              </span>
              <span class="flex-1 min-w-0 py-2.5 pr-3 flex flex-col justify-center">
                <span class="text-[11px] font-medium text-amber-700 dark:text-amber-400 mb-0.5">
                  {{ itemKindLabel(row) }}
                </span>
                <span class="text-sm font-medium text-neutral-900 dark:text-neutral-100 line-clamp-2">
                  {{ itemTitle(row) }}
                </span>
              </span>
            </button>
          </li>
        </ul>

        <div class="p-5 sm:p-6 pt-3 flex justify-end shrink-0 border-t border-black/5 dark:border-white/10 mt-1">
          <button
            type="button"
            class="px-4 py-2.5 rounded-xl text-sm font-medium bg-amber-600 text-white hover:bg-amber-700 transition disabled:opacity-50"
            :disabled="busy"
            @click="emit('dismiss')"
          >
            知道了
          </button>
        </div>
      </div>
    </div>

    <div
      v-else-if="single"
      class="fixed inset-0 z-[90] flex items-end sm:items-center justify-center p-0 sm:p-4"
      role="dialog"
      aria-modal="true"
      aria-labelledby="episode-published-popup-title"
    >
      <div class="absolute inset-0 bg-black/45 backdrop-blur-[1px]" aria-hidden="true" />
      <div
        class="relative w-full sm:max-w-md rounded-t-2xl sm:rounded-2xl bg-white dark:bg-neutral-900 shadow-xl border border-black/5 dark:border-white/10 overflow-hidden"
      >
        <button
          v-if="coverSrc && (single.video_id || single.article_id)"
          type="button"
          class="relative block w-full aspect-video bg-neutral-200 dark:bg-neutral-800 group disabled:opacity-60"
          :disabled="busy"
          @click="onOpenSingle"
        >
          <img
            :src="coverSrc"
            :alt="displayTitle"
            class="absolute inset-0 w-full h-full object-cover transition group-hover:scale-[1.02]"
          />
          <span
            class="absolute inset-0 flex items-center justify-center bg-black/25 group-hover:bg-black/35 transition"
            aria-hidden="true"
          >
            <span
              class="w-12 h-12 rounded-full bg-white/95 text-neutral-900 flex items-center justify-center shadow-md"
            >
              <svg
                v-if="!isArticle"
                xmlns="http://www.w3.org/2000/svg"
                viewBox="0 0 24 24"
                fill="currentColor"
                class="w-6 h-6 ml-0.5"
              >
                <path
                  d="M8 5.14v13.72a1 1 0 0 0 1.5.86l11-6.86a1 1 0 0 0 0-1.72l-11-6.86A1 1 0 0 0 8 5.14Z"
                />
              </svg>
              <svg
                v-else
                xmlns="http://www.w3.org/2000/svg"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="1.8"
                class="w-6 h-6"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M4.5 5.25h10.5A1.5 1.5 0 0 1 16.5 6.75v11.25H6A1.5 1.5 0 0 1 4.5 16.5V5.25Z"
                />
                <path stroke-linecap="round" d="M16.5 6.75h3v11.25a1.5 1.5 0 0 1-1.5 1.5" />
              </svg>
            </span>
          </span>
        </button>
        <div
          v-else-if="coverSrc"
          class="relative w-full aspect-video bg-neutral-200 dark:bg-neutral-800"
        >
          <img
            :src="coverSrc"
            :alt="displayTitle"
            class="absolute inset-0 w-full h-full object-cover"
          />
        </div>

        <div class="p-5 sm:p-6">
          <div class="flex items-start justify-between gap-3 mb-3">
            <div>
              <p
                class="text-xs font-medium mb-1"
                :class="
                  isNewRelease
                    ? 'text-amber-700 dark:text-amber-400'
                    : 'text-emerald-700 dark:text-emerald-400'
                "
              >
                {{
                  isArticle ? '新文章上线' : isNewRelease ? '新视频上线' : '审核通过'
                }}
              </p>
              <h2 id="episode-published-popup-title" class="text-base font-semibold leading-snug">
                {{
                  isArticle
                    ? '有新的阅读文章发布了'
                    : isNewRelease
                      ? '有新的学习视频发布了'
                      : '投稿视频已通过审核'
                }}
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

          <p v-if="isNewRelease" class="text-sm text-neutral-600 dark:text-neutral-300 leading-relaxed">
            「
            <span class="font-medium text-neutral-800 dark:text-neutral-100">{{ displayTitle }}</span>
            」已上线，{{ isArticle ? '快来阅读吧。' : '快来学习吧。' }}
          </p>
          <p v-else class="text-sm text-neutral-600 dark:text-neutral-300 leading-relaxed">
            你于
            <span class="font-medium text-neutral-800 dark:text-neutral-100">{{
              single.submitted_at || '近期'
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
              v-if="single.video_id || single.article_id"
              type="button"
              class="px-4 py-2.5 rounded-xl text-sm font-medium bg-amber-600 text-white hover:bg-amber-700 transition disabled:opacity-50"
              :disabled="busy"
              @click="onOpenSingle"
            >
              {{ isArticle ? '前往阅读' : '前往观看' }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </Teleport>
</template>
