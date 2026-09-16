<script setup lang="ts">
import { computed } from 'vue'
import { useListenPlayerStore } from '@/stores/listenPlayer'
import { stripSpeakerMarkers } from '@/utils/subtitleHtml'
import { isSubtitleWordRead, tokenizeSubtitleHtml } from '@/utils/subtitleWordProgress'

withDefaults(
  defineProps<{
    compact?: boolean
  }>(),
  { compact: false },
)

const listen = useListenPlayerStore()

const englishTokens = computed(() => {
  const sub = listen.currentSub
  if (!sub) return []
  return tokenizeSubtitleHtml(sub.english_html || sub.english || '')
})

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
      <template v-for="(token, i) in englishTokens" :key="i">
        <span
          v-if="token.kind === 'word'"
          class="transition-colors duration-150"
          :class="
            isSubtitleWordRead(
              token.wordIndex,
              englishTokens.filter((t) => t.kind === 'word').length,
              listen.currentTime,
              listen.currentSub.start,
              listen.currentSub.end,
            )
              ? 'text-white'
              : 'text-white/45'
          "
          v-html="token.html"
        />
        <span v-else>{{ token.text }}</span>
      </template>
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
