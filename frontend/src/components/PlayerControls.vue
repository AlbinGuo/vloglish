<script setup lang="ts">
import type { usePlayerControls } from '@/composables/usePlayerControls'
import PlayerControlBar from '@/components/player/PlayerControlBar.vue'

defineProps<{
  player: ReturnType<typeof usePlayerControls>
  showIpa: boolean
  videoHidden: boolean
  subtitlesHidden?: boolean
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
  toggleChrome: []
}>()
</script>

<template>
  <PlayerControlBar
    :player="player"
    :show-ipa="showIpa"
    :video-hidden="videoHidden"
    :subtitles-hidden="subtitlesHidden"
    :video-panel-ref="videoPanelRef"
    :compact="compact"
    :docked="docked"
    :show-chrome-toggle="showChromeToggle"
    :chrome-visible="chromeVisible"
    @update:show-ipa="$emit('update:showIpa', $event)"
    @update:video-hidden="$emit('update:videoHidden', $event)"
    @update:subtitles-hidden="$emit('update:subtitlesHidden', $event)"
    @toggle-chrome="$emit('toggleChrome')"
  />
</template>
