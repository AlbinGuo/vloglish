<script setup lang="ts">
import { toRef } from 'vue'
import { RouterLink } from 'vue-router'
import { accentIconFor } from '@/constants/accentOptions'
import { useEpisodeFavorite } from '@/composables/useEpisodeFavorite'
import { requestEpisodeAutoplay } from '@/composables/useEpisodeAutoplay'
import { useAuthStore } from '@/stores/auth'
import StarIcon from '@/components/icons/StarIcon.vue'
import type { EpisodeSummary } from '@/types'
import { displayLearnerCount } from '@/utils/displayLearnerCount'
import { resolveMediaUrl } from '@/utils/mediaUrl'
import { isOpenToFreeUsers } from '@/utils/episodeAccess'
import EpisodeAccessBadge from '@/components/EpisodeAccessBadge.vue'

const props = defineProps<{
  episode: EpisodeSummary
  to: string
  rowIndex: number
}>()

const episodeRef = toRef(props, 'episode')
const auth = useAuthStore()
const { favorited, loading, toggle } = useEpisodeFavorite(episodeRef)

const accentIcon = accentIconFor(props.episode.author.accent)

function formatDuration(sec: number) {
  const m = Math.floor(sec / 60)
  const s = Math.floor(sec % 60)
  return `${m}:${String(s).padStart(2, '0')}`
}

function learnerLabel() {
  return `${displayLearnerCount(props.episode.learner_count, props.episode.video_id)}人学过`
}
</script>

<template>
  <div class="flex items-stretch gap-3 border-b border-black/5 dark:border-white/10 bg-card hover:bg-neutral-50/80 dark:hover:bg-neutral-800/80 transition">
    <div class="w-10 shrink-0 flex items-center justify-center text-sm text-neutral-400 tabular-nums">
      {{ rowIndex }}
    </div>

    <RouterLink :to="to" class="flex flex-1 min-w-0 items-center gap-3 py-3 pr-2 cursor-pointer" @click="requestEpisodeAutoplay">
      <div class="relative w-28 sm:w-32 shrink-0 aspect-video rounded-lg overflow-hidden bg-sunken">
        <img
          :src="resolveMediaUrl(episode.cover)"
          :alt="episode.short_title"
          class="w-full h-full object-cover"
          loading="lazy"
        />
        <EpisodeAccessBadge
          class="absolute top-1.5 left-1.5"
          :free="isOpenToFreeUsers(episode)"
          compact
        />
        <span class="absolute bottom-1 right-1 text-white text-[10px] bg-black/60 px-1 py-0.5 rounded">
          {{ formatDuration(episode.clip_length) }}
        </span>
      </div>

      <div class="flex-1 min-w-0 space-y-1">
        <div class="flex flex-wrap items-center gap-x-2 gap-y-1">
          <span class="text-xs text-neutral-500">第 {{ episode.index }} 期</span>
          <span
            v-if="episode.is_pinned"
            class="text-xs px-2 py-0.5 rounded-md bg-amber-500 text-white font-bold leading-none"
          >
            置顶
          </span>
          <span
            v-if="episode.is_new"
            class="text-xs px-2 py-0.5 rounded-md bg-red-500 text-white font-bold leading-none"
          >
            新
          </span>
          <span
            v-if="episode.is_learned"
            class="text-[10px] px-1.5 py-0.5 rounded-full bg-emerald-100 text-emerald-700 dark:bg-emerald-900/50 dark:text-emerald-300 whitespace-nowrap"
          >
            已看完
          </span>
          <span
            v-else-if="auth.isLoggedIn && episode.progress_percent && episode.progress_percent > 0"
            class="text-[10px] px-1.5 py-0.5 rounded-full bg-sunken text-neutral-600 dark:text-neutral-400"
          >
            {{ Math.round(episode.progress_percent) }}%
          </span>
          <div class="flex items-center gap-0.5">
            <StarIcon v-for="n in 5" :key="n" :active="n <= episode.stars" />
          </div>
          <span
            v-for="t in episode.tags.slice(0, 2)"
            :key="t.id"
            class="text-[10px] bg-sunken text-neutral-600 dark:text-neutral-400 px-1.5 py-0.5 rounded"
          >
            {{ t.name }}
          </span>
        </div>
        <h3 class="font-semibold text-sm leading-snug line-clamp-1">{{ episode.short_title }}</h3>
        <p class="text-xs text-neutral-500 line-clamp-1">{{ episode.summary }}</p>
        <div class="flex flex-wrap items-center gap-x-2 gap-y-1 text-[11px] text-neutral-400">
          <span>{{ episode.voca_size }} 词 · {{ episode.subtitle_count }} 句 · {{ episode.author.name }}</span>
          <img
            v-if="accentIcon"
            :src="accentIcon"
            :alt="episode.author.accent"
            class="w-4 h-4 object-contain shrink-0"
          />
          <span class="font-semibold text-warning tabular-nums">
            {{ learnerLabel() }}
          </span>
        </div>
      </div>
    </RouterLink>

    <div v-if="auth.isMember" class="shrink-0 flex items-center pr-3">
      <button
        type="button"
        class="w-8 h-8 rounded-full border border-line flex items-center justify-center hover:bg-sunken transition disabled:opacity-60"
        :disabled="loading"
        :title="favorited ? '取消收藏' : '添加收藏'"
        @click="toggle"
      >
        <StarIcon
          :active="favorited"
          size-class="w-4 h-4"
          :class="favorited ? 'fav-star-burst' : ''"
          active-class="text-amber-400"
          inactive-class="text-neutral-300"
        />
      </button>
    </div>
  </div>
</template>
