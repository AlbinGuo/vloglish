<script setup lang="ts">
const expanded = defineModel<boolean>('expanded', { required: true })

function toggleExpanded() {
  expanded.value = !expanded.value
}
</script>

<template>
  <div
    class="relative min-h-0 self-stretch flex"
    :class="expanded ? 'flex-1 min-w-0' : 'shrink-0'"
  >
    <aside
      class="flex flex-col h-full min-h-0 border-l border-black/5 dark:border-white/10 bg-neutral-100 dark:bg-neutral-950 overflow-hidden transition-[width] duration-200 ease-out"
      :class="expanded ? 'flex-1 min-w-0 w-auto' : 'w-10'"
    >
      <div
        class="flex flex-col h-full min-h-0"
        :class="expanded ? 'w-full' : 'w-10'"
      >
        <div
          class="shrink-0 flex items-start gap-2 border-b border-black/5 dark:border-white/10 bg-neutral-100/80 dark:bg-neutral-950/80"
          :class="expanded ? 'px-3 pt-3 pb-2' : 'px-1 pt-2 pb-2 justify-center'"
        >
          <div v-if="expanded" class="min-w-0 flex-1 pr-1">
            <p class="text-sm font-semibold text-neutral-800 dark:text-neutral-100">段落</p>
            <p class="text-xs text-neutral-500 mt-0.5">逐段朗读 · 查词 · 重点词汇</p>
          </div>
          <button
            type="button"
            class="shrink-0 flex h-7 w-7 items-center justify-center rounded-md text-neutral-400 hover:text-neutral-700 dark:hover:text-neutral-200 hover:bg-black/5 dark:hover:bg-white/10 transition-colors"
            :class="expanded ? 'mt-0.5 ml-auto' : ''"
            :aria-label="expanded ? '收起段落栏' : '展开段落栏'"
            :aria-expanded="expanded"
            @click="toggleExpanded"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="16"
              height="16"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              stroke-linecap="round"
              stroke-linejoin="round"
              aria-hidden="true"
            >
              <path v-if="expanded" d="m9 18 6-6-6-6" />
              <path v-else d="m15 18-6-6 6-6" />
            </svg>
          </button>
        </div>

        <div v-show="expanded" class="flex-1 min-h-0 overflow-hidden">
          <slot />
        </div>
      </div>
    </aside>
  </div>
</template>
