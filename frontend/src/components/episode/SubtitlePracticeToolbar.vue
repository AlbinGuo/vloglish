<script setup lang="ts">
import { computed, nextTick, onMounted, onUnmounted, ref, watch } from 'vue'

const props = withDefaults(
  defineProps<{
    align?: 'left' | 'center'
    shadowActive?: boolean
    hasShadowTrack?: boolean
    dictationActive?: boolean
    /**
     * responsive：宽栏展开文案按钮，窄栏收成「练习」菜单（桌面）
     * inline-row：始终在字幕下方横排展示；一行放不下则只显示图标（手机）
     */
    variant?: 'responsive' | 'inline-row'
    /** responsive 下容器宽度低于此值时收成「练习」菜单 */
    compactBelow?: number
  }>(),
  {
    align: 'center',
    shadowActive: false,
    hasShadowTrack: false,
    dictationActive: false,
    variant: 'responsive',
    compactBelow: 440,
  },
)

const emit = defineEmits<{
  explain: [e: MouseEvent]
  shadowing: [e: MouseEvent]
  shadow: [e: MouseEvent]
  cloze: [e: MouseEvent]
  dictation: [e: MouseEvent]
  menuOpenChange: [open: boolean]
}>()

type ActionKind = 'explain' | 'shadowing' | 'shadow' | 'cloze' | 'dictation'

const rootRef = ref<HTMLElement | null>(null)
const probeRef = ref<HTMLElement | null>(null)
const menuRef = ref<HTMLElement | null>(null)
const width = ref(9999)
const iconsOnly = ref(false)
const menuOpen = ref(false)
let ro: ResizeObserver | null = null

const isInlineRow = computed(() => props.variant === 'inline-row')
const compactMenu = computed(
  () => !isInlineRow.value && width.value < props.compactBelow,
)

const justifyClass = computed(() => {
  if (props.align === 'left') return 'justify-start'
  if (isInlineRow.value) return 'justify-center'
  return 'justify-end'
})

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
  'inline-flex items-center justify-center gap-1 h-7 rounded-full text-[11px] font-medium border transition bg-white/90 border-black/10 text-neutral-600 dark:bg-neutral-800/90 dark:border-white/10 dark:text-neutral-300 touch-manipulation shrink-0'

const menuItemBase =
  'w-full flex items-center justify-between gap-3 px-3 py-2 text-left text-[13px] text-neutral-700 hover:bg-neutral-100 dark:text-neutral-200 dark:hover:bg-neutral-800 transition'

function measureWidth() {
  const el = rootRef.value
  if (!el) return
  width.value = el.clientWidth
}

function measureIconsOnly() {
  if (!isInlineRow.value) {
    iconsOnly.value = false
    return
  }
  const root = rootRef.value
  const probe = probeRef.value
  if (!root || !probe) return
  iconsOnly.value = probe.scrollWidth > root.clientWidth + 1
}

function measure() {
  measureWidth()
  void nextTick(measureIconsOnly)
}

function setMenuOpen(open: boolean) {
  if (menuOpen.value === open) return
  menuOpen.value = open
  emit('menuOpenChange', open)
}

function toggleMenu(e: MouseEvent) {
  e.stopPropagation()
  e.preventDefault()
  setMenuOpen(!menuOpen.value)
}

function closeMenu() {
  setMenuOpen(false)
}

function onDocPointerDown(e: Event) {
  if (!menuOpen.value) return
  const t = e.target as Node | null
  if (menuRef.value?.contains(t) || rootRef.value?.contains(t)) return
  closeMenu()
}

function fire(kind: ActionKind, e: MouseEvent) {
  e.stopPropagation()
  e.preventDefault()
  closeMenu()
  emit(kind, e)
}

watch([() => props.variant, () => props.align], () => {
  closeMenu()
  measure()
})

watch(compactMenu, () => {
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
    class="relative flex flex-nowrap items-center gap-1"
    :class="[
      isInlineRow ? ['w-full mt-1.5', justifyClass] : ['w-full mb-1.5 flex-wrap', justifyClass],
      menuOpen ? 'z-50' : '',
    ]"
    @click.stop
  >
    <!-- 测量用：完整文案宽度，判断能否单行放下 -->
    <div
      v-if="isInlineRow"
      ref="probeRef"
      class="absolute left-0 top-0 -z-10 flex items-center gap-1 opacity-0 pointer-events-none whitespace-nowrap"
      aria-hidden="true"
    >
      <span :class="[btnBase, 'px-2']">AI讲解</span>
      <span :class="[btnBase, 'px-2']">
        AI跟读
        <span class="px-1 py-px rounded text-[9px] font-semibold leading-none bg-sky-100 text-sky-800">评分</span>
      </span>
      <span :class="[btnBase, 'px-2.5']">影子跟读</span>
      <span :class="[btnBase, 'px-2.5']">
        练习
        <svg class="w-3.5 h-3.5" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
          <path
            fill-rule="evenodd"
            d="M5.23 7.21a.75.75 0 0 1 1.06.02L10 11.17l3.71-3.94a.75.75 0 1 1 1.08 1.04l-4.25 4.5a.75.75 0 0 1-1.08 0l-4.25-4.5a.75.75 0 0 1 .02-1.06Z"
            clip-rule="evenodd"
          />
        </svg>
      </span>
    </div>

    <!-- 手机：字幕下方横排；挖空/听写收进「练习」菜单 -->
    <template v-if="isInlineRow">
      <button
        type="button"
        :class="[btnBase, iconsOnly ? 'w-7 px-0' : 'px-2', 'hover:border-violet-400 hover:text-violet-700 dark:hover:border-violet-500']"
        title="AI 讲解本句"
        aria-label="AI讲解"
        @click="fire('explain', $event)"
      >
        <svg class="w-3.5 h-3.5 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
          <path stroke-linecap="round" stroke-linejoin="round" d="M12 3l1.6 4.2L18 9l-4.4 1.8L12 15l-1.6-4.2L6 9l4.4-1.8L12 3z" />
          <path stroke-linecap="round" stroke-linejoin="round" d="M19 14l.7 1.8L21.5 16.5l-1.8.7L19 19l-.7-1.8L16.5 16.5l1.8-.7L19 14z" />
        </svg>
        <span v-if="!iconsOnly">AI讲解</span>
      </button>
      <button
        type="button"
        :class="[btnBase, iconsOnly ? 'w-7 px-0' : 'px-2', 'hover:border-sky-400 hover:text-sky-700 dark:hover:border-sky-500']"
        title="AI 跟读评分"
        aria-label="AI跟读"
        @click="fire('shadowing', $event)"
      >
        <svg class="w-3.5 h-3.5 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
          <path stroke-linecap="round" stroke-linejoin="round" d="M12 3a3 3 0 0 1 3 3v5a3 3 0 1 1-6 0V6a3 3 0 0 1 3-3z" />
          <path stroke-linecap="round" stroke-linejoin="round" d="M19 11a7 7 0 0 1-14 0M12 18v3" />
        </svg>
        <template v-if="!iconsOnly">
          <span>AI跟读</span>
          <span class="px-1 py-px rounded text-[9px] font-semibold leading-none bg-sky-100 text-sky-800 dark:bg-sky-950/60 dark:text-sky-300">
            评分
          </span>
        </template>
      </button>
      <button
        type="button"
        :class="[
          btnBase,
          iconsOnly ? 'w-7 px-0' : 'px-2.5',
          'hover:border-teal-400 hover:text-teal-700 dark:hover:border-teal-500',
          shadowBtnClass,
        ]"
        title="影子跟读：边听边说"
        aria-label="影子跟读"
        :aria-pressed="shadowActive"
        @click="fire('shadow', $event)"
      >
        <svg class="w-3.5 h-3.5 shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
          <path stroke-linecap="round" stroke-linejoin="round" d="M4 12c1.5-2 3-3 4.5-3S11 10 12 12s1.5 3 3.5 3 3-1 4.5-3" />
          <path stroke-linecap="round" stroke-linejoin="round" d="M4 17c1.5-2 3-3 4.5-3S11 15 12 17s1.5 3 3.5 3 3-1 4.5-3" />
        </svg>
        <span v-if="!iconsOnly">影子跟读</span>
        <span
          v-if="hasShadowTrack"
          class="w-1.5 h-1.5 rounded-full bg-teal-500"
          aria-hidden="true"
        />
      </button>
      <div ref="menuRef" class="relative shrink-0">
        <button
          type="button"
          :class="[
            btnBase,
            iconsOnly ? 'w-7 px-0' : 'px-2.5',
            'hover:border-neutral-400 dark:hover:border-neutral-500',
            dictationActive
              ? 'border-amber-400 text-amber-700 dark:border-amber-500 dark:text-amber-300'
              : '',
          ]"
          title="更多练习"
          aria-label="练习"
          :aria-expanded="menuOpen"
          aria-haspopup="menu"
          @click="toggleMenu"
        >
          <svg
            v-if="iconsOnly"
            class="w-3.5 h-3.5 shrink-0"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            aria-hidden="true"
          >
            <path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h10" />
          </svg>
          <template v-else>
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
          </template>
        </button>
        <div
          v-if="menuOpen"
          role="menu"
          class="absolute right-0 top-full mt-1 z-50 min-w-[9.5rem] rounded-xl border border-black/10 dark:border-white/10 bg-white dark:bg-neutral-900 shadow-lg shadow-black/10 py-1 overflow-hidden"
        >
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
    </template>

    <!-- 桌面窄栏：收成「练习」菜单 -->
    <div v-else-if="compactMenu" ref="menuRef" class="relative">
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
        class="absolute right-0 top-full mt-1 z-50 min-w-[10.5rem] rounded-xl border border-black/10 dark:border-white/10 bg-white dark:bg-neutral-900 shadow-lg shadow-black/10 py-1 overflow-hidden"
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

    <!-- 桌面宽栏：展开按钮组 -->
    <template v-else>
      <button
        type="button"
        :class="[btnBase, 'px-2 hover:border-violet-400 hover:text-violet-700 dark:hover:border-violet-500']"
        title="AI 讲解本句"
        @click="fire('explain', $event)"
      >
        AI讲解
      </button>
      <button
        type="button"
        :class="[btnBase, 'px-2 hover:border-sky-400 hover:text-sky-700 dark:hover:border-sky-500 dark:hover:text-sky-300']"
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
        :class="[btnBase, 'px-2 hover:border-emerald-400 hover:text-emerald-700']"
        title="AI 挖空练习"
        @click="fire('cloze', $event)"
      >
        AI挖空
      </button>
      <button
        type="button"
        :class="[
          btnBase,
          'px-2 hover:border-amber-400 hover:text-amber-700 dark:hover:border-amber-500 dark:hover:text-amber-300',
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
