<script setup lang="ts">
import { onMounted, ref, watch } from 'vue'
import { getRecentEpisodes, type RecentEpisode } from '@/api/learning'
import { useAuthStore } from '@/stores/auth'
import { useListenPlayerStore, type ListenQueueItem } from '@/stores/listenPlayer'
import { formatListenTime } from '@/utils/formatListenTime'
import { resolveMediaUrl } from '@/utils/mediaUrl'

const listen = useListenPlayerStore()
const auth = useAuthStore()

const favorites = ref<ListenQueueItem[]>([])
const history = ref<RecentEpisode[]>([])
const loadingFav = ref(false)
const loadingHistory = ref(false)

function close() {
  listen.playlistOpen = false
}

async function loadFavorites() {
  if (!auth.isLoggedIn) {
    favorites.value = []
    return
  }
  loadingFav.value = true
  try {
    favorites.value = await listen.loadFavoriteQueue()
  } catch {
    favorites.value = []
  } finally {
    loadingFav.value = false
  }
}

async function loadHistory() {
  if (!auth.isLoggedIn) {
    history.value = []
    return
  }
  loadingHistory.value = true
  try {
    history.value = await getRecentEpisodes({ limit: 40, includeCompleted: true })
  } catch {
    history.value = []
  } finally {
    loadingHistory.value = false
  }
}

watch(
  () => listen.playlistOpen,
  (open) => {
    if (!open) return
    if (listen.playlistTab === 'favorites') void loadFavorites()
    if (listen.playlistTab === 'history') void loadHistory()
  },
)

watch(
  () => listen.playlistTab,
  (tab) => {
    if (!listen.playlistOpen) return
    if (tab === 'favorites') void loadFavorites()
    if (tab === 'history') void loadHistory()
  },
)

onMounted(() => {
  if (listen.playlistOpen && listen.playlistTab === 'favorites') void loadFavorites()
})

function playItem(videoId: string) {
  void listen.playFromQueue(videoId, false)
}

function playHistory(row: RecentEpisode) {
  void listen.enqueueAndPlay(
    {
      video_id: row.video_id,
      short_title: row.short_title,
      cover: row.cover,
      clip_length: row.clip_length || 0,
      author_name: row.author_name || '',
    },
    false,
  )
}
</script>

<template>
  <Teleport to="body">
    <div
      v-if="listen.playlistOpen"
      class="fixed inset-0 z-[70] flex flex-col justify-end bg-black/45"
      @click.self="close"
    >
      <div
        class="max-h-[78dvh] flex flex-col rounded-t-2xl bg-white dark:bg-neutral-900 pb-[max(0.5rem,env(safe-area-inset-bottom))]"
        @click.stop
      >
        <div class="flex justify-center pt-3">
          <div class="w-10 h-1 rounded-full bg-neutral-300 dark:bg-neutral-600" />
        </div>
        <div class="flex items-center gap-1 px-3 pt-2 pb-1">
          <button
            type="button"
            class="flex-1 py-2.5 text-sm font-medium"
            :class="listen.playlistTab === 'queue' ? 'text-ink' : 'text-neutral-400'"
            @click="listen.playlistTab = 'queue'"
          >
            当前播放
          </button>
          <button
            type="button"
            class="flex-1 py-2.5 text-sm font-medium"
            :class="listen.playlistTab === 'favorites' ? 'text-ink' : 'text-neutral-400'"
            @click="listen.playlistTab = 'favorites'"
          >
            我的收藏
          </button>
          <button
            type="button"
            class="flex-1 py-2.5 text-sm font-medium"
            :class="listen.playlistTab === 'history' ? 'text-ink' : 'text-neutral-400'"
            @click="listen.playlistTab = 'history'"
          >
            收听历史
          </button>
          <button type="button" class="w-9 h-9 text-neutral-400" aria-label="关闭" @click="close">
            ×
          </button>
        </div>

        <div class="flex-1 min-h-0 overflow-y-auto px-3 pb-3">
          <template v-if="listen.playlistTab === 'queue'">
            <p v-if="!listen.queue.length" class="py-16 text-center text-sm text-neutral-400">队列是空的</p>
            <div
              v-for="item in listen.queue"
              :key="item.video_id"
              class="w-full flex items-center gap-3 py-2.5"
            >
              <button
                type="button"
                class="flex items-center gap-3 min-w-0 flex-1 text-left"
                @click="playItem(item.video_id)"
              >
                <div class="relative w-14 h-14 rounded-lg overflow-hidden bg-neutral-200 shrink-0">
                  <img :src="resolveMediaUrl(item.cover)" alt="" class="w-full h-full object-cover" />
                  <span
                    v-if="item.video_id === listen.currentVideoId && listen.isPlaying"
                    class="absolute inset-0 flex items-end justify-start p-1 bg-black/25"
                  >
                    <span class="listen-eq flex items-end gap-px h-3">
                      <i /><i /><i />
                    </span>
                  </span>
                </div>
                <div class="min-w-0 flex-1">
                  <p
                    class="text-sm font-medium leading-snug line-clamp-2"
                    :class="item.video_id === listen.currentVideoId ? 'text-amber-700 dark:text-amber-300' : ''"
                  >
                    {{ item.short_title }}
                  </p>
                  <p class="mt-0.5 text-[11px] text-neutral-400">
                    {{ item.author_name || 'Vloglish' }}
                    <span v-if="item.clip_length" class="tabular-nums">
                      {{ formatListenTime(item.clip_length) }}
                    </span>
                  </p>
                </div>
              </button>
              <button
                type="button"
                class="w-8 h-8 shrink-0 text-neutral-400 hover:text-neutral-700"
                aria-label="移出队列"
                @click="listen.removeFromQueue(item.video_id)"
              >
                ×
              </button>
            </div>
          </template>

          <template v-else-if="listen.playlistTab === 'favorites'">
            <p v-if="!auth.isLoggedIn" class="py-16 text-center text-sm text-neutral-400">登录后查看收藏</p>
            <p v-else-if="loadingFav" class="py-16 text-center text-sm text-neutral-400">加载中...</p>
            <p v-else-if="!favorites.length" class="py-16 text-center text-sm text-neutral-400">还没有收藏</p>
            <button
              v-for="item in favorites"
              :key="item.video_id"
              type="button"
              class="w-full flex items-center gap-3 py-2.5 text-left"
              @click="listen.enqueueAndPlay(item, false)"
            >
              <img
                :src="resolveMediaUrl(item.cover)"
                alt=""
                class="w-14 h-14 rounded-lg object-cover bg-neutral-200 shrink-0"
              />
              <div class="min-w-0 flex-1">
                <p class="text-sm font-medium leading-snug line-clamp-2">{{ item.short_title }}</p>
                <p class="mt-0.5 text-[11px] text-neutral-400">
                  {{ item.author_name || 'Vloglish' }}
                  <span v-if="item.clip_length" class="tabular-nums">{{ formatListenTime(item.clip_length) }}</span>
                </p>
              </div>
            </button>
          </template>

          <template v-else>
            <p v-if="!auth.isLoggedIn" class="py-16 text-center text-sm text-neutral-400">登录后查看收听历史</p>
            <p v-else-if="loadingHistory" class="py-16 text-center text-sm text-neutral-400">加载中...</p>
            <p v-else-if="!history.length" class="py-16 text-center text-sm text-neutral-400">还没有收听记录</p>
            <button
              v-for="row in history"
              :key="row.video_id"
              type="button"
              class="w-full flex items-center gap-3 py-2.5 text-left"
              @click="playHistory(row)"
            >
              <img
                :src="resolveMediaUrl(row.cover)"
                alt=""
                class="w-14 h-14 rounded-lg object-cover bg-neutral-200 shrink-0"
              />
              <div class="min-w-0 flex-1">
                <p class="text-sm font-medium leading-snug line-clamp-2">{{ row.short_title }}</p>
                <p class="mt-0.5 text-[11px] text-neutral-400 tabular-nums">
                  {{ row.author_name || 'Vloglish' }}
                  听到 {{ formatListenTime(row.last_position_sec || 0) }}
                  <span v-if="row.clip_length"> / {{ formatListenTime(row.clip_length) }}</span>
                </p>
              </div>
            </button>
          </template>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<style scoped>
.listen-eq i {
  display: block;
  width: 2px;
  background: #fff;
  animation: listen-eq 0.7s ease-in-out infinite;
}
.listen-eq i:nth-child(1) {
  height: 40%;
  animation-delay: 0s;
}
.listen-eq i:nth-child(2) {
  height: 90%;
  animation-delay: 0.15s;
}
.listen-eq i:nth-child(3) {
  height: 60%;
  animation-delay: 0.28s;
}
@keyframes listen-eq {
  0%,
  100% {
    transform: scaleY(0.45);
  }
  50% {
    transform: scaleY(1);
  }
}
</style>
