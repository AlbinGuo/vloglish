<script setup lang="ts">
import { computed, watch } from 'vue'
import { RouterLink } from 'vue-router'
import type { PracticeRecord } from '@/api/practiceRecords'
import { useAudioDuration } from '@/composables/useAudioDuration'
import AppIcon from '@/components/AppIcon.vue'

const props = defineProps<{
  item: PracticeRecord
  playing?: boolean
  deleting?: boolean
  sourcePath?: string
  /** 父组件已探测到的时长（秒），可避免重复探测 */
  durationSec?: number | null
}>()

const emit = defineEmits<{
  open: []
  play: []
  remove: []
}>()

const MODE_LABEL: Record<string, string> = {
  word: '单词',
  sentence: '句子',
  passage: '篇章',
  shadow: '影子',
}

const modeLabel = computed(() => MODE_LABEL[props.item.mode] || props.item.mode)

const scoreTone = computed(() => {
  const s = props.item.score
  if (s >= 80) return 'good'
  if (s >= 60) return 'mid'
  return 'low'
})

const displayTitle = computed(() => (props.item.title || '').trim())

const placeholderClass = computed(() => {
  if (props.item.source_type === 'article') {
    return 'bg-gradient-to-br from-sky-100 to-emerald-50 dark:from-sky-950/50 dark:to-emerald-950/30'
  }
  if (props.item.source_type === 'vocab' || props.item.mode === 'word') {
    return 'bg-gradient-to-br from-violet-100 to-amber-50 dark:from-violet-950/40 dark:to-amber-950/30'
  }
  return 'bg-gradient-to-br from-amber-100 to-orange-50 dark:from-amber-950/40 dark:to-orange-950/30'
})

const audioUrl = computed(() =>
  props.item.has_audio ? (props.item.audio_url || '').trim() : '',
)
const { label: durationLabel, setKnownDuration } = useAudioDuration(audioUrl)

watch(
  () => props.durationSec,
  (sec) => {
    if (sec != null) setKnownDuration(sec)
  },
  { immediate: true },
)

function formatTime(iso: string | null) {
  if (!iso) return ''
  const d = new Date(iso.endsWith('Z') ? iso : `${iso}Z`)
  if (Number.isNaN(d.getTime())) return ''
  const mm = String(d.getMonth() + 1).padStart(2, '0')
  const dd = String(d.getDate()).padStart(2, '0')
  const hh = String(d.getHours()).padStart(2, '0')
  const mi = String(d.getMinutes()).padStart(2, '0')
  return `${mm}-${dd} ${hh}:${mi}`
}
</script>

<template>
  <article
    role="button"
    tabindex="0"
    class="group flex gap-2.5 sm:gap-2.5 overflow-hidden rounded-2xl border border-line-soft bg-neutral-50/90 dark:bg-neutral-950/50 p-3 sm:p-2.5 text-left cursor-pointer transition hover:border-amber-200/80 dark:hover:border-amber-800/50 hover:bg-white dark:hover:bg-neutral-900/80 active:bg-white dark:active:bg-neutral-900/80"
    @click="emit('open')"
    @keydown.enter.prevent="emit('open')"
    @keydown.space.prevent="emit('open')"
  >
    <!-- 左侧小封面：只作来源锚点，不抢内容 -->
    <div
      class="relative shrink-0 w-16 sm:w-[4.75rem] aspect-[4/5] rounded-xl overflow-hidden bg-neutral-200/80 dark:bg-neutral-800"
    >
      <img
        v-if="item.cover_url"
        :src="item.cover_url"
        :alt="displayTitle || '练习封面'"
        class="h-full w-full object-cover"
        loading="lazy"
      />
      <div v-else class="flex h-full w-full items-center justify-center" :class="placeholderClass">
        <span class="text-[10px] font-medium text-neutral-500 dark:text-neutral-400">
          {{ item.source_type === 'article' ? '读报' : item.mode === 'word' ? '词' : '跟读' }}
        </span>
      </div>
      <span
        class="absolute left-1 top-1 rounded px-1 py-px text-[9px] font-medium leading-none text-white/95"
        :class="
          item.mode === 'word'
            ? 'bg-violet-500/90'
            : item.mode === 'passage'
              ? 'bg-sky-500/90'
              : 'bg-amber-500/90'
        "
      >
        {{ modeLabel }}
      </span>
    </div>

    <!-- 右侧：分数 + 文本 + 操作 -->
    <div class="min-w-0 flex-1 flex flex-col">
      <div class="flex items-start justify-between gap-2">
        <div class="min-w-0 flex-1">
          <p
            class="text-[13px] font-medium leading-snug text-neutral-900 dark:text-neutral-100 line-clamp-2"
            :title="item.ref_text"
          >
            {{ item.ref_text }}
          </p>
          <p class="mt-1 text-[11px] text-neutral-400 truncate">
            <span v-if="item.level">{{ item.level }}</span>
            <span v-if="item.level && displayTitle" class="mx-1 opacity-40">·</span>
            <span v-if="displayTitle">{{ displayTitle }}</span>
            <span v-if="(item.level || displayTitle) && formatTime(item.created_at)" class="mx-1 opacity-40">·</span>
            <span v-if="formatTime(item.created_at)" class="tabular-nums">{{ formatTime(item.created_at) }}</span>
          </p>
        </div>

        <div
          class="shrink-0 flex flex-col items-center justify-center min-w-[2.75rem] rounded-xl px-1.5 py-1"
          :class="{
            'bg-emerald-100 text-emerald-800 dark:bg-emerald-900/45 dark:text-emerald-200': scoreTone === 'good',
            'bg-amber-100 text-warning dark:bg-amber-900/45': scoreTone === 'mid',
            'bg-rose-100 text-rose-800 dark:bg-rose-900/45 dark:text-rose-200': scoreTone === 'low',
          }"
        >
          <span class="text-lg font-bold leading-none tabular-nums">{{ item.score }}</span>
          <span class="text-[10px] font-medium mt-0.5 opacity-80">分</span>
        </div>
      </div>

      <div class="mt-auto flex items-center justify-between gap-2 pt-2" @click.stop>
        <!-- 回听：主行动；手机加大触控热区 -->
        <button
          v-if="item.has_audio"
          type="button"
          class="relative inline-flex items-center gap-1.5 h-9 sm:h-8 pl-1.5 pr-3 sm:pr-2.5 rounded-full text-[13px] sm:text-[12px] font-semibold transition active:scale-[0.97] touch-manipulation"
          :class="
            playing
              ? 'bg-emerald-600 text-white shadow-[0_6px_16px_rgba(16,185,129,0.35)]'
              : 'bg-emerald-500 text-white shadow-[0_6px_14px_rgba(16,185,129,0.28)] hover:bg-emerald-400 hover:shadow-[0_8px_18px_rgba(16,185,129,0.38)]'
          "
          :aria-label="
            playing
              ? `停止回听${durationLabel ? `，时长 ${durationLabel}` : ''}`
              : `听一听自己的发音${durationLabel ? `，时长 ${durationLabel}` : ''}`
          "
          :title="playing ? '停止' : durationLabel ? `听一听 · ${durationLabel}` : '听一听'"
          @click="emit('play')"
        >
          <span
            v-if="playing"
            class="absolute inset-0 rounded-full bg-emerald-400/40 animate-ping"
            aria-hidden="true"
          />
          <span
            class="relative flex h-7 w-7 sm:h-6 sm:w-6 items-center justify-center rounded-full bg-white/20"
            aria-hidden="true"
          >
            <AppIcon name="pause" v-if="playing" :size="12" />
            <AppIcon name="play" class="ml-0.5" :size="13" />
          </span>
          <span class="relative inline-flex items-baseline gap-1">
            <span>{{ playing ? '播放中' : '听一听' }}</span>
            <span
              v-if="durationLabel"
              class="tabular-nums font-medium opacity-90"
            >{{ durationLabel }}</span>
          </span>
        </button>
        <span v-else class="text-[11px] text-neutral-400">暂无录音</span>

        <div class="flex items-center gap-0.5 shrink-0">
          <RouterLink
            v-if="sourcePath"
            :to="sourcePath"
            class="inline-flex h-9 w-9 sm:h-7 sm:w-7 items-center justify-center rounded-lg text-neutral-400 hover:text-amber-700 hover:bg-amber-50 dark:hover:text-amber-300 dark:hover:bg-amber-950/40 transition touch-manipulation"
            aria-label="回看来源"
            title="回看"
          >
            <AppIcon name="external-link" :size="15" />
          </RouterLink>

          <button
            type="button"
            class="inline-flex h-9 w-9 sm:h-7 sm:w-7 items-center justify-center rounded-lg text-neutral-400 hover:text-rose-600 hover:bg-rose-50 dark:hover:text-rose-400 dark:hover:bg-rose-950/40 transition disabled:opacity-40 touch-manipulation"
            :disabled="deleting"
            aria-label="删除记录"
            title="删除"
            @click="emit('remove')"
          >
            <AppIcon name="spinner" v-if="deleting" class="animate-spin" :size="14" />
            <AppIcon name="trash" :size="14" />
          </button>
        </div>
      </div>
    </div>
  </article>
</template>
