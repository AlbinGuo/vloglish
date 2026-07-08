<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { fetchWordLookup, type WordLookupMeta } from '@/composables/useWordLookupCache'
import {
  glossKey,
  isHighlightTokenHtml,
  tokenizeForIntensive,
  tokenTypeFromHtml,
  wordFromTokenHtml,
  type GlossInfo,
} from '@/utils/intensiveGlosses'

const props = withDefaults(
  defineProps<{
    html: string
    context: string
    lookupMeta?: WordLookupMeta
    active?: boolean
    large?: boolean
    align?: 'left' | 'center'
  }>(),
  { align: 'left' },
)

defineEmits<{ click: [event: MouseEvent] }>()

const tokens = computed(() => tokenizeForIntensive(props.html))
const glossMap = ref<Map<string, GlossInfo>>(new Map())

const rootClass = computed(() => [
  'intensive-english subtitle-english pointer-events-auto leading-relaxed font-medium',
  props.large ? 'text-lg sm:text-xl intensive-english--large' : 'text-base',
  props.active ? 'subtitle-english--active' : '',
  props.align === 'left' ? 'intensive-english--left' : 'intensive-english--center',
])

async function loadGlosses() {
  const highlights = tokens.value.filter(
    (token) => token.kind === 'word' && isHighlightTokenHtml(token.html),
  )
  if (highlights.length === 0) return

  const next = new Map(glossMap.value)
  for (const token of highlights) {
    if (token.kind !== 'word') continue
    const word = wordFromTokenHtml(token.html)
    const key = glossKey(word)
    if (next.has(key) && !next.get(key)?.loading) continue
    next.set(key, { ipa: '', gloss: '', loading: true })
  }
  glossMap.value = next

  await Promise.all(
    highlights.map(async (token) => {
      if (token.kind !== 'word') return
      const word = wordFromTokenHtml(token.html)
      const key = glossKey(word)
      const type = tokenTypeFromHtml(token.html)
      const entry = await fetchWordLookup(word, type, props.context, props.lookupMeta ?? {})
      const current = glossMap.value.get(key)
      if (!current?.loading) return
      glossMap.value.set(key, {
        ipa: entry?.pronunciations?.[0]?.ipa?.trim() ?? '',
        gloss: entry?.definitions?.[0]?.definition_cn?.trim() || '…',
        loading: false,
      })
      glossMap.value = new Map(glossMap.value)
    }),
  )
}

watch(
  () => [props.html, props.context] as const,
  () => {
    glossMap.value = new Map()
    void loadGlosses()
  },
  { immediate: true },
)

function glossFor(html: string): GlossInfo | undefined {
  return glossMap.value.get(glossKey(wordFromTokenHtml(html)))
}
</script>

<template>
  <div :class="rootClass" @click="$emit('click', $event)">
    <template v-for="(token, i) in tokens" :key="i">
      <span v-if="token.kind === 'space'" class="intensive-token-space">{{ token.text }}</span>
      <span
        v-else-if="isHighlightTokenHtml(token.html)"
        class="intensive-gloss-unit"
      >
        <span class="intensive-gloss-word" v-html="token.html" />
        <span
          class="intensive-gloss-cn"
          :class="glossFor(token.html)?.loading ? 'opacity-40 animate-pulse' : ''"
        >
          {{ glossFor(token.html)?.gloss || '…' }}
        </span>
      </span>
      <span v-else class="intensive-plain-token" v-html="token.html" />
    </template>
  </div>
</template>
