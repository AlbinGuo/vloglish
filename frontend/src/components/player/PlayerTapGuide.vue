<script setup lang="ts">
defineEmits<{ dismiss: [] }>()

const items = [
  { key: 'left', title: '点按左侧', action: '上一句' },
  { key: 'middle', title: '点按中间', action: '播放 / 暂停' },
  { key: 'right', title: '点按右侧', action: '下一句' },
] as const
</script>

<template>
  <div
    class="absolute inset-0 z-40 flex flex-col items-center justify-center bg-black/65 px-2 text-white"
    role="dialog"
    aria-label="播放器手势指引"
    @click.stop="$emit('dismiss')"
    @pointerdown.stop
  >
    <div class="grid w-full max-w-md grid-cols-3 gap-1 text-center">
      <div v-for="it in items" :key="it.key" class="flex flex-col items-center gap-1.5">
        <span
          class="flex h-12 w-12 items-center justify-center rounded-full border border-white/45 text-white/90"
        >
          <svg
            viewBox="0 0 24 24"
            class="h-7 w-7"
            fill="none"
            stroke="currentColor"
            stroke-width="1.5"
            stroke-linecap="round"
            stroke-linejoin="round"
            aria-hidden="true"
          >
            <path d="M9 12V6.5a1.5 1.5 0 0 1 3 0V11" />
            <path d="M12 11V9a1.5 1.5 0 0 1 3 0v2" />
            <path d="M15 11v-1a1.5 1.5 0 0 1 3 0v4a6 6 0 0 1-6 6h-1a5 5 0 0 1-4-2l-2.4-3.2a1.6 1.6 0 0 1 2.5-2L9 15" />
          </svg>
        </span>
        <p class="text-[12px] font-medium leading-tight text-white">{{ it.title }}</p>
        <p class="text-[12px] font-semibold leading-tight text-emerald-400">{{ it.action }}</p>
      </div>
    </div>
    <p class="mt-4 text-[11px] text-white/65">点按任意处开始</p>
  </div>
</template>
