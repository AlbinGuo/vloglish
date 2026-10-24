<script setup lang="ts">
import { computed, inject, ref, watch } from 'vue'
import { RouterLink } from 'vue-router'
import type { EntryDetail } from '@/types'
import { READING_TTS_KEY } from '@/composables/useReadingTts'
import { posLabel } from '@/utils/posLabel'
import { examTagClass, formatExamTags } from '@/utils/examTags'
import { playWordPronunciation } from '@/utils/speakWord'
import AppIcon from '@/components/AppIcon.vue'

const props = defineProps<{
  entry: EntryDetail | null
  loading?: boolean
  error?: string
  canSaveVocabulary?: boolean
  /** 收藏操作短时提示文案 */
  vocabNotice?: string
  /** ok=成功，err=失败 */
  vocabNoticeType?: 'ok' | 'err' | ''
}>()

const emit = defineEmits<{ close: []; toggleVocabulary: [entry: EntryDetail] }>()

const readingTts = inject(READING_TTS_KEY, null)
const starPulse = ref(false)

const primaryPron = computed(() => {
  const list = props.entry?.pronunciations ?? []
  return list.find((p) => p.is_primary) ?? list[0] ?? null
})

const examTags = computed(() => formatExamTags(props.entry?.exam_tags ?? []))

const showVocabViewLink = computed(
  () =>
    props.vocabNoticeType === 'ok' &&
    Boolean(props.entry?.favorite) &&
    props.vocabNotice === '已加入生词本',
)

const canSave = computed(
  () => Boolean(props.canSaveVocabulary && props.entry?.id),
)

const vocabActionLabel = computed(() =>
  props.entry?.favorite ? '已在生词本' : '加入生词本',
)

watch(
  () => [props.vocabNotice, props.vocabNoticeType] as const,
  ([notice, type]) => {
    if (notice && type === 'ok') {
      starPulse.value = false
      requestAnimationFrame(() => {
        starPulse.value = true
        window.setTimeout(() => {
          starPulse.value = false
        }, 450)
      })
    }
  },
)

function playPronunciation() {
  if (!props.entry) return
  readingTts?.pause()
  const url = primaryPron.value?.audio_url
  playWordPronunciation(props.entry.headword, url)
}

function onToggleVocabulary() {
  if (props.entry) emit('toggleVocabulary', props.entry)
}
</script>

<template>
  <div
    class="entry-card-overlay fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-black/35 p-0 sm:p-4"
    @click.self="emit('close')"
  >
    <div
      class="relative w-full max-w-lg max-h-[88dvh] sm:max-h-[85dvh] flex flex-col rounded-t-[24px] sm:rounded-[24px] bg-[#FDF8F1] dark:bg-neutral-900 shadow-2xl overflow-hidden"
      role="dialog"
      aria-modal="true"
    >
      <div class="shrink-0 flex justify-center pt-3 pb-1 sm:hidden">
        <div class="w-10 h-1 rounded-full bg-neutral-300/80" />
      </div>

      <button
        type="button"
        class="absolute top-3 right-4 z-10 w-8 h-8 flex items-center justify-center rounded-full text-neutral-400 hover:text-neutral-700 hover:bg-black/5 dark:hover:text-neutral-200 dark:hover:bg-white/10 transition-colors"
        aria-label="关闭"
        @click="emit('close')"
      >
        <AppIcon name="close" :size="18" />
      </button>

      <!-- Loading -->
      <div v-if="loading && !entry" class="p-6 space-y-4">
        <div class="h-8 w-40 bg-neutral-200/70 dark:bg-neutral-700/70 rounded-lg animate-pulse" />
        <div class="h-5 w-32 bg-neutral-200/60 dark:bg-neutral-700/60 rounded animate-pulse" />
        <div class="bg-white dark:bg-neutral-800 rounded-2xl p-4 space-y-3">
          <div class="h-4 w-12 bg-neutral-100 dark:bg-neutral-700 rounded animate-pulse" />
          <div class="h-6 w-full bg-neutral-100 dark:bg-neutral-700 rounded animate-pulse" />
          <div class="h-4 w-4/5 bg-neutral-100 dark:bg-neutral-700 rounded animate-pulse" />
        </div>
      </div>

      <!-- Error -->
      <div v-else-if="error && !entry" class="p-8 text-center">
        <p class="text-neutral-600 dark:text-neutral-300 mb-4">{{ error }}</p>
        <button
          type="button"
          class="px-4 py-2 rounded-full bg-neutral-900 text-white text-sm dark:bg-neutral-100 dark:text-neutral-900"
          @click="emit('close')"
        >
          关闭
        </button>
      </div>

      <!-- Content -->
      <template v-else-if="entry">
        <header class="shrink-0 px-5 pt-2 pb-3 pr-12">
          <div class="flex items-start justify-between gap-3">
            <div class="flex items-center gap-2 min-w-0">
              <button
                v-if="canSave"
                type="button"
                class="shrink-0 transition-colors"
                :class="[
                  entry.favorite ? 'text-amber-400 hover:text-amber-500' : 'text-neutral-300 hover:text-amber-400',
                  starPulse ? 'entry-vocab-star-pulse' : '',
                ]"
                :aria-label="entry.favorite ? '移出生词本' : '加入生词本'"
                @click="onToggleVocabulary"
              >
                <AppIcon name="star" :size="22" :fill="entry.favorite ? 'currentColor' : 'none'" />
              </button>
              <h2 class="text-[1.75rem] leading-tight font-serif font-bold text-neutral-900 dark:text-neutral-100 truncate">
                {{ entry.headword }}
              </h2>
            </div>
            <span class="shrink-0 px-2.5 py-0.5 rounded-md bg-[#E8A87C] text-white text-xs font-medium">
              {{ entry.category }}
            </span>
          </div>

          <p
            v-if="loading"
            class="mt-2 text-xs text-neutral-400 dark:text-neutral-500"
            role="status"
          >
            {{ entry.definitions.length ? '正在完善词条…' : '正在查询释义…' }}
          </p>

          <p
            v-if="vocabNotice"
            class="mt-2 text-xs leading-none flex items-center gap-2 transition-opacity"
            :class="vocabNoticeType === 'err' ? 'text-danger' : 'text-amber-700 dark:text-amber-300'"
            role="status"
          >
            <span>{{ vocabNotice }}</span>
            <RouterLink
              v-if="showVocabViewLink"
              to="/english/vocabulary"
              class="underline underline-offset-2 hover:text-amber-900 dark:hover:text-amber-200"
              @click="emit('close')"
            >
              查看
            </RouterLink>
          </p>

          <div v-if="examTags.length" class="flex flex-wrap gap-1.5 mt-2">
            <span
              v-for="tag in examTags"
              :key="tag.key"
              class="text-[10px] leading-none px-1.5 py-0.5 rounded font-medium"
              :class="examTagClass(tag.key)"
            >
              {{ tag.label }}
            </span>
          </div>

          <div v-if="primaryPron || entry.headword" class="flex items-center gap-2 mt-3">
            <button
              type="button"
              class="inline-flex items-center gap-1.5 text-sm text-neutral-600 hover:text-neutral-900 dark:text-neutral-400 dark:hover:text-neutral-100 transition-colors"
              @click="playPronunciation"
            >
              <span v-if="primaryPron" class="font-medium">{{ primaryPron.accent_type }}</span>
              <AppIcon name="volume-up" class="text-neutral-500" :size="16" />
              <span v-if="primaryPron?.ipa" class="font-serif text-neutral-700 dark:text-neutral-300">{{ primaryPron.ipa }}</span>
              <span v-else class="text-neutral-500">朗读</span>
            </button>
          </div>

          <!-- 桌面：词头下方主按钮，更易发现 -->
          <button
            v-if="canSave"
            type="button"
            class="hidden sm:inline-flex mt-4 items-center justify-center gap-1.5 px-4 py-2 rounded-xl text-sm font-medium transition-colors"
            :class="
              entry.favorite
                ? 'bg-amber-100 text-warning dark:bg-amber-900/40'
                : 'bg-neutral-900 text-ink-inverse dark:bg-amber-500'
            "
            @click="onToggleVocabulary"
          >
            <AppIcon name="star" :size="16" :fill="entry.favorite ? 'currentColor' : 'none'" />
            {{ vocabActionLabel }}
          </button>
        </header>

        <div
          class="flex-1 min-h-0 overflow-y-auto overscroll-contain px-4 space-y-3"
          :class="canSave ? 'pb-3 sm:pb-6' : 'pb-6'"
        >
          <div
            v-if="loading && !entry.definitions.length"
            class="bg-white dark:bg-neutral-800 rounded-2xl p-4 space-y-3"
          >
            <div class="h-4 w-12 bg-neutral-100 dark:bg-neutral-700 rounded animate-pulse" />
            <div class="h-6 w-full bg-neutral-100 dark:bg-neutral-700 rounded animate-pulse" />
            <div class="h-4 w-4/5 bg-neutral-100 dark:bg-neutral-700 rounded animate-pulse" />
          </div>
          <article
            v-for="def in entry.definitions"
            :key="def.id"
            class="bg-white dark:bg-neutral-800 rounded-2xl p-4 shadow-[0_1px_3px_rgba(0,0,0,0.06)] dark:shadow-none dark:border dark:border-white/10"
          >
            <span
              v-if="def.pos"
              class="inline-block px-2 py-0.5 mb-2 rounded text-xs font-medium bg-[#F5E6D8] text-[#B45309] dark:bg-amber-900/40 dark:text-amber-300"
            >
              {{ posLabel(def.pos) }}
            </span>

            <p class="text-lg font-semibold text-neutral-900 dark:text-neutral-100 leading-snug mb-1">
              {{ def.definition_cn }}
            </p>
            <p class="text-sm text-neutral-600 dark:text-neutral-300 leading-relaxed mb-3">
              {{ def.definition_en }}
            </p>

            <div v-if="def.usage_pattern" class="mb-3">
              <p class="text-xs text-neutral-400 mb-1">用法</p>
              <p class="text-sm text-neutral-700 dark:text-neutral-300">{{ def.usage_pattern }}</p>
            </div>

            <div v-for="ex in def.examples" :key="ex.order" class="mt-3">
              <p class="text-xs text-neutral-400 mb-1">例句</p>
              <p class="text-sm text-neutral-800 dark:text-neutral-200 leading-relaxed">{{ ex.example_en }}</p>
              <p class="text-sm text-neutral-500 dark:text-neutral-400 mt-0.5 leading-relaxed">{{ ex.example_cn }}</p>
            </div>
          </article>
        </div>

        <!-- 手机：底部固定收藏，拇指区可达 -->
        <div
          v-if="canSave"
          class="sm:hidden shrink-0 border-t border-black/5 dark:border-white/10 bg-[#FDF8F1]/95 dark:bg-neutral-900/95 backdrop-blur-sm px-4 pt-3 pb-[max(0.75rem,env(safe-area-inset-bottom))]"
        >
          <button
            type="button"
            class="w-full inline-flex items-center justify-center gap-1.5 px-4 py-3 rounded-xl text-sm font-semibold transition-colors"
            :class="
              entry.favorite
                ? 'bg-amber-100 text-warning dark:bg-amber-900/40'
                : 'bg-neutral-900 text-ink-inverse dark:bg-amber-500'
            "
            @click="onToggleVocabulary"
          >
            <AppIcon name="star" :size="18" :fill="entry.favorite ? 'currentColor' : 'none'" />
            {{ vocabActionLabel }}
          </button>
        </div>
      </template>
    </div>
  </div>
</template>

<style scoped>
@keyframes entry-vocab-star-pulse {
  0% {
    transform: scale(1);
  }
  40% {
    transform: scale(1.28);
  }
  100% {
    transform: scale(1);
  }
}

.entry-vocab-star-pulse {
  animation: entry-vocab-star-pulse 0.45s ease-out;
}
</style>
