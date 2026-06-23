<script setup lang="ts">
import { computed, onMounted, watch } from 'vue'
import { useCatalogStore } from '@/stores/catalog'
import EpisodeCard from '@/components/EpisodeCard.vue'

const store = useCatalogStore()
const totalPages = computed(() => Math.max(1, Math.ceil(store.total / store.filters.page_size)))

onMounted(async () => {
  await store.loadFilters()
  await store.loadEpisodes()
})

watch(
  () => [store.filters.stars, store.filters.accent, store.filters.gender, store.filters.tag, store.filters.ordering],
  () => store.loadEpisodes(true),
)

function applyAndLoad() {
  store.loadEpisodes(true)
}
</script>

<template>
  <div class="max-w-6xl mx-auto p-4 sm:p-6">
    <div class="mb-6">
      <h1 class="text-2xl font-semibold mb-1">语料目录</h1>
      <p class="text-sm text-neutral-500">共 {{ store.total }} 期 · 持续更新中</p>
    </div>

    <!-- 筛选栏 -->
    <div class="bg-white rounded-2xl border border-black/5 p-4 mb-6 space-y-3">
      <div class="flex flex-wrap gap-3 items-end">
        <label class="text-sm space-y-1">
          <span class="text-neutral-500">难度</span>
          <select v-model="store.filters.stars" class="block border rounded-lg px-2 py-1.5 min-w-[100px]">
            <option :value="undefined">全部</option>
            <option v-for="n in 5" :key="n" :value="n">{{ n }} 星</option>
          </select>
        </label>

        <label class="text-sm space-y-1">
          <span class="text-neutral-500">口音</span>
          <select v-model="store.filters.accent" class="block border rounded-lg px-2 py-1.5 min-w-[100px]">
            <option :value="undefined">全部</option>
            <option v-for="a in store.accents" :key="a" :value="a">{{ a }}</option>
          </select>
        </label>

        <label class="text-sm space-y-1">
          <span class="text-neutral-500">性别</span>
          <select v-model="store.filters.gender" class="block border rounded-lg px-2 py-1.5 min-w-[100px]">
            <option :value="undefined">全部</option>
            <option value="m">男性</option>
            <option value="f">女性</option>
          </select>
        </label>

        <label class="text-sm space-y-1">
          <span class="text-neutral-500">主题</span>
          <select v-model="store.filters.tag" class="block border rounded-lg px-2 py-1.5 min-w-[120px]">
            <option :value="undefined">全部</option>
            <option v-for="t in store.tags" :key="t.id" :value="t.id">{{ t.name }}</option>
          </select>
        </label>

        <label class="text-sm space-y-1">
          <span class="text-neutral-500">排序</span>
          <select v-model="store.filters.ordering" class="block border rounded-lg px-2 py-1.5 min-w-[120px]">
            <option value="index">期数倒序</option>
            <option value="-index">期数正序</option>
            <option value="stars">难度从高到低</option>
            <option value="-stars">难度从低到高</option>
          </select>
        </label>

        <button class="px-4 py-1.5 text-sm border rounded-lg hover:bg-neutral-50" @click="store.clearFilters(); applyAndLoad()">
          清除
        </button>
      </div>
    </div>

    <div v-if="store.loading" class="text-center py-16 text-neutral-500">加载中...</div>
    <div v-else-if="!store.episodes.length" class="text-center py-16 text-neutral-500">没有匹配的内容</div>
    <div v-else class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
      <EpisodeCard
        v-for="ep in store.episodes"
        :key="ep.video_id"
        :episode="ep"
        :to="`/english/episode/${ep.video_id}`"
      />
    </div>

    <div v-if="totalPages > 1" class="flex justify-center gap-2 mt-8">
      <button
        class="px-3 py-1 border rounded-lg disabled:opacity-40"
        :disabled="store.filters.page <= 1"
        @click="store.filters.page--; store.loadEpisodes()"
      >
        上一页
      </button>
      <span class="px-3 py-1 text-sm text-neutral-500">{{ store.filters.page }} / {{ totalPages }}</span>
      <button
        class="px-3 py-1 border rounded-lg disabled:opacity-40"
        :disabled="store.filters.page >= totalPages"
        @click="store.filters.page++; store.loadEpisodes()"
      >
        下一页
      </button>
    </div>
  </div>
</template>
