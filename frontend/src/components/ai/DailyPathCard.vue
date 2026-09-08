<script setup lang="ts">
import { computed, onActivated, onMounted, ref } from 'vue'
import { RouterLink } from 'vue-router'
import { aiDailyPath, type DailyPathResult } from '@/api/aiCoach'
import { resolveMediaUrl } from '@/utils/mediaUrl'

const props = withDefaults(
  defineProps<{
    /** full：学习页完整路径；compact：首页今日一句 */
    variant?: 'full' | 'compact'
  }>(),
  { variant: 'full' },
)

const loading = ref(true)
const data = ref<DailyPathResult | null>(null)
let mountedOnce = false

async function load() {
  loading.value = !data.value
  try {
    data.value = await aiDailyPath()
  } catch {
    if (!data.value) data.value = null
  } finally {
    loading.value = false
  }
}

onMounted(async () => {
  await load()
  mountedOnce = true
})

onActivated(() => {
  if (mountedOnce) void load()
})

const isCompact = computed(() => props.variant === 'compact')
const sentence = computed(() => data.value?.today_sentence ?? null)
const streak = computed(() => sentence.value?.streak_days ?? data.value?.daily_streak ?? 0)
const preview = computed(() => data.value?.vocab_preview ?? [])
const continueItem = computed(() => {
  const item = data.value?.continue_item
  if (!item) return null
  if (sentence.value && item.video_id === sentence.value.video_id) return null
  return item
})
</script>

<template>
  <section
    v-if="isCompact"
    class="rounded-xl border border-amber-200/70 dark:border-amber-900/40 bg-amber-50/70 dark:bg-amber-950/25 px-2.5 py-2"
  >
    <div v-if="loading && !data" class="flex items-center gap-2.5 h-10 animate-pulse" aria-hidden="true">
      <div class="h-2.5 w-12 rounded bg-amber-200/50 dark:bg-amber-900/40" />
      <div class="h-3 flex-1 rounded bg-amber-200/40 dark:bg-amber-900/30" />
      <div class="h-6 w-12 rounded bg-amber-200/50 dark:bg-amber-900/40" />
    </div>

    <div v-else class="flex items-center gap-2 min-w-0">
      <RouterLink
        v-if="sentence"
        :to="sentence.path"
        class="flex items-center gap-2 min-w-0 flex-1 rounded-lg -m-0.5 p-0.5 active:bg-amber-100/60 dark:active:bg-amber-900/30 transition"
      >
        <span class="shrink-0 text-[11px] font-medium text-amber-700 dark:text-amber-300">
          {{ sentence.completed ? '已打卡' : '今日一句' }}
        </span>
        <span class="min-w-0 flex-1 text-sm font-medium truncate text-neutral-900 dark:text-neutral-100">
          {{ sentence.english }}
        </span>
      </RouterLink>
      <p v-else class="flex-1 text-sm text-neutral-500 truncate">暂时没有今日一句</p>

      <span class="shrink-0 text-[11px] tabular-nums text-amber-800/80 dark:text-amber-300/80">
        {{ streak }}天
      </span>
      <RouterLink
        v-if="continueItem"
        :to="`/english/episode/${continueItem.video_id}`"
        class="shrink-0 text-[11px] font-medium text-amber-800 dark:text-amber-300 px-1.5 py-1 rounded-lg hover:bg-amber-100/80 dark:hover:bg-amber-900/40"
      >
        继续
      </RouterLink>
      <RouterLink
        v-if="preview.length"
        :to="preview[0].path"
        class="shrink-0 text-[11px] font-medium text-amber-800 dark:text-amber-300 px-1.5 py-1 rounded-lg hover:bg-amber-100/80 dark:hover:bg-amber-900/40 whitespace-nowrap"
      >
        {{ preview.length }}词
      </RouterLink>
    </div>
  </section>

  <section
    v-else
    class="rounded-xl border border-amber-200/80 dark:border-amber-900/50 bg-gradient-to-br from-amber-50/90 to-white dark:from-amber-950/30 dark:to-neutral-900 p-4 sm:p-5"
  >
    <div class="flex items-center gap-2 mb-3 min-w-0">
      <h2 class="text-sm font-semibold text-neutral-900 dark:text-neutral-100 shrink-0">
        今日学习路径
      </h2>
      <span
        class="inline-flex items-center px-1.5 h-5 rounded-md text-[10px] font-semibold tracking-wide bg-amber-500/15 text-amber-800 dark:bg-amber-400/15 dark:text-amber-200 border border-amber-500/25 dark:border-amber-400/30 shrink-0"
      >
        今日一句优先
      </span>
    </div>

    <p v-if="loading && !data" class="text-sm text-neutral-500 py-4">加载中...</p>
    <p v-else-if="!data" class="text-sm text-neutral-500 py-4">暂时无法加载推荐</p>
    <div v-else class="space-y-3">
      <RouterLink
        v-if="sentence"
        :to="sentence.path"
        class="block rounded-lg border border-amber-300/60 dark:border-amber-800/60 bg-white/80 dark:bg-neutral-900/60 p-3 hover:border-amber-400 transition"
      >
        <p class="text-xs text-amber-700 dark:text-amber-300">
          {{ sentence.completed ? '今日已打卡' : '今日一句' }} · 连续 {{ sentence.streak_days }} 天
        </p>
        <p class="text-sm font-medium mt-1 leading-snug">{{ sentence.english }}</p>
        <p v-if="sentence.chinese" class="text-xs text-neutral-500 mt-0.5">{{ sentence.chinese }}</p>
      </RouterLink>

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
