<script setup lang="ts">
import { computed, nextTick, onMounted, onUnmounted, ref, toRef, watch } from 'vue'
import { useRouter } from 'vue-router'
import { getEpisodeDetail, lookupWord } from '@/api/demo'
import { getLookupHistory, getSubtitleProgress, removeVocabulary, saveVocabulary, updateSubtitleProgress, type SubtitleProgress, type WordLookupRecord } from '@/api/learning'
import { getEpisodeList, setEpisodeFavorite } from '@/api/episodes'
import EpisodeSidePanel from '@/components/episode/EpisodeSidePanel.vue'
import SubtitleModeSheet from '@/components/episode/SubtitleModeSheet.vue'
import { useIsMobile } from '@/composables/useBreakpoint'
import { useSwipeNavigation } from '@/composables/useSwipeNavigation'
import { useLearningProgress } from '@/composables/useLearningProgress'
import { consumeEpisodeAutoplay, requestEpisodeAutoplay } from '@/composables/useEpisodeAutoplay'
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
const isMobile = useIsMobile()
const showSidePanel = ref(true)
const mobileDrawerOpen = ref(false)
const subtitleModeSheetOpen = ref(false)
const dynamicFocusRef = ref<HTMLElement | null>(null)
const sidePanelTab = ref<'related' | 'lookup'>('related')
const relatedEpisodes = ref<EpisodeSummary[]>([])
const relatedLoading = ref(false)
const lookupHistory = ref<WordLookupRecord[]>([])
const lookupLoading = ref(false)
const isFavorite = ref(false)
const favoriteLoading = ref(false)
const learnedSubtitleIds = ref<Set<number>>(new Set())
const videoAutoplay = ref(false)

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

const currentModeLabel = computed(
  () => modeButtons.find((m) => m.key === subtitleMode.value)?.label ?? '字幕',
)

watch(
  isMobile,
  (mobile) => {
    if (mobile) {
      showSidePanel.value = false
    } else {
      showSidePanel.value = true
      mobileDrawerOpen.value = false
      subtitleModeSheetOpen.value = false
    }
  },
  { immediate: true },
)

useSwipeNavigation(listRef, {
  onSwipeLeft: () => player.nextSentence(),
  onSwipeRight: () => player.prevSentence(),
})

useSwipeNavigation(dynamicFocusRef, {
  onSwipeLeft: () => player.nextSentence(),
  onSwipeRight: () => player.prevSentence(),
})

const displaySub = computed(() => resolveDisplaySub(sortedSubs.value, player.currentTime.value))

const showCurrentSubtitleBar = computed(
  () => Boolean(displaySub.value) && !isMobile.value,
)

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
  nextTick(() => scrollCurrentIntoView(isMobile.value ? 'auto' : 'smooth'))
})

function preloadPoster(url: string) {
  if (!url || document.querySelector(`link[rel="preload"][href="${url}"]`)) return
  const link = document.createElement('link')
  link.rel = 'preload'
  link.as = 'image'
  link.href = url
  document.head.appendChild(link)
}

function openMobileDrawer(tab: 'related' | 'lookup') {
  sidePanelTab.value = tab
  mobileDrawerOpen.value = true
  if (tab === 'lookup' && auth.isLoggedIn && !lookupHistory.value.length && !lookupLoading.value) {
    void loadLookupHistory()
  }
}

function closeMobileDrawer() {
  mobileDrawerOpen.value = false
}

function episodePath(videoId: string) {
  return auth.isMember ? `/english/episode/${videoId}` : `/english/demo/${videoId}`
}

function onSelectRelatedEpisode(videoId: string) {
  if (videoId === props.videoId) return
  requestEpisodeAutoplay()
  router.push(episodePath(videoId))
}

function startPlayback() {
  const tryStart = () => {
    const v = videoRef.value
    if (!v) return false

    const sub = sortedSubs.value[0]
    if (sub) {
      player.seekTo(sub)
      v.currentTime = sub.start
      player.currentTime.value = sub.start
    }
    void v.play().catch(() => {})
    player.isPlaying.value = true
    nextTick(() => scrollCurrentIntoView())
    return true
  }

  if (!tryStart()) {
    window.setTimeout(() => tryStart(), 150)
  }
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
  const shouldAutoplay = consumeEpisodeAutoplay()
  const isSwitch = Boolean(episode.value)

  if (isSwitch) {
    videoRef.value?.pause()
    player.isPlaying.value = false
  } else {
    loading.value = true
    sidePanelTab.value = 'related'
    relatedEpisodes.value = []
    lookupHistory.value = []
  }

  error.value = ''
  try {
    const data = props.adminPreview
      ? await (await import('@/api/admin')).adminGetEpisodePreview(props.videoId)
      : await getEpisodeDetail(props.videoId)
    episode.value = data.episode
    preloadPoster(data.episode.media?.thumbnail_url ?? '')
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
    if (!isSwitch) error.value = '加载失败'
  } finally {
    loading.value = false
    if (shouldAutoplay && episode.value) {
      videoAutoplay.value = true
      await nextTick()
      startPlayback()
      window.setTimeout(() => {
        videoAutoplay.value = false
      }, 1000)
    }
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

/** 列表模式：当前句始终贴在字幕滚动区顶部（第一张卡片位置） */
function scrollCurrentIntoView(behavior: ScrollBehavior = 'smooth') {
  const container = listRef.value
  const el = container?.querySelector(`[data-sub-index="${currentIndex.value}"]`) as HTMLElement | null
  if (!container || !el) return

  const padding = 8
  const containerRect = container.getBoundingClientRect()
  const elRect = el.getBoundingClientRect()
  const top = container.scrollTop + (elRect.top - containerRect.top) - padding
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
  router.push(props.backTo ?? (auth.isMember ? '/english' : '/demo'))
}

function subtitleRowClass(index: number) {
  const isCurrent = index === currentIndex.value
  if (modeIsDynamicFocus(subtitleMode.value)) return ''

  if (isChineseOnly.value) {
    return [
      'p-3 px-4 rounded-2xl cursor-pointer transition-all duration-300 border sm:p-4 sm:px-5',
      isCurrent
        ? 'bg-neutral-900 text-white border-neutral-800 shadow-md dark:bg-neutral-100 dark:text-neutral-900 dark:border-neutral-200'
        : 'bg-white hover:bg-neutral-50 border-transparent hover:border-black/5 dark:bg-neutral-800 dark:hover:bg-neutral-700 dark:hover:border-white/10',
    ]
  }

  return [
    'p-2.5 px-3 rounded-2xl cursor-pointer transition-all duration-300 border sm:p-3 sm:px-4',
    isCurrent
      ? 'bg-black text-white border-black/10 shadow-sm scale-[1.01] dark:bg-neutral-100 dark:text-neutral-900 dark:border-neutral-200'
      : 'bg-white hover:bg-neutral-50 border-transparent dark:bg-neutral-800 dark:hover:bg-neutral-700 dark:border-transparent dark:hover:border-white/10',
  ]
}
</script>

<template>
  <!-- h-dvh + overflow-hidden：整页不滚动，仅字幕列表区域滚动 -->
  <div
    class="flex flex-col overflow-hidden bg-neutral-100 dark:bg-neutral-950"
    :class="adminPreview ? 'h-dvh' : 'h-full'"
  >
    <header class="shrink-0 flex items-center gap-3 px-4 py-3 pt-[max(0.75rem,env(safe-area-inset-top))] bg-white dark:bg-neutral-900 border-b border-black/5 dark:border-white/10 z-30">
      <button class="text-sm text-neutral-500 hover:text-black dark:text-neutral-400 dark:hover:text-white" @click="goBack">← 返回</button>
      <div v-if="episode" class="flex-1 min-w-0">
        <p class="font-semibold truncate flex items-center gap-2">
          <span>{{ episode.short_title }}</span>
          <span
            v-if="isCompleted"
            class="shrink-0 text-[10px] px-1.5 py-0.5 rounded-full bg-emerald-100 text-emerald-700 dark:bg-emerald-900/50 dark:text-emerald-300 font-medium"
          >
            已学完
          </span>
        </p>
        <p class="text-xs text-neutral-500 dark:text-neutral-400">{{ episode.author.name }} · 第 {{ episode.index }} 期</p>
      </div>
      <div class="flex items-center gap-1 shrink-0">
        <button
          v-if="auth.isMember && !adminPreview"
          type="button"
          class="inline-flex items-center justify-center w-8 h-8 rounded-lg hover:bg-neutral-100 dark:hover:bg-neutral-800 transition-colors disabled:opacity-50"
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
        <button class="hidden sm:inline text-xs text-neutral-400 hover:text-black dark:hover:text-white px-2 py-1" @click="player.showHelp.value = true">
          ? 快捷键
        </button>
      </div>
    </header>

    <div
      v-if="resumePrompt && !adminPreview"
      class="shrink-0 flex flex-wrap items-center justify-between gap-2 px-4 py-2.5 bg-amber-50 dark:bg-amber-950/40 border-b border-amber-100 dark:border-amber-900/50 text-sm"
    >
      <span class="text-amber-900 dark:text-amber-200 max-sm:text-xs">
        <span class="sm:hidden">从断点继续？</span>
        <span class="hidden sm:inline">检测到上次学习进度，是否从断点继续？</span>
      </span>
      <div class="flex items-center gap-2">
        <button type="button" class="px-3 py-1 rounded-full bg-amber-600 text-white text-xs" @click="applyResume">
          继续学习
        </button>
        <button type="button" class="px-3 py-1 rounded-full border border-amber-200 dark:border-amber-800 text-amber-800 dark:text-amber-300 text-xs" @click="dismissResume">
          从头开始
        </button>
      </div>
    </div>

    <div v-if="loading && !episode" class="flex-1 flex items-center justify-center text-neutral-500">加载中...</div>
    <div v-else-if="error && !episode" class="flex-1 flex items-center justify-center text-red-500">{{ error }}</div>

    <div v-else-if="episode" class="flex-1 min-h-0 flex flex-col lg:flex-row max-lg:landscape:flex-row overflow-hidden">
      <!-- 视频区 -->
      <aside
        ref="videoPanelRef"
        class="shrink-0 lg:w-[46%] xl:w-[44%] lg:min-h-0 flex flex-col gap-2 overflow-hidden lg:border-r border-black/5 dark:border-white/10 bg-neutral-100 dark:bg-neutral-950 p-3 sm:p-4 max-lg:sticky max-lg:top-0 max-lg:z-20 max-lg:max-h-[42dvh] max-lg:landscape:max-h-none max-lg:landscape:static max-lg:landscape:w-[42%] max-lg:landscape:shrink-0"
      >
        <VideoPlayer
          :src="playbackSrc"
          :poster="episode.media.thumbnail_url"
          :hidden="videoHidden"
          :autoplay="videoAutoplay"
          :register-video="registerVideoEl"
          :player="player"
        />
        <PlayerControls
          :player="player"
          :show-ipa="showIpa"
          :video-hidden="videoHidden"
          :video-panel-ref="videoPanelRef"
          :compact="isMobile"
          @update:show-ipa="showIpa = $event"
          @update:video-hidden="videoHidden = $event"
        />
        <CurrentSubtitleBar
          v-if="showCurrentSubtitleBar"
          :sub="displaySub"
          :current-time="playbackTime"
          :subtitle-mode="subtitleMode"
          :show-ipa="showIpa"
          :english-html="renderHtml(displaySub.english_html)"
          @seek="player.seekTo(displaySub)"
          @click="onSubtitleClick"
        />
      </aside>

      <!-- 字幕区 -->
      <section
        class="subtitle-panel flex-1 min-h-0 flex flex-col overflow-hidden bg-neutral-50 dark:bg-neutral-900 border-t lg:border-t-0 border-black/5 dark:border-white/10 max-lg:pb-[calc(3.5rem+env(safe-area-inset-bottom))] max-lg:landscape:pb-0"
      >
        <!-- 移动端：字幕模式入口 -->
        <div
          v-if="isMobile"
          class="shrink-0 flex items-center gap-2 p-3 bg-white dark:bg-neutral-900 border-b border-black/5 dark:border-white/10 z-10"
        >
          <button
            type="button"
            class="flex-1 flex items-center justify-between gap-2 px-4 py-2.5 rounded-xl bg-neutral-100 dark:bg-neutral-800 text-sm font-medium"
            @click="subtitleModeSheetOpen = true"
          >
            <span>字幕：{{ currentModeLabel }}</span>
            <span class="text-neutral-400 text-xs">切换</span>
          </button>
        </div>

        <!-- 桌面端：完整工具栏 -->
        <div
          v-else
          class="shrink-0 flex flex-wrap items-center gap-1 p-3 bg-white dark:bg-neutral-900 border-b border-black/5 dark:border-white/10 text-sm z-10"
        >
          <button
            v-for="m in modeButtons"
            :key="m.key"
            class="px-3 py-1 rounded-full whitespace-nowrap"
            :class="subtitleMode === m.key ? 'bg-black text-white dark:bg-neutral-100 dark:text-neutral-900' : 'bg-neutral-100 dark:bg-neutral-800 dark:text-neutral-300'"
            @click="subtitleMode = m.key"
          >
            {{ m.label }}
          </button>
          <div class="flex items-center gap-0.5 ml-1 pl-2 border-l border-black/10 dark:border-white/10 flex-1 min-w-0">
            <button
              v-for="a in alignButtons"
              :key="a.key"
              class="px-2.5 py-1 rounded-full whitespace-nowrap text-xs"
              :class="subtitleAlign === a.key ? 'bg-neutral-800 text-white dark:bg-neutral-200 dark:text-neutral-900' : 'bg-neutral-100 text-neutral-500 dark:bg-neutral-800 dark:text-neutral-400'"
              @click="subtitleAlign = a.key"
            >
              {{ a.label }}
            </button>
            <button
              v-if="!adminPreview && !showSidePanel"
              type="button"
              class="ml-auto text-xs px-2.5 py-1 rounded-full whitespace-nowrap border border-black/10 dark:border-white/10 text-neutral-500 dark:text-neutral-400 hover:bg-neutral-50 dark:hover:bg-neutral-800 transition-colors"
              @click="toggleSidePanel"
            >
              显示侧栏
            </button>
          </div>
        </div>

        <!-- 动态模式 -->
        <div
          v-if="modeIsDynamicFocus(subtitleMode) && currentSub"
          ref="dynamicFocusRef"
          class="subtitle-focus-light subtitle-scroll-hide flex-1 min-h-0 overflow-y-auto overscroll-contain flex flex-col justify-start pt-2 px-3 pb-4 lg:justify-center lg:p-6 xl:p-10 cursor-pointer touch-pan-y"
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
          class="subtitle-scroll-hide flex-1 min-h-0 overflow-y-auto overscroll-contain [-webkit-overflow-scrolling:touch] touch-pan-y px-3 pt-2 pb-4 space-y-2 lg:p-4"
        >
          <div
            v-for="(sub, i) in sortedSubs"
            :key="sub.id"
            :data-sub-index="i"
            class="flex flex-col cursor-pointer scroll-mt-2"
            :class="subtitleAlign === 'left' ? 'items-stretch' : 'items-center'"
            @click="player.seekTo(sub)"
          >
            <div class="w-full relative" :class="[subtitleRowClass(i), i === currentIndex && 'subtitle-row--active']">
              <button
                v-if="auth.isLoggedIn && !adminPreview"
                type="button"
                class="absolute top-2 right-2 z-10 w-10 h-10 rounded-full text-sm flex items-center justify-center border transition"
                :class="
                  learnedSubtitleIds.has(sub.id)
                    ? 'bg-emerald-500 border-emerald-500 text-white'
                    : 'bg-white/80 border-black/10 text-neutral-400 hover:border-emerald-400 dark:bg-neutral-800/80 dark:border-white/10 dark:text-neutral-500 dark:hover:border-emerald-500'
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
        v-if="!adminPreview && showSidePanel && !isMobile"
        :tab="sidePanelTab"
        :related-episodes="relatedEpisodes"
        :related-loading="relatedLoading"
        :lookup-history="lookupHistory"
        :lookup-loading="lookupLoading"
        :show-lookup-tab="auth.isLoggedIn"
        @update:tab="onSidePanelTabChange"
        @reopen-lookup="reopenLookup"
        @select-episode="onSelectRelatedEpisode"
        @close="closeSidePanel"
      />
    </div>

    <!-- 移动端底部导航 -->
    <nav
      v-if="isMobile && !adminPreview && episode"
      class="fixed bottom-0 inset-x-0 z-40 flex border-t border-black/10 dark:border-white/10 bg-white/95 dark:bg-neutral-900/95 backdrop-blur-md pb-[env(safe-area-inset-bottom)]"
    >
      <button
        type="button"
        class="flex-1 py-3 text-sm font-medium text-neutral-700 dark:text-neutral-200 active:bg-neutral-100 dark:active:bg-neutral-800"
        @click="openMobileDrawer('related')"
      >
        同标签视频
      </button>
      <button
        v-if="auth.isLoggedIn"
        type="button"
        class="flex-1 py-3 text-sm font-medium text-neutral-700 dark:text-neutral-200 border-l border-black/10 dark:border-white/10 active:bg-neutral-100 dark:active:bg-neutral-800"
        @click="openMobileDrawer('lookup')"
      >
        查词记录
      </button>
    </nav>

    <!-- 移动端侧栏抽屉 -->
    <Teleport to="body">
      <div
        v-if="isMobile && mobileDrawerOpen && !adminPreview"
        class="fixed inset-0 z-50 flex flex-col justify-end bg-black/40"
        @click.self="closeMobileDrawer"
      >
        <div
          class="relative flex flex-col h-[min(72dvh,560px)] rounded-t-2xl bg-white dark:bg-neutral-900 overflow-hidden pb-[env(safe-area-inset-bottom)]"
          @click.stop
        >
          <EpisodeSidePanel
            drawer
            :tab="sidePanelTab"
            :related-episodes="relatedEpisodes"
            :related-loading="relatedLoading"
            :lookup-history="lookupHistory"
            :lookup-loading="lookupLoading"
            :show-lookup-tab="auth.isLoggedIn"
            @update:tab="onSidePanelTabChange"
            @reopen-lookup="(r) => { closeMobileDrawer(); reopenLookup(r) }"
            @select-episode="(id) => { closeMobileDrawer(); onSelectRelatedEpisode(id) }"
            @close="closeMobileDrawer"
          />
        </div>
      </div>
    </Teleport>

    <SubtitleModeSheet
      v-if="isMobile"
      :open="subtitleModeSheetOpen"
      :subtitle-mode="subtitleMode"
      :subtitle-align="subtitleAlign"
      :mode-buttons="modeButtons"
      :align-buttons="alignButtons"
      @close="subtitleModeSheetOpen = false"
      @update:subtitle-mode="subtitleMode = $event"
      @update:subtitle-align="subtitleAlign = $event"
    />

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
