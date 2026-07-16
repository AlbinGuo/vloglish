<script setup lang="ts">
import { computed } from 'vue'
import type { Subtitle } from '@/types'
import type { BlankPrintOptions } from '@/utils/blankPrint'
import { preprocessSubtitleHtml, stripSpeakerMarkers } from '@/utils/subtitleHtml'

const props = defineProps<{
  title: string
  authorName?: string
  episodeIndex?: number
  subtitles: Subtitle[]
  options: BlankPrintOptions | null
}>()

const ready = computed(() => Boolean(props.options && props.subtitles.length))

function blankHtml(html: string) {
  return preprocessSubtitleHtml(html || '', { blank: true })
}

function plainEnglish(sub: Subtitle) {
  return stripSpeakerMarkers(sub.english || '')
}

function plainChinese(sub: Subtitle) {
  return stripSpeakerMarkers(sub.chinese || '')
}
</script>

<template>
  <Teleport to="body">
    <div
      v-if="ready && options"
      class="blank-print-document"
      aria-hidden="true"
    >
      <header class="blank-print-header">
        <h1 class="blank-print-title">{{ title }}</h1>
        <p class="blank-print-meta">
          挖空练习
          <template v-if="authorName"> · {{ authorName }}</template>
          <template v-if="episodeIndex != null"> · 第 {{ episodeIndex }} 期</template>
          · 共 {{ subtitles.length }} 句
        </p>
        <p class="blank-print-hint">
          {{ options.hintMode === 'with-chinese' ? '带中文提示' : '仅英文挖空' }}
          · 下划线处为需填写的重点词
        </p>
      </header>

      <section class="blank-print-section">
        <h2 class="blank-print-section-title">练习</h2>
        <ol class="blank-print-list">
          <li v-for="sub in subtitles" :key="`blank-${sub.id}`" class="blank-print-item">
            <div
              class="blank-print-english blank-print-english--blank"
              v-html="blankHtml(sub.english_html || sub.english)"
            />
            <p
              v-if="options.hintMode === 'with-chinese' && plainChinese(sub)"
              class="blank-print-chinese"
            >
              {{ plainChinese(sub) }}
            </p>
          </li>
        </ol>
      </section>

      <section v-if="options.includeAnswers" class="blank-print-section blank-print-answers">
        <h2 class="blank-print-section-title">答案</h2>
        <ol class="blank-print-list">
          <li v-for="sub in subtitles" :key="`ans-${sub.id}`" class="blank-print-item">
            <p class="blank-print-english">{{ plainEnglish(sub) }}</p>
            <p v-if="plainChinese(sub)" class="blank-print-chinese">{{ plainChinese(sub) }}</p>
          </li>
        </ol>
      </section>
    </div>
  </Teleport>
</template>
