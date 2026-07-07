<script setup lang="ts">
withDefaults(
  defineProps<{
    orientation?: 'vertical' | 'horizontal'
  }>(),
  { orientation: 'vertical' },
)
</script>

<template>
  <div
    class="shrink-0 bg-black/10 dark:bg-white/10"
    :class="orientation === 'vertical' ? 'w-px self-stretch min-h-[2rem]' : 'h-px w-full my-1'"
    aria-hidden="true"
    role="separator"
  />
</template>
