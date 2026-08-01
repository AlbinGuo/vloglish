<script setup lang="ts">
import { computed } from 'vue'
import { renderRichText } from '@/utils/renderRichText'

const props = defineProps<{
  content: string
}>()

const html = computed(() => renderRichText(props.content))
const hasContent = computed(() => Boolean(html.value))
</script>

<template>
  <div class="flex-1 min-h-0 overflow-y-auto overscroll-contain px-4 py-4 sm:px-6 sm:py-5">
    <div
      v-if="hasContent"
      class="video-context-prose max-w-3xl mx-auto text-sm sm:text-base leading-relaxed text-neutral-800 dark:text-neutral-200"
      v-html="html"
    />
    <p
      v-else
      class="text-sm text-neutral-400 dark:text-neutral-500 text-center py-12"
    >
      暂无视频语境
    </p>
  </div>
</template>

<style scoped>
.video-context-prose :deep(h1),
.video-context-prose :deep(h2),
.video-context-prose :deep(h3),
.video-context-prose :deep(h4) {
  font-weight: 600;
  color: inherit;
  margin: 1.25em 0 0.5em;
  line-height: 1.3;
}
.video-context-prose :deep(h1) {
  font-size: 1.35em;
}
.video-context-prose :deep(h2) {
  font-size: 1.2em;
}
.video-context-prose :deep(h3) {
  font-size: 1.1em;
}
.video-context-prose :deep(p) {
  margin: 0.65em 0;
}
.video-context-prose :deep(ul),
.video-context-prose :deep(ol) {
  margin: 0.65em 0;
  padding-left: 1.4em;
}
.video-context-prose :deep(li) {
  margin: 0.25em 0;
}
.video-context-prose :deep(a) {
  color: #2563eb;
  text-decoration: underline;
  text-underline-offset: 2px;
}
:global(.dark) .video-context-prose :deep(a) {
  color: #93c5fd;
}
.video-context-prose :deep(blockquote) {
  margin: 0.85em 0;
  padding-left: 0.9em;
  border-left: 3px solid rgba(0, 0, 0, 0.12);
  color: rgba(0, 0, 0, 0.65);
}
:global(.dark) .video-context-prose :deep(blockquote) {
  border-left-color: rgba(255, 255, 255, 0.2);
  color: rgba(255, 255, 255, 0.7);
}
.video-context-prose :deep(pre) {
  margin: 0.85em 0;
  padding: 0.75em 1em;
  overflow-x: auto;
  border-radius: 0.5rem;
  background: rgba(0, 0, 0, 0.04);
  font-size: 0.875em;
}
:global(.dark) .video-context-prose :deep(pre) {
  background: rgba(255, 255, 255, 0.06);
}
.video-context-prose :deep(code) {
  font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
  font-size: 0.9em;
}
.video-context-prose :deep(:not(pre) > code) {
  padding: 0.1em 0.35em;
  border-radius: 0.25rem;
  background: rgba(0, 0, 0, 0.05);
}
:global(.dark) .video-context-prose :deep(:not(pre) > code) {
  background: rgba(255, 255, 255, 0.08);
}
.video-context-prose :deep(img) {
  max-width: 100%;
  height: auto;
  border-radius: 0.5rem;
  margin: 0.85em 0;
}
.video-context-prose :deep(hr) {
  margin: 1.25em 0;
  border: 0;
  border-top: 1px solid rgba(0, 0, 0, 0.1);
}
:global(.dark) .video-context-prose :deep(hr) {
  border-top-color: rgba(255, 255, 255, 0.12);
}
.video-context-prose :deep(table) {
  width: 100%;
  border-collapse: collapse;
  margin: 0.85em 0;
  font-size: 0.95em;
}
.video-context-prose :deep(th),
.video-context-prose :deep(td) {
  border: 1px solid rgba(0, 0, 0, 0.1);
  padding: 0.4em 0.6em;
  text-align: left;
}
:global(.dark) .video-context-prose :deep(th),
:global(.dark) .video-context-prose :deep(td) {
  border-color: rgba(255, 255, 255, 0.12);
}
</style>
