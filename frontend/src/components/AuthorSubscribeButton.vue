<script setup lang="ts">
import { toRef } from 'vue'
import { useAuthorSubscribe } from '@/composables/useAuthorSubscribe'

const props = withDefaults(
  defineProps<{
    authorId?: number
    isSubscribed?: boolean
    subscriberCount?: number
    compact?: boolean
    showCount?: boolean
  }>(),
  {
    authorId: 0,
    isSubscribed: false,
    subscriberCount: 0,
    compact: false,
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
      compact
        ? [
            'inline-flex items-center justify-center shrink-0 rounded-full text-[11px] font-medium px-2 py-0.5 leading-none border transition-colors disabled:opacity-50',
            subscribed
              ? 'border-black/10 text-neutral-500 dark:border-white/15 dark:text-neutral-400'
              : 'border-amber-500/80 bg-amber-500 text-white hover:bg-amber-600',
          ]
        : [
            'inline-flex items-center justify-center gap-1.5 rounded-full text-sm font-medium px-4 py-2 transition-colors disabled:opacity-50',
            subscribed
              ? 'border border-black/10 text-neutral-600 hover:bg-neutral-50 dark:border-white/15 dark:text-neutral-300 dark:hover:bg-neutral-800'
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
