<script setup lang="ts">
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
    <svg
      :width="size"
      :height="size"
      viewBox="0 0 32 32"
      xmlns="http://www.w3.org/2000/svg"
      class="block"
    >
      <circle cx="16" cy="16" r="16" class="fill-neutral-900 dark:fill-white" />
      <path
        d="M10.2 9.6h3.05l2.55 8.35L18.35 9.6h3.05L16.95 23.1h-1.9L10.2 9.6Z"
        class="fill-white dark:fill-neutral-900"
      />
    </svg>
  </span>
</template>
