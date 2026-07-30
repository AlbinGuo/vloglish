<script setup lang="ts">
import { computed } from 'vue'
import type { WordCardItem } from '@/composables/useEpisodeWordCards'
import type { WordCardPrintOptions } from '@/utils/wordCardPrint'

const props = defineProps<{
  title: string
  authorName?: string
  episodeIndex?: number
  items: WordCardItem[]
  options: WordCardPrintOptions | null
}>()

const ready = computed(() => Boolean(props.options && props.items.length))

function typeAndExam(item: WordCardItem) {
  const parts = [item.typeLabel, ...item.examTags.map((t) => t.label)].filter(Boolean)
  return parts.join(' · ')
}
</script>

<template>
  <Teleport to="body">
    <div
      v-if="ready && options"
      class="app-print-document wordcard-print-document"
      aria-hidden="true"
    >
      <header class="wordcard-print-header">
        <h1 class="wordcard-print-title">{{ title }}</h1>
        <p class="wordcard-print-meta">
          词卡
          <template v-if="authorName"> · {{ authorName }}</template>
          <template v-if="episodeIndex != null"> · 第 {{ episodeIndex }} 期</template>
          · 共 {{ items.length }} 词
        </p>
        <p class="wordcard-print-hint">
          {{ options.mode === 'quiz' ? '默写练习（释义留空）' : '完整词卡' }}
          <template v-if="options.includeAnswers"> · 含答案页</template>
        </p>
      </header>

      <section class="wordcard-print-section">
        <h2 class="wordcard-print-section-title">
          {{ options.mode === 'quiz' ? '练习' : '词卡' }}
        </h2>
        <ol class="wordcard-print-list">
          <li v-for="(item, index) in items" :key="`wc-${item.word}-${index}`" class="wordcard-print-item">
            <div class="wordcard-print-row">
              <span class="wordcard-print-index">{{ index + 1 }}.</span>
              <div class="wordcard-print-body">
                <p class="wordcard-print-word">
                  <span>{{ item.word }}</span>
                  <span v-if="item.ipa" class="wordcard-print-ipa">{{ item.ipa }}</span>
                </p>
                <p v-if="options.mode === 'full'" class="wordcard-print-meaning">
                  {{ item.meaning || '暂无释义' }}
                </p>
                <p v-else class="wordcard-print-blank-line" aria-hidden="true" />
                <p
                  v-if="options.mode === 'full' && typeAndExam(item)"
                  class="wordcard-print-tags"
                >
                  {{ typeAndExam(item) }}
                </p>
              </div>
            </div>
          </li>
        </ol>
      </section>

      <section
        v-if="options.includeAnswers"
        class="wordcard-print-section wordcard-print-answers"
      >
        <h2 class="wordcard-print-section-title">答案</h2>
        <ol class="wordcard-print-list">
          <li
            v-for="(item, index) in items"
            :key="`ans-${item.word}-${index}`"
            class="wordcard-print-item"
          >
            <div class="wordcard-print-row">
              <span class="wordcard-print-index">{{ index + 1 }}.</span>
              <div class="wordcard-print-body">
                <p class="wordcard-print-word">
                  <span>{{ item.word }}</span>
                  <span v-if="item.ipa" class="wordcard-print-ipa">{{ item.ipa }}</span>
                </p>
                <p class="wordcard-print-meaning">{{ item.meaning || '暂无释义' }}</p>
                <p v-if="typeAndExam(item)" class="wordcard-print-tags">{{ typeAndExam(item) }}</p>
                <p v-if="item.context" class="wordcard-print-tags">语境：{{ item.context }}</p>
              </div>
            </div>
          </li>
        </ol>
      </section>
    </div>
  </Teleport>
</template>
