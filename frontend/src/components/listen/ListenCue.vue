<script setup lang="ts">
import { computed } from 'vue'
import { useListenPlayerStore } from '@/stores/listenPlayer'
import { stripSpeakerMarkers } from '@/utils/subtitleHtml'

withDefaults(
  defineProps<{
    compact?: boolean
  }>(),
  { compact: false },
)

const listen = useListenPlayerStore()

const english = computed(() => stripSpeakerMarkers(listen.currentSub?.english || ''))
const chinese = computed(() => stripSpeakerMarkers(listen.currentSub?.chinese || ''))
</script>

<template>
  <div
    v-if="listen.currentSub"
    class="text-center px-5"
    :class="compact ? 'py-2' : 'py-4'"
  >
    <p
      class="font-semibold leading-snug text-white"
      :class="compact ? 'text-base' : 'text-[1.35rem]'"
    >
      {{ english }}
    </p>
    <p
      v-if="chinese"
      class="mt-1.5 text-white/80 leading-relaxed"
      :class="compact ? 'text-xs' : 'text-sm'"
    >
      {{ chinese }}
    </p>
  </div>
</template>
