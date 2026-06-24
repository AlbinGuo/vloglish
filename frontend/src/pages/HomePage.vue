<script setup lang="ts">
import { computed, onMounted, watch } from 'vue'
import { RouterLink } from 'vue-router'
import { useCatalogViewMode } from '@/composables/useCatalogViewMode'
import { useAuthStore } from '@/stores/auth'
import { useCatalogStore } from '@/stores/catalog'
import CatalogCalendar from '@/components/catalog/CatalogCalendar.vue'
import CatalogFilters from '@/components/catalog/CatalogFilters.vue'
import CatalogListToolbar from '@/components/catalog/CatalogListToolbar.vue'
import CatalogViewSettings from '@/components/catalog/CatalogViewSettings.vue'
import CatalogEpisodeSkeletons from '@/components/skeleton/CatalogEpisodeSkeletons.vue'
import EpisodeCard from '@/components/EpisodeCard.vue'
import EpisodeListRow from '@/components/EpisodeListRow.vue'

const store = useCatalogStore()
const auth = useAuthStore()
const { viewMode } = useCatalogViewMode()

const totalPages = computed(() => Math.max(1, Math.ceil(store.total / store.filters.page_size)))

const pageRowOffset = computed(() => (store.filters.page - 1) * store.filters.page_size)

const skeletonCount = computed(() => Math.min(store.filters.page_size, 12))

const previewBanner = computed(() => {
  if (auth.isMember) return null
  if (auth.isLoggedIn) {
    return {
      text: '当前仅展示 5 期视频，激活会员解锁全量。',
      showLogin: false,
      showSignup: false,
      showActivate: true,
    }
  }
  return {
    text: '当前仅展示 2 期视频，登录后可看 5 期。',
    showLogin: true,
    showSignup: true,
    showActivate: false,
  }
})

onMounted(async () => {
  await store.loadFilters()
  await store.loadEpisodes()
})

function episodePath(videoId: string) {
  return auth.isMember ? `/english/episode/${videoId}` : `/english/demo/${videoId}`
}

watch(
  () => [auth.isMember, auth.isLoggedIn],
  () => {
    store.loadEpisodes(true)
  },
)

function prevPage() {
  if (store.filters.page <= 1) return
  store.filters.page--
  store.loadEpisodes()
}

function nextPage() {
  if (store.filters.page >= totalPages.value) return
  store.filters.page++
  store.loadEpisodes()
}
</script>

<template>
  <div class="page-container py-6">
    <div class="flex flex-col lg:flex-row gap-6 lg:gap-8">
      <aside class="w-full lg:w-72 xl:w-80 shrink-0 space-y-4">
        <CatalogCalendar />
        <CatalogFilters />
        <CatalogViewSettings />
      </aside>

      <section class="flex-1 min-w-0">
        <div
          v-if="previewBanner"
          class="mb-4 rounded-xl border border-amber-200 bg-amber-50 px-4 py-3 text-sm text-amber-900 flex flex-wrap items-center gap-x-2 gap-y-1"
        >
          <span>{{ previewBanner.text }}</span>
          <RouterLink v-if="previewBanner.showLogin" to="/login" class="font-medium underline">登录</RouterLink>
          <RouterLink v-if="previewBanner.showSignup" to="/signup" class="font-medium underline">注册</RouterLink>
          <RouterLink v-if="previewBanner.showActivate" to="/activate" class="font-medium underline">激活会员</RouterLink>
        </div>

        <CatalogEpisodeSkeletons v-if="store.loading" :count="skeletonCount" />

        <div v-else-if="viewMode === 'card'">
          <div v-if="!store.episodes.length" class="text-center py-24 text-neutral-500">没有匹配的内容</div>
          <div v-else class="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-3">
            <EpisodeCard
              v-for="ep in store.episodes"
              :key="ep.video_id"
              :episode="ep"
              :to="episodePath(ep.video_id)"
            />
          </div>
        </div>

        <div v-else class="rounded-xl border border-black/5 overflow-hidden bg-white">
          <CatalogListToolbar />
          <div v-if="!store.episodes.length" class="text-center py-16 text-neutral-500">没有匹配的内容</div>
          <EpisodeListRow
            v-for="(ep, i) in store.episodes"
            :key="ep.video_id"
            :episode="ep"
            :row-index="pageRowOffset + i + 1"
            :to="episodePath(ep.video_id)"
          />
        </div>

        <div v-if="!store.loading && totalPages > 1" class="flex justify-center items-center gap-3 mt-10">
          <button
            type="button"
            class="px-4 py-1.5 text-sm border rounded-lg disabled:opacity-40 hover:bg-neutral-50"
            :disabled="store.filters.page <= 1"
            @click="prevPage"
          >
            上一页
          </button>
          <span class="text-sm text-neutral-500">{{ store.filters.page }} / {{ totalPages }}</span>
          <button
            type="button"
            class="px-4 py-1.5 text-sm border rounded-lg disabled:opacity-40 hover:bg-neutral-50"
            :disabled="store.filters.page >= totalPages"
            @click="nextPage"
          >
            下一页
          </button>
        </div>
      </section>
    </div>
  </div>
</template>
