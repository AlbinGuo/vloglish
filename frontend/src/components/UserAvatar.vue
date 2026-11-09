<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { avatarSrc } from '@/utils/defaultAvatars'
import { resolveMediaUrl } from '@/utils/mediaUrl'

const props = withDefaults(
  defineProps<{
    avatarKey?: string | null
    /** 自定义头像 URL，优先于 avatarKey */
    avatarUrl?: string | null
    userId?: number
    sizeClass?: string
    alt?: string
  }>(),
  {
    avatarKey: '',
    avatarUrl: '',
    userId: 0,
    sizeClass: 'w-9 h-9',
    alt: '头像',
  },
)

const failed = ref(false)
watch(
  () => props.avatarUrl,
  () => {
    failed.value = false
  },
)

const hasCustom = computed(() => Boolean((props.avatarUrl || '').trim()) && !failed.value)
const customSrc = computed(() => resolveMediaUrl((props.avatarUrl || '').trim()))
const src = computed(() => (hasCustom.value ? customSrc.value : avatarSrc(props.avatarKey, props.userId)))
</script>

<template>
  <img
    :src="src"
    :alt="alt"
    class="rounded-full object-cover bg-neutral-200 dark:bg-neutral-700 shrink-0"
    :class="sizeClass"
    draggable="false"
    @error="failed = true"
  />
</template>
