<script setup lang="ts">
import { computed } from 'vue'
import { resolveMediaUrl } from '@/utils/mediaUrl'

const props = defineProps<{
  cover?: string
  title?: string
}>()

const coverUrl = computed(() => {
  const raw = (props.cover || '').trim()
  return raw ? resolveMediaUrl(raw) : ''
})
</script>

<template>
  <div
    v-if="coverUrl"
    class="overflow-hidden rounded-xl bg-neutral-100 dark:bg-neutral-800 ring-1 ring-black/5 dark:ring-white/10"
  >
    <img
      :src="coverUrl"
      :alt="title || '文章封面'"
      class="w-full aspect-[16/9] object-cover"
      loading="lazy"
    />
  </div>
</template>
