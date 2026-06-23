<script setup lang="ts">
import { computed, nextTick, onMounted, onUnmounted, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import { getEpisodeDetail, getEntryDetail, lookupToken } from '@/api/demo'
import type { EntryDetail, EpisodeDetail } from '@/types'
import EntryCard from '@/components/EntryCard.vue'
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

const props = defineProps<{ videoId: string; backTo?: string }>()
const router = useRouter()

const episode = ref<EpisodeDetail | null>(null)
const loading = ref(true)
const error = ref('')
const subtitleMode = ref<SubtitleDisplayMode>('both')
const subtitleAlign = ref<SubtitleAlign>('center')
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

function registerVideoEl(el: HTMLVideoElement | null) {
  videoRef.value = el
}

const sortedSubs = computed(() =>
  [...(episode.value?.subtitles ?? [])].sort((a, b) => a.index - b.index),
)

const currentSub = computed(() => sortedSubs.value[currentIndex.value] ?? null)

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

const player = usePlayerControls({
  videoRef,
  sortedSubs,
  currentIndex,
})

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

async function load() {
  loading.value = true
  error.value = ''
  try {
    const data = await getEpisodeDetail(props.videoId)
    episode.value = data.episode
    currentIndex.value = 0
    nextTick(scrollCurrentIntoView)
  } catch {
    error.value = '加载失败'
  } finally {
    loading.value = false
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

async function onSubtitleClick(e: MouseEvent) {
  const target = (e.target as HTMLElement).closest('span')
  if (!target) return
  const tid = target.getAttribute('tid')
  const pid = target.getAttribute('pid')
  if (!tid && !pid) return

  showEntryPanel.value = true
  entryLoading.value = true
  entryError.value = ''
  selectedEntry.value = null

  const id = parseInt(tid ?? pid!, 10)
  const type = pid ? 2 : 1
  try {
    try {
      selectedEntry.value = await lookupToken(id, type as 1 | 2)
    } catch {
      selectedEntry.value = await getEntryDetail(id)
    }
    target.classList.add('highlight', 'token-clicked')
  } catch {
    entryError.value = '词条加载失败，请稍后重试'
  } finally {
    entryLoading.value = false
  }
}

function closeEntryPanel() {
  showEntryPanel.value = false
  selectedEntry.value = null
  entryError.value = ''
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
  <div class="h-full flex flex-col overflow-hidden bg-neutral-100">
    <header class="shrink-0 flex items-center gap-4 px-4 py-3 bg-white border-b border-black/5 z-30">
      <button class="text-sm text-neutral-500 hover:text-black" @click="goBack">← 返回</button>
      <div v-if="episode" class="flex-1 min-w-0">
        <p class="font-semibold truncate">{{ episode.short_title }}</p>
        <p class="text-xs text-neutral-500">{{ episode.author.name }} · 第 {{ episode.index }} 期</p>
      </div>
      <div class="flex items-center gap-1 shrink-0">
        <SettingsButton @click="showSettings = true" />
        <button class="text-xs text-neutral-400 hover:text-black px-2 py-1" @click="player.showHelp.value = true">
          ? 快捷键
        </button>
      </div>
    </header>

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
          <div class="flex items-center gap-0.5 ml-1 pl-2 border-l border-black/10">
            <button
              v-for="a in alignButtons"
              :key="a.key"
              class="px-2.5 py-1 rounded-full whitespace-nowrap text-xs"
              :class="subtitleAlign === a.key ? 'bg-neutral-800 text-white' : 'bg-neutral-100 text-neutral-500'"
              @click="subtitleAlign = a.key"
            >
              {{ a.label }}
            </button>
          </div>
        </div>

        <!-- 动态模式 -->
        <div
          v-if="modeIsDynamicFocus(subtitleMode) && currentSub"
          class="flex-1 min-h-0 overflow-y-auto overscroll-contain flex flex-col justify-center p-6 sm:p-10"
          :class="subtitleAlign === 'left' ? 'items-start text-left' : 'items-center text-center'"
          @click="currentSub && player.seekTo(currentSub)"
        >
          <SubtitleBlock
            :english-html="renderHtml(currentSub.english_html)"
            :chinese="currentSub.chinese"
            :ipa="currentSub.ipa"
            :active="true"
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
          class="flex-1 min-h-0 overflow-y-auto overscroll-contain [-webkit-overflow-scrolling:touch] p-4 space-y-2"
        >
          <div
            v-for="(sub, i) in sortedSubs"
            :key="sub.id"
            :data-sub-index="i"
            class="flex flex-col"
            :class="subtitleAlign === 'left' ? 'items-stretch' : 'items-center'"
            @click="player.seekTo(sub)"
          >
            <div class="w-full" :class="subtitleRowClass(i)">
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
    </div>

    <EntryCard
      v-if="showEntryPanel"
      :entry="selectedEntry"
      :loading="entryLoading"
      :error="entryError"
      @close="closeEntryPanel"
    />
    <KeyboardHelp v-if="player.showHelp.value" @close="player.showHelp.value = false" />
    <SettingsPanel v-if="showSettings" @close="showSettings = false" />
  </div>
</template>
