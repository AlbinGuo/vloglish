<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { RouterLink, useRoute } from 'vue-router'
import { getAuthorDetail, getEpisodeList } from '@/api/episodes'
import EpisodeCard from '@/components/EpisodeCard.vue'
import { accentIconFor } from '@/constants/accentOptions'
import { useAuthStore } from '@/stores/auth'
import type { AuthorCatalogItem, EpisodeSummary } from '@/types'

defineOptions({ name: 'AuthorDetailPage' })

const route = useRoute()
const auth = useAuthStore()

const loading = ref(true)
const error = ref('')
const author = ref<AuthorCatalogItem | null>(null)
const episodes = ref<EpisodeSummary[]>([])

const authorId = computed(() => Number(route.params.authorId))
const accentIcon = computed(() => (author.value ? accentIconFor(author.value.accent) : undefined))
const genderLabel = computed(() => (author.value?.gender === 'f' ? '女' : '男'))

function episodePath(videoId: string) {
  if (!auth.isLoggedIn) {
    return `/login?next=${encodeURIComponent(`/english/episode/${videoId}`)}`
  }
  return `/english/episode/${videoId}`
}

async function load() {
  if (!Number.isFinite(authorId.value) || authorId.value <= 0) {
    error.value = '作者不存在'
    author.value = null
    episodes.value = []
    loading.value = false
    return
  }

  loading.value = true
  error.value = ''
  try {
    const [detail, list] = await Promise.all([
      getAuthorDetail(authorId.value),
      getEpisodeList({ author_id: authorId.value, page_size: 50, offset: 0 }),
    ])
    author.value = detail
    episodes.value = list.results
  } catch {
    author.value = null
    episodes.value = []
    error.value = '作者不存在或加载失败'
  } finally {
    loading.value = false
  }
}

onMounted(load)
watch(authorId, load)
</script>

<template>
  <div class="page-container py-6">
    <p v-if="loading" class="py-24 text-center text-neutral-500">加载中...</p>
    <p v-else-if="error" class="py-24 text-center text-red-600">{{ error }}</p>

    <template v-else-if="author">
      <div class="mb-6 min-w-0">
        <RouterLink
          to="/english"
          class="text-xs text-neutral-500 hover:text-neutral-800 dark:hover:text-neutral-200"
        >
          ← 返回视频
        </RouterLink>
        <h1 class="mt-2 text-2xl font-semibold tracking-tight">{{ author.name }}</h1>
        <div class="mt-2 flex flex-wrap items-center gap-x-3 gap-y-1.5 text-sm text-neutral-600 dark:text-neutral-300">
          <span v-if="author.nationality" class="inline-flex items-center gap-1.5">
            <span class="text-base leading-none">{{ author.nationality }}</span>
            <span class="text-neutral-500">国籍</span>
          </span>
          <span class="inline-flex items-center gap-1.5">
            <img
              v-if="accentIcon"
              :src="accentIcon"
              :alt="author.accent"
              class="w-4 h-4 object-contain rounded-full border border-black/10 dark:border-white/20"
            />
            <span>{{ author.accent || '口音未标注' }}</span>
          </span>
          <span>{{ genderLabel }}</span>
          <span class="text-neutral-400">·</span>
          <span>共 {{ author.episode_count }} 个视频</span>
        </div>
      </div>

      <div v-if="!episodes.length" class="text-center py-20 text-neutral-500">暂无视频</div>
      <div v-else class="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-3">
        <EpisodeCard
          v-for="ep in episodes"
          :key="ep.video_id"
          :episode="ep"
          :to="episodePath(ep.video_id)"
        />
      </div>
    </template>
  </div>
</template>
