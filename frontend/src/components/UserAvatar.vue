<script setup lang="ts">
import { computed } from 'vue'
import { avatarSrc } from '@/utils/defaultAvatars'

const props = withDefaults(
  defineProps<{
    avatarKey?: string | null
    userId?: number
    sizeClass?: string
    alt?: string
  }>(),
  {
    avatarKey: '',
    userId: 0,
    sizeClass: 'w-9 h-9',
    alt: '头像',
  },
)

const src = computed(() => avatarSrc(props.avatarKey, props.userId))
</script>

<template>
  <img
    :src="src"
    :alt="alt"
    class="rounded-full object-cover bg-neutral-200 dark:bg-neutral-700 shrink-0"
    :class="sizeClass"
    draggable="false"
  />
</template>
