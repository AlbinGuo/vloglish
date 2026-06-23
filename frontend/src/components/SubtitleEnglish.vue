<script setup lang="ts">
import { computed } from 'vue'

defineEmits<{ click: [event: MouseEvent] }>()

const props = withDefaults(
  defineProps<{
    html: string
    active?: boolean
    large?: boolean
    align?: 'left' | 'center'
    /** 0–1，设置后启用「文字渐深」双层渲染 */
    readProgress?: number
  }>(),
  { align: 'center' },
)

const readClipStyle = computed(() => ({
  clipPath: `inset(0 ${100 - (props.readProgress ?? 0) * 100}% 0 0)`,
}))

function layerClasses(layer: 'dim' | 'read' | 'normal') {
  return [
    'subtitle-english',
    layer === 'dim' ? 'subtitle-english-dim' : '',
    layer === 'read' ? 'subtitle-english-read' : '',
    'pointer-events-auto flex flex-wrap items-center gap-x-1.5 gap-y-0.5 leading-relaxed tracking-wide font-medium',
  ]
}
</script>

<template>
  <span
    v-if="readProgress != null"
    class="subtitle-english-progress relative inline-flex max-w-full"
    :class="align === 'left' ? 'justify-start w-full' : 'justify-center'"
  >
    <span
      :class="[
        ...layerClasses('dim'),
        align === 'left' ? 'justify-start w-full' : 'justify-center',
        large ? 'text-xl sm:text-2xl' : 'text-base',
      ]"
      v-html="html"
      aria-hidden="true"
    />
    <span
      :class="[
        ...layerClasses('read'),
        'absolute inset-0',
        align === 'left' ? 'justify-start' : 'justify-center',
        large ? 'text-xl sm:text-2xl' : 'text-base',
        active ? 'subtitle-english--active' : '',
      ]"
      :style="readClipStyle"
      v-html="html"
      @click="$emit('click', $event)"
    />
  </span>
  <span
    v-else
    :class="[
      ...layerClasses('normal'),
      align === 'left' ? 'justify-start w-full' : 'justify-center',
      large ? 'text-xl sm:text-2xl' : 'text-base',
      active ? 'subtitle-english--active' : '',
    ]"
    v-html="html"
    @click="$emit('click', $event)"
  />
</template>
