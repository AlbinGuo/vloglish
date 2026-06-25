<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { RouterLink } from 'vue-router'
import { getVocabulary, removeVocabulary, type VocabularyItem } from '@/api/learning'

const loading = ref(true)
const items = ref<VocabularyItem[]>([])
const error = ref('')

async function load() {
  loading.value = true
  error.value = ''
  try {
    items.value = await getVocabulary()
  } catch {
    error.value = '加载失败，请先登录'
  } finally {
    loading.value = false
  }
}

async function remove(item: VocabularyItem) {
  await removeVocabulary(item.entry_id)
  items.value = items.value.filter((v) => v.id !== item.id)
}

onMounted(load)
</script>

<template>
  <div class="page-container py-6 max-w-2xl">
    <div class="flex items-center gap-3 text-sm mb-6">
      <RouterLink to="/english/learning" class="text-neutral-500 hover:text-neutral-900 dark:text-neutral-400 dark:hover:text-white">← 学习统计</RouterLink>
      <span class="text-neutral-300 dark:text-neutral-600">|</span>
      <span class="font-medium">生词本</span>
    </div>

    <p v-if="error" class="text-sm text-red-600 dark:text-red-400 mb-4">{{ error }}</p>
    <div v-if="loading" class="text-neutral-500 dark:text-neutral-400 text-sm">加载中...</div>
    <div v-else-if="!items.length" class="rounded-xl border border-black/5 dark:border-white/10 bg-white dark:bg-neutral-900 p-12 text-center text-neutral-500 dark:text-neutral-400 text-sm">
      暂无生词，在学习页查词后可加入生词本
    </div>
    <ul v-else class="space-y-2">
      <li
        v-for="item in items"
        :key="item.id"
        class="rounded-xl border border-black/5 dark:border-white/10 bg-white dark:bg-neutral-900 px-4 py-3 flex items-center justify-between gap-3"
      >
        <div class="min-w-0">
          <p class="font-medium">{{ item.word }}</p>
          <p v-if="item.source_episode_title" class="text-xs text-neutral-400 truncate">
            来自 {{ item.source_episode_title }}
          </p>
        </div>
        <div class="flex items-center gap-2 shrink-0">
          <RouterLink
            v-if="item.source_video_id"
            :to="`/english/episode/${item.source_video_id}`"
            class="text-xs text-amber-700 dark:text-amber-400 hover:underline"
          >
            回看
          </RouterLink>
          <button type="button" class="text-xs text-red-600 dark:text-red-400 hover:underline" @click="remove(item)">
            移除
          </button>
        </div>
      </li>
    </ul>
  </div>
</template>
