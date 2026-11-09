<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { resolveMediaUrl } from '@/utils/mediaUrl'

const props = withDefaults(
  defineProps<{
    src?: string
    name?: string
    /** 直径（px） */
    size?: number
  }>(),
  { src: '', name: '', size: 24 },
)

const failed = ref(false)
watch(
  () => props.src,
  () => {
    failed.value = false
  },
)

const resolvedSrc = computed(() => resolveMediaUrl((props.src || '').trim()))
const showImg = computed(() => Boolean(resolvedSrc.value) && !failed.value)

const initial = computed(() => {
  const n = (props.name || '').trim()
  if (!n) return '?'
  const ch = Array.from(n)[0] || '?'
  return /[a-zA-Z]/.test(ch) ? ch.toUpperCase() : ch
})

/** 用名字哈希生成稳定的渐变，作为默认头像配色 */
const fallbackStyle = computed(() => {
  const n = (props.name || '?').trim() || '?'
  let h = 0
  for (let i = 0; i < n.length; i++) h = (h * 31 + n.charCodeAt(i)) % 360
  return {
    width: `${props.size}px`,
    height: `${props.size}px`,
    fontSize: `${Math.max(10, Math.round(props.size * 0.42))}px`,
    background: `linear-gradient(135deg, hsl(${h} 62% 54%), hsl(${(h + 42) % 360} 68% 44%))`,
  }
})

const imgStyle = computed(() => ({
  width: `${props.size}px`,
  height: `${props.size}px`,
}))
</script>

<template>
  <img
    v-if="showImg"
    :src="resolvedSrc"
    :alt="name"
    :style="imgStyle"
    class="shrink-0 rounded-full object-cover bg-sunken"
    loading="lazy"
    @error="failed = true"
  />
  <span
    v-else
    :style="fallbackStyle"
    class="shrink-0 inline-grid place-items-center rounded-full text-white font-semibold select-none leading-none"
    aria-hidden="true"
  >
    {{ initial }}
  </span>
</template>
