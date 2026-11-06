<script setup lang="ts">
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import AppIcon from '@/components/AppIcon.vue'
import { navigateBack } from '@/utils/navigation'

const props = withDefaults(
  defineProps<{
    /** 没有可回退历史时的兜底路由 */
    fallback?: string
    /** 可选文案，例如“生词本”；不传则只显示箭头 */
    label?: string
    /** ghost：浅色文字按钮；solid：深色半透明圆形浮层按钮 */
    variant?: 'ghost' | 'solid'
  }>(),
  {
    fallback: '/english',
    label: '',
    variant: 'ghost',
  },
)

const router = useRouter()

const labelText = computed(() => props.label.trim())

function goBack() {
  navigateBack(router, props.fallback)
}
</script>

<template>
  <button
    type="button"
    :class="[
      'inline-flex shrink-0 items-center gap-1 rounded-full transition active:scale-95',
      variant === 'solid'
        ? 'h-9 w-9 justify-center bg-black/35 text-white backdrop-blur-sm hover:bg-black/45'
        : '-ml-1 rounded-lg px-2 py-1.5 text-ink-soft hover:bg-sunken hover:text-ink',
    ]"
    aria-label="返回上一级"
    @click="goBack"
  >
    <AppIcon name="chevron-left" class="h-5 w-5 shrink-0" />
    <span v-if="labelText" class="text-sm font-medium leading-none">{{ labelText }}</span>
  </button>
</template>
