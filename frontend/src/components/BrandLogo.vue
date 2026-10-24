<script setup lang="ts">
import AppIcon from '@/components/AppIcon.vue'
withDefaults(
  defineProps<{
    size?: number
  }>(),
  { size: 32 },
)
</script>

<template>
  <!-- 几何 V 商标：自定义字型 + 细描边，避免系统字体“贴纸感” -->
  <span
    class="inline-flex shrink-0 select-none rounded-full shadow-[0_0_0_1px_rgba(0,0,0,0.06),0_1px_2px_rgba(0,0,0,0.04)] dark:shadow-[0_0_0_1px_rgba(255,255,255,0.12),0_1px_2px_rgba(0,0,0,0.35)]"
    :style="{ width: `${size}px`, height: `${size}px` }"
    aria-hidden="true"
  >
    <AppIcon name="brand-mark" class="block" />
  </span>
</template>
