<script setup lang="ts">
import { computed } from 'vue'
import { useTheme } from '@/composables/useTheme'
import { renderThemedRichText } from '@/utils/renderRichText'

const props = defineProps<{
  content: string
}>()

const { resolvedTheme } = useTheme()
const html = computed(() => renderThemedRichText(props.content))
const hasContent = computed(() => Boolean(html.value))
const isDark = computed(() => resolvedTheme.value === 'dark')
</script>

<template>
  <div class="flex-1 min-h-0 overflow-y-auto overscroll-contain px-4 py-4 sm:px-6 sm:py-5">
    <div
      v-if="hasContent"
      class="video-context-prose max-w-3xl mx-auto text-sm sm:text-base leading-relaxed"
      :class="isDark ? 'video-context-prose--dark' : 'video-context-prose--light'"
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
