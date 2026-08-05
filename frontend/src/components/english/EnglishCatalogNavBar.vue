<script setup lang="ts">
import EnglishNavTabs from '@/components/english/EnglishNavTabs.vue'
</script>

<template>
  <!-- 仅手机：紧贴全局顶栏；PC 仍用页内原 Tab -->
  <div
    class="sm:hidden border-b border-black/5 dark:border-white/10 bg-white/90 dark:bg-neutral-900/90 backdrop-blur"
  >
    <div class="page-container py-2">
      <EnglishNavTabs stretch />
    </div>
  </div>
</template>
