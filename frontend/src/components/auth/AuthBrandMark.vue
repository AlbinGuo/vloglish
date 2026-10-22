<script setup lang="ts">
withDefaults(defineProps<{ size?: number }>(), { size: 40 })
</script>

<template>
  <span
    class="auth-vmark"
    :style="{ width: `${size}px`, height: `${size}px`, borderRadius: `${Math.round(size * 0.3)}px` }"
    aria-hidden="true"
  >
    <svg viewBox="0 0 32 32" class="h-[58%] w-[58%]" fill="none">
      <path d="M7.5 9.5h5l3.5 10.2L19.5 9.5h5l-6 15.2h-4.9L7.5 9.5Z" fill="#fff" />
    </svg>
  </span>
</template>
