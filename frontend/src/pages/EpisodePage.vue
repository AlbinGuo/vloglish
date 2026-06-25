<script setup lang="ts">
import { computed, nextTick, onMounted, onUnmounted, ref, toRef, watch } from 'vue'
import { useRouter } from 'vue-router'
import { getEpisodeDetail, lookupWord } from '@/api/demo'
import { getLookupHistory, getSubtitleProgress, removeVocabulary, saveVocabulary, updateSubtitleProgress, type SubtitleProgress, type WordLookupRecord } from '@/api/learning'
import { getEpisodeList, setEpisodeFavorite } from '@/api/episodes'
import EpisodeSidePanel from '@/components/episode/EpisodeSidePanel.vue'
import { useLearningProgress } from '@/composables/useLearningProgress'
import { useAuthStore } from '@/stores/auth'
import type { EntryDetail, EpisodeDetail, EpisodeSummary } from '@/types'
import EntryCard from '@/components/EntryCard.vue'
import StarIcon from '@/components/icons/StarIcon.vue'
import PlayerControls from '@/components/PlayerControls.vue'
import VideoPlayer from '@/components/player/VideoPlayer.vue'
import KeyboardHelp from '@/components/KeyboardHelp.vue'
import SettingsButton from '@/components/SettingsButton.vue'
import SettingsPanel from '@/components/SettingsPanel.vue'
import CurrentSubtitleBar from '@/components/CurrentSubtitleBar.vue'
import SubtitleBlock from '@/components/SubtitleBlock.vue'
import { usePlayerControls } from '@/composables/usePlayerControls'
import {
  modeIsDynamicFocus,
  modeIsChineseOnly,
  modeShowsChinese,
  modeShowsEnglish,
  modeShowsIpa,
  modeUsesBlank,
  preprocessSubtitleHtml,
  resolveDisplaySub,
  type SubtitleAlign,
  type SubtitleDisplayMode,
} from '@/utils/subtitleHtml'

const props = defineProps<{ videoId: string; backTo?: string; adminPreview?: boolean }>()
const router = useRouter()
const auth = useAuthStore()

const episode = ref<EpisodeDetail | null>(null)
const loading = ref(true)
const error = ref('')
const subtitleMode = ref<SubtitleDisplayMode>('both')
const subtitleAlign = ref<SubtitleAlign>('left')
const showIpa = ref(true)
const selectedEntry = ref<EntryDetail | null>(null)
const showEntryPanel = ref(false)
const entryLoading = ref(false)
const entryError = ref('')
const currentIndex = ref(0)
const videoRef = ref<HTMLVideoElement | null>(null)
const videoPanelRef = ref<HTMLElement | null>(null)
const videoHidden = ref(false)
const listRef = ref<HTMLElement | null>(null)
const showSettings = ref(false)
const showSidePanel = ref(true)
const sidePanelTab = ref<'related' | 'lookup'>('related')
const relatedEpisodes = ref<EpisodeSummary[]>([])
const relatedLoading = ref(false)
const lookupHistory = ref<WordLookupRecord[]>([])
const lookupLoading = ref(false)
const isFavorite = ref(false)
const favoriteLoading = ref(false)
const learnedSubtitleIds = ref<Set<number>>(new Set())

function registerVideoEl(el: HTMLVideoElement | null) {
  videoRef.value = el
}

const sortedSubs = computed(() =>
  [...(episode.value?.subtitles ?? [])].sort((a, b) => a.index - b.index),
)

const currentSub = computed(() => sortedSubs.value[currentIndex.value] ?? null)

const learningBridge = {
  markComplete: () => {},
  tickWatchTime: (_delta: number) => {},
}

const player = usePlayerControls({
  videoRef,
  sortedSubs,
  currentIndex,
  onPlaybackComplete: () => {
    if (!props.adminPreview && auth.isLoggedIn) learningBridge.markComplete()
  },
  onWatchTick: (delta) => {
    if (!props.adminPreview && auth.isLoggedIn) learningBridge.tickWatchTime(delta)
  },
})

const learning = useLearningProgress({
  videoId: toRef(props, 'videoId'),
  currentIndex,
  currentTime: player.currentTime,
  sortedSubs,
  subtitleMode,
  loopMode: player.loopMode,
  playbackRate: player.playbackRate,
})

const {
  resumePrompt,
  isCompleted,
  init: initLearning,
  clearResumePrompt,
  noteLookup,
  markComplete: markLearningComplete,
  tickWatchTime: tickLearningWatchTime,
} = learning

learningBridge.markComplete = () => {
  void markLearningComplete()
}
learningBridge.tickWatchTime = (delta) => {
  tickLearningWatchTime(delta)
}

const playbackSrc = computed(() => {
  const media = episode.value?.media
  if (!media) return ''
  if (videoHidden.value && media.audio_url) return media.audio_url
  return media.video_url
})

const isChineseOnly = computed(() => modeIsChineseOnly(subtitleMode.value))

const alignButtons: { key: SubtitleAlign; label: string }[] = [
  { key: 'left', label: '左对齐' },
  { key: 'center', label: '居中' },
]

const modeButtons: { key: SubtitleDisplayMode; label: string }[] = [
  { key: 'both', label: '双语' },
  { key: 'en', label: '英语' },
  { key: 'zh', label: '中文' },
  { key: 'blank', label: '挖空' },
  { key: 'dynamic', label: '动态' },
  { key: 'ipa', label: 'IPA' },
]

const displaySub = computed(() => resolveDisplaySub(sortedSubs.value, player.currentTime.value))

const playbackTime = computed(() => player.currentTime.value)

watch(showEntryPanel, (open) => {
  document.body.style.overflow = open ? 'hidden' : ''
})

watch(showSettings, (open) => {
  if (open && !showEntryPanel.value) document.body.style.overflow = 'hidden'
  else if (!showEntryPanel.value) document.body.style.overflow = ''
})

function onEntryKeydown(e: KeyboardEvent) {
  if (e.key === 'Escape') {
    if (showEntryPanel.value) closeEntryPanel()
    else if (showSettings.value) showSettings.value = false
  }
}

onMounted(() => {
  load()
  window.addEventListener('keydown', onEntryKeydown)
})

onUnmounted(() => {
  document.body.style.overflow = ''
  window.removeEventListener('keydown', onEntryKeydown)
})
watch(() => props.videoId, load)
watch(currentIndex, () => {
  if (modeIsDynamicFocus(subtitleMode.value)) return
  nextTick(scrollCurrentIntoView)
})

function episodePath(videoId: string) {
  return auth.isMember ? `/english/episode/${videoId}` : `/english/demo/${videoId}`
}

async function loadRelatedEpisodes() {
  const tags = episode.value?.tags ?? []
  if (!tags.length) {
    relatedEpisodes.value = []
    return
  }
  relatedLoading.value = true
  try {
    const seen = new Set<string>()
    const merged: EpisodeSummary[] = []
    for (const tag of tags) {
      const data = await getEpisodeList({ tag: tag.id, page_size: 20 })
      for (const ep of data.results) {
        if (ep.video_id === props.videoId || seen.has(ep.video_id)) continue
        seen.add(ep.video_id)
        merged.push(ep)
      }
    }
    relatedEpisodes.value = merged.slice(0, 24)
  } catch {
    relatedEpisodes.value = []
  } finally {
    relatedLoading.value = false
  }
}

async function loadLookupHistory() {
  if (!auth.isLoggedIn) {
    lookupHistory.value = []
    return
  }
  lookupLoading.value = true
  try {
    const data = await getLookupHistory(props.videoId)
    lookupHistory.value = data.results
  } catch {
    lookupHistory.value = []
  } finally {
    lookupLoading.value = false
  }
}

async function load() {
  loading.value = true
  error.value = ''
  sidePanelTab.value = 'related'
  relatedEpisodes.value = []
  lookupHistory.value = []
  try {
    const data = props.adminPreview
      ? await (await import('@/api/admin')).adminGetEpisodePreview(props.videoId)
      : await getEpisodeDetail(props.videoId)
    episode.value = data.episode
    currentIndex.value = 0
    if (!props.adminPreview) {
      void loadRelatedEpisodes()
    }
    if (!props.adminPreview && auth.isLoggedIn) {
      await initLearning()
      void loadLookupHistory()
      try {
        const rows = await getSubtitleProgress(props.videoId)
        learnedSubtitleIds.value = new Set(
          rows.filter((r: SubtitleProgress) => r.is_marked_learned).map((r) => r.subtitle_id),
        )
      } catch {
        learnedSubtitleIds.value = new Set()
      }
    }
    nextTick(scrollCurrentIntoView)
  } catch {
    error.value = '加载失败'
  } finally {
    loading.value = false
  }
}

async function applyResume() {
  const prompt = resumePrompt.value
  if (!prompt) return
  clearResumePrompt()

  const idx = Math.min(Math.max(0, prompt.index), sortedSubs.value.length - 1)
  const sub = sortedSubs.value[idx]
  if (!sub) return

  const seekToResume = () => {
    const v = videoRef.value
    if (!v) return false

    player.seekTo(sub)
    const position = Math.max(
      sub.start,
      Math.min(prompt.position, sub.end > sub.start ? sub.end - 0.05 : prompt.position),
    )
    if (position > sub.start) {
      v.currentTime = position
      player.currentTime.value = position
    }
    void v.play().catch(() => {})
    player.isPlaying.value = true
    nextTick(() => scrollCurrentIntoView())
    return true
  }

  await nextTick()
  if (!seekToResume()) {
    window.setTimeout(() => seekToResume(), 150)
  }
}

function dismissResume() {
  clearResumePrompt()
}

async function toggleFavorite() {
  if (!auth.isMember || favoriteLoading.value) return
  favoriteLoading.value = true
  const next = !isFavorite.value
  isFavorite.value = next
  try {
    const res = await setEpisodeFavorite(props.videoId, next)
    isFavorite.value = res.is_favorite
  } catch {
    isFavorite.value = !next
  } finally {
    favoriteLoading.value = false
  }
}

function toggleSidePanel() {
  showSidePanel.value = !showSidePanel.value
}

function closeSidePanel() {
  showSidePanel.value = false
}

function onSidePanelTabChange(tab: 'related' | 'lookup') {
  sidePanelTab.value = tab
  if (tab === 'lookup' && auth.isLoggedIn && !lookupHistory.value.length && !lookupLoading.value) {
    void loadLookupHistory()
  }
}

async function toggleVocabulary(entry: EntryDetail) {
  if (!auth.isLoggedIn || !entry) return
  const sub = currentSub.value
  try {
    if (entry.favorite) {
      await removeVocabulary(entry.id)
      entry.favorite = false
    } else {
      await saveVocabulary({
        entry_id: entry.id,
        word: entry.headword,
        token_type: entry.category === 'phrase' ? 2 : 1,
        video_id: props.videoId,
        subtitle_id: sub?.id,
      })
      entry.favorite = true
      noteLookup()
    }
  } catch {
    // ignore
  }
}

async function reopenLookup(record: WordLookupRecord) {
  showEntryPanel.value = true
  entryLoading.value = true
  entryError.value = ''
  selectedEntry.value = null
  try {
    selectedEntry.value = await lookupWord(record.word, record.token_type as 1 | 2, record.context, {
      video_id: props.videoId,
      subtitle_id: undefined,
    })
  } catch {
    entryError.value = '词条加载失败'
  } finally {
    entryLoading.value = false
  }
}

function renderHtml(html: string) {
  return preprocessSubtitleHtml(html, { blank: modeUsesBlank(subtitleMode.value) })
}

function scrollCurrentIntoView(behavior: ScrollBehavior = 'smooth') {
  const container = listRef.value
  const el = container?.querySelector(`[data-sub-index="${currentIndex.value}"]`) as HTMLElement | null
  if (!container || !el) return
  const top =
    el.offsetTop - container.clientHeight / 2 + el.clientHeight / 2
  container.scrollTo({ top: Math.max(0, top), behavior })
}

function resolveSentenceContext(target: HTMLElement): string {
  const row = target.closest('[data-sub-index]')
  if (row) {
    const idx = parseInt(row.getAttribute('data-sub-index') ?? '', 10)
    const sub = sortedSubs.value[idx]
    if (sub) return sub.english
  }
  return displaySub.value?.english ?? currentSub.value?.english ?? ''
}

async function onSubtitleClick(e: MouseEvent) {
  const target = (e.target as HTMLElement).closest('span')
  if (!target) return
  const tid = target.getAttribute('tid')
  const pid = target.getAttribute('pid')
  if (!tid && !pid) return

  const word = target.textContent?.trim() ?? ''
  if (!word) return

  showEntryPanel.value = true
  entryLoading.value = true
  entryError.value = ''
  selectedEntry.value = null

  const type = pid ? 2 : 1
  const context = resolveSentenceContext(target)
  const sub = currentSub.value
  try {
    selectedEntry.value = await lookupWord(word, type as 1 | 2, context, {
      video_id: props.videoId,
      subtitle_id: sub?.id,
    })
    if (auth.isLoggedIn) noteLookup()
    if (sidePanelTab.value === 'lookup') void loadLookupHistory()
    target.classList.add('highlight', 'token-clicked')
  } catch {
    entryError.value = '词条加载失败，请确认后端已启动且 DeepSeek API 配置正确'
  } finally {
    entryLoading.value = false
  }
}

function closeEntryPanel() {
  showEntryPanel.value = false
  selectedEntry.value = null
  entryError.value = ''
}

async function toggleSubtitleLearned(sub: { id: number }, e: Event) {
  e.stopPropagation()
  if (!auth.isLoggedIn || props.adminPreview) return
  const next = !learnedSubtitleIds.value.has(sub.id)
  try {
    await updateSubtitleProgress(sub.id, next)
    const copy = new Set(learnedSubtitleIds.value)
    if (next) copy.add(sub.id)
    else copy.delete(sub.id)
    learnedSubtitleIds.value = copy
  } catch {
    // ignore
  }
}

function goBack() {
  router.push(props.backTo ?? '/demo')
}

function subtitleRowClass(index: number) {
  const isCurrent = index === currentIndex.value
  if (modeIsDynamicFocus(subtitleMode.value)) return ''

  if (isChineseOnly.value) {
    return [
      'p-4 px-5 rounded-2xl cursor-pointer transition-all duration-300 border',
      isCurrent
        ? 'bg-neutral-900 text-white border-neutral-800 shadow-md'
        : 'bg-white hover:bg-neutral-50 border-transparent hover:border-black/5',
    ]
  }

  return [
    'p-3 px-4 rounded-2xl cursor-pointer transition-all duration-300 border',
    isCurrent
      ? 'bg-black text-white border-black/10 shadow-sm scale-[1.01]'
      : 'bg-white hover:bg-neutral-50 border-transparent opacity-75 hover:opacity-100',
  ]
}
</script>

<template>
  <!-- h-dvh + overflow-hidden：整页不滚动，仅字幕列表区域滚动 -->
  <div
    class="flex flex-col overflow-hidden bg-neutral-100"
    :class="adminPreview ? 'h-dvh' : 'h-full'"
  >
    <header class="shrink-0 flex items-center gap-4 px-4 py-3 bg-white border-b border-black/5 z-30">
      <button class="text-sm text-neutral-500 hover:text-black" @click="goBack">← 返回</button>
      <div v-if="episode" class="flex-1 min-w-0">
        <p class="font-semibold truncate flex items-center gap-2">
          <span>{{ episode.short_title }}</span>
          <span
            v-if="isCompleted"
            class="shrink-0 text-[10px] px-1.5 py-0.5 rounded-full bg-emerald-100 text-emerald-700 font-medium"
          >
            已学完
          </span>
        </p>
        <p class="text-xs text-neutral-500">{{ episode.author.name }} · 第 {{ episode.index }} 期</p>
      </div>
      <div class="flex items-center gap-1 shrink-0">
        <button
          v-if="auth.isMember && !adminPreview"
          type="button"
          class="inline-flex items-center justify-center w-8 h-8 rounded-lg hover:bg-neutral-100 transition-colors disabled:opacity-50"
          :disabled="favoriteLoading"
          :aria-label="isFavorite ? '取消收藏' : '添加收藏'"
          :title="isFavorite ? '取消收藏' : '添加收藏'"
          @click="toggleFavorite"
        >
          <StarIcon
            :active="isFavorite"
            size-class="w-5 h-5"
            active-class="text-amber-400"
            inactive-class="text-neutral-400"
          />
        </button>
        <SettingsButton @click="showSettings = true" />
        <button class="text-xs text-neutral-400 hover:text-black px-2 py-1" @click="player.showHelp.value = true">
          ? 快捷键
        </button>
      </div>
    </header>

    <div
      v-if="resumePrompt && !adminPreview"
      class="shrink-0 flex flex-wrap items-center justify-between gap-2 px-4 py-2.5 bg-amber-50 border-b border-amber-100 text-sm"
    >
      <span class="text-amber-900">检测到上次学习进度，是否从断点继续？</span>
      <div class="flex items-center gap-2">
        <button type="button" class="px-3 py-1 rounded-full bg-amber-600 text-white text-xs" @click="applyResume">
          继续学习
        </button>
        <button type="button" class="px-3 py-1 rounded-full border border-amber-200 text-amber-800 text-xs" @click="dismissResume">
          从头开始
        </button>
      </div>
    </div>

    <div v-if="loading" class="flex-1 flex items-center justify-center text-neutral-500">加载中...</div>
    <div v-else-if="error" class="flex-1 flex items-center justify-center text-red-500">{{ error }}</div>

    <div v-else-if="episode" class="flex-1 min-h-0 flex flex-col lg:flex-row overflow-hidden">
      <!-- 视频区：始终可见，不参与字幕滚动 -->
      <aside
        ref="videoPanelRef"
        class="shrink-0 lg:w-[46%] xl:w-[44%] lg:min-h-0 flex flex-col gap-2 overflow-hidden lg:border-r border-black/5 bg-neutral-100 p-3 sm:p-4"
      >
        <VideoPlayer
          :src="playbackSrc"
          :poster="episode.media.thumbnail_url"
          :hidden="videoHidden"
          :register-video="registerVideoEl"
          :player="player"
        />
        <PlayerControls
          :player="player"
          :show-ipa="showIpa"
          :video-hidden="videoHidden"
          :video-panel-ref="videoPanelRef"
          @update:show-ipa="showIpa = $event"
          @update:video-hidden="videoHidden = $event"
        />
        <CurrentSubtitleBar
          v-if="displaySub"
          :sub="displaySub"
          :current-time="playbackTime"
          :subtitle-mode="subtitleMode"
          :show-ipa="showIpa"
          :english-html="renderHtml(displaySub.english_html)"
          @seek="player.seekTo(displaySub)"
          @click="onSubtitleClick"
        />
      </aside>

      <!-- 字幕区：独立滚动 -->
      <section class="subtitle-panel flex-1 min-h-0 flex flex-col overflow-hidden bg-neutral-50 border-t lg:border-t-0 border-black/5">
        <div class="shrink-0 flex flex-wrap items-center gap-1 p-3 bg-white border-b border-black/5 text-sm z-10">
          <button
            v-for="m in modeButtons"
            :key="m.key"
            class="px-3 py-1 rounded-full whitespace-nowrap"
            :class="subtitleMode === m.key ? 'bg-black text-white' : 'bg-neutral-100'"
            @click="subtitleMode = m.key"
          >
            {{ m.label }}
          </button>
          <div class="flex items-center gap-0.5 ml-1 pl-2 border-l border-black/10 flex-1 min-w-0">
            <button
              v-for="a in alignButtons"
              :key="a.key"
              class="px-2.5 py-1 rounded-full whitespace-nowrap text-xs"
              :class="subtitleAlign === a.key ? 'bg-neutral-800 text-white' : 'bg-neutral-100 text-neutral-500'"
              @click="subtitleAlign = a.key"
            >
              {{ a.label }}
            </button>
            <button
              v-if="!adminPreview && !showSidePanel"
              type="button"
              class="ml-auto text-xs px-2.5 py-1 rounded-full whitespace-nowrap border border-black/10 text-neutral-500 hover:bg-neutral-50 transition-colors"
              @click="toggleSidePanel"
            >
              显示侧栏
            </button>
          </div>
        </div>

        <!-- 动态模式 -->
        <div
          v-if="modeIsDynamicFocus(subtitleMode) && currentSub"
          class="subtitle-focus-light subtitle-scroll-hide flex-1 min-h-0 overflow-y-auto overscroll-contain flex flex-col justify-center p-6 sm:p-10"
          :class="subtitleAlign === 'left' ? 'items-start text-left' : 'items-center text-center'"
          @click="currentSub && player.seekTo(currentSub)"
        >
          <SubtitleBlock
            :english-html="renderHtml(currentSub.english_html)"
            :chinese="currentSub.chinese"
            :ipa="currentSub.ipa"
            :active="false"
            :large="true"
            :align="subtitleAlign"
            :chinese-focus="isChineseOnly"
            :show-english="modeShowsEnglish(subtitleMode)"
            :show-chinese="modeShowsChinese(subtitleMode)"
            :show-ipa="modeShowsIpa(subtitleMode, showIpa)"
            @click="onSubtitleClick"
          />
        </div>

        <!-- 列表模式 -->
        <div
          v-else
          ref="listRef"
          class="subtitle-scroll-hide flex-1 min-h-0 overflow-y-auto overscroll-contain [-webkit-overflow-scrolling:touch] p-4 space-y-2"
        >
          <div
            v-for="(sub, i) in sortedSubs"
            :key="sub.id"
            :data-sub-index="i"
            class="flex flex-col"
            :class="subtitleAlign === 'left' ? 'items-stretch' : 'items-center'"
            @click="player.seekTo(sub)"
          >
            <div class="w-full relative" :class="subtitleRowClass(i)">
              <button
                v-if="auth.isLoggedIn && !adminPreview"
                type="button"
                class="absolute top-2 right-2 z-10 w-6 h-6 rounded-full text-xs flex items-center justify-center border transition"
                :class="
                  learnedSubtitleIds.has(sub.id)
                    ? 'bg-emerald-500 border-emerald-500 text-white'
                    : 'bg-white/80 border-black/10 text-neutral-400 hover:border-emerald-400'
                "
                :title="learnedSubtitleIds.has(sub.id) ? '取消已掌握' : '标记已掌握'"
                @click="toggleSubtitleLearned(sub, $event)"
              >
                ✓
              </button>
              <SubtitleBlock
                :english-html="renderHtml(sub.english_html)"
                :chinese="sub.chinese"
                :ipa="sub.ipa"
                :active="i === currentIndex"
                :align="subtitleAlign"
                :chinese-focus="isChineseOnly"
                :show-english="modeShowsEnglish(subtitleMode)"
                :show-chinese="modeShowsChinese(subtitleMode)"
                :show-ipa="modeShowsIpa(subtitleMode, showIpa)"
                @click.stop="onSubtitleClick"
              />
            </div>
          </div>
        </div>
      </section>

      <EpisodeSidePanel
        v-if="!adminPreview && showSidePanel"
        :tab="sidePanelTab"
        :related-episodes="relatedEpisodes"
        :related-loading="relatedLoading"
        :lookup-history="lookupHistory"
        :lookup-loading="lookupLoading"
        :show-lookup-tab="auth.isLoggedIn"
        :episode-path="episodePath"
        @update:tab="onSidePanelTabChange"
        @reopen-lookup="reopenLookup"
        @close="closeSidePanel"
      />
    </div>

    <EntryCard
      v-if="showEntryPanel"
      :entry="selectedEntry"
      :loading="entryLoading"
      :error="entryError"
      :can-save-vocabulary="auth.isLoggedIn && !adminPreview"
      @close="closeEntryPanel"
      @toggle-vocabulary="toggleVocabulary"
    />
    <KeyboardHelp v-if="player.showHelp.value" @close="player.showHelp.value = false" />
    <SettingsPanel v-if="showSettings" @close="showSettings = false" />
  </div>
</template>

<style scoped>
.subtitle-scroll-hide {
  scrollbar-width: none;
  -ms-overflow-style: none;
}

.subtitle-scroll-hide::-webkit-scrollbar {
  display: none;
}
</style>
