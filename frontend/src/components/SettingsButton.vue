<script setup lang="ts">
import AppIcon from '@/components/AppIcon.vue'
defineEmits<{ click: [] }>()
</script>

<template>
  <button
    type="button"
    class="inline-flex items-center justify-center w-8 h-8 rounded-lg text-ink-faint hover:text-black hover:bg-sunken dark:hover:text-white transition-colors"
    aria-label="设置"
    @click="$emit('click')"
  >
    <AppIcon name="settings" :size="20" />
  </button>
</template>
