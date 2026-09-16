<script setup lang="ts">
import { onMounted, onUnmounted, ref } from 'vue'

const HINT_KEY = 'vloglish_listen_swipe_hint_v1'

const visible = ref(false)
let showTimer: ReturnType<typeof setTimeout> | null = null
let hideTimer: ReturnType<typeof setTimeout> | null = null

function dismiss() {
  visible.value = false
  if (showTimer) clearTimeout(showTimer)
  if (hideTimer) clearTimeout(hideTimer)
  try {
    localStorage.setItem(HINT_KEY, '1')
  } catch {
    /* ignore */
  }
}

onMounted(() => {
  try {
    if (localStorage.getItem(HINT_KEY) === '1') return
  } catch {
    /* ignore */
  }
  showTimer = setTimeout(() => {
    visible.value = true
  }, 700)
  hideTimer = setTimeout(dismiss, 5600)
})

onUnmounted(() => {
  if (showTimer) clearTimeout(showTimer)
  if (hideTimer) clearTimeout(hideTimer)
})

defineExpose({ dismiss })
</script>

<template>
  <button
    v-if="visible"
    type="button"
    class="listen-swipe-hint pointer-events-auto absolute left-1/2 z-30 -translate-x-1/2 top-[42%] flex flex-col items-center gap-3 text-white"
    aria-label="上滑切换下一集"
    @click="dismiss"
  >
    <span class="listen-swipe-hint__stage" aria-hidden="true">
      <span class="listen-swipe-hint__page listen-swipe-hint__page--next" />
      <span class="listen-swipe-hint__page listen-swipe-hint__page--current">
        <span class="listen-swipe-hint__finger" />
      </span>
    </span>
    <span class="rounded-full bg-black/55 px-3 py-1 text-xs tracking-wide">上滑切换下一集</span>
  </button>
</template>

<style scoped>
.listen-swipe-hint__stage {
  position: relative;
  width: 4.6rem;
  height: 5.6rem;
  filter: drop-shadow(0 8px 16px rgba(0, 0, 0, 0.35));
}
.listen-swipe-hint__page {
  position: absolute;
  inset: 0;
  border-radius: 0.7rem;
  border: 1px solid rgba(255, 255, 255, 0.35);
}
.listen-swipe-hint__page--next {
  background: rgba(255, 255, 255, 0.16);
  transform: translateY(18%);
}
.listen-swipe-hint__page--current {
  background: rgba(255, 255, 255, 0.92);
  animation: listen-swipe-page 1.35s ease-in-out infinite;
}
.listen-swipe-hint__finger {
  position: absolute;
  left: 50%;
  bottom: 18%;
  width: 0.7rem;
  height: 0.7rem;
  margin-left: -0.35rem;
  border-radius: 999px;
  background: #2563eb;
  box-shadow: 0 0 0 6px rgba(37, 99, 235, 0.22);
  animation: listen-swipe-finger 1.35s ease-in-out infinite;
}
@keyframes listen-swipe-page {
  0%,
  12% {
    transform: translateY(0);
    opacity: 1;
  }
  55% {
    transform: translateY(-58%);
    opacity: 0.35;
  }
  100% {
    transform: translateY(0);
    opacity: 1;
  }
}
@keyframes listen-swipe-finger {
  0%,
  12% {
    transform: translateY(0);
    opacity: 1;
  }
  55% {
    transform: translateY(-1.7rem);
    opacity: 0.15;
  }
  100% {
    transform: translateY(0);
    opacity: 1;
  }
}
</style>
