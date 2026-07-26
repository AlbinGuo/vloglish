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

const props = defineProps<{ episode: EpisodeSummary; to: string }>()

const episodeRef = toRef(props, 'episode')
const auth = useAuthStore()
const { favorited, loading: favoriteLoading, toggle: toggleFavorite } = useEpisodeFavorite(episodeRef)

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
  <RouterLink :to="to" class="block group cursor-pointer" @click="requestEpisodeAutoplay">
    <article class="rounded-xl overflow-hidden border border-black/5 dark:border-white/10 shadow-sm hover:shadow-md transition bg-white dark:bg-neutral-900 h-full">
      <div class="relative aspect-video bg-neutral-200 dark:bg-neutral-800">
        <img
          :src="episode.cover"
          :alt="episode.short_title"
          class="w-full h-full object-cover group-hover:scale-[1.02] transition-transform duration-300"
          loading="lazy"
        />
        <div class="absolute inset-x-0 bottom-0 bg-gradient-to-t from-black/70 to-transparent px-2.5 pb-2 pt-7">
          <div class="flex items-center gap-1.5 min-w-0 pr-14">
            <span class="text-white text-xs font-medium truncate">@{{ episode.author.name }}</span>
            <img
              v-if="accentIcon"
              :src="accentIcon"
              :alt="episode.author.accent"
              class="w-4 h-4 object-contain shrink-0 rounded-full border border-white"
            />
          </div>
        </div>
        <span class="absolute bottom-2 right-2 text-white text-xs bg-black/60 px-2 py-0.5 rounded">
          {{ formatDuration(episode.clip_length) }}
        </span>
        <div class="absolute top-2 left-2 flex flex-row items-center gap-1.5 z-10">
          <span
            v-if="episode.is_pinned"
            class="text-[10px] px-1.5 py-0.5 rounded-md bg-amber-500 text-white font-bold shadow-md leading-none"
          >
            置顶
          </span>
          <span
            v-if="episode.is_new"
            class="text-sm px-2.5 py-1 rounded-md bg-red-500 text-white font-bold shadow-md leading-none"
          >
            新
          </span>
          <span
            v-if="episode.is_learned"
            class="text-[10px] px-1.5 py-0.5 rounded-full bg-emerald-600/90 text-white font-medium whitespace-nowrap"
          >
            已看完
          </span>
          <span
            v-else-if="auth.isLoggedIn && episode.progress_percent && episode.progress_percent > 0"
            class="text-[10px] px-1.5 py-0.5 rounded-full bg-black/55 text-white font-medium"
          >
            {{ Math.round(episode.progress_percent) }}%
          </span>
        </div>
        <button
          v-if="auth.isMember"
          type="button"
          class="absolute top-2 right-2 w-8 h-8 rounded-full bg-black/40 backdrop-blur flex items-center justify-center hover:bg-black/55 transition z-20 disabled:opacity-60"
          :disabled="favoriteLoading"
          :title="favorited ? '取消收藏' : '添加收藏'"
          @click="toggleFavorite"
        >
          <StarIcon
            :active="favorited"
            size-class="w-4.5 h-4.5"
            active-class="text-amber-300"
            inactive-class="text-white/90"
          />
        </button>
      </div>

      <div class="p-3 flex flex-col gap-1.5">
        <div class="flex items-center justify-between gap-1.5">
          <span class="text-xs font-medium text-neutral-500">第 {{ episode.index }} 期</span>
          <div class="flex items-center gap-0.5 shrink-0">
            <StarIcon v-for="n in 5" :key="n" :active="n <= episode.stars" />
          </div>
        </div>

        <div class="flex flex-wrap gap-1">
          <span
            v-for="t in episode.tags.slice(0, 2)"
            :key="t.id"
            class="text-[11px] bg-neutral-100 text-neutral-600 dark:bg-neutral-800 dark:text-neutral-400 px-1.5 py-0.5 rounded"
          >
            {{ t.name }}
          </span>
        </div>

        <h3 class="font-semibold text-sm leading-snug truncate min-w-0">{{ episode.short_title }}</h3>
        <p class="text-xs text-neutral-500 line-clamp-2 leading-relaxed">{{ episode.summary }}</p>

        <div class="flex items-center justify-between gap-2 text-[11px] text-neutral-400 pt-1.5 border-t border-black/5 dark:border-white/10">
          <span class="truncate">{{ episode.voca_size }} 词 · {{ episode.subtitle_count }} 句</span>
          <span class="shrink-0 font-semibold text-amber-700 dark:text-amber-400 tabular-nums">
            {{ learnerLabel() }}
          </span>
        </div>
      </div>
    </article>
  </RouterLink>
</template>
