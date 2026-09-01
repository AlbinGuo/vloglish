<script setup lang="ts">
import { computed, nextTick, onMounted, onUnmounted, ref, toRef, watch } from 'vue'
import { useRoute, useRouter, RouterLink } from 'vue-router'
import { getEpisodeDetail, lookupWord } from '@/api/demo'
import { getLookupHistory, getSubtitleProgress, removeVocabulary, saveVocabulary, updateSubtitleProgress, type SubtitleProgress, type WordLookupRecord } from '@/api/learning'
import { getEpisodeList, setAuthorSubscribe, setEpisodeFavorite, warmEpisodeWordLookups } from '@/api/episodes'
import { useFavoriteToastStore } from '@/stores/favoriteToast'
import { useMyCorpusBadgeStore } from '@/stores/myCorpusBadge'
import AuthorSubscribeButton from '@/components/AuthorSubscribeButton.vue'
import EpisodeSidePanel from '@/components/episode/EpisodeSidePanel.vue'
import EpisodeWordCardList from '@/components/episode/EpisodeWordCardList.vue'
import EpisodeVocabSummaryList from '@/components/episode/EpisodeVocabSummaryList.vue'
import EpisodeVideoContextPanel from '@/components/episode/EpisodeVideoContextPanel.vue'
import BlankPrintDocument from '@/components/episode/BlankPrintDocument.vue'
import BlankPrintSheet from '@/components/episode/BlankPrintSheet.vue'
import SentenceDictationSheet from '@/components/episode/SentenceDictationSheet.vue'
import ShadowingSessionBar from '@/components/episode/ShadowingSessionBar.vue'
import ShadowTrack from '@/components/episode/ShadowTrack.vue'
import SubtitlePracticeToolbar from '@/components/episode/SubtitlePracticeToolbar.vue'
import VocabDanmakuOverlay from '@/components/episode/VocabDanmakuOverlay.vue'
import AiExplainSheet from '@/components/ai/AiExplainSheet.vue'
import AiShadowingSheet from '@/components/ai/AiShadowingSheet.vue'
import AiClozeSheet from '@/components/ai/AiClozeSheet.vue'
import {
  aiExplainSubtitleStream,
  aiGenerateCloze,
  type AiClozeResult,
  type AiExplainResult,
} from '@/api/aiCoach'
import WordCardPrintDocument from '@/components/episode/WordCardPrintDocument.vue'
import WordCardPrintSheet from '@/components/episode/WordCardPrintSheet.vue'
import SubtitleModeSheet from '@/components/episode/SubtitleModeSheet.vue'
import { useIsPad, useIsPhone, useMediaQuery } from '@/composables/useBreakpoint'
import { useEpisodeVideoSplit } from '@/composables/useEpisodeVideoSplit'
import { useMobilePlayerChrome } from '@/composables/useMobilePlayerChrome'
import { useSwipeNavigation } from '@/composables/useSwipeNavigation'
import { useSubtitleVirtualList } from '@/composables/useSubtitleVirtualList'
import { useLearningProgress } from '@/composables/useLearningProgress'
import { consumeEpisodeAutoplay, requestEpisodeAutoplay } from '@/composables/useEpisodeAutoplay'
import { useSourceFocusPulse } from '@/composables/useSourceFocusPulse'
import { useWordLongPress } from '@/composables/useWordLongPress'
import { useAuthStore } from '@/stores/auth'
import { useVocabularyStore } from '@/stores/vocabulary'
import { useVoiceCloneStore } from '@/stores/voiceClone'
import type { EntryDetail, EpisodeDetail, EpisodeSummary, Subtitle } from '@/types'
import { resolveMediaUrl } from '@/utils/mediaUrl'
import EntryCard from '@/components/EntryCard.vue'
import StarIcon from '@/components/icons/StarIcon.vue'
import PlayerControls from '@/components/PlayerControls.vue'
import VideoPlayer from '@/components/player/VideoPlayer.vue'
import GapCountdownOverlay from '@/components/player/GapCountdownOverlay.vue'
import VideoProgressBar from '@/components/player/VideoProgressBar.vue'
import KeyboardHelp from '@/components/KeyboardHelp.vue'
import SettingsButton from '@/components/SettingsButton.vue'
import SettingsPanel from '@/components/SettingsPanel.vue'
import CurrentSubtitleBar from '@/components/CurrentSubtitleBar.vue'
import SubtitleBlock from '@/components/SubtitleBlock.vue'
import SubtitleWordTooltipHost from '@/components/SubtitleWordTooltipHost.vue'
import IntensiveReadingBlock from '@/components/intensive/IntensiveReadingBlock.vue'
import IntensiveReadingStatsBar from '@/components/intensive/IntensiveReadingStatsBar.vue'
import IntensiveCoreVocabPanel from '@/components/intensive/IntensiveCoreVocabPanel.vue'
import IntensiveCoreVocabMobile from '@/components/intensive/IntensiveCoreVocabMobile.vue'
import IntensiveModeToggle from '@/components/intensive/IntensiveModeToggle.vue'
import { useIntensiveReadingMode } from '@/composables/useIntensiveReadingMode'
import { useVocabDanmaku } from '@/composables/useVocabDanmaku'
import { useCoreVocabulary, type CoreVocabSource } from '@/composables/useCoreVocabulary'
import {
  useEpisodeWordCards,
  type WordCardItem,
} from '@/composables/useEpisodeWordCards'
import { usePlayerControls } from '@/composables/usePlayerControls'
import { fetchWordLookup, getCachedWordLookup, makeLookupStub } from '@/composables/useWordLookupCache'
import { useShadowingRecorder } from '@/composables/useShadowingRecorder'
import { useClonedSubtitleSpeak } from '@/composables/useClonedSubtitleSpeak'
import {
  listShadowTracks,
  upsertShadowRecord,
  uploadPracticeAudio,
  type PracticeRecord,
} from '@/api/practiceRecords'
import VoiceCloneSheet from '@/components/voice/VoiceCloneSheet.vue'
import type { BlankPrintOptions } from '@/utils/blankPrint'
import type { WordCardPrintOptions } from '@/utils/wordCardPrint'
import { parseVocabSummary } from '@/utils/vocabSummary'
import { matchSummaryDanmakuSources } from '@/utils/vocabDanmaku'
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
  type FullscreenCaptionMode,
} from '@/utils/subtitleHtml'
import { exitAppFullscreen, getFullscreenElement, subscribeFullscreenChange } from '@/utils/fullscreen'

const props = defineProps<{ videoId: string; backTo?: string; adminPreview?: boolean }>()
const route = useRoute()
const router = useRouter()
const auth = useAuthStore()
const vocabularyStore = useVocabularyStore()
const voiceClone = useVoiceCloneStore()

const subtitleVoiceMode = computed({
  get: () => voiceClone.subtitleVoiceMode,
  set: (mode: 'original' | 'cloned') => {
    void applySubtitleVoiceMode(mode)
  },
})
const hasClonedVoice = computed(() => voiceClone.hasClonedVoice)
const voiceCloneOpen = ref(false)
const {
  speaking: clonedSpeaking,
  error: clonedSpeakError,
  speakFitted: speakClonedFitted,
  stop: stopClonedSpeak,
  prefetch: prefetchClonedSpeak,
} = useClonedSubtitleSpeak()

/** 复刻模式：视频按原速连续播，TTS 按字幕时间窗拟合 */
const clonedChainActive = ref(false)
let clonedChainToken = 0
let clonedSpokenSubId: number | null = null

async function applySubtitleVoiceMode(mode: 'original' | 'cloned', opts?: { silent?: boolean }) {
  if (mode === 'original') {
    stopClonedChain()
  }
  const result = await voiceClone.selectMode(mode)
  if (result === 'needLogin') {
    router.push({ path: '/login', query: { redirect: route.fullPath } })
    return
  }
  if (result === 'needEnroll') {
    if (voiceClone.error) {
      flashQuickVocabToast(voiceClone.error)
    }
    openVoiceClone()
    return
  }
  if (mode === 'cloned' && !opts?.silent) {
    const v = videoRef.value
    if (v && !v.paused) {
      try {
        v.pause()
      } catch {
        /* ignore */
      }
      player.isPlaying.value = false
    }
    flashQuickVocabToast('已切换为我的声音：语速/停顿按字幕时间轴对齐')
  }
}

function setSubtitleVoiceMode(mode: 'original' | 'cloned') {
  void applySubtitleVoiceMode(mode)
}

function openVoiceClone() {
  if (!auth.isLoggedIn) {
    router.push({ path: '/login', query: { redirect: route.fullPath } })
    return
  }
  voiceCloneOpen.value = true
}

function onClonedVoiceUpdated(voice: import('@/api/voiceClone').ClonedVoiceInfo | null) {
  voiceClone.setLocalVoice(voice)
  if (voice?.voice) {
    voiceClone.persistMode('cloned')
    void voiceClone.setPreferPlayback(true)
    const v = videoRef.value
    if (v && !v.paused) {
      try {
        v.pause()
      } catch {
        /* ignore */
      }
      player.isPlaying.value = false
    }
    flashQuickVocabToast('复刻成功：各端登录同一账号即可直接使用')
  }
}

function stopClonedChain() {
  clonedChainActive.value = false
  clonedChainToken += 1
  clonedSpokenSubId = null
  stopClonedSpeak()
  endClonedVideoSync()
}

/** 复刻朗读：视频静音按原速连续播，TTS 拟合每句字幕时长 */
let clonedVideoRestore: { muted: boolean; rate: number } | null = null
let clonedVideoTimeHandler: ((ev: Event) => void) | null = null

function clearClonedVideoTick() {
  const v = videoRef.value
  if (v && clonedVideoTimeHandler) {
    v.removeEventListener('timeupdate', clonedVideoTimeHandler)
    clonedVideoTimeHandler = null
  }
}

function beginClonedVideoSync() {
  const v = videoRef.value
  if (!v) return
  if (!clonedVideoRestore) {
    clonedVideoRestore = {
      muted: v.muted,
      rate: player.playbackRate.value || v.playbackRate || 1,
    }
  }
  v.muted = true
  v.playbackRate = clonedVideoRestore.rate
  player.playbackRate.value = clonedVideoRestore.rate
  if (player.loopMode.value !== 'off') {
    player.loopMode.value = 'off'
  }
}

function endClonedVideoSync() {
  clearClonedVideoTick()
  const v = videoRef.value
  if (v) {
    try {
      v.pause()
    } catch {
      /* ignore */
    }
    if (clonedVideoRestore) {
      v.muted = clonedVideoRestore.muted
      v.playbackRate = clonedVideoRestore.rate
      player.playbackRate.value = clonedVideoRestore.rate
    }
  }
  clonedVideoRestore = null
  player.isPlaying.value = false
}

function resolveSubAtTime(t: number): Subtitle | null {
  const subs = sortedSubs.value
  if (!subs.length) return null
  for (const s of subs) {
    if (t >= s.start - 0.02 && t < s.end - 0.01) return s
  }
  // 落在间隙：取即将到来的下一句
  for (const s of subs) {
    if (s.start >= t) return s
  }
  return subs[subs.length - 1] ?? null
}

function prefetchAround(sub: Subtitle) {
  const subs = sortedSubs.value
  const idx = subs.findIndex((s) => s.id === sub.id)
  if (idx < 0) return
  for (const j of [idx + 1, idx + 2]) {
    const n = subs[j]
    if (n?.english?.trim()) {
      const dur = Math.max(200, Math.round((n.end - n.start) * 1000))
      prefetchClonedSpeak(n.english, dur)
    }
  }
}

/** 按当前视频时间触发对应句的复刻音（拉伸到本句剩余时长） */
function syncClonedVoiceToTimeline() {
  if (!clonedChainActive.value) return
  const v = videoRef.value
  if (!v || v.paused) return
  const sub = resolveSubAtTime(v.currentTime)
  if (!sub?.english?.trim()) return

  const idx = sortedSubs.value.findIndex((s) => s.id === sub.id)
  if (idx >= 0 && currentIndex.value !== idx) currentIndex.value = idx

  prefetchAround(sub)
  if (clonedSpokenSubId === sub.id) return
  clonedSpokenSubId = sub.id

  const rate = Math.max(0.5, v.playbackRate || clonedVideoRestore?.rate || 1)
  const remain = Math.max(0.25, sub.end - v.currentTime)
  const wallSec = remain / rate
  void speakClonedFitted(sub.english, wallSec, `sub:${sub.id}`).then((ok) => {
    if (!ok && clonedSpeakError.value && clonedChainActive.value) {
      // 单句失败不打断整段视频
    }
  })
}

const clonedPlaybackActive = computed(() => clonedChainActive.value)

/**
 * 我的声音：视频按原速连续播放（静音原声），复刻音跟随字幕时间轴，不再句末停顿等 TTS。
 */
async function playClonedSentence() {
  if (clonedChainActive.value) {
    stopClonedChain()
    return
  }
  if (!hasClonedVoice.value) {
    openVoiceClone()
    return
  }
  const startSub = currentSub.value
  if (!startSub) return

  const token = ++clonedChainToken
  clonedChainActive.value = true
  clonedSpokenSubId = null
  beginClonedVideoSync()

  const v = videoRef.value
  if (!v) {
    stopClonedChain()
    return
  }

  player.seekTo(startSub)
  try {
    v.currentTime = startSub.start
  } catch {
    /* ignore */
  }

  clearClonedVideoTick()
  clonedVideoTimeHandler = () => {
    if (token !== clonedChainToken || !clonedChainActive.value) return
    syncClonedVoiceToTimeline()
    // 播到片尾结束
    const vid = videoRef.value
    if (vid && vid.ended) stopClonedChain()
  }
  v.addEventListener('timeupdate', clonedVideoTimeHandler)

  try {
    await v.play()
    player.isPlaying.value = true
    syncClonedVoiceToTimeline()
  } catch {
    player.isPlaying.value = false
    if (token === clonedChainToken) stopClonedChain()
  }
}

/** 复刻模式下上一句 / 下一句：只跳视频时间轴，TTS 由 timeline 接着跟 */
function clonedStepSentence(delta: 1 | -1) {
  if (!hasClonedVoice.value || subtitleVoiceMode.value !== 'cloned') {
    if (delta > 0) player.nextSentence()
    else player.prevSentence()
    return
  }
  const subs = sortedSubs.value
  if (!subs.length) return
  const nextIdx = Math.max(0, Math.min(subs.length - 1, currentIndex.value + delta))
  const sub = subs[nextIdx]
  if (!sub) return

  currentIndex.value = nextIdx
  clonedSpokenSubId = null
  stopClonedSpeak()
  player.seekTo(sub)
  const v = videoRef.value
  if (v) {
    try {
      v.currentTime = sub.start
    } catch {
      /* ignore */
    }
  }

  if (clonedChainActive.value) {
    beginClonedVideoSync()
    if (v?.paused) {
      void v.play().then(() => {
        player.isPlaying.value = true
        syncClonedVoiceToTimeline()
      })
    } else {
      syncClonedVoiceToTimeline()
    }
  } else {
    void playClonedSentence()
  }
}

watch(
  () => [auth.ready, auth.isLoggedIn] as const,
  ([ready, ok]) => {
    if (!ready) return
    if (ok) {
      if (!props.adminPreview) void voiceClone.refresh()
    } else {
      stopClonedChain()
    }
  },
)
const episodeVocabPracticeCount = computed(() => {
  const vid = props.videoId
  if (!vid || !auth.isLoggedIn) return 0
  return vocabularyStore.items.filter(
    (i) =>
      i.source_type !== 'article' &&
      i.source_video_id === vid &&
      /^[A-Za-z][A-Za-z\-']{0,63}$/.test((i.word || '').trim()) &&
      !/\s/.test((i.word || '').trim()),
  ).length
})
const {
  focusWord: sourceFocusWord,
  trigger: triggerSourceFocus,
  isFocused: isSourceFocused,
} = useSourceFocusPulse(5000)

const episode = ref<EpisodeDetail | null>(null)
const loading = ref(true)
const error = ref('')
const subtitleMode = ref<SubtitleDisplayMode>('both')
const fullscreenCaptionMode = ref<FullscreenCaptionMode>(
  (() => {
    try {
      const raw = localStorage.getItem('teco-fs-caption-mode')
      if (raw === 'en' || raw === 'both' || raw === 'blind') return raw
    } catch {
      /* ignore */
    }
    return 'both'
  })(),
)
const fullscreenCaptionBottomPct = ref(
  (() => {
    try {
      const n = Number(localStorage.getItem('teco-fs-caption-bottom') || '12')
      if (Number.isFinite(n)) return Math.min(78, Math.max(4, n))
    } catch {
      /* ignore */
    }
    return 12
  })(),
)
const captionDragging = ref(false)
const contentView = ref<'subtitles' | 'wordcards' | 'summary' | 'context'>('subtitles')
const showWordCards = computed(() => contentView.value === 'wordcards')
const vocabSummaryGroups = computed(() => {
  const ep = episode.value
  if (!ep) return []

  const fromText = (text: string) => {
    const parsed = parseVocabSummary(text)
    return parsed.filter((g) => g.items.length > 0)
  }

  const text = typeof ep.vocab_summary_text === 'string' ? ep.vocab_summary_text : ''
  if (text.trim()) {
    const parsed = fromText(text)
    if (parsed.length) return parsed
  }

  const raw = ep.vocab_summary
  if (typeof raw === 'string' && raw.trim()) return fromText(raw)
  if (Array.isArray(raw) && raw.length) {
    return raw
      .map((g) => ({
        title: (g?.title || '汇总').trim() || '汇总',
        items: (g?.items || [])
          .map((it) => {
            const row = it as {
              en?: string
              zh?: string
              note?: string
              example?: string
              level?: string
            }
            return {
              en: String(row.en || '').trim(),
              zh: String(row.zh || '').trim(),
              note: String(row.note || '').trim(),
              example: String(row.example || '').trim(),
              level: String(row.level || '').trim(),
            }
          })
          .filter((it) => it.en),
      }))
      .filter((g) => g.items.length > 0)
  }
  return []
})
const blankPrintSheetOpen = ref(false)
const blankPrintOptions = ref<BlankPrintOptions | null>(null)
const wordCardPrintSheetOpen = ref(false)
const wordCardPrintOptions = ref<WordCardPrintOptions | null>(null)
const subtitleAlign = ref<SubtitleAlign>('left')
const showIpa = ref(true)
const selectedEntry = ref<EntryDetail | null>(null)
const showEntryPanel = ref(false)
const entryLoading = ref(false)
/** 查词时所在字幕（收藏生词时用，避免误用播放进度的 currentSub） */
const entrySourceSubtitleId = ref<number | null>(null)
const entryError = ref('')
const vocabNotice = ref('')
const vocabNoticeType = ref<'ok' | 'err' | ''>('')
let vocabNoticeTimer: ReturnType<typeof setTimeout> | null = null
/** 打开词条弹窗前是否在播放；关闭后据此决定是否恢复 */
const resumeAfterEntryClose = ref(false)
const currentIndex = ref(0)
const videoRef = ref<HTMLVideoElement | null>(null)
const videoPanelRef = ref<HTMLElement | null>(null)
const isVideoPanelFullscreen = ref(false)

function onVideoPanelFullscreenChange() {
  isVideoPanelFullscreen.value = getFullscreenElement() === videoPanelRef.value
}

const subtitleTooltipTeleport = computed(() =>
  isVideoPanelFullscreen.value && videoPanelRef.value ? videoPanelRef.value : 'body',
)
const videoHidden = ref(false)
const SUBTITLES_HIDDEN_KEY = 'teco-subtitles-hidden'
/** 仅这些视频进入时默认隐藏字幕；其余视频一律显示字幕 */
const FORCE_SUBTITLES_HIDDEN_VIDEO_IDS = new Set(['S26GSrESWWCCKRw'])
const subtitlesHidden = ref(false)
const skipSubtitlesHiddenPersist = ref(false)

watch(subtitlesHidden, (hidden) => {
  if (skipSubtitlesHiddenPersist.value) return
  try {
    localStorage.setItem(SUBTITLES_HIDDEN_KEY, hidden ? '1' : '0')
  } catch {
    /* ignore */
  }
})

function syncSubtitlesHiddenForVideo(videoId: string) {
  const hide =
    !props.adminPreview && FORCE_SUBTITLES_HIDDEN_VIDEO_IDS.has(videoId)
  skipSubtitlesHiddenPersist.value = true
  subtitlesHidden.value = hide
  skipSubtitlesHiddenPersist.value = false
}
const listRef = ref<HTMLElement | null>(null)
const showSettings = ref(false)
const isPhone = useIsPhone()
const isPad = useIsPad()
const isSplitRow = useMediaQuery(
  '(min-width: 1024px), (min-width: 768px) and (max-width: 1023px) and (orientation: landscape)',
)
const episodeSplitRef = ref<HTMLElement | null>(null)
const {
  videoPercent,
  dragging: splitDragging,
  startDrag: startVideoSplitDrag,
  reset: resetVideoSplit,
  nudge: nudgeVideoSplit,
  minPercent: videoSplitMin,
  maxPercent: videoSplitMax,
} = useEpisodeVideoSplit()
const showSidePanel = ref(true)
const mobileDrawerOpen = ref(false)
const mobileMoreOpen = ref(false)
const subtitleModeSheetOpen = ref(false)
const dynamicFocusRef = ref<HTMLElement | null>(null)
const sidePanelTab = ref<'related' | 'lookup'>('related')
const relatedEpisodes = ref<EpisodeSummary[]>([])
const relatedLoading = ref(false)
const lookupHistory = ref<WordLookupRecord[]>([])
const lookupLoading = ref(false)
const isFavorite = ref(false)
const favoriteLoading = ref(false)
const favoriteToast = useFavoriteToastStore()
const corpusBadge = useMyCorpusBadgeStore()
const learnedSubtitleIds = ref<Set<number>>(new Set())
const videoAutoplay = ref(false)
const subtitleSlideDir = ref<'next' | 'prev'>('next')
let listScrollAnim = 0

function registerVideoEl(el: HTMLVideoElement | null) {
  videoRef.value = el
}

const sortedSubs = computed(() =>
  [...(episode.value?.subtitles ?? [])].sort((a, b) => a.index - b.index),
)

const { intensiveMode, intensivePageClass } = useIntensiveReadingMode()
const { vocabDanmakuEnabled } = useVocabDanmaku()

const coreVocabSources = computed<CoreVocabSource[]>(() =>
  sortedSubs.value.map((sub) => ({
    id: sub.id,
    englishHtml: sub.english_html,
    context: sub.english,
    meta: { video_id: props.videoId, subtitle_id: sub.id },
  })),
)
const coreVocab = useCoreVocabulary(coreVocabSources, { enabled: intensiveMode })
const { items: coreVocabItems, loading: coreVocabLoading, count: coreVocabCount } = coreVocab

const wordCards = useEpisodeWordCards(
  computed(() => props.videoId),
  showWordCards,
)
const { items: wordCardItems, groups: wordCardGroups, loading: wordCardsLoading } = wordCards

const currentSub = computed(() => sortedSubs.value[currentIndex.value] ?? null)

const learningBridge = {
  markComplete: () => {},
  tickWatchTime: (_delta: number) => {},
}

const continuousFinishedNotice = ref(false)
let continuousFinishedTimer: ReturnType<typeof setTimeout> | null = null

function showContinuousFinishedNotice() {
  continuousFinishedNotice.value = true
  if (continuousFinishedTimer) clearTimeout(continuousFinishedTimer)
  continuousFinishedTimer = setTimeout(() => {
    continuousFinishedNotice.value = false
    continuousFinishedTimer = null
  }, 3200)
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
  onSentenceLoopComplete: (sub) => {
    openDictationFor(sub)
  },
  onContinuousLoopComplete: ({ openDictation }) => {
    showContinuousFinishedNotice()
    if (openDictation) {
      const first = sortedSubs.value[0]
      if (first) openDictationFor(first)
    }
  },
  onReplaySentence: () => {
    if (subtitleVoiceMode.value !== 'cloned' || !hasClonedVoice.value) return false
    void playClonedSentence()
    return true
  },
  onStepSentence: (delta) => {
    if (subtitleVoiceMode.value !== 'cloned' || !hasClonedVoice.value) return false
    clonedStepSentence(delta)
    return true
  },
  onTogglePlay: () => {
    if (subtitleVoiceMode.value !== 'cloned' || !hasClonedVoice.value) return false
    // 复刻模式：空格/播放键 = 开始或停止 TTS，不再播视频原声
    void playClonedSentence()
    return true
  },
})

const dictationOpen = ref(false)
const dictationSubtitle = ref<Subtitle | null>(null)
/** 听写弹窗打开时，对该句施加毛玻璃遮罩 */
const dictationTargetId = ref<number | null>(null)
/** 练习菜单打开时抬高该行，避免被下一条字幕盖住 */
const practiceMenuOpenId = ref<number | null>(null)

function onPracticeMenuOpenChange(subId: number, open: boolean) {
  practiceMenuOpenId.value = open ? subId : practiceMenuOpenId.value === subId ? null : practiceMenuOpenId.value
}
/** 暂时隐藏「标记已掌握」入口，改为每句「听写」 */
const showSubtitleLearnedMark = false

function pauseForDictationSheet() {
  const v = videoRef.value
  if (!v || v.paused) return
  v.pause()
  player.isPlaying.value = false
}

function openDictationFor(sub: Subtitle) {
  dictationSubtitle.value = sub
  dictationTargetId.value = sub.id
  dictationOpen.value = true
}

function closeDictation() {
  dictationOpen.value = false
  dictationTargetId.value = null
}

function startSubtitleDictation(sub: Subtitle, e?: Event) {
  e?.stopPropagation()
  pauseForDictationSheet()
  // 立刻弹填空；需要播放时再点弹窗里的「播放」
  openDictationFor(sub)
}

const aiExplainOpen = ref(false)
const aiExplainLoading = ref(false)
const aiExplainError = ref('')
const aiExplainResult = ref<AiExplainResult | null>(null)
const aiExplainSub = ref<Subtitle | null>(null)
const aiExplainSessionCache = new Map<number, AiExplainResult>()
let aiExplainAbort: AbortController | null = null

const aiShadowOpen = ref(false)
const aiShadowSub = ref<Subtitle | null>(null)

const aiClozeOpen = ref(false)
const aiClozeLoading = ref(false)
const aiClozeError = ref('')
const aiClozeResult = ref<AiClozeResult | null>(null)
const aiClozeSub = ref<Subtitle | null>(null)
const aiClozeSessionCache = new Map<number, AiClozeResult>()

function emptyExplainShell(sub: Subtitle): AiExplainResult {
  return {
    video_id: props.videoId,
    subtitle_id: sub.id,
    english: sub.english || '',
    chinese: sub.chinese || '',
    plain_chinese: '',
    structure: '',
    expressions: [],
    paraphrase: '',
    tip: '',
  }
}

async function startAiExplain(sub: Subtitle, e?: Event, force = false) {
  e?.stopPropagation()
  pauseForDictationSheet()
  aiExplainSub.value = sub
  aiExplainOpen.value = true
  aiExplainError.value = ''
  if (!force) {
    const cached = aiExplainSessionCache.get(sub.id)
    if (cached) {
      aiExplainResult.value = cached
      aiExplainLoading.value = false
      return
    }
  }

  aiExplainAbort?.abort()
  const ac = new AbortController()
  aiExplainAbort = ac

  aiExplainLoading.value = true
  aiExplainResult.value = emptyExplainShell(sub)
  try {
    const result = await aiExplainSubtitleStream(props.videoId, sub.id, {
      force,
      signal: ac.signal,
      onEvent: (event) => {
        if (ac.signal.aborted) return
        if (event.type === 'meta') {
          aiExplainResult.value = {
            ...(aiExplainResult.value || emptyExplainShell(sub)),
            video_id: event.video_id,
            subtitle_id: event.subtitle_id,
            english: event.english || sub.english || '',
            chinese: event.chinese || sub.chinese || '',
            from_cache: event.from_cache,
            quota: event.quota,
          }
          return
        }
        if (event.type === 'field') {
          const cur = aiExplainResult.value || emptyExplainShell(sub)
          const key = event.key
          if (key === 'expressions' && Array.isArray(event.value)) {
            aiExplainResult.value = {
              ...cur,
              expressions: event.value as AiExplainResult['expressions'],
            }
          } else if (
            key === 'plain_chinese' ||
            key === 'structure' ||
            key === 'paraphrase' ||
            key === 'tip'
          ) {
            aiExplainResult.value = { ...cur, [key]: String(event.value || '') }
          }
        }
      },
    })
    if (ac.signal.aborted) return
    aiExplainResult.value = result
    aiExplainSessionCache.set(sub.id, result)
  } catch (err: unknown) {
    if (ac.signal.aborted || (err as { name?: string })?.name === 'AbortError') return
    const { promptIfAiQuotaExhausted } = await import('@/utils/aiQuotaGate')
    if (await promptIfAiQuotaExhausted(err)) {
      closeAiExplain()
      return
    }
    const msg =
      err instanceof Error
        ? err.message
        : (err as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    aiExplainError.value = typeof msg === 'string' && msg ? msg : '讲解失败，请稍后重试'
  } finally {
    if (aiExplainAbort === ac) {
      aiExplainLoading.value = false
      aiExplainAbort = null
    }
  }
}

function regenerateAiExplain() {
  const sub = aiExplainSub.value
  if (!sub || aiExplainLoading.value) return
  aiExplainSessionCache.delete(sub.id)
  void startAiExplain(sub, undefined, true)
}

function closeAiExplain() {
  aiExplainAbort?.abort()
  aiExplainAbort = null
  aiExplainOpen.value = false
  aiExplainLoading.value = false
}

function startAiShadowing(sub: Subtitle, e?: Event) {
  e?.stopPropagation()
  pauseForDictationSheet()
  closeShadowSession()
  aiShadowSub.value = sub
  aiShadowOpen.value = true
}

const aiShadowSentenceIndex = computed(() => {
  const sub = aiShadowSub.value
  if (!sub) return -1
  return sortedSubs.value.findIndex((s) => s.id === sub.id)
})

const aiShadowHasNext = computed(() => {
  const idx = aiShadowSentenceIndex.value
  return idx >= 0 && idx + 1 < sortedSubs.value.length
})

let shadowRateBefore: number | null = null

function onShadowPlay(rate = 1) {
  const sub = aiShadowSub.value
  if (!sub) return
  if (shadowRateBefore == null) shadowRateBefore = player.playbackRate.value
  player.setRate(rate)
  player.playSentenceOnce(sub)
}

watch(aiShadowOpen, (open) => {
  if (open) {
    shadowRateBefore = player.playbackRate.value
    return
  }
  if (shadowRateBefore != null) {
    player.setRate(shadowRateBefore)
    shadowRateBefore = null
  }
})

function nextAiShadowing() {
  const subs = sortedSubs.value
  const idx = aiShadowSentenceIndex.value
  const next = idx >= 0 ? subs[idx + 1] : null
  if (!next) {
    aiShadowOpen.value = false
    aiShadowSub.value = null
    return
  }
  pauseForDictationSheet()
  player.seekTo(next)
  aiShadowSub.value = next
}

/* —— 影子跟读（句下音轨） —— */
const shadowRecorder = useShadowingRecorder()
const {
  phase: shadowPhase,
  error: shadowRecError,
  micEnabled: shadowMicEnabled,
  ensureMic: ensureShadowMic,
  cancel: cancelShadowRecorder,
  releaseMic: releaseShadowMic,
  armAfterReferenceStart,
  stop: stopShadowRecorder,
} = shadowRecorder
const shadowActiveSubId = ref<number | null>(null)
const shadowDelaySec = ref(0.5)
const shadowRate = ref(1)
const shadowBusy = ref(false)
const shadowUploadId = ref<number | null>(null)
const shadowTracks = ref<Record<number, PracticeRecord>>({})
const shadowSessionRunning = ref(false)
let shadowSafetyTimer: ReturnType<typeof setTimeout> | null = null
let shadowRateBeforeSession: number | null = null
let shadowEndWatching = false
let shadowFinishing = false

const shadowActiveSub = computed(
  () => sortedSubs.value.find((s) => s.id === shadowActiveSubId.value) ?? null,
)

const subtitleCount = computed(() => sortedSubs.value.length)
const listRemeasureKey = computed(
  () =>
    `${shadowActiveSubId.value ?? ''}|${dictationTargetId.value ?? ''}|${practiceMenuOpenId.value ?? ''}|${intensiveMode.value}|${subtitleMode.value}|${showIpa.value}`,
)
const subtitleVirtual = useSubtitleVirtualList({
  containerRef: listRef,
  count: subtitleCount,
  estimatePx: isPhone.value ? 112 : 104,
  gapPx: 8,
  overscan: isPhone.value ? 6 : 8,
  remeasureKey: listRemeasureKey,
})
const visibleSubtitleRows = computed(() => {
  const { start, end } = subtitleVirtual.range.value
  return sortedSubs.value.slice(start, end).map((sub, i) => ({ sub, index: start + i }))
})

function clearShadowSafetyTimer() {
  if (shadowSafetyTimer) {
    clearTimeout(shadowSafetyTimer)
    shadowSafetyTimer = null
  }
}

async function loadShadowTracks() {
  if (props.adminPreview || !auth.isLoggedIn) {
    shadowTracks.value = {}
    return
  }
  try {
    const data = await listShadowTracks(props.videoId)
    const map: Record<number, PracticeRecord> = {}
    for (const row of data.results) {
      if (row.subtitle_id != null && row.audio_url) map[row.subtitle_id] = row
    }
    shadowTracks.value = map
  } catch {
    /* 静默 */
  }
}

function closeShadowSession() {
  clearShadowSafetyTimer()
  shadowEndWatching = false
  shadowSessionRunning.value = false
  shadowFinishing = false
  cancelShadowRecorder()
  releaseShadowMic()
  if (shadowRateBeforeSession != null) {
    player.setRate(shadowRateBeforeSession)
    shadowRateBeforeSession = null
  }
  shadowActiveSubId.value = null
  shadowBusy.value = false
}

function startShadowPractice(sub: Subtitle, e?: Event) {
  e?.stopPropagation()
  if (!auth.isLoggedIn) {
    void router.push({ path: '/login', query: { next: `/english/episode/${props.videoId}` } })
    return
  }
  pauseForDictationSheet()
  aiShadowOpen.value = false
  // 再点一次同一句：收起面板
  if (shadowActiveSubId.value === sub.id) {
    if (!shadowSessionRunning.value) closeShadowSession()
    return
  }
  closeShadowSession()
  shadowActiveSubId.value = sub.id
  shadowMicEnabled.value = true
  void ensureShadowMic()
  nextTick(() => {
    // 手机端视频区 sticky，把面板滚到可视区中部，避免被顶栏挡住
    document
      .querySelector(`[data-shadow-anchor="${sub.id}"]`)
      ?.scrollIntoView({ behavior: 'smooth', block: 'center' })
  })
}

function sentenceDurationSec(sub: Subtitle) {
  return Math.max(0.4, (sub.end || 0) - (sub.start || 0))
}

/** 原声播完后再留 delay + 余量，避免半拍/一拍句尾被掐 */
const SHADOW_END_GRACE_SEC = 0.4

function scheduleShadowFinishAfterReference() {
  if (!shadowSessionRunning.value && !shadowEndWatching) return
  shadowEndWatching = false
  clearShadowSafetyTimer()
  const graceSec = Math.max(0, shadowDelaySec.value) + SHADOW_END_GRACE_SEC
  shadowSafetyTimer = setTimeout(() => {
    shadowSafetyTimer = null
    void finishShadowTake()
  }, graceSec * 1000)
}

async function startShadowTake() {
  const sub = shadowActiveSub.value
  if (!sub || shadowSessionRunning.value) return
  clearShadowSafetyTimer()
  shadowBusy.value = true
  shadowSessionRunning.value = true
  shadowEndWatching = true
  try {
    if (shadowRateBeforeSession == null) shadowRateBeforeSession = player.playbackRate.value
    player.setRate(shadowRate.value)
    player.playSentenceOnce(sub)
    await armAfterReferenceStart(shadowDelaySec.value)
    // 句末检测失败时的兜底：原声时长 + 延迟 + 余量 + 缓冲
    const fallbackSec =
      sentenceDurationSec(sub) / Math.max(0.5, shadowRate.value) +
      Math.max(0, shadowDelaySec.value) +
      SHADOW_END_GRACE_SEC +
      1.5
    shadowSafetyTimer = setTimeout(() => {
      shadowSafetyTimer = null
      void finishShadowTake()
    }, fallbackSec * 1000)
  } catch {
    shadowSessionRunning.value = false
    shadowEndWatching = false
    clearShadowSafetyTimer()
  } finally {
    shadowBusy.value = false
  }
}

async function finishShadowTake() {
  if (shadowFinishing) return
  if (!shadowSessionRunning.value) return
  shadowFinishing = true
  clearShadowSafetyTimer()
  shadowEndWatching = false
  shadowSessionRunning.value = false
  const sub = shadowActiveSub.value
  if (!sub) {
    cancelShadowRecorder()
    shadowFinishing = false
    return
  }
  const subId = sub.id
  const micOn = shadowMicEnabled.value
  shadowBusy.value = true
  try {
    const blob = await stopShadowRecorder()
    pauseForDictationSheet()
    if (shadowRateBeforeSession != null) {
      player.setRate(shadowRateBeforeSession)
      shadowRateBeforeSession = null
    }
    releaseShadowMic()

    if (!blob || !micOn) {
      // 只听不录：收起会话条
      shadowActiveSubId.value = null
      return
    }

    // 先收起会话条并露出迷你音轨（上传中）
    shadowActiveSubId.value = null
    shadowUploadId.value = subId

    const row = await upsertShadowRecord({
      video_id: props.videoId,
      subtitle_id: subId,
      title: episode.value?.short_title || '',
      ref_text: sub.english || '',
    })
    const uploaded = await uploadPracticeAudio(row.id, blob)
    shadowTracks.value = {
      ...shadowTracks.value,
      [subId]: {
        ...row,
        audio_url: uploaded.audio_url,
        has_audio: true,
        audio_source: 'upload',
      },
    }
  } catch {
    /* 上传失败：重新打开会话条便于重试 */
    shadowActiveSubId.value = subId
  } finally {
    shadowUploadId.value = null
    shadowBusy.value = false
    shadowFinishing = false
  }
}

function stopShadowTake() {
  void finishShadowTake()
}

function rerecordShadow(sub: Subtitle) {
  startShadowPractice(sub)
}

function scoreShadow(sub: Subtitle) {
  closeShadowSession()
  startAiShadowing(sub)
}

function playShadowReference(sub: Subtitle) {
  if (shadowRateBeforeSession == null) shadowRateBeforeSession = player.playbackRate.value
  player.setRate(1)
  player.playSentenceOnce(sub)
}

watch(
  () => [player.isPlaying.value, player.currentTime.value] as const,
  ([playing, t]) => {
    if (!shadowEndWatching || !shadowActiveSub.value) return
    const sub = shadowActiveSub.value
    // 原声句播完 → 再等 delay+余量后停录（半拍跟读不截尾）
    if (!playing && t >= sub.end - 0.2) {
      scheduleShadowFinishAfterReference()
    }
  },
)

watch(
  () => auth.isLoggedIn,
  (ok) => {
    if (ok) void loadShadowTracks()
    else shadowTracks.value = {}
  },
)

async function startAiCloze(sub: Subtitle, e?: Event, force = false) {
  e?.stopPropagation()
  pauseForDictationSheet()
  aiClozeSub.value = sub
  aiClozeOpen.value = true
  aiClozeError.value = ''
  if (!force) {
    const cached = aiClozeSessionCache.get(sub.id)
    if (cached) {
      aiClozeResult.value = cached
      aiClozeLoading.value = false
      return
    }
  }
  aiClozeLoading.value = true
  // 先展示原句，减少空白等待感
  aiClozeResult.value = {
    video_id: props.videoId,
    subtitle_id: sub.id,
    english: sub.english || '',
    chinese: sub.chinese || '',
    blanks: [],
    hint: '',
  }
  try {
    const result = await aiGenerateCloze(props.videoId, sub.id, force)
    aiClozeResult.value = result
    aiClozeSessionCache.set(sub.id, result)
  } catch (err: unknown) {
    const msg = (err as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    aiClozeError.value = typeof msg === 'string' ? msg : '出题失败，请稍后重试'
  } finally {
    aiClozeLoading.value = false
  }
}

function regenerateAiCloze() {
  const sub = aiClozeSub.value
  if (!sub || aiClozeLoading.value) return
  aiClozeSessionCache.delete(sub.id)
  void startAiCloze(sub, undefined, true)
}

function clozeToDictation() {
  const sub = aiClozeSub.value
  aiClozeOpen.value = false
  if (sub) openDictationFor(sub)
}

function replayDictationSentence() {
  const sub = dictationSubtitle.value
  if (!sub) return
  // 按设定循环次数播放，弹窗保持打开
  player.startDictationLoop(sub)
}

function nextAfterDictation() {
  const subs = sortedSubs.value
  const idx = subs.findIndex((s) => s.id === dictationSubtitle.value?.id)
  const next = idx >= 0 ? subs[idx + 1] : null
  if (!next) {
    closeDictation()
    return
  }
  pauseForDictationSheet()
  openDictationFor(next)
}

function onDictationLoopCountChange(count: number) {
  player.setSentenceLoopCount(count > 0 ? count : 1)
}

function isDictationFrost(subId: number) {
  return dictationOpen.value && dictationTargetId.value === subId
}

const dictationFrostClass =
  'absolute inset-0 z-[5] rounded-[inherit] pointer-events-none bg-white/50 dark:bg-neutral-950/55 backdrop-blur-[7px] shadow-[inset_0_0_0_1px_rgba(255,255,255,0.28)] dark:shadow-[inset_0_0_0_1px_rgba(255,255,255,0.06)]'

/** 悬停查词时若正在播放则暂停，移开后恢复 */
let resumePlaybackAfterWordHover = false

function onSubtitleWordHoverStart() {
  if (!player.isPlaying.value) return
  resumePlaybackAfterWordHover = true
  player.togglePlay()
}

function onSubtitleWordHoverEnd() {
  if (!resumePlaybackAfterWordHover) return
  resumePlaybackAfterWordHover = false
  if (!player.isPlaying.value) player.togglePlay()
}
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
  if (videoHidden.value && media.audio_url) return resolveMediaUrl(media.audio_url)
  return resolveMediaUrl(media.video_url)
})

const isChineseOnly = computed(() => modeIsChineseOnly(subtitleMode.value))

/** 全屏当前句：中英 / 英语 / 盲听（不改侧栏字幕模式） */
function setFullscreenCaptionMode(mode: FullscreenCaptionMode) {
  fullscreenCaptionMode.value = mode
  try {
    localStorage.setItem('teco-fs-caption-mode', mode)
  } catch {
    /* ignore */
  }
  if (mode === 'both' || mode === 'en') selectSubtitleMode(mode)
}

function persistCaptionBottom() {
  try {
    localStorage.setItem(
      'teco-fs-caption-bottom',
      String(Math.round(fullscreenCaptionBottomPct.value)),
    )
  } catch {
    /* ignore */
  }
}

function updateCaptionBottomFromPointer(e: PointerEvent) {
  const playerEl = videoPanelRef.value?.querySelector('.video-panel__player') as HTMLElement | null
  if (!playerEl) return
  const rect = playerEl.getBoundingClientRect()
  if (rect.height < 8) return
  const fromBottom = rect.bottom - e.clientY
  fullscreenCaptionBottomPct.value = Math.min(78, Math.max(4, (fromBottom / rect.height) * 100))
}

function onCaptionPointerDown(e: PointerEvent) {
  if (e.button !== 0) return
  e.preventDefault()
  const el = e.currentTarget as HTMLElement
  el.setPointerCapture(e.pointerId)
  captionDragging.value = true
  updateCaptionBottomFromPointer(e)
}

function onCaptionPointerMove(e: PointerEvent) {
  if (!captionDragging.value) return
  updateCaptionBottomFromPointer(e)
}

function onCaptionPointerUp(e: PointerEvent) {
  if (!captionDragging.value) return
  captionDragging.value = false
  const el = e.currentTarget as HTMLElement
  if (el.hasPointerCapture(e.pointerId)) el.releasePointerCapture(e.pointerId)
  persistCaptionBottom()
}

const modeButtons: { key: SubtitleDisplayMode; label: string }[] = [
  { key: 'both', label: '双语' },
  { key: 'en', label: '英语' },
  { key: 'zh', label: '中文' },
  { key: 'blank', label: '挖空' },
]

const currentModeLabel = computed(() => {
  if (contentView.value === 'wordcards') return '词卡'
  if (contentView.value === 'summary') return '汇总'
  if (contentView.value === 'context') return '视频语境'
  return modeButtons.find((m) => m.key === subtitleMode.value)?.label ?? '字幕'
})

function selectSubtitleMode(mode: SubtitleDisplayMode) {
  subtitleMode.value = mode
  contentView.value = 'subtitles'
}

function openWordCardsView() {
  contentView.value = 'wordcards'
}

function openVocabSummaryView() {
  contentView.value = 'summary'
}

function openVideoContextView() {
  contentView.value = 'context'
}

function openBlankPrintSheet() {
  blankPrintSheetOpen.value = true
}

function openWordCardPrintSheet() {
  wordCardPrintSheetOpen.value = true
}

async function confirmBlankPrint(options: BlankPrintOptions) {
  blankPrintSheetOpen.value = false
  wordCardPrintOptions.value = null
  blankPrintOptions.value = options
  await nextTick()
  await nextTick()
  window.print()
}

async function confirmWordCardPrint(options: WordCardPrintOptions) {
  wordCardPrintSheetOpen.value = false
  blankPrintOptions.value = null
  wordCardPrintOptions.value = options
  await nextTick()
  await nextTick()
  window.print()
}

function onAfterPrint() {
  blankPrintOptions.value = null
  wordCardPrintOptions.value = null
}

function pausePlaybackForEntry() {
  const v = videoRef.value
  if (!v || v.paused || v.ended) return
  resumeAfterEntryClose.value = true
  v.pause()
  player.isPlaying.value = false
}

function resumePlaybackAfterEntry() {
  if (!resumeAfterEntryClose.value) return
  resumeAfterEntryClose.value = false
  const v = videoRef.value
  if (!v || v.ended) return
  void v
    .play()
    .then(() => {
      player.isPlaying.value = true
    })
    .catch(() => {
      /* 自动播放被拦截时保持暂停 */
    })
}

async function openWordCard(item: WordCardItem) {
  pausePlaybackForEntry()
  showEntryPanel.value = true
  entryLoading.value = !item.entry
  entryError.value = ''
  clearVocabNotice()
  selectedEntry.value = item.entry
  entrySourceSubtitleId.value = item.meta?.subtitle_id ?? null
  try {
    selectedEntry.value = await lookupWord(item.word, item.type, item.context, {
      video_id: props.videoId,
      subtitle_id: item.meta?.subtitle_id,
    })
  } catch {
    entryError.value = '词条加载失败'
  } finally {
    entryLoading.value = false
  }
}

watch(
  [isPhone, isPad],
  ([phone, pad]) => {
    if (phone) {
      showSidePanel.value = false
    } else if (pad) {
      showSidePanel.value = false
      mobileDrawerOpen.value = false
      subtitleModeSheetOpen.value = false
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

/** 当前句字幕中命中的「汇总」词，供弹幕同步展示 */
const danmakuSources = computed(() =>
  matchSummaryDanmakuSources(displaySub.value?.english || '', vocabSummaryGroups.value),
)

/** 当前句字幕条是否应挂载（全屏下保持挂载，仅用 v-show 显隐，避免卸载 Teleport 扰乱 Fullscreen） */
const mountCurrentSubtitleBar = computed(
  () => Boolean(displaySub.value) && (!isPhone.value || isVideoPanelFullscreen.value),
)

/** 当前句字幕条是否可见 */
const showCurrentSubtitleBar = computed(
  () => mountCurrentSubtitleBar.value && !subtitlesHidden.value,
)

const canResizeSplit = computed(
  () =>
    !isPhone.value &&
    isSplitRow.value &&
    !isVideoPanelFullscreen.value &&
    !subtitlesHidden.value,
)

/** 非全屏时的视频栏宽度/观影布局；全屏期间不切换，避免改全屏元素 class 导致 API 状态异常 */
const videoPanelLayoutClass = computed(() => {
  if (isVideoPanelFullscreen.value) return ''
  if (subtitlesHidden.value) {
    return 'video-panel--cinema flex-1 min-w-0 max-lg:landscape:flex-1 max-lg:landscape:min-w-0 lg:justify-center'
  }
  if (canResizeSplit.value) {
    return 'video-panel--resizable min-w-0 max-lg:landscape:shrink-0'
  }
  return 'lg:w-[46%] xl:w-[44%] max-lg:landscape:w-[42%] max-lg:landscape:shrink-0'
})

const videoPanelSplitStyle = computed(() => {
  if (!canResizeSplit.value) return undefined
  return { width: `${videoPercent.value}%` }
})

function onVideoSplitKeydown(event: KeyboardEvent) {
  if (event.key === 'ArrowLeft') {
    event.preventDefault()
    nudgeVideoSplit(-2)
    return
  }
  if (event.key === 'ArrowRight') {
    event.preventDefault()
    nudgeVideoSplit(2)
    return
  }
  if (event.key === 'Home' || event.key === 'Enter') {
    event.preventDefault()
    resetVideoSplit()
  }
}

const playbackTime = computed(() => player.currentTime.value)

const mobileChromeEnabled = computed(
  () => isPhone.value && Boolean(episode.value) && !props.adminPreview,
)

const mobileChromeBlocked = computed(
  () =>
    mobileMoreOpen.value ||
    mobileDrawerOpen.value ||
    showEntryPanel.value ||
    subtitleModeSheetOpen.value ||
    showSettings.value ||
    dictationOpen.value,
)

const {
  visible: mobileChromeVisible,
  toggle: toggleMobileChrome,
  onChromeInteraction: onMobileChromeInteraction,
} = useMobilePlayerChrome({
  enabled: mobileChromeEnabled,
  isPlaying: player.isPlaying,
  isBlocked: mobileChromeBlocked,
})

const mobileListBottomPad = computed(() => {
  if (!isPhone.value) return ''
  if (props.adminPreview) return 'pb-[calc(7.5rem+env(safe-area-inset-bottom))]'
  return mobileChromeVisible.value
    ? 'pb-[calc(7.5rem+env(safe-area-inset-bottom))]'
    : 'pb-[calc(2.75rem+env(safe-area-inset-bottom))]'
})

const mobileEpisodeHeaderSpacer = 'h-[calc(2.75rem+max(0.75rem,env(safe-area-inset-top)))]'

const mobileVideoImmersive = computed(
  () => mobileChromeEnabled.value && !mobileChromeVisible.value,
)

watch(showEntryPanel, (open) => {
  document.body.style.overflow = open ? 'hidden' : ''
})

watch(showSettings, (open) => {
  if (open && !showEntryPanel.value) document.body.style.overflow = 'hidden'
  else if (!showEntryPanel.value && !mobileMoreOpen.value) document.body.style.overflow = ''
})

watch(mobileMoreOpen, (open) => {
  if (open && !showEntryPanel.value) document.body.style.overflow = 'hidden'
  else if (!showEntryPanel.value && !showSettings.value) document.body.style.overflow = ''
})

function onEntryKeydown(e: KeyboardEvent) {
  if (e.key === 'Escape') {
    if (getFullscreenElement()) {
      void exitAppFullscreen()
      return
    }
    if (showEntryPanel.value) closeEntryPanel()
    else if (showSettings.value) showSettings.value = false
  }
}

let unsubscribeVideoPanelFullscreen: (() => void) | null = null

onMounted(() => {
  syncSubtitlesHiddenForVideo(props.videoId)
  load()
  if (auth.isLoggedIn) void vocabularyStore.load()
  window.addEventListener('keydown', onEntryKeydown)
  window.addEventListener('afterprint', onAfterPrint)
  unsubscribeVideoPanelFullscreen = subscribeFullscreenChange(onVideoPanelFullscreenChange)
  if (props.videoId) void warmEpisodeWordLookups(props.videoId)
})

onUnmounted(() => {
  stopClonedChain()
  closeShadowSession()
  if (continuousFinishedTimer) clearTimeout(continuousFinishedTimer)
  if (listScrollAnim) cancelAnimationFrame(listScrollAnim)
  if (quickVocabToastTimer != null) clearTimeout(quickVocabToastTimer)
  document.body.style.overflow = ''
  window.removeEventListener('keydown', onEntryKeydown)
  window.removeEventListener('afterprint', onAfterPrint)
  unsubscribeVideoPanelFullscreen?.()
  unsubscribeVideoPanelFullscreen = null
  void exitAppFullscreen()
})
watch(
  () => props.videoId,
  (videoId) => {
    void exitAppFullscreen()
    contentView.value = 'subtitles'
    syncSubtitlesHiddenForVideo(videoId)
    void load()
    if (videoId) void warmEpisodeWordLookups(videoId)
  },
)
watch(currentIndex, (idx, prevIdx) => {
  if (prevIdx !== undefined && idx !== prevIdx) {
    subtitleSlideDir.value = idx > prevIdx ? 'next' : 'prev'
  }
  if (modeIsDynamicFocus(subtitleMode.value)) return
  nextTick(() => scrollCurrentIntoView())
})

function preloadPoster(url: string) {
  if (!url || document.querySelector(`link[rel="preload"][href="${url}"]`)) return
  const link = document.createElement('link')
  link.rel = 'preload'
  link.as = 'image'
  link.href = url
  document.head.appendChild(link)
}

function closeMobileMore() {
  mobileMoreOpen.value = false
}

function openMobileMore() {
  mobileMoreOpen.value = true
}

function openSubtitleModeFromMore() {
  closeMobileMore()
  subtitleModeSheetOpen.value = true
}

function openMobileDrawerFromMore(tab: 'related' | 'lookup') {
  closeMobileMore()
  openMobileDrawer(tab)
}

function openSettingsFromMore() {
  closeMobileMore()
  showSettings.value = true
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
  return `/english/episode/${videoId}`
}

function onSelectRelatedEpisode(videoId: string) {
  if (videoId === props.videoId) return
  const ep = relatedEpisodes.value.find((e) => e.video_id === videoId)
  if (ep?.requires_membership) {
    void router.push('/pricing')
    return
  }
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

const relatedPanelLabel = computed(() => (episode.value?.series ? '同合集' : '相似视频'))

async function loadRelatedEpisodes() {
  relatedLoading.value = true
  try {
    const series = episode.value?.series
    if (series?.id) {
      const data = await getEpisodeList({
        series_id: series.id,
        ordering: 'series_index',
        page_size: 50,
      })
      // 合集侧栏保留当前集，便于定位与高亮
      relatedEpisodes.value = data.results
      return
    }

    const tags = episode.value?.tags ?? []
    if (!tags.length) {
      relatedEpisodes.value = []
      return
    }
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

function goSeriesEpisode(videoId: string | null | undefined) {
  if (!videoId) return
  requestEpisodeAutoplay()
  router.push(episodePath(videoId))
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
  isFavorite.value = false
  try {
    const data = props.adminPreview
      ? await (await import('@/api/admin')).adminGetEpisodePreview(props.videoId)
      : await getEpisodeDetail(props.videoId)
    episode.value = data.episode
    isFavorite.value = Boolean(data.episode.is_favorite)
    preloadPoster(data.episode.media?.thumbnail_url ?? '')
    currentIndex.value = 0
    if (!props.adminPreview) {
      void loadRelatedEpisodes()
    }
    if (!props.adminPreview && auth.isLoggedIn) {
      await initLearning()
      void loadLookupHistory()
      void loadShadowTracks()
      try {
        const rows = await getSubtitleProgress(props.videoId)
        learnedSubtitleIds.value = new Set(
          rows.filter((r: SubtitleProgress) => r.is_marked_learned).map((r) => r.subtitle_id),
        )
      } catch {
        learnedSubtitleIds.value = new Set()
      }
    }
    const jumped = await applyVocabDeepLink()
    if (!jumped) nextTick(scrollCurrentIntoView)
  } catch (e: unknown) {
    const status = (e as { response?: { status?: number; data?: { detail?: string } } })?.response?.status
    const detail = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    if (!props.adminPreview && status === 403) {
      await router.replace({
        path: '/pricing',
        query: { next: `/english/episode/${props.videoId}` },
      })
      return
    }
    if (!isSwitch) {
      if (status === 404) error.value = '视频不存在或已下架'
      else if (typeof detail === 'string' && detail) error.value = detail
      else error.value = '加载失败'
    }
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

function subtitleContainsWord(sub: Subtitle, word: string) {
  const needle = word.trim().toLowerCase()
  if (!needle) return true
  const hay = `${sub.english || ''} ${sub.english_html || ''}`.toLowerCase()
  return needle.split(/\s+/).every((part) => {
    const clean = part.replace(/[^a-z0-9'-]/gi, '')
    return !clean || hay.includes(clean)
  })
}

/** 优先精确 id；若带 word 且该句不含词，则在邻近句 / 全篇中校正 */
function resolveDeepLinkSubtitle(subtitleId: number, word: string): Subtitle | null {
  const subs = sortedSubs.value
  const idx = subs.findIndex((s) => s.id === subtitleId)
  const base = idx >= 0 ? subs[idx] : null
  if (base && subtitleContainsWord(base, word)) return base

  if (word.trim() && idx >= 0) {
    for (const delta of [1, -1, 2, -2, 3, -3]) {
      const nearby = subs[idx + delta]
      if (nearby && subtitleContainsWord(nearby, word)) return nearby
    }
  }
  if (word.trim()) {
    const hit = subs.find((s) => subtitleContainsWord(s, word))
    if (hit) return hit
  }
  return base
}

/** 生词本「回看」：按 subtitle id（并可按 word 校正）定位到对应字幕句 */
async function applyVocabDeepLink(): Promise<boolean> {
  const raw = route.query.subtitle
  const subtitleId = Number(Array.isArray(raw) ? raw[0] : raw)
  const wordRaw = route.query.word
  const word = String(Array.isArray(wordRaw) ? wordRaw[0] : wordRaw || '')
  if (!Number.isFinite(subtitleId) || subtitleId <= 0) return false

  const sub = resolveDeepLinkSubtitle(subtitleId, word)
  if (!sub) return false

  // 生词定位优先于「继续上次进度」提示
  clearResumePrompt()
  player.seekTo(sub)
  await nextTick()
  scrollCurrentIntoView()

  // 播放器稍晚挂载时再对齐一次时间轴
  for (const delay of [120, 320, 700]) {
    window.setTimeout(() => {
      if (sortedSubs.value.some((s) => s.id === sub.id)) {
        player.seekTo(sub)
        scrollCurrentIntoView()
      }
    }, delay)
  }

  window.setTimeout(() => {
    triggerSourceFocus(sub.id, word)
  }, 100)
  return true
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
    favoriteToast.show(res.is_favorite, episode.value?.short_title || '')
    void corpusBadge.refresh()
  } catch {
    isFavorite.value = !next
  } finally {
    favoriteLoading.value = false
  }
}

async function toggleAuthorSubscribeFromMore() {
  const author = episode.value?.author
  const authorId = author?.id
  if (!authorId || !auth.isLoggedIn) return
  const next = !author.is_subscribed
  author.is_subscribed = next
  try {
    const res = await setAuthorSubscribe(authorId, next)
    author.is_subscribed = res.is_subscribed
    author.subscriber_count = res.subscriber_count
  } catch {
    author.is_subscribed = !next
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

function clearVocabNotice() {
  if (vocabNoticeTimer != null) {
    clearTimeout(vocabNoticeTimer)
    vocabNoticeTimer = null
  }
  vocabNotice.value = ''
  vocabNoticeType.value = ''
}

/** persist=true 时不自动消失（加入成功后保留「已加入生词本 / 查看」） */
function flashVocabNotice(message: string, type: 'ok' | 'err', persist = false) {
  if (vocabNoticeTimer != null) clearTimeout(vocabNoticeTimer)
  vocabNoticeTimer = null
  vocabNotice.value = message
  vocabNoticeType.value = type
  if (persist) return
  vocabNoticeTimer = setTimeout(() => {
    vocabNotice.value = ''
    vocabNoticeType.value = ''
    vocabNoticeTimer = null
  }, 2200)
}

async function toggleVocabulary(entry: EntryDetail) {
  if (!auth.isLoggedIn || !entry) return
  const subtitleId = entrySourceSubtitleId.value ?? currentSub.value?.id
  const wasSaved = Boolean(entry.favorite)
  // 先即时反馈，避免等接口才出现「已加入」
  flashVocabNotice(wasSaved ? '移出中…' : '加入中…', 'ok')
  try {
    if (wasSaved) {
      await removeVocabulary(entry.id)
      entry.favorite = false
      flashVocabNotice('已移出生词本', 'ok')
    } else {
      await saveVocabulary({
        entry_id: entry.id,
        word: entry.headword,
        token_type: entry.category === 'phrase' ? 2 : 1,
        video_id: props.videoId,
        subtitle_id: subtitleId,
      })
      entry.favorite = true
      noteLookup()
      flashVocabNotice('已加入生词本', 'ok', true)
      try {
        const { useVocabularyStore } = await import('@/stores/vocabulary')
        useVocabularyStore().invalidate()
      } catch {
        // ignore
      }
    }
  } catch {
    flashVocabNotice('操作失败，请重试', 'err')
  }
}

async function reopenLookup(record: WordLookupRecord) {
  pausePlaybackForEntry()
  showEntryPanel.value = true
  entryLoading.value = true
  entryError.value = ''
  clearVocabNotice()
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

/** 列表模式：当前句贴在顶部；手机端用动画滚动 */
function animateScrollTo(el: HTMLElement, to: number, duration = 320) {
  if (listScrollAnim) cancelAnimationFrame(listScrollAnim)
  const from = el.scrollTop
  const delta = to - from
  if (Math.abs(delta) < 1) return
  const start = performance.now()
  const tick = (now: number) => {
    const t = Math.min(1, (now - start) / duration)
    const eased = t < 0.5 ? 2 * t * t : 1 - (-2 * t + 2) ** 2 / 2
    el.scrollTop = from + delta * eased
    if (t < 1) listScrollAnim = requestAnimationFrame(tick)
    else listScrollAnim = 0
  }
  listScrollAnim = requestAnimationFrame(tick)
}

function scrollCurrentIntoView() {
  const container = listRef.value
  if (!container || !sortedSubs.value.length) return
  const targetTop = Math.max(0, subtitleVirtual.offsetOf(currentIndex.value) - 8)
  const jump = Math.abs(container.scrollTop - targetTop) > 360
  if (jump) {
    container.scrollTop = targetTop
  } else if (isPhone.value || isPad.value) {
    animateScrollTo(container, targetTop)
  } else {
    container.scrollTo({ top: targetTop, behavior: 'smooth' })
  }
  nextTick(() => {
    subtitleVirtual.measure()
    const corrected = Math.max(0, subtitleVirtual.offsetOf(currentIndex.value) - 8)
    if (Math.abs(container.scrollTop - corrected) > 28) {
      container.scrollTop = corrected
    }
  })
}

function resolveSentenceContext(target: HTMLElement): string {
  const sub = resolveSubtitleFromTarget(target)
  if (sub) return sub.english
  return displaySub.value?.english ?? currentSub.value?.english ?? ''
}

function resolveSubtitleFromTarget(target: HTMLElement) {
  const row = target.closest('[data-sub-index]')
  if (row) {
    const idx = parseInt(row.getAttribute('data-sub-index') ?? '', 10)
    return sortedSubs.value[idx] ?? null
  }
  return displaySub.value ?? currentSub.value ?? null
}

function resolveClickedWordSpan(target: HTMLElement, root: HTMLElement): HTMLElement | null {
  let el = target.closest('span')
  while (el && root.contains(el)) {
    if (el.classList.contains('subtitle-word-wrap')) {
      el = (el.querySelector(':scope > span') as HTMLElement | null) ?? el
    }
    if (el.parentElement?.classList.contains('subtitle-word-wrap')) {
      el = el.parentElement.querySelector(':scope > span') as HTMLElement
    }
    const text = el.textContent?.trim() ?? ''
    if (text && el !== root && !el.classList.contains('subtitle-english-word-progress')) {
      return el
    }
    el = el.parentElement?.closest('span') ?? null
  }
  return null
}

function resolveWordHitFromEvent(e: Event) {
  const root = (e.target as HTMLElement).closest('.subtitle-english') as HTMLElement | null
  if (!root) return null
  const target = resolveClickedWordSpan(e.target as HTMLElement, root)
  if (!target) return null
  const word = target.textContent?.trim().replace(/\s+/g, ' ') ?? ''
  if (!word) return null
  const pid = target.getAttribute('pid')
  const isPhrase = Boolean(pid) || target.classList.contains('phrase-token')
  const type = (isPhrase ? 2 : 1) as 1 | 2
  const context = resolveSentenceContext(target)
  const sub = resolveSubtitleFromTarget(target)
  const gloss = (target.getAttribute('data-gloss') || '').trim()
  return { target, word, type, context, subtitleId: sub?.id ?? null, gloss }
}

const quickVocabToast = ref('')
let quickVocabToastTimer: ReturnType<typeof setTimeout> | null = null
let quickFavoriteBusy = false

function flashQuickVocabToast(message: string) {
  if (quickVocabToastTimer != null) clearTimeout(quickVocabToastTimer)
  quickVocabToast.value = message
  quickVocabToastTimer = setTimeout(() => {
    quickVocabToast.value = ''
    quickVocabToastTimer = null
  }, 2200)
}

async function quickFavoriteFromPointer(e: PointerEvent) {
  if (!auth.isLoggedIn || props.adminPreview || quickFavoriteBusy) return
  const hit = resolveWordHitFromEvent(e)
  if (!hit) return

  quickFavoriteBusy = true
  entrySourceSubtitleId.value = hit.subtitleId
  try {
    const entry = await lookupWord(hit.word, hit.type, hit.context, {
      video_id: props.videoId,
      subtitle_id: hit.subtitleId ?? undefined,
    })
    noteLookup()
    if (entry.favorite) {
      flashQuickVocabToast(`「${entry.headword}」已在生词本`)
      return
    }
    await saveVocabulary({
      entry_id: entry.id,
      word: entry.headword,
      token_type: entry.category === 'phrase' ? 2 : 1,
      video_id: props.videoId,
      subtitle_id: hit.subtitleId ?? undefined,
    })
    hit.target.classList.add('highlight', 'token-clicked')
    flashQuickVocabToast(`已加入生词本：${entry.headword}`)
    try {
      const { useVocabularyStore } = await import('@/stores/vocabulary')
      useVocabularyStore().invalidate()
    } catch {
      // ignore
    }
  } catch {
    flashQuickVocabToast('收藏失败，请重试')
  } finally {
    quickFavoriteBusy = false
  }
}

const wordLongPress = useWordLongPress({
  enabled: () => auth.isLoggedIn && !props.adminPreview,
  onLongPress: (e) => {
    void quickFavoriteFromPointer(e)
  },
})

const wordLongPressHandlers = {
  pointerdown: (e: PointerEvent) => {
    prefetchWordFromEvent(e)
    wordLongPress.onPointerDown(e)
  },
  pointermove: wordLongPress.onPointerMove,
  pointerup: wordLongPress.onPointerUp,
  pointercancel: wordLongPress.onPointerCancel,
  contextmenu: wordLongPress.onContextMenu,
}

function prefetchWordFromEvent(e: Event) {
  const hit = resolveWordHitFromEvent(e)
  if (!hit) return
  void fetchWordLookup(hit.word, hit.type, hit.context, {
    video_id: props.videoId,
    subtitle_id: hit.subtitleId ?? undefined,
  })
}

async function openWordEntry(payload: {
  word: string
  type: 1 | 2
  context: string
  subtitleId: number | null
  gloss?: string
}) {
  pausePlaybackForEntry()
  showEntryPanel.value = true
  entryError.value = ''
  clearVocabNotice()
  entrySourceSubtitleId.value = payload.subtitleId

  const cached = getCachedWordLookup(payload.word, payload.type, payload.context)
  selectedEntry.value = cached ?? makeLookupStub(payload.word, payload.type, payload.gloss)
  entryLoading.value = !cached

  try {
    selectedEntry.value = await lookupWord(payload.word, payload.type, payload.context, {
      video_id: props.videoId,
      subtitle_id: payload.subtitleId ?? undefined,
    })
    if (auth.isLoggedIn) noteLookup()
    if (sidePanelTab.value === 'lookup') void loadLookupHistory()
  } catch {
    if (!cached && !payload.gloss) entryError.value = '词条加载失败，请确认后端已启动且 DeepSeek API 配置正确'
  } finally {
    entryLoading.value = false
  }
}

async function onSubtitleClick(e: MouseEvent) {
  if (wordLongPress.consumeIfFired()) return

  const hit = resolveWordHitFromEvent(e)
  if (!hit) return

  await openWordEntry({
    word: hit.word,
    type: hit.type,
    context: hit.context,
    subtitleId: hit.subtitleId,
    gloss: hit.gloss,
  })
  hit.target.classList.add('highlight', 'token-clicked')
}

function onDanmakuOpenWord(payload: {
  word: string
  tokenType: 1 | 2
  context: string
  subtitleId: number | null
}) {
  void openWordEntry({
    word: payload.word,
    type: payload.tokenType,
    context: payload.context,
    subtitleId: payload.subtitleId,
  })
}

function closeEntryPanel() {
  showEntryPanel.value = false
  selectedEntry.value = null
  entryError.value = ''
  clearVocabNotice()
  resumePlaybackAfterEntry()
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

const backFrom = computed(() => {
  const raw = route.query.from
  return String(Array.isArray(raw) ? raw[0] : raw || '')
})
const fromVocabulary = computed(() => backFrom.value === 'vocab')
const fromLearning = computed(() => backFrom.value === 'learning')

function goBack() {
  if (fromVocabulary.value) {
    router.push('/english/vocabulary')
    return
  }
  if (fromLearning.value) {
    router.push('/english/learning')
    return
  }
  router.push(props.backTo ?? '/english')
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
    class="no-print flex flex-col overflow-hidden bg-neutral-100 dark:bg-neutral-950"
    :class="[adminPreview ? 'h-dvh' : 'h-full', intensivePageClass]"
  >
    <header
      class="flex items-center gap-3 px-4 py-3 pt-[max(0.75rem,env(safe-area-inset-top))] bg-white dark:bg-neutral-900 border-b border-black/5 dark:border-white/10 z-30 transition-transform duration-300 ease-out"
      :class="
        mobileChromeEnabled
          ? [
              'fixed inset-x-0 top-0',
              mobileChromeVisible ? 'translate-y-0' : '-translate-y-full pointer-events-none',
            ]
          : 'shrink-0'
      "
    >
      <button class="text-sm text-neutral-500 hover:text-black dark:text-neutral-400 dark:hover:text-white" @click="goBack">
        {{ fromVocabulary ? '← 生词本' : fromLearning ? '← 学习统计' : '← 返回' }}
      </button>
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
        <p class="text-xs text-neutral-500 dark:text-neutral-400 max-lg:hidden flex items-center gap-1.5 min-w-0">
          <RouterLink
            v-if="episode.author.id"
            :to="`/english/authors/${episode.author.id}`"
            class="hover:text-amber-700 dark:hover:text-amber-400 truncate"
          >
            {{ episode.author.name }}
          </RouterLink>
          <span v-else class="truncate">{{ episode.author.name }}</span>
          <AuthorSubscribeButton
            v-if="!adminPreview && episode.author.id"
            compact
            :author-id="episode.author.id"
            :is-subscribed="Boolean(episode.author.is_subscribed)"
            :subscriber-count="episode.author.subscriber_count || 0"
            @update:is-subscribed="(v) => episode && (episode.author.is_subscribed = v)"
            @update:subscriber-count="(v) => episode && (episode.author.subscriber_count = v)"
          />
          <span class="text-neutral-400">·</span>
          <template v-if="episode.series">
            <RouterLink
              :to="`/english/series/${episode.series.slug}`"
              class="hover:text-amber-700 dark:hover:text-amber-400 truncate"
            >
              {{ episode.series.title }}
            </RouterLink>
            <span class="shrink-0">第 {{ episode.series.series_index }} / {{ episode.series.episode_count }} 集</span>
          </template>
          <span v-else class="shrink-0">第 {{ episode.index }} 期</span>
        </p>
      </div>
      <div
        v-if="episode?.series && !adminPreview"
        class="hidden sm:flex items-center gap-1 shrink-0"
      >
        <button
          type="button"
          class="text-xs px-2.5 py-1.5 rounded-lg border border-black/10 dark:border-white/10 text-neutral-600 dark:text-neutral-300 hover:bg-neutral-50 dark:hover:bg-neutral-800 disabled:opacity-40 disabled:pointer-events-none"
          :disabled="!episode.series.prev_video_id"
          @click="goSeriesEpisode(episode.series.prev_video_id)"
        >
          上一集
        </button>
        <button
          type="button"
          class="text-xs px-2.5 py-1.5 rounded-lg border border-black/10 dark:border-white/10 text-neutral-600 dark:text-neutral-300 hover:bg-neutral-50 dark:hover:bg-neutral-800 disabled:opacity-40 disabled:pointer-events-none"
          :disabled="!episode.series.next_video_id"
          @click="goSeriesEpisode(episode.series.next_video_id)"
        >
          下一集
        </button>
      </div>
      <div class="flex items-center gap-1 shrink-0">
        <AuthorSubscribeButton
          v-if="isPhone && !adminPreview && episode?.author?.id"
          compact
          :author-id="episode.author.id"
          :is-subscribed="Boolean(episode.author.is_subscribed)"
          :subscriber-count="episode.author.subscriber_count || 0"
          @update:is-subscribed="(v) => episode && (episode.author.is_subscribed = v)"
          @update:subscriber-count="(v) => episode && (episode.author.subscriber_count = v)"
        />
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
            :class="isFavorite ? 'fav-star-burst' : ''"
            active-class="text-amber-400"
            inactive-class="text-neutral-400"
          />
        </button>
        <button
          v-if="isPhone && !adminPreview"
          type="button"
          class="inline-flex items-center justify-center w-8 h-8 rounded-lg text-neutral-500 hover:text-black hover:bg-neutral-100 dark:text-neutral-400 dark:hover:text-white dark:hover:bg-neutral-800 transition-colors"
          aria-label="更多"
          @click="openMobileMore"
        >
          <svg class="w-5 h-5" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
            <circle cx="5" cy="12" r="1.75" />
            <circle cx="12" cy="12" r="1.75" />
            <circle cx="19" cy="12" r="1.75" />
          </svg>
        </button>
        <IntensiveModeToggle />
        <SettingsButton v-if="!isPhone" @click="showSettings = true" />
        <button class="hidden sm:inline text-xs text-neutral-400 hover:text-black dark:hover:text-white px-2 py-1" @click="player.showHelp.value = true">
          ? 快捷键
        </button>
      </div>
    </header>

    <div
      v-if="mobileChromeEnabled"
      class="shrink-0 pointer-events-none overflow-hidden transition-[height] duration-300 ease-out"
      :class="mobileChromeVisible ? mobileEpisodeHeaderSpacer : 'h-0'"
      aria-hidden="true"
    />

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

    <div
      v-else-if="episode"
      class="flex-1 min-h-0 flex flex-col lg:flex-row max-lg:landscape:flex-row overflow-hidden"
      :class="subtitlesHidden && isPhone ? 'pb-[calc(1.25rem+env(safe-area-inset-bottom))]' : ''"
    >
      <div
        ref="episodeSplitRef"
        class="flex-1 min-h-0 min-w-0 flex flex-col lg:flex-row max-lg:landscape:flex-row overflow-hidden"
        :class="splitDragging ? 'episode-split--dragging' : ''"
      >
      <!-- 视频区 -->
      <aside
        ref="videoPanelRef"
        class="video-panel shrink-0 min-h-0 lg:h-full flex flex-col gap-2 overflow-hidden bg-neutral-100 dark:bg-neutral-950 p-3 sm:p-4 max-lg:h-auto max-lg:sticky max-lg:top-0 max-lg:z-20 max-lg:shrink-0 max-lg:landscape:static max-lg:landscape:h-auto"
        :class="[
          mobileVideoImmersive ? 'max-lg:!p-0 max-lg:!gap-0 max-lg:!rounded-none' : '',
          isVideoPanelFullscreen ? 'video-panel--fullscreen' : '',
          videoPanelLayoutClass,
          canResizeSplit ? '' : 'lg:border-r border-black/5 dark:border-white/10',
        ]"
        :style="videoPanelSplitStyle"
      >
        <div
          class="video-panel__player shrink-0 w-full min-h-0"
          :class="videoHidden && !isVideoPanelFullscreen ? 'contents' : 'relative'"
        >
          <VideoPlayer
            class="w-full"
            :src="playbackSrc"
            :poster="episode.media.thumbnail_url"
            :hidden="videoHidden"
            :autoplay="videoAutoplay"
            :register-video="registerVideoEl"
            :player="player"
            :show-progress-bar="!isPhone || isVideoPanelFullscreen"
            :auto-hide-progress="!isPhone || isVideoPanelFullscreen"
            :flush="mobileVideoImmersive || isVideoPanelFullscreen"
          />
          <VocabDanmakuOverlay
            v-if="vocabDanmakuEnabled && !videoHidden && displaySub"
            :sources="danmakuSources"
            :context="displaySub.english || ''"
            :video-id="videoId"
            :subtitle-id="displaySub.id"
            :start="displaySub.start"
            :end="displaySub.end"
            :current-time="player.currentTime.value"
            :paused="!player.isPlaying.value || player.gapActive.value"
            :can-save="auth.isLoggedIn && !adminPreview"
            @open-word="onDanmakuOpenWord"
          />
          <GapCountdownOverlay
            v-if="!videoHidden && player.gapActive.value"
            :remaining-ms="player.gapRemainingMs.value"
            :duration-ms="player.gapDurationMs.value"
            :kind="player.gapKind.value"
            @skip="player.skipGapHold"
          />
          <div
            v-if="isVideoPanelFullscreen"
            class="video-panel__subtitle"
            :class="{
              'is-blind': fullscreenCaptionMode === 'blind',
              'is-dragging': captionDragging,
            }"
            :style="{ bottom: `${fullscreenCaptionBottomPct}%` }"
          >
            <div
              class="video-panel__subtitle-drag"
              title="上下拖动字幕位置"
              @pointerdown="onCaptionPointerDown"
              @pointermove="onCaptionPointerMove"
              @pointerup="onCaptionPointerUp"
              @pointercancel="onCaptionPointerUp"
            >
              <div class="video-panel__subtitle-drag-bar" aria-hidden="true" />
              <span class="sr-only">拖动字幕位置</span>
            </div>
            <div
              class="video-panel__caption-mode shrink-0 flex items-center justify-center gap-1 pb-1"
              role="group"
              aria-label="全屏字幕语言"
            >
              <button
                type="button"
                class="video-panel__caption-mode-btn"
                :class="fullscreenCaptionMode === 'both' ? 'is-active' : ''"
                :aria-pressed="fullscreenCaptionMode === 'both'"
                @click="setFullscreenCaptionMode('both')"
              >
                中英
              </button>
              <button
                type="button"
                class="video-panel__caption-mode-btn"
                :class="fullscreenCaptionMode === 'en' ? 'is-active' : ''"
                :aria-pressed="fullscreenCaptionMode === 'en'"
                @click="setFullscreenCaptionMode('en')"
              >
                英语
              </button>
              <button
                type="button"
                class="video-panel__caption-mode-btn"
                :class="fullscreenCaptionMode === 'blind' ? 'is-active' : ''"
                :aria-pressed="fullscreenCaptionMode === 'blind'"
                @click="setFullscreenCaptionMode('blind')"
              >
                盲听
              </button>
            </div>
            <SubtitleWordTooltipHost
              v-if="fullscreenCaptionMode !== 'blind' && displaySub"
              class="w-full shrink-0"
              :context="displaySub.english"
              :lookup-meta="{ video_id: videoId, subtitle_id: displaySub.id }"
              :teleport-to="subtitleTooltipTeleport"
              :suppressed="showEntryPanel"
              @word-hover-start="onSubtitleWordHoverStart"
              @word-hover-end="onSubtitleWordHoverEnd"
            >
              <CurrentSubtitleBar
                class="w-full shrink-0"
                pin-chinese
                :align="isPhone ? 'left' : 'center'"
                :mono-english="isPhone"
                :intensive="intensiveMode"
                :lookup-meta="{ video_id: videoId, subtitle_id: displaySub.id }"
                :sub="displaySub"
                :current-time="playbackTime"
                :subtitle-mode="fullscreenCaptionMode === 'both' ? 'both' : 'en'"
                :show-ipa="false"
                :english-html="renderHtml(displaySub.english_html)"
                :dictation-frost="isDictationFrost(displaySub.id)"
                :data-subtitle-context="displaySub.english"
                @seek="player.seekTo(displaySub)"
                v-on="wordLongPressHandlers"
                @click="onSubtitleClick"
              />
            </SubtitleWordTooltipHost>
          </div>
        </div>
        <PlayerControls
          v-if="!isPhone || isVideoPanelFullscreen"
          class="shrink-0 video-panel__controls"
          :player="player"
          :show-ipa="showIpa"
          :video-hidden="videoHidden"
          :subtitles-hidden="subtitlesHidden"
          :subtitle-mode="subtitleMode"
          :fullscreen-caption-mode="fullscreenCaptionMode"
          :video-panel-ref="videoPanelRef"
          :compact="isPhone"
          :subtitle-voice-mode="subtitleVoiceMode"
          :has-cloned-voice="hasClonedVoice"
          :cloned-speaking="clonedPlaybackActive"
          @update:show-ipa="showIpa = $event"
          @update:video-hidden="videoHidden = $event"
          @update:subtitles-hidden="subtitlesHidden = $event"
          @update:subtitle-mode="selectSubtitleMode"
          @update:fullscreen-caption-mode="setFullscreenCaptionMode"
          @update:subtitle-voice-mode="setSubtitleVoiceMode"
          @open-voice-clone="openVoiceClone"
          @refresh-voice-clone="() => voiceClone.refresh()"
        />
        <button
          v-if="subtitlesHidden && !isVideoPanelFullscreen"
          type="button"
          class="shrink-0 self-start lg:self-center text-xs px-2.5 py-1 rounded-full border border-black/10 dark:border-white/10 text-neutral-500 dark:text-neutral-400 hover:bg-white/80 dark:hover:bg-neutral-800 transition-colors"
          @click="subtitlesHidden = false"
        >
          字幕已隐藏 · 点击显示
        </button>
        <div
          v-if="mountCurrentSubtitleBar && displaySub && !isVideoPanelFullscreen"
          v-show="showCurrentSubtitleBar"
          class="flex flex-col flex-1"
          :class="canResizeSplit ? 'min-h-[4.5rem]' : 'min-h-0'"
        >
          <SubtitleWordTooltipHost
            class="min-h-0 flex flex-col flex-1"
            :context="displaySub.english"
            :lookup-meta="{ video_id: videoId, subtitle_id: displaySub.id }"
            :teleport-to="subtitleTooltipTeleport"
            :suppressed="showEntryPanel"
            @word-hover-start="onSubtitleWordHoverStart"
            @word-hover-end="onSubtitleWordHoverEnd"
          >
            <CurrentSubtitleBar
              class="w-full"
              :class="isPhone ? '' : 'min-h-0 flex-1'"
              :compact="isPhone"
              :top-align="isPad"
              :intensive="intensiveMode"
              :lookup-meta="{ video_id: videoId, subtitle_id: displaySub.id }"
              :sub="displaySub"
              :current-time="playbackTime"
              :subtitle-mode="subtitleMode"
              :show-ipa="showIpa"
              :english-html="renderHtml(displaySub.english_html)"
              :dictation-frost="isDictationFrost(displaySub.id)"
              :data-subtitle-context="displaySub.english"
              @seek="player.seekTo(displaySub)"
              v-on="wordLongPressHandlers"
              @click="onSubtitleClick"
            />
          </SubtitleWordTooltipHost>
        </div>
      </aside>

      <div
        v-if="canResizeSplit"
        role="separator"
        aria-orientation="vertical"
        aria-label="调整视频区域宽度，双击恢复默认"
        :aria-valuenow="Math.round(videoPercent)"
        :aria-valuemin="videoSplitMin"
        :aria-valuemax="videoSplitMax"
        tabindex="0"
        title="拖动调整宽度，双击恢复默认"
        class="episode-split-handle group relative shrink-0 cursor-col-resize touch-none bg-transparent hover:bg-amber-500/15 active:bg-amber-500/25 transition-colors w-3.5 lg:w-2"
        :class="splitDragging ? 'bg-amber-500/20' : ''"
        @pointerdown="startVideoSplitDrag($event, episodeSplitRef)"
        @dblclick.prevent="resetVideoSplit"
        @keydown="onVideoSplitKeydown"
      >
        <div
          class="pointer-events-none absolute inset-y-0 left-1/2 w-px -translate-x-1/2 bg-black/10 dark:bg-white/15 group-hover:bg-amber-500/70 group-active:bg-amber-500"
          :class="splitDragging ? 'bg-amber-500' : ''"
        />
        <div
          class="pointer-events-none absolute top-1/2 left-1/2 h-10 w-1 -translate-x-1/2 -translate-y-1/2 rounded-full bg-neutral-300 dark:bg-neutral-600 opacity-80 group-hover:bg-amber-500 group-hover:opacity-100"
          :class="splitDragging ? 'bg-amber-500 opacity-100' : ''"
        />
      </div>

      <!-- 字幕区：全屏时侧栏不可见且勿强行 v-show，避免牵动全屏元素所在 flex 布局 -->
      <section
        v-show="!subtitlesHidden && !isVideoPanelFullscreen"
        class="subtitle-panel flex-1 min-h-0 flex overflow-hidden bg-neutral-50 dark:bg-neutral-900 border-t lg:border-t-0 border-black/5 dark:border-white/10 max-lg:min-h-0"
      >
        <div class="flex flex-col flex-1 min-h-0 min-w-0 overflow-hidden">
        <!-- 桌面 / Pad：完整工具栏 -->
        <div
          v-if="!isPhone"
          class="shrink-0 flex flex-wrap items-center gap-1 p-3 bg-white dark:bg-neutral-900 border-b border-black/5 dark:border-white/10 text-sm z-10"
        >
          <button
            v-for="m in modeButtons"
            :key="m.key"
            class="px-3 py-1 rounded-full whitespace-nowrap"
            :class="
              contentView === 'subtitles' && subtitleMode === m.key
                ? 'bg-black text-white dark:bg-neutral-100 dark:text-neutral-900'
                : 'bg-neutral-100 dark:bg-neutral-800 dark:text-neutral-300'
            "
            @click="selectSubtitleMode(m.key)"
          >
            {{ m.label }}
          </button>
          <button
            type="button"
            class="px-3 py-1 rounded-full whitespace-nowrap"
            :class="
              contentView === 'wordcards'
                ? 'bg-black text-white dark:bg-neutral-100 dark:text-neutral-900'
                : 'bg-neutral-100 dark:bg-neutral-800 dark:text-neutral-300'
            "
            @click="openWordCardsView"
          >
            词卡
          </button>
          <button
            type="button"
            class="px-3 py-1 rounded-full whitespace-nowrap"
            :class="
              contentView === 'summary'
                ? 'bg-black text-white dark:bg-neutral-100 dark:text-neutral-900'
                : 'bg-neutral-100 dark:bg-neutral-800 dark:text-neutral-300'
            "
            @click="openVocabSummaryView"
          >
            汇总
          </button>
          <button
            type="button"
            class="relative inline-flex items-center gap-1.5 px-3 py-1 pr-4 rounded-full whitespace-nowrap"
            :class="
              contentView === 'context'
                ? 'bg-black text-white dark:bg-neutral-100 dark:text-neutral-900'
                : 'bg-neutral-100 dark:bg-neutral-800 dark:text-neutral-300'
            "
            @click="openVideoContextView"
            title="结合视频背景，帮助理解内容"
          >
            视频语境
            <span
              class="text-[10px] font-medium leading-none px-1.5 py-0.5 rounded-full"
              :class="
                contentView === 'context'
                  ? 'bg-white/20 text-white dark:bg-neutral-900/15 dark:text-neutral-900'
                  : 'bg-amber-100 text-amber-800 dark:bg-amber-900/40 dark:text-amber-200'
              "
            >
              看懂背景
            </span>
            <span
              class="absolute -top-1.5 -right-1 px-1.5 py-0.5 rounded-md text-[10px] font-bold leading-none bg-red-500 text-white shadow-sm"
            >
              新
            </span>
          </button>
          <div class="flex items-center gap-1.5 ml-auto shrink-0">
            <button
              v-if="contentView === 'subtitles' && subtitleMode === 'blank'"
              type="button"
              class="text-xs px-2.5 py-1 rounded-full whitespace-nowrap border border-black/10 dark:border-white/10 text-neutral-500 dark:text-neutral-400 hover:bg-neutral-50 dark:hover:bg-neutral-800 transition-colors"
              @click="openBlankPrintSheet"
            >
              打印挖空
            </button>
            <button
              v-if="contentView === 'wordcards'"
              type="button"
              class="text-xs px-2.5 py-1 rounded-full whitespace-nowrap border border-black/10 dark:border-white/10 text-neutral-500 dark:text-neutral-400 hover:bg-neutral-50 dark:hover:bg-neutral-800 transition-colors disabled:opacity-40"
              :disabled="wordCardsLoading"
              @click="openWordCardPrintSheet"
            >
              打印词卡
            </button>
            <RouterLink
              v-if="!adminPreview && auth.isLoggedIn && episodeVocabPracticeCount > 0"
              :to="{
                path: '/english/word-practice',
                query: { source: 'episode_vocab', videoId: props.videoId, limit: '15' },
              }"
              class="text-xs px-2.5 py-1 rounded-full whitespace-nowrap border border-teal-300/80 text-teal-700 dark:border-teal-700 dark:text-teal-300 hover:bg-teal-50 dark:hover:bg-teal-950/40 transition-colors"
              title="练习本集加入生词本的单词拼写"
            >
              练本集生词{{ episodeVocabPracticeCount > 0 ? ` ${episodeVocabPracticeCount}` : '' }}
            </RouterLink>
            <button
              v-if="!adminPreview && !showSidePanel"
              type="button"
              class="text-xs px-2.5 py-1 rounded-full whitespace-nowrap border border-black/10 dark:border-white/10 text-neutral-500 dark:text-neutral-400 hover:bg-neutral-50 dark:hover:bg-neutral-800 transition-colors"
              @click="toggleSidePanel"
            >
              显示侧栏
            </button>
          </div>
        </div>

        <IntensiveReadingStatsBar
          v-if="intensiveMode && contentView === 'subtitles'"
          :title="episode.short_title"
          :subtitle="
            episode.series
              ? `${episode.series.title} · 第 ${episode.series.series_index}/${episode.series.episode_count} 集`
              : `${episode.author.name} · 第 ${episode.index} 期`
          "
          :word-count="episode.voca_size"
          :highlight-count="coreVocabCount"
          :segment-count="episode.subtitle_count"
        />

        <EpisodeWordCardList
          v-if="contentView === 'wordcards'"
          :items="wordCardItems"
          :groups="wordCardGroups"
          :loading="wordCardsLoading"
          @select="openWordCard"
        />

        <EpisodeVocabSummaryList
          v-else-if="contentView === 'summary'"
          :groups="vocabSummaryGroups"
          :video-id="videoId"
          :can-save="auth.isLoggedIn && !adminPreview"
        />

        <EpisodeVideoContextPanel
          v-else-if="contentView === 'context'"
          :content="episode.video_context || ''"
        />

        <!-- 动态模式 -->
        <div
          v-else-if="modeIsDynamicFocus(subtitleMode) && currentSub && !isPhone"
          ref="dynamicFocusRef"
          class="subtitle-focus-light subtitle-scroll-hide flex-1 min-h-0 overflow-hidden overscroll-contain flex flex-col justify-start pt-2 px-3 pb-4 lg:justify-center lg:p-6 xl:p-10 cursor-pointer touch-pan-y"
          :class="subtitleAlign === 'left' ? 'items-start text-left' : 'items-center text-center'"
          @click="currentSub && player.seekTo(currentSub)"
        >
          <div class="relative w-full max-w-3xl rounded-2xl p-2 -m-2">
            <Transition
              :name="subtitleSlideDir === 'next' ? 'subtitle-slide-next' : 'subtitle-slide-prev'"
            >
              <IntensiveReadingBlock
                v-if="intensiveMode"
                :key="currentSub.id"
                :english-html="renderHtml(currentSub.english_html)"
                :english="currentSub.english"
                :chinese="currentSub.chinese"
                :ipa="currentSub.ipa"
                :large="true"
                :align="subtitleAlign"
                :show-english="modeShowsEnglish(subtitleMode)"
                :show-chinese="modeShowsChinese(subtitleMode)"
                :show-ipa="modeShowsIpa(subtitleMode, showIpa)"
                :lookup-meta="{ video_id: videoId, subtitle_id: currentSub.id }"
                :emphasize-word="isSourceFocused(currentSub.id) ? sourceFocusWord : ''"
                v-on="wordLongPressHandlers"
                @click="onSubtitleClick"
              />
              <SubtitleBlock
                v-else
                :key="currentSub.id"
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
                :emphasize-word="isSourceFocused(currentSub.id) ? sourceFocusWord : ''"
                v-on="wordLongPressHandlers"
                @click="onSubtitleClick"
              />
            </Transition>
            <div
              v-if="isDictationFrost(currentSub.id)"
              :class="dictationFrostClass"
              class="rounded-xl"
              aria-hidden="true"
            />
          </div>
        </div>

        <!-- 列表模式 -->
        <div
          v-else
          ref="listRef"
          class="subtitle-scroll-hide flex-1 min-h-0 overflow-y-auto overscroll-contain [-webkit-overflow-scrolling:touch] touch-pan-y px-3 pt-2 lg:p-4 lg:pb-4"
          :class="mobileListBottomPad"
        >
          <div
            class="flex flex-col gap-2"
            :style="{
              paddingTop: `${subtitleVirtual.padTop.value}px`,
              paddingBottom: `${subtitleVirtual.padBottom.value}px`,
            }"
          >
          <div
            v-for="row in visibleSubtitleRows"
            :key="row.sub.id"
            :data-sub-index="row.index"
            class="flex flex-col cursor-pointer scroll-mt-2"
            :class="subtitleAlign === 'left' ? 'items-stretch' : 'items-center'"
            @click="player.seekTo(row.sub)"
          >
            <div
              class="w-full relative transition-colors duration-200 ease-out pr-2 sm:pr-4"
              :class="[
                intensiveMode
                  ? [
                      'intensive-subtitle-card rounded-xl border p-3 sm:p-4',
                      row.index === currentIndex
                        ? 'border-red-300/80 dark:border-red-700/50 ring-1 ring-red-200/60 dark:ring-red-900/30'
                        : 'border-red-100/80 dark:border-red-950/40',
                    ]
                  : [subtitleRowClass(row.index), row.index === currentIndex && 'subtitle-row--active'],
                showSubtitleLearnedMark && auth.isLoggedIn && !adminPreview ? 'pr-10 sm:pr-12' : '',
                practiceMenuOpenId === row.sub.id && 'z-40',
              ]"
            >
              <button
                v-if="showSubtitleLearnedMark && auth.isLoggedIn && !adminPreview"
                type="button"
                class="absolute top-2 right-2 z-10 w-7 h-7 rounded-full text-sm flex items-center justify-center border transition"
                :class="
                  learnedSubtitleIds.has(row.sub.id)
                    ? 'bg-emerald-500 border-emerald-500 text-white'
                    : 'bg-white/80 border-black/10 text-neutral-400 hover:border-emerald-400 dark:bg-neutral-800/80 dark:border-white/10 dark:text-neutral-500 dark:hover:border-emerald-500'
                "
                :title="learnedSubtitleIds.has(row.sub.id) ? '取消已掌握' : '标记已掌握'"
                @click="toggleSubtitleLearned(row.sub, $event)"
              >
                ✓
              </button>
              <IntensiveReadingBlock
                v-if="intensiveMode"
                :english-html="renderHtml(row.sub.english_html)"
                :english="row.sub.english"
                :chinese="row.sub.chinese"
                :ipa="row.sub.ipa"
                :active="false"
                :align="subtitleAlign"
                :show-english="modeShowsEnglish(subtitleMode)"
                :show-chinese="modeShowsChinese(subtitleMode)"
                :show-ipa="modeShowsIpa(subtitleMode, showIpa)"
                :lookup-meta="{ video_id: videoId, subtitle_id: row.sub.id }"
                :emphasize-word="isSourceFocused(row.sub.id) ? sourceFocusWord : ''"
                v-on="wordLongPressHandlers"
                @click.stop="onSubtitleClick"
              />
              <SubtitleBlock
                v-else
                :english-html="renderHtml(row.sub.english_html)"
                :chinese="row.sub.chinese"
                :ipa="row.sub.ipa"
                :active="row.index === currentIndex"
                :align="subtitleAlign"
                :chinese-focus="isChineseOnly"
                :show-english="modeShowsEnglish(subtitleMode)"
                :show-chinese="modeShowsChinese(subtitleMode)"
                :show-ipa="modeShowsIpa(subtitleMode, showIpa)"
                :emphasize-word="isSourceFocused(row.sub.id) ? sourceFocusWord : ''"
                v-on="wordLongPressHandlers"
                @click.stop="onSubtitleClick"
              />
              <SubtitlePracticeToolbar
                v-if="!adminPreview && !showSubtitleLearnedMark"
                variant="inline-row"
                :align="subtitleAlign"
                :shadow-active="shadowActiveSubId === row.sub.id"
                :has-shadow-track="Boolean(shadowTracks[row.sub.id]?.audio_url)"
                :dictation-active="dictationTargetId === row.sub.id"
                @explain="startAiExplain(row.sub, $event)"
                @shadowing="startAiShadowing(row.sub, $event)"
                @shadow="startShadowPractice(row.sub, $event)"
                @cloze="startAiCloze(row.sub, $event)"
                @dictation="startSubtitleDictation(row.sub, $event)"
                @menu-open-change="onPracticeMenuOpenChange(row.sub.id, $event)"
              />
              <div
                v-if="
                  !adminPreview &&
                  (shadowActiveSubId === row.sub.id ||
                    shadowTracks[row.sub.id]?.audio_url ||
                    shadowUploadId === row.sub.id)
                "
                :data-shadow-anchor="row.sub.id"
                class="mt-0.5"
              >
                <ShadowingSessionBar
                  v-if="shadowActiveSubId === row.sub.id"
                  v-model:delay-sec="shadowDelaySec"
                  v-model:rate="shadowRate"
                  v-model:mic-enabled="shadowMicEnabled"
                  :phase="shadowPhase"
                  :error="shadowRecError"
                  :busy="shadowBusy"
                  @start="startShadowTake"
                  @stop="stopShadowTake"
                  @close="closeShadowSession"
                />
                <ShadowTrack
                  v-if="
                    shadowActiveSubId !== row.sub.id &&
                    (shadowTracks[row.sub.id]?.audio_url || shadowUploadId === row.sub.id)
                  "
                  :audio-url="shadowTracks[row.sub.id]?.audio_url || ''"
                  :sentence-duration-sec="sentenceDurationSec(row.sub)"
                  :uploading="shadowUploadId === row.sub.id"
                  @rerecord="rerecordShadow(row.sub)"
                  @score="scoreShadow(row.sub)"
                  @play-reference="playShadowReference(row.sub)"
                />
              </div>
              <div
                v-if="isDictationFrost(row.sub.id)"
                :class="dictationFrostClass"
                aria-hidden="true"
              />
            </div>
          </div>
          </div>
        </div>

        </div>

        <IntensiveCoreVocabPanel
          v-if="intensiveMode && contentView === 'subtitles'"
          :items="coreVocabItems"
          :loading="coreVocabLoading"
        />
      </section>
      </div>

      <IntensiveCoreVocabMobile
        v-if="intensiveMode && contentView === 'subtitles' && !subtitlesHidden && !isVideoPanelFullscreen"
        :items="coreVocabItems"
        :loading="coreVocabLoading"
      />

      <EpisodeSidePanel
        v-if="!adminPreview && showSidePanel && !isPhone"
        :tab="sidePanelTab"
        :related-label="relatedPanelLabel"
        :related-episodes="relatedEpisodes"
        :related-loading="relatedLoading"
        :current-video-id="videoId"
        :lookup-history="lookupHistory"
        :lookup-loading="lookupLoading"
        :show-lookup-tab="auth.isLoggedIn"
        @update:tab="onSidePanelTabChange"
        @reopen-lookup="reopenLookup"
        @select-episode="onSelectRelatedEpisode"
        @close="closeSidePanel"
      />
    </div>

    <!-- 手机端：底部播放控制（全屏时改用面板内控制条，避免遮挡/抢点击） -->
    <div v-if="isPhone && episode && !isVideoPanelFullscreen" class="fixed inset-x-0 bottom-0 z-40 pointer-events-none">
      <button
        v-if="!adminPreview && !mobileChromeVisible"
        type="button"
        class="pointer-events-auto absolute right-3 z-50 flex h-9 w-9 items-center justify-center rounded-full border border-black/10 bg-white/95 text-neutral-600 shadow-md backdrop-blur-md transition-all duration-300 dark:border-white/10 dark:bg-neutral-900/95 dark:text-neutral-300 bottom-[calc(0.625rem+env(safe-area-inset-bottom))]"
        aria-label="显示播放控制"
        :aria-expanded="false"
        @click.stop="toggleMobileChrome"
      >
        <svg class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
          <path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16" />
        </svg>
      </button>

      <div
        class="pointer-events-auto transition-transform duration-300 ease-out pb-[env(safe-area-inset-bottom)]"
        :class="mobileChromeVisible || adminPreview ? 'translate-y-0' : 'translate-y-full'"
        @pointerdown="onMobileChromeInteraction"
      >
        <div class="border-t border-black/10 bg-white/95 backdrop-blur-md dark:border-white/10 dark:bg-neutral-900/95">
          <VideoProgressBar :video="videoRef" variant="dock" />
          <PlayerControls
            v-if="!adminPreview"
            :player="player"
            :show-ipa="showIpa"
            :video-hidden="videoHidden"
            :subtitles-hidden="subtitlesHidden"
            :video-panel-ref="videoPanelRef"
            compact
            docked
            show-chrome-toggle
            :chrome-visible="mobileChromeVisible"
            :subtitle-voice-mode="subtitleVoiceMode"
            :has-cloned-voice="hasClonedVoice"
            :cloned-speaking="clonedPlaybackActive"
            @update:show-ipa="showIpa = $event"
            @update:video-hidden="videoHidden = $event"
            @update:subtitles-hidden="subtitlesHidden = $event"
            @update:subtitle-voice-mode="setSubtitleVoiceMode"
            @toggle-chrome="toggleMobileChrome"
            @open-voice-clone="openVoiceClone"
            @refresh-voice-clone="() => voiceClone.refresh()"
          />
        </div>
      </div>
    </div>

    <!-- 移动端更多菜单 -->
    <Teleport to="body">
      <div
        v-if="isPhone && mobileMoreOpen && !adminPreview"
        class="fixed inset-0 z-50 flex flex-col justify-end bg-black/40"
        @click.self="closeMobileMore"
      >
        <div
          class="rounded-t-2xl bg-white dark:bg-neutral-900 border-t border-black/10 dark:border-white/10 pb-[env(safe-area-inset-bottom)]"
          @click.stop
        >
          <div class="flex justify-center pt-3 pb-2">
            <div class="w-10 h-1 rounded-full bg-neutral-300 dark:bg-neutral-600" />
          </div>
          <div class="px-2 pb-2">
            <button
              v-if="episode?.author.id"
              type="button"
              class="w-full text-left px-4 py-3.5 text-sm rounded-xl hover:bg-neutral-50 dark:hover:bg-neutral-800"
              @click="closeMobileMore(); void toggleAuthorSubscribeFromMore()"
            >
              {{ episode.author.is_subscribed ? '取消关注作者' : '关注作者' }}
            </button>
            <RouterLink
              v-if="episode?.author.id"
              :to="`/english/authors/${episode.author.id}`"
              class="block w-full text-left px-4 py-3.5 text-sm rounded-xl hover:bg-neutral-50 dark:hover:bg-neutral-800"
              @click="closeMobileMore"
            >
              查看作者主页
            </RouterLink>
            <button
              type="button"
              class="w-full text-left px-4 py-3.5 text-sm rounded-xl hover:bg-neutral-50 dark:hover:bg-neutral-800"
              @click="openSubtitleModeFromMore"
            >
              字幕 / 词卡 / 汇总 / 视频语境
              <span class="ml-1.5 align-middle px-1.5 py-0.5 rounded-md text-[10px] font-bold leading-none bg-red-500 text-white">新</span>
              <span class="float-right text-neutral-400">{{ currentModeLabel }}</span>
            </button>
            <button
              type="button"
              class="w-full text-left px-4 py-3.5 text-sm rounded-xl hover:bg-neutral-50 dark:hover:bg-neutral-800"
              @click="closeMobileMore(); subtitlesHidden = !subtitlesHidden"
            >
              {{ subtitlesHidden ? '显示字幕' : '隐藏字幕' }}
            </button>
            <button
              v-if="contentView === 'subtitles' && subtitleMode === 'blank'"
              type="button"
              class="w-full text-left px-4 py-3.5 text-sm rounded-xl hover:bg-neutral-50 dark:hover:bg-neutral-800"
              @click="closeMobileMore(); openBlankPrintSheet()"
            >
              打印挖空
            </button>
            <button
              v-if="contentView === 'wordcards'"
              type="button"
              class="w-full text-left px-4 py-3.5 text-sm rounded-xl hover:bg-neutral-50 dark:hover:bg-neutral-800 disabled:opacity-40"
              :disabled="wordCardsLoading"
              @click="closeMobileMore(); openWordCardPrintSheet()"
            >
              打印词卡
            </button>
            <template v-if="episode?.series">
              <button
                type="button"
                class="w-full text-left px-4 py-3.5 text-sm rounded-xl hover:bg-neutral-50 dark:hover:bg-neutral-800 disabled:opacity-40"
                :disabled="!episode.series.prev_video_id"
                @click="closeMobileMore(); goSeriesEpisode(episode.series.prev_video_id)"
              >
                上一集
              </button>
              <button
                type="button"
                class="w-full text-left px-4 py-3.5 text-sm rounded-xl hover:bg-neutral-50 dark:hover:bg-neutral-800 disabled:opacity-40"
                :disabled="!episode.series.next_video_id"
                @click="closeMobileMore(); goSeriesEpisode(episode.series.next_video_id)"
              >
                下一集
              </button>
              <RouterLink
                :to="`/english/series/${episode.series.slug}`"
                class="block w-full text-left px-4 py-3.5 text-sm rounded-xl hover:bg-neutral-50 dark:hover:bg-neutral-800"
                @click="closeMobileMore"
              >
                查看合集
              </RouterLink>
            </template>
            <button
              type="button"
              class="w-full text-left px-4 py-3.5 text-sm rounded-xl hover:bg-neutral-50 dark:hover:bg-neutral-800"
              @click="openMobileDrawerFromMore('related')"
            >
              {{ relatedPanelLabel }}
            </button>
            <button
              v-if="auth.isLoggedIn"
              type="button"
              class="w-full text-left px-4 py-3.5 text-sm rounded-xl hover:bg-neutral-50 dark:hover:bg-neutral-800"
              @click="openMobileDrawerFromMore('lookup')"
            >
              查词记录
            </button>
            <button
              type="button"
              class="w-full text-left px-4 py-3.5 text-sm rounded-xl hover:bg-neutral-50 dark:hover:bg-neutral-800"
              @click="openSettingsFromMore"
            >
              设置
            </button>
          </div>
        </div>
      </div>
    </Teleport>

    <!-- 移动端侧栏抽屉 -->
    <Teleport to="body">
      <div
        v-if="isPhone && mobileDrawerOpen && !adminPreview"
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
            :related-label="relatedPanelLabel"
            :related-episodes="relatedEpisodes"
            :related-loading="relatedLoading"
            :current-video-id="videoId"
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
      v-if="isPhone"
      :open="subtitleModeSheetOpen"
      :subtitle-mode="subtitleMode"
      :content-view="contentView"
      :mode-buttons="modeButtons"
      :show-vocab-summary="true"
      @close="subtitleModeSheetOpen = false"
      @update:subtitle-mode="(m) => { selectSubtitleMode(m); subtitleModeSheetOpen = false }"
      @select-word-cards="openWordCardsView(); subtitleModeSheetOpen = false"
      @select-vocab-summary="openVocabSummaryView(); subtitleModeSheetOpen = false"
      @select-video-context="openVideoContextView(); subtitleModeSheetOpen = false"
    />

    <BlankPrintSheet
      :open="blankPrintSheetOpen"
      @close="blankPrintSheetOpen = false"
      @confirm="confirmBlankPrint"
    />
    <SentenceDictationSheet
      :open="dictationOpen"
      :subtitle="dictationSubtitle"
      :loop-count="player.sentenceLoopCount.value"
      @close="closeDictation"
      @replay="replayDictationSentence"
      @next="nextAfterDictation"
      @update:loop-count="onDictationLoopCountChange"
    />
    <AiExplainSheet
      :open="aiExplainOpen"
      :loading="aiExplainLoading"
      :error="aiExplainError"
      :result="aiExplainResult"
      @close="closeAiExplain"
      @regenerate="regenerateAiExplain"
    />
    <AiShadowingSheet
      :open="aiShadowOpen"
      :video-id="videoId"
      :subtitle-id="aiShadowSub?.id ?? null"
      :english="aiShadowSub?.english || ''"
      :chinese="aiShadowSub?.chinese || ''"
      :title="episode?.short_title || ''"
      source-type="video"
      :sentence-index="aiShadowSentenceIndex"
      :sentence-total="sortedSubs.length"
      :has-next="aiShadowHasNext"
      @close="aiShadowOpen = false; aiShadowSub = null"
      @play="onShadowPlay"
      @next="nextAiShadowing"
    />
    <AiClozeSheet
      :open="aiClozeOpen"
      :loading="aiClozeLoading"
      :error="aiClozeError"
      :result="aiClozeResult"
      @close="aiClozeOpen = false"
      @dictation="clozeToDictation"
      @regenerate="regenerateAiCloze"
    />
    <BlankPrintDocument
      v-if="episode"
      :title="episode.short_title"
      :author-name="episode.author.name"
      :episode-index="episode.index"
      :subtitles="sortedSubs"
      :options="blankPrintOptions"
    />
    <WordCardPrintSheet
      :open="wordCardPrintSheetOpen"
      :disabled="wordCardsLoading || wordCardItems.length === 0"
      :disabled-reason="
        wordCardsLoading
          ? '词卡加载中，请稍候再打印'
          : wordCardItems.length === 0
            ? '本集暂无可打印的词卡'
            : undefined
      "
      @close="wordCardPrintSheetOpen = false"
      @confirm="confirmWordCardPrint"
    />
    <WordCardPrintDocument
      v-if="episode"
      :title="episode.short_title"
      :author-name="episode.author.name"
      :episode-index="episode.index"
      :items="wordCardItems"
      :options="wordCardPrintOptions"
    />

    <Teleport :to="subtitleTooltipTeleport">
      <EntryCard
        v-if="showEntryPanel"
        :entry="selectedEntry"
        :loading="entryLoading"
        :error="entryError"
        :can-save-vocabulary="auth.isLoggedIn && !adminPreview"
        :vocab-notice="vocabNotice"
        :vocab-notice-type="vocabNoticeType"
        @close="closeEntryPanel"
        @toggle-vocabulary="toggleVocabulary"
      />
    </Teleport>

    <Teleport to="body">
      <Transition name="continuous-finished-fade">
        <div
          v-if="quickVocabToast"
          class="fixed inset-x-0 bottom-24 sm:bottom-28 z-[420] flex justify-center pointer-events-none px-4"
          role="status"
        >
          <div
            class="rounded-full bg-neutral-900/90 dark:bg-neutral-100/95 text-white dark:text-neutral-900 text-sm px-4 py-2 shadow-lg max-w-sm text-center"
          >
            {{ quickVocabToast }}
          </div>
        </div>
      </Transition>
    </Teleport>
    <KeyboardHelp v-if="player.showHelp.value" @close="player.showHelp.value = false" />
    <VoiceCloneSheet
      v-if="auth.isLoggedIn && auth.user"
      :open="voiceCloneOpen"
      :user-id="auth.user.id"
      @close="voiceCloneOpen = false"
      @updated="onClonedVoiceUpdated"
    />
    <SettingsPanel
      v-if="showSettings"
      :subtitle-align="subtitleAlign"
      @close="showSettings = false"
      @update:subtitle-align="subtitleAlign = $event"
    />

    <Teleport to="body">
      <Transition name="continuous-finished-fade">
        <div
          v-if="continuousFinishedNotice"
          class="fixed inset-x-0 bottom-20 sm:bottom-24 z-[400] flex justify-center pointer-events-none px-4"
          role="status"
        >
          <p
            class="rounded-full bg-neutral-900/90 dark:bg-neutral-100/95 text-white dark:text-neutral-900 text-sm font-medium px-4 py-2 shadow-lg"
          >
            已播完
          </p>
        </div>
      </Transition>
    </Teleport>
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

/* 动态模式：切句整段上滚，不淡入淡出 */
.subtitle-slide-next-enter-active,
.subtitle-slide-next-leave-active,
.subtitle-slide-prev-enter-active,
.subtitle-slide-prev-leave-active {
  transition: transform 0.5s cubic-bezier(0.22, 1, 0.36, 1);
}
.subtitle-slide-next-leave-active,
.subtitle-slide-prev-leave-active {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  pointer-events: none;
}
.subtitle-slide-next-enter-from {
  transform: translateY(100%);
}
.subtitle-slide-next-leave-to {
  transform: translateY(-100%);
}
.subtitle-slide-prev-enter-from {
  transform: translateY(-100%);
}
.subtitle-slide-prev-leave-to {
  transform: translateY(100%);
}

.continuous-finished-fade-enter-active,
.continuous-finished-fade-leave-active {
  transition: opacity 0.25s ease, transform 0.25s ease;
}

.continuous-finished-fade-enter-from,
.continuous-finished-fade-leave-to {
  opacity: 0;
  transform: translateY(0.5rem);
}
</style>
