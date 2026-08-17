<script setup lang="ts">
import type { usePlayerControls } from '@/composables/usePlayerControls'
import PlayerControlBar from '@/components/player/PlayerControlBar.vue'
import type { SubtitleDisplayMode } from '@/utils/subtitleHtml'

defineProps<{
  player: ReturnType<typeof usePlayerControls>
  showIpa: boolean
  videoHidden: boolean
  subtitlesHidden?: boolean
  subtitleMode?: SubtitleDisplayMode
  videoPanelRef: HTMLElement | null | undefined
  compact?: boolean
  docked?: boolean
  showChromeToggle?: boolean
  chromeVisible?: boolean
}>()

defineEmits<{
  'update:showIpa': [value: boolean]
  'update:videoHidden': [value: boolean]
  'update:subtitlesHidden': [value: boolean]
  'update:subtitleMode': [value: SubtitleDisplayMode]
  toggleChrome: []
}>()
</script>

<template>
  <PlayerControlBar
    :player="player"
    :show-ipa="showIpa"
    :video-hidden="videoHidden"
    :subtitles-hidden="subtitlesHidden"
    :subtitle-mode="subtitleMode"
    :video-panel-ref="videoPanelRef"
    :compact="compact"
    :docked="docked"
    :show-chrome-toggle="showChromeToggle"
    :chrome-visible="chromeVisible"
    @update:show-ipa="$emit('update:showIpa', $event)"
    @update:video-hidden="$emit('update:videoHidden', $event)"
    @update:subtitles-hidden="$emit('update:subtitlesHidden', $event)"
    @update:subtitle-mode="$emit('update:subtitleMode', $event)"
    @toggle-chrome="$emit('toggleChrome')"
  />
</template>
