<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { RouterLink, useRoute } from 'vue-router'
import { getAuthorDetail, getEpisodeList, urgeAuthor } from '@/api/episodes'
import AuthorSubscribeButton from '@/components/AuthorSubscribeButton.vue'
import AppIcon from '@/components/AppIcon.vue'
import EpisodeCard from '@/components/EpisodeCard.vue'
import AuthorAvatar from '@/components/AuthorAvatar.vue'
import { accentIconFor } from '@/constants/accentOptions'
import { useAuthStore } from '@/stores/auth'
import { useIsMobile } from '@/composables/useBreakpoint'
import type { AuthorCatalogItem, EpisodeSummary } from '@/types'

defineOptions({ name: 'AuthorDetailPage' })

const route = useRoute()
const auth = useAuthStore()
const isMobile = useIsMobile()

const loading = ref(true)
const error = ref('')
const author = ref<AuthorCatalogItem | null>(null)
const episodes = ref<EpisodeSummary[]>([])

const urging = ref(false)
const urgedTimes = ref(0)
const urgeMsg = ref('')

async function onUrge() {
  if (!author.value || urging.value) return
  urging.value = true
  urgeMsg.value = ''
  try {
    const res = await urgeAuthor(author.value.id)
    urgedTimes.value = res.my_count
    urgeMsg.value = `已催更，该作者累计被催更 ${res.author_total} 次`
  } catch {
    urgeMsg.value = '催更失败，请稍后重试'
  } finally {
    urging.value = false
  }
}

const authorId = computed(() => Number(route.params.authorId))
const accentIcon = computed(() => (author.value ? accentIconFor(author.value.accent) : undefined))
const genderLabel = computed(() => (author.value?.gender === 'f' ? '女' : '男'))

function episodePath(ep: { video_id: string; requires_membership?: boolean }) {
  if (!auth.isLoggedIn) {
    return `/login?next=${encodeURIComponent(`/english/episode/${ep.video_id}`)}`
  }
  if (ep.requires_membership) return '/pricing'
  return `/english/episode/${ep.video_id}`
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
      <!-- 移动端：顶部背景 hero + 头像名字叠加（背景可由管理端设置） -->
      <div v-if="isMobile" class="relative -mx-4 -mt-6 mb-3">
        <div class="relative h-52 w-full overflow-hidden bg-gradient-to-br from-sky-400 via-blue-500 to-indigo-600">
          <img
            v-if="author.banner"
            :src="author.banner"
            class="absolute inset-0 h-full w-full object-cover"
            alt=""
            loading="lazy"
          />
          <div
            class="pointer-events-none absolute inset-x-0 bottom-0 h-28 bg-gradient-to-t from-canvas via-canvas/55 to-transparent"
          />
        </div>
        <div class="absolute inset-x-0 bottom-0 flex items-end gap-3 px-4 pb-1">
          <div class="rounded-full bg-card shadow-lg ring-4 ring-white/80">
            <AuthorAvatar :src="author.avatar" :name="author.name" :size="76" />
          </div>
          <div class="min-w-0 flex-1 pb-1.5">
            <h1 class="truncate text-xl font-semibold tracking-tight text-ink">{{ author.name }}</h1>
            <p class="truncate text-xs text-ink-soft">
              {{ author.accent || '口音未标注' }}
              <span class="mx-1 text-neutral-400">·</span>共 {{ author.episode_count }} 个视频
            </p>
          </div>
        </div>
      </div>

      <!-- 移动端：关注 / 催更 -->
      <div v-if="isMobile" class="mb-4 flex flex-wrap items-center gap-3">
        <AuthorSubscribeButton
          class="flex-1 min-w-0"
          :author-id="author.id"
          :is-subscribed="Boolean(author.is_subscribed)"
          :subscriber-count="author.subscriber_count || 0"
          show-count
          @update:is-subscribed="author.is_subscribed = $event"
          @update:subscriber-count="author.subscriber_count = $event"
        />
        <button
          type="button"
          class="flex flex-1 min-w-0 items-center justify-center gap-1.5 rounded-lg border border-amber-200 bg-amber-50 px-3 py-2 text-sm font-medium text-amber-700 transition hover:bg-amber-100 disabled:opacity-50 dark:border-amber-800 dark:bg-amber-950/30 dark:text-amber-300"
          :disabled="urging"
          @click="onUrge"
        >
          <AppIcon name="bell" class="h-4 w-4" />
          {{ urging ? '发送中…' : '催更' }}
        </button>
        <span v-if="urgeMsg" class="w-full text-center text-xs text-amber-600 dark:text-amber-300">{{ urgeMsg }}</span>
      </div>

      <!-- 桌面端：原信息块 -->
      <div v-else class="mb-6 min-w-0">
        <RouterLink
          to="/english"
          class="text-xs text-neutral-500 hover:text-ink-soft"
        >
          ← 返回视频
        </RouterLink>
        <div class="mt-2 flex items-center gap-3 min-w-0">
          <AuthorAvatar :src="author.avatar" :name="author.name" :size="56" />
          <h1 class="text-2xl font-semibold tracking-tight truncate">{{ author.name }}</h1>
        </div>
        <div class="mt-3 flex flex-wrap items-center gap-3">
          <AuthorSubscribeButton
            :author-id="author.id"
            :is-subscribed="Boolean(author.is_subscribed)"
            :subscriber-count="author.subscriber_count || 0"
            show-count
            @update:is-subscribed="author.is_subscribed = $event"
            @update:subscriber-count="author.subscriber_count = $event"
          />
          <button
            type="button"
            class="inline-flex items-center gap-1.5 rounded-lg border border-amber-200 bg-amber-50 px-3 py-2 text-sm font-medium text-amber-700 transition hover:bg-amber-100 disabled:opacity-50 dark:border-amber-800 dark:bg-amber-950/30 dark:text-amber-300"
            :disabled="urging"
            @click="onUrge"
          >
            <AppIcon name="bell" class="h-4 w-4" />
            {{ urging ? '发送中…' : '催更' }}
          </button>
          <span v-if="urgeMsg" class="text-xs text-amber-600 dark:text-amber-300">{{ urgeMsg }}</span>
        </div>
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
          :to="episodePath(ep)"
        />
      </div>
    </template>
  </div>
</template>
