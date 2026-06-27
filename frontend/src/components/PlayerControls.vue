<script setup lang="ts">
import type { usePlayerControls } from '@/composables/usePlayerControls'
import PlayerControlBar from '@/components/player/PlayerControlBar.vue'

defineProps<{
  player: ReturnType<typeof usePlayerControls>
  showIpa: boolean
  videoHidden: boolean
  videoPanelRef: HTMLElement | null | undefined
  compact?: boolean
}>()

defineEmits<{
  'update:showIpa': [value: boolean]
  'update:videoHidden': [value: boolean]
}>()
</script>

<template>
  <PlayerControlBar
    :player="player"
    :show-ipa="showIpa"
    :video-hidden="videoHidden"
    :video-panel-ref="videoPanelRef"
    :compact="compact"
    @update:show-ipa="$emit('update:showIpa', $event)"
    @update:video-hidden="$emit('update:videoHidden', $event)"
  />
</template>
