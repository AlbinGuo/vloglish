<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref, watch } from 'vue'

const props = withDefaults(
  defineProps<{
    align?: 'left' | 'center'
    shadowActive?: boolean
    hasShadowTrack?: boolean
    dictationActive?: boolean
    /** 容器宽度低于此值时收成「练习」菜单 */
    compactBelow?: number
  }>(),
  {
    align: 'center',
    shadowActive: false,
    hasShadowTrack: false,
    dictationActive: false,
    compactBelow: 440,
  },
)

const emit = defineEmits<{
  explain: [e: MouseEvent]
  shadowing: [e: MouseEvent]
  shadow: [e: MouseEvent]
  cloze: [e: MouseEvent]
  dictation: [e: MouseEvent]
}>()

const rootRef = ref<HTMLElement | null>(null)
const menuRef = ref<HTMLElement | null>(null)
const width = ref(9999)
const menuOpen = ref(false)
let ro: ResizeObserver | null = null

const compact = computed(() => width.value < props.compactBelow)

const justifyClass = computed(() =>
  props.align === 'left' ? 'justify-start' : 'justify-end',
)

const shadowBtnClass = computed(() => {
  if (props.shadowActive) {
    return 'border-teal-500 bg-teal-50 text-teal-800 ring-2 ring-teal-400/30 dark:border-teal-500 dark:bg-teal-950/50 dark:text-teal-200'
  }
  if (props.hasShadowTrack) {
    return 'border-teal-300/80 text-teal-700 dark:border-teal-700 dark:text-teal-300'
  }
  return ''
})

const btnBase =
  'inline-flex items-center gap-1 px-2 h-7 rounded-full text-[11px] font-medium border transition bg-white/90 border-black/10 text-neutral-600 dark:bg-neutral-800/90 dark:border-white/10 dark:text-neutral-300 touch-manipulation'

const menuItemBase =
  'w-full flex items-center justify-between gap-3 px-3 py-2 text-left text-[13px] text-neutral-700 hover:bg-neutral-100 dark:text-neutral-200 dark:hover:bg-neutral-800 transition'

function measure() {
  const el = rootRef.value
  if (!el) return
  width.value = el.clientWidth
}

function toggleMenu(e: MouseEvent) {
  e.stopPropagation()
  e.preventDefault()
  menuOpen.value = !menuOpen.value
}

function closeMenu() {
  menuOpen.value = false
}

function onDocPointerDown(e: Event) {
  if (!menuOpen.value) return
  const t = e.target as Node | null
  if (menuRef.value?.contains(t) || rootRef.value?.contains(t)) return
  closeMenu()
}

function fire(kind: 'explain' | 'shadowing' | 'shadow' | 'cloze' | 'dictation', e: MouseEvent) {
  e.stopPropagation()
  e.preventDefault()
  closeMenu()
  emit(kind, e)
}

watch(compact, () => {
  closeMenu()
})

onMounted(() => {
  measure()
  if (typeof ResizeObserver !== 'undefined' && rootRef.value) {
    ro = new ResizeObserver(() => measure())
    ro.observe(rootRef.value)
  }
  document.addEventListener('pointerdown', onDocPointerDown, true)
})

onUnmounted(() => {
  ro?.disconnect()
  ro = null
  document.removeEventListener('pointerdown', onDocPointerDown, true)
})
</script>

<template>
  <div
    ref="rootRef"
    class="relative w-full flex flex-wrap items-center gap-1 mb-1.5"
    :class="justifyClass"
    @click.stop
  >
    <!-- 窄栏：收成「练习」菜单 -->
    <div v-if="compact" ref="menuRef" class="relative">
      <button
        type="button"
        class="inline-flex items-center gap-1 px-2.5 h-7 rounded-full text-[11px] font-medium border transition bg-white/90 border-black/10 text-neutral-600 hover:border-neutral-400 dark:bg-neutral-800/90 dark:border-white/10 dark:text-neutral-300 dark:hover:border-neutral-500"
        :class="
          shadowActive || hasShadowTrack || dictationActive
            ? 'border-teal-400/70 text-teal-700 dark:border-teal-600 dark:text-teal-300'
            : ''
        "
        :aria-expanded="menuOpen"
        aria-haspopup="menu"
        @click="toggleMenu"
      >
        练习
        <svg
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 20 20"
          fill="currentColor"
          class="w-3.5 h-3.5 opacity-70 transition-transform"
          :class="menuOpen ? 'rotate-180' : ''"
          aria-hidden="true"
        >
          <path
            fill-rule="evenodd"
            d="M5.23 7.21a.75.75 0 0 1 1.06.02L10 11.17l3.71-3.94a.75.75 0 1 1 1.08 1.04l-4.25 4.5a.75.75 0 0 1-1.08 0l-4.25-4.5a.75.75 0 0 1 .02-1.06Z"
            clip-rule="evenodd"
          />
        </svg>
        <span
          v-if="hasShadowTrack"
          class="w-1.5 h-1.5 rounded-full bg-teal-500"
          aria-hidden="true"
        />
      </button>
      <div
        v-if="menuOpen"
        role="menu"
        class="absolute right-0 top-full mt-1 z-30 min-w-[10.5rem] rounded-xl border border-black/10 dark:border-white/10 bg-white dark:bg-neutral-900 shadow-lg shadow-black/10 py-1 overflow-hidden"
      >
        <button type="button" role="menuitem" :class="menuItemBase" @click="fire('explain', $event)">
          AI讲解
        </button>
        <button type="button" role="menuitem" :class="menuItemBase" @click="fire('shadowing', $event)">
          <span>AI跟读</span>
          <span class="px-1 py-px rounded text-[9px] font-semibold leading-none bg-sky-100 text-sky-800 dark:bg-sky-950/60 dark:text-sky-300">
            评分
          </span>
        </button>
        <button
          type="button"
          role="menuitem"
          :class="[menuItemBase, shadowActive ? 'bg-teal-50 dark:bg-teal-950/40' : '']"
          @click="fire('shadow', $event)"
        >
          <span>影子跟读</span>
          <span
            v-if="hasShadowTrack"
            class="w-1.5 h-1.5 rounded-full bg-teal-500"
            aria-hidden="true"
          />
        </button>
        <button type="button" role="menuitem" :class="menuItemBase" @click="fire('cloze', $event)">
          AI挖空
        </button>
        <button
          type="button"
          role="menuitem"
          :class="[menuItemBase, dictationActive ? 'bg-amber-50 dark:bg-amber-950/40' : '']"
          @click="fire('dictation', $event)"
        >
          听写
        </button>
      </div>
    </div>

    <!-- 宽栏：展开按钮组 -->
    <template v-else>
      <button
        type="button"
        :class="[btnBase, 'hover:border-violet-400 hover:text-violet-700 dark:hover:border-violet-500']"
        title="AI 讲解本句"
        @click="fire('explain', $event)"
      >
        AI讲解
      </button>
      <button
        type="button"
        :class="[btnBase, 'hover:border-sky-400 hover:text-sky-700 dark:hover:border-sky-500 dark:hover:text-sky-300']"
        title="AI 跟读评分"
        @click="fire('shadowing', $event)"
      >
        AI跟读
        <span class="px-1 py-px rounded text-[9px] font-semibold leading-none bg-sky-100 text-sky-800 dark:bg-sky-950/60 dark:text-sky-300">
          评分
        </span>
      </button>
      <button
        type="button"
        :class="[
          btnBase,
          'px-2.5 min-h-8 hover:border-teal-400 hover:text-teal-700 dark:hover:border-teal-500 dark:hover:text-teal-300',
          shadowBtnClass,
        ]"
        title="影子跟读：边听边说"
        :aria-pressed="shadowActive"
        @click="fire('shadow', $event)"
      >
        <span class="sm:hidden">影子</span>
        <span class="hidden sm:inline">影子跟读</span>
        <span
          v-if="hasShadowTrack"
          class="w-1.5 h-1.5 rounded-full bg-teal-500"
          aria-hidden="true"
        />
      </button>
      <button
        type="button"
        :class="[btnBase, 'hover:border-emerald-400 hover:text-emerald-700']"
        title="AI 挖空练习"
        @click="fire('cloze', $event)"
      >
        AI挖空
      </button>
      <button
        type="button"
        :class="[
          btnBase,
          'hover:border-amber-400 hover:text-amber-700 dark:hover:border-amber-500 dark:hover:text-amber-300',
          dictationActive ? 'border-amber-400 text-amber-700 dark:border-amber-500 dark:text-amber-300' : '',
        ]"
        title="听写本句"
        @click="fire('dictation', $event)"
      >
        听写
      </button>
    </template>
  </div>
</template>
