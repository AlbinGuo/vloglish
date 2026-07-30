<script setup lang="ts">
defineProps<{
  title: string
  subtitle?: string
  wordCount?: number
  highlightCount?: number
  segmentCount?: number
}>()
</script>

<template>
  <div class="intensive-stats-bar shrink-0 px-4 py-3 border-b">
    <div class="flex flex-wrap items-center gap-x-4 gap-y-1">
      <div class="min-w-0 flex-1">
        <p class="text-sm font-semibold truncate">{{ title }}</p>
        <p v-if="subtitle" class="text-xs opacity-80 truncate mt-0.5">{{ subtitle }}</p>
      </div>
      <div class="flex flex-wrap items-center gap-2 text-xs shrink-0">
        <span v-if="wordCount != null" class="intensive-stat-chip">单词 {{ wordCount }}</span>
        <span v-if="highlightCount != null" class="intensive-stat-chip">重点 {{ highlightCount }}</span>
        <span v-if="segmentCount != null" class="intensive-stat-chip">{{ segmentCount }} 段</span>
      </div>
    </div>
  </div>
</template>
