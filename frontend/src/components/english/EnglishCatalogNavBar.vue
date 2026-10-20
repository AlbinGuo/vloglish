<script setup lang="ts">
import EnglishNavTabs from '@/components/english/EnglishNavTabs.vue'
</script>

<template>
  <!-- 移动端主导航已迁移到底部 Tab Bar，此顶部菜单项默认隐藏 -->
  <div
    class="hidden border-b border-black/5 dark:border-white/10 bg-white/90 dark:bg-neutral-900/90 backdrop-blur"
  >
    <div class="page-container py-2">
      <EnglishNavTabs stretch />
    </div>
  </div>
</template>
