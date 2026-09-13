<script setup lang="ts">
defineProps<{
  free: boolean
  compact?: boolean
}>()
</script>

<template>
  <span
    :class="
      compact
        ? free
          ? 'text-[10px] px-1.5 py-0.5 rounded bg-emerald-600/90 text-white font-semibold leading-none'
          : 'text-[10px] px-1.5 py-0.5 rounded bg-black/75 text-amber-200 font-semibold leading-none'
        : free
          ? 'text-sm px-2.5 py-1 rounded-md bg-emerald-600/90 text-white font-semibold tracking-wide shadow-md leading-none'
          : 'text-sm px-2.5 py-1 rounded-md bg-black/75 text-amber-200 font-semibold tracking-wide shadow-md backdrop-blur-[2px] leading-none'
    "
  >
    {{ free ? '免费' : '会员' }}
  </span>
</template>
