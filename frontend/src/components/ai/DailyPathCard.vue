<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { RouterLink } from 'vue-router'
import { aiDailyPath, type DailyPathResult } from '@/api/aiCoach'
import { resolveMediaUrl } from '@/utils/mediaUrl'

const props = withDefaults(
  defineProps<{
    /** full：学习页完整路径；compact：首页一行续学 */
    variant?: 'full' | 'compact'
  }>(),
  { variant: 'full' },
)

const loading = ref(true)
const data = ref<DailyPathResult | null>(null)

onMounted(async () => {
  try {
    data.value = await aiDailyPath()
  } catch {
    data.value = null
  } finally {
    loading.value = false
  }
})

const isCompact = computed(() => props.variant === 'compact')

/** compact：优先续学，否则今日推荐第一条 */
const compactPrimary = computed(() => {
  const d = data.value
  if (!d) return null
  if (d.continue_item) {
    return {
      videoId: d.continue_item.video_id,
      title: d.continue_item.title,
      cover: d.continue_item.cover,
      label: '继续',
      reason: d.continue_item.reason,
    }
  }
  const first = d.recommend[0]
  if (!first) return null
  return {
    videoId: first.video_id,
    title: first.title,
    cover: first.cover,
    label: '今日推荐',
    reason: first.reason,
  }
})

const compactVocabCount = computed(() => data.value?.vocab_review?.count ?? 0)
const compactVocabPath = computed(() => data.value?.vocab_review?.path ?? '/english/vocabulary')

const showCompact = computed(() => {
  if (!isCompact.value) return false
  if (loading.value) return true
  return Boolean(compactPrimary.value) || compactVocabCount.value > 0
})
</script>

<template>
  <!-- compact：一行续学 / 生词 -->
  <section
    v-if="isCompact && showCompact"
    class="rounded-xl border border-amber-200/70 dark:border-amber-900/40 bg-amber-50/70 dark:bg-amber-950/25 px-2.5 py-2"
  >
    <div v-if="loading" class="flex items-center gap-2.5 h-11 animate-pulse" aria-hidden="true">
      <div class="w-14 h-9 rounded-md bg-amber-200/50 dark:bg-amber-900/40 shrink-0" />
      <div class="flex-1 space-y-1.5 min-w-0">
        <div class="h-2.5 w-10 rounded bg-amber-200/50 dark:bg-amber-900/40" />
        <div class="h-3 w-2/3 rounded bg-amber-200/40 dark:bg-amber-900/30" />
      </div>
    </div>

    <div v-else class="flex items-center gap-2 min-w-0">
      <RouterLink
        v-if="compactPrimary"
        :to="`/english/episode/${compactPrimary.videoId}`"
        class="flex items-center gap-2.5 min-w-0 flex-1 rounded-lg -m-0.5 p-0.5 active:bg-amber-100/60 dark:active:bg-amber-900/30 transition"
      >
        <div class="w-14 h-9 rounded-md overflow-hidden bg-neutral-200 dark:bg-neutral-800 shrink-0">
          <img
            v-if="compactPrimary.cover"
            :src="resolveMediaUrl(compactPrimary.cover)"
            alt=""
            class="w-full h-full object-cover"
          />
        </div>
        <div class="min-w-0 flex-1">
          <p class="text-[11px] leading-none text-amber-700 dark:text-amber-300 font-medium">
            {{ compactPrimary.label }}
          </p>
          <p class="text-sm font-medium truncate text-neutral-900 dark:text-neutral-100 mt-0.5">
            {{ compactPrimary.title }}
          </p>
        </div>
        <svg
          class="w-4 h-4 shrink-0 text-neutral-400"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="2"
          aria-hidden="true"
        >
          <path d="M9 18l6-6-6-6" />
        </svg>
      </RouterLink>

      <RouterLink
        v-if="compactVocabCount > 0"
        :to="compactVocabPath"
        class="shrink-0 text-[11px] font-medium text-amber-800 dark:text-amber-300 px-2 py-1.5 rounded-lg hover:bg-amber-100/80 dark:hover:bg-amber-900/40 whitespace-nowrap"
      >
        复习 {{ compactVocabCount }} 词
      </RouterLink>
    </div>
  </section>

  <!-- full：完整学习路径 -->
  <section
    v-else-if="!isCompact"
    class="rounded-xl border border-amber-200/80 dark:border-amber-900/50 bg-gradient-to-br from-amber-50/90 to-white dark:from-amber-950/30 dark:to-neutral-900 p-4 sm:p-5"
  >
    <div class="flex items-center gap-2 mb-3 min-w-0">
      <h2 class="text-sm font-semibold text-neutral-900 dark:text-neutral-100 shrink-0">
        今日学习路径
      </h2>
      <span
        class="inline-flex items-center px-1.5 h-5 rounded-md text-[10px] font-semibold tracking-wide bg-amber-500/15 text-amber-800 dark:bg-amber-400/15 dark:text-amber-200 border border-amber-500/25 dark:border-amber-400/30 shrink-0"
        title="根据你的学习进度自动推荐续学、精听与生词复习"
      >
        按进度智能推荐
      </span>
    </div>

    <p v-if="loading" class="text-sm text-neutral-500 py-4">加载中...</p>
    <p v-else-if="!data" class="text-sm text-neutral-500 py-4">暂时无法加载推荐</p>
    <div v-else class="space-y-3">
      <RouterLink
        v-if="data.continue_item"
        :to="`/english/episode/${data.continue_item.video_id}`"
        class="flex items-center gap-3 rounded-lg border border-black/5 dark:border-white/10 bg-white/80 dark:bg-neutral-900/60 p-2.5 hover:border-amber-400 transition"
      >
        <div class="w-16 h-10 rounded-md overflow-hidden bg-neutral-200 dark:bg-neutral-800 shrink-0">
          <img
            v-if="data.continue_item.cover"
            :src="resolveMediaUrl(data.continue_item.cover)"
            alt=""
            class="w-full h-full object-cover"
          />
        </div>
        <div class="min-w-0 flex-1">
          <p class="text-xs text-amber-700 dark:text-amber-300">{{ data.continue_item.reason }}</p>
          <p class="text-sm font-medium truncate">{{ data.continue_item.title }}</p>
        </div>
      </RouterLink>

      <div v-if="data.recommend.length" class="space-y-2">
        <p class="text-xs text-neutral-500">今日推荐</p>
        <RouterLink
          v-for="item in data.recommend"
          :key="item.video_id"
          :to="`/english/episode/${item.video_id}`"
          class="flex items-center gap-3 rounded-lg px-1 py-1.5 hover:bg-black/[0.03] dark:hover:bg-white/[0.04] transition"
        >
          <div class="w-14 h-9 rounded-md overflow-hidden bg-neutral-200 dark:bg-neutral-800 shrink-0">
            <img
              v-if="item.cover"
              :src="resolveMediaUrl(item.cover)"
              alt=""
              class="w-full h-full object-cover"
            />
          </div>
          <div class="min-w-0">
            <p class="text-sm truncate">{{ item.title }}</p>
            <p class="text-[11px] text-neutral-400">{{ item.reason }}</p>
          </div>
        </RouterLink>
      </div>

      <RouterLink
        :to="data.vocab_review.path"
        class="block text-sm text-amber-800 dark:text-amber-300 hover:underline"
      >
        {{ data.vocab_review.reason }}
        <span v-if="data.vocab_review.count">（{{ data.vocab_review.count }}）</span>
      </RouterLink>
    </div>
  </section>
</template>
