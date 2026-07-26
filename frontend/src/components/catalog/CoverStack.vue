<script setup lang="ts">
import { computed } from 'vue'
import { resolveMediaUrl } from '@/utils/mediaUrl'

const props = withDefaults(
  defineProps<{
    covers?: string[]
    count?: number
    alt?: string
    /** 由外层卡片 hover/focus 控制，避免依赖易失效的全局 CSS 选择器 */
    active?: boolean
  }>(),
  {
    covers: () => [],
    count: 0,
    alt: '',
    active: false,
  },
)

const resolved = computed(() =>
  (props.covers || []).map((c) => resolveMediaUrl(c)).filter(Boolean).slice(0, 3),
)
</script>

<template>
  <div
    class="cover-stack relative w-full aspect-video mb-2.5 px-1.5 sm:px-2 pt-0.5"
    :class="{ 'is-active': active }"
  >
    <div class="relative w-full h-full">
      <template v-if="resolved.length">
        <div
          v-for="(cover, i) in resolved"
          :key="`${alt}-${i}-${cover}`"
          class="cover-stack__card absolute inset-0 rounded-lg overflow-hidden border border-black/10 dark:border-white/15 bg-neutral-200 dark:bg-neutral-800"
          :data-i="i"
          :data-count="resolved.length"
          :style="{ zIndex: resolved.length - i }"
        >
          <img
            :src="cover"
            :alt="alt"
            class="cover-stack__img w-full h-full object-cover"
            loading="lazy"
            draggable="false"
          />
          <span class="cover-stack__shine" aria-hidden="true" />
        </div>
      </template>
      <div
        v-else
        class="absolute inset-0 rounded-lg bg-neutral-200 dark:bg-neutral-800 flex items-center justify-center text-neutral-400 text-sm"
      >
        暂无封面
      </div>
      <span
        v-if="count > 0"
        class="cover-stack__badge absolute -bottom-1.5 -right-1.5 z-20 min-w-[1.75rem] h-7 px-2 rounded-full bg-neutral-900 text-white dark:bg-white dark:text-neutral-900 text-xs font-semibold flex items-center justify-center shadow-sm"
      >
        {{ count }}
      </span>
    </div>
  </div>
</template>

<style scoped>
.cover-stack__card,
.cover-stack__badge,
.cover-stack__img,
.cover-stack__shine {
  pointer-events: none;
}

.cover-stack__card {
  transform-origin: 50% 85%;
  box-shadow: 0 1px 2px rgb(0 0 0 / 0.06);
  transition:
    transform 0.45s cubic-bezier(0.22, 1, 0.36, 1),
    box-shadow 0.45s cubic-bezier(0.22, 1, 0.36, 1);
}

.cover-stack__card[data-i='0'] {
  transform: translate(0, 0) rotate(0deg) scale(1);
}
.cover-stack__card[data-i='1'] {
  transform: translate(6px, -5px) rotate(3deg) scale(0.96);
}
.cover-stack__card[data-i='2'] {
  transform: translate(12px, -10px) rotate(6deg) scale(0.92);
}

.cover-stack__img {
  transition: transform 0.5s cubic-bezier(0.22, 1, 0.36, 1);
}

.cover-stack__shine {
  position: absolute;
  inset: 0;
  background: linear-gradient(
    115deg,
    transparent 35%,
    rgb(255 255 255 / 0.28) 48%,
    transparent 62%
  );
  transform: translateX(-120%) skewX(-12deg);
  opacity: 0;
}

.cover-stack__badge {
  transition: transform 0.4s cubic-bezier(0.34, 1.4, 0.64, 1);
}

/* 激活：扇开 + 浮起 + 扫光 */
.cover-stack.is-active .cover-stack__card {
  box-shadow:
    0 10px 20px rgb(0 0 0 / 0.12),
    0 2px 6px rgb(0 0 0 / 0.08);
}

.cover-stack.is-active .cover-stack__card[data-count='1'][data-i='0'] {
  transform: translateY(-10px) rotate(-3deg) scale(1.05);
}

.cover-stack.is-active .cover-stack__card[data-count='2'][data-i='0'] {
  transform: translate(-10px, -8px) rotate(-8deg) scale(1.03);
}
.cover-stack.is-active .cover-stack__card[data-count='2'][data-i='1'] {
  transform: translate(10px, -8px) rotate(8deg) scale(1.03);
}

.cover-stack.is-active .cover-stack__card[data-count='3'][data-i='0'] {
  transform: translateY(-10px) rotate(0deg) scale(1.05);
}
.cover-stack.is-active .cover-stack__card[data-count='3'][data-i='1'] {
  transform: translate(-12px, -2px) rotate(-9deg) scale(0.98);
}
.cover-stack.is-active .cover-stack__card[data-count='3'][data-i='2'] {
  transform: translate(12px, -2px) rotate(9deg) scale(0.98);
}

.cover-stack.is-active .cover-stack__img {
  transform: scale(1.06);
}

.cover-stack.is-active .cover-stack__card[data-i='0'] .cover-stack__shine {
  opacity: 1;
  animation: cover-stack-shine 0.7s cubic-bezier(0.22, 1, 0.36, 1) 0.05s both;
}

.cover-stack.is-active .cover-stack__badge {
  transform: scale(1.12) translateY(-2px);
}

@media (prefers-reduced-motion: reduce) {
  .cover-stack__card,
  .cover-stack__img,
  .cover-stack__badge {
    transition: none !important;
  }

  .cover-stack.is-active .cover-stack__card[data-i='0'] .cover-stack__shine {
    animation: none;
    opacity: 0;
  }
}

@keyframes cover-stack-shine {
  from {
    transform: translateX(-120%) skewX(-12deg);
  }
  to {
    transform: translateX(120%) skewX(-12deg);
  }
}
</style>
