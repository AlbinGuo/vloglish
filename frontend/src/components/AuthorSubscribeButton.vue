<script setup lang="ts">
import { toRef } from 'vue'
import { useAuthorSubscribe } from '@/composables/useAuthorSubscribe'

const props = withDefaults(
  defineProps<{
    authorId?: number
    isSubscribed?: boolean
    subscriberCount?: number
    compact?: boolean
    listenChip?: boolean
    showCount?: boolean
  }>(),
  {
    authorId: 0,
    isSubscribed: false,
    subscriberCount: 0,
    compact: false,
    listenChip: false,
    showCount: false,
  },
)

const emit = defineEmits<{
  'update:isSubscribed': [value: boolean]
  'update:subscriberCount': [value: number]
}>()

const { subscribed, subscriberCount, loading, toggle, label } = useAuthorSubscribe(
  toRef(props, 'authorId'),
  toRef(props, 'isSubscribed'),
  toRef(props, 'subscriberCount'),
)

async function onToggle() {
  const ok = await toggle()
  if (!ok) return
  emit('update:isSubscribed', subscribed.value)
  emit('update:subscriberCount', subscriberCount.value)
}
</script>

<template>
  <button
    type="button"
    :disabled="loading || !authorId"
    :aria-pressed="subscribed"
    :title="subscribed ? '取消关注，将不再单独通知该作者上新' : '关注后，作者上新会通知你'"
    :class="
      listenChip
        ? 'listen-follow-chip inline-flex items-center justify-center shrink-0 text-[11px] font-medium leading-none disabled:opacity-50'
        : compact
          ? [
              'inline-flex items-center justify-center shrink-0 rounded-full text-[11px] font-medium px-2 py-0.5 leading-none border transition-colors disabled:opacity-50',
              subscribed
                ? 'border-line-strong text-ink-faint'
                : 'border-amber-500/80 bg-amber-500 text-white hover:bg-amber-600',
            ]
          : [
              'inline-flex items-center justify-center gap-1.5 rounded-full text-sm font-medium px-4 py-2 transition-colors disabled:opacity-50',
              subscribed
                ? 'border border-line-strong text-ink-soft hover:bg-sunken'
                : 'bg-amber-600 text-white hover:bg-amber-700',
            ]
    "
    @click.stop="onToggle"
  >
    {{ label }}
    <span v-if="showCount && subscriberCount > 0" class="font-normal opacity-80">
      · {{ subscriberCount }}
    </span>
  </button>
</template>

<style scoped>
.listen-follow-chip {
  border-radius: 4px;
  padding: 6px 8px;
  background: #cfcfc96e;
  border: 0;
  color: inherit;
}
</style>
