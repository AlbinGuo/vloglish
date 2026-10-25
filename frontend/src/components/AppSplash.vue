<script setup lang="ts">
import { onBeforeUnmount, onMounted, ref } from 'vue'

const SLOGAN = 'Real vlogs・Real English'

const show = ref(true)
const leaving = ref(false)
const typed = ref('')
const typingDone = ref(false)

let leaveTimer: ReturnType<typeof setTimeout> | undefined
let removeTimer: ReturnType<typeof setTimeout> | undefined
let typeTimer: ReturnType<typeof setTimeout> | undefined

onMounted(() => {
  leaveTimer = setTimeout(() => {
    leaving.value = true
  }, 1900)
  removeTimer = setTimeout(() => {
    show.value = false
  }, 2400)

  // 从 logo 出现后开始，从左到右逐字显示下方文字
  const startDelay = 560
  const perChar = 45
  let i = 0
  const tick = () => {
    i += 1
    typed.value = SLOGAN.slice(0, i)
    if (i < SLOGAN.length) {
      typeTimer = setTimeout(tick, perChar)
    } else {
      typingDone.value = true
    }
  }
  typeTimer = setTimeout(tick, startDelay)
})

onBeforeUnmount(() => {
  if (leaveTimer) clearTimeout(leaveTimer)
  if (removeTimer) clearTimeout(removeTimer)
  if (typeTimer) clearTimeout(typeTimer)
})
</script>

<template>
  <div v-if="show" class="app-splash" :class="{ 'app-splash--leave': leaving }">
    <div class="app-splash__content">
      <div class="app-splash__logo">
        <svg viewBox="0 0 32 32" class="app-splash__v" aria-hidden="true">
          <path
            d="M10.6 9.7 L16 22.3 L21.4 9.7"
            fill="none"
            stroke="#111111"
            stroke-width="4.6"
            stroke-linecap="round"
            stroke-linejoin="round"
          />
        </svg>
      </div>
      <p class="app-splash__text" aria-label="Real vlogs・Real English">
        <span class="app-splash__text-ghost">{{ SLOGAN }}</span>
        <span class="app-splash__text-live">
          {{ typed }}<span class="app-splash__caret" :class="{ 'is-done': typingDone }"></span>
        </span>
      </p>
    </div>
  </div>
</template>

<style scoped>
.app-splash {
  position: fixed;
  inset: 0;
  z-index: 9999;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #111111;
  transition: opacity 0.45s ease;
}
.app-splash--leave {
  opacity: 0;
}
.app-splash__content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20px;
}
.app-splash__logo {
  width: 78px;
  height: 78px;
  border-radius: 9999px;
  background: #ffffff;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.45);
  opacity: 0;
  transform: translateY(8px);
  animation: appSplashIn 0.9s ease 0.15s forwards;
}
.app-splash__v {
  width: 54px;
  height: 54px;
}
.app-splash__text {
  position: relative;
  font-size: 13px;
  font-weight: 500;
  letter-spacing: 0.14em;
  color: #d4d4d4;
  white-space: nowrap;
  opacity: 0;
  animation: appSplashFade 0.5s ease 0.45s forwards;
}
.app-splash__text-ghost {
  visibility: hidden;
}
.app-splash__text-live {
  position: absolute;
  inset: 0;
  white-space: nowrap;
}
.app-splash__caret {
  display: inline-block;
  width: 1px;
  height: 1em;
  margin-left: 2px;
  vertical-align: -0.12em;
  background: currentColor;
  animation: appSplashBlink 1s steps(1, end) infinite;
}
.app-splash__caret.is-done {
  animation: none;
  opacity: 0;
}
@keyframes appSplashIn {
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
@keyframes appSplashFade {
  to {
    opacity: 1;
  }
}
@keyframes appSplashBlink {
  50% {
    opacity: 0;
  }
}
</style>
