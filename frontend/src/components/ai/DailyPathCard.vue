<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { RouterLink } from 'vue-router'
import { aiDailyPath, type DailyPathResult } from '@/api/aiCoach'
import { resolveMediaUrl } from '@/utils/mediaUrl'

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
</script>

<template>
  <section
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
