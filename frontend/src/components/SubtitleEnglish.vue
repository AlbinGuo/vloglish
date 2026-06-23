<script setup lang="ts">
defineEmits<{ click: [event: MouseEvent] }>()

withDefaults(
  defineProps<{
    html: string
    active?: boolean
    large?: boolean
    align?: 'left' | 'center'
  }>(),
  { align: 'center' },
)
</script>

<template>
  <span
    class="subtitle-english pointer-events-auto flex flex-wrap items-center gap-x-1.5 gap-y-0.5 leading-relaxed tracking-wide font-medium"
    :class="[
      align === 'left' ? 'justify-start w-full' : 'justify-center',
      large ? 'text-xl sm:text-2xl' : 'text-base',
      active ? 'subtitle-english--active' : '',
    ]"
    v-html="html"
    @click="$emit('click', $event)"
  />
</template>
