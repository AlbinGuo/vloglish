<script setup lang="ts">
import { onBeforeUnmount, onMounted, ref } from 'vue'

const show = ref(true)
const leaving = ref(false)
let leaveTimer: ReturnType<typeof setTimeout> | undefined
let removeTimer: ReturnType<typeof setTimeout> | undefined

onMounted(() => {
  leaveTimer = setTimeout(() => {
    leaving.value = true
  }, 1900)
  removeTimer = setTimeout(() => {
    show.value = false
  }, 2400)
})

onBeforeUnmount(() => {
  if (leaveTimer) clearTimeout(leaveTimer)
  if (removeTimer) clearTimeout(removeTimer)
})
</script>

<template>
  <div v-if="show" class="app-splash" :class="{ 'app-splash--leave': leaving }">
    <div class="app-splash__content">
      <div class="app-splash__logo">
        <svg viewBox="0 0 32 32" class="app-splash__v" aria-hidden="true">
          <polygon points="10.2,9.6 13.25,9.6 15.8,17.95 18.35,9.6 21.4,9.6 16.95,23.1 15.05,23.1" />
        </svg>
      </div>
      <p class="app-splash__text">Real vlogs・Real English</p>
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
  width: 44px;
  height: 44px;
  fill: #111111;
}
.app-splash__text {
  font-size: 13px;
  font-weight: 500;
  letter-spacing: 0.14em;
  color: #d4d4d4;
  opacity: 0;
  transform: translateY(8px);
  animation: appSplashIn 0.9s ease 0.5s forwards;
}
@keyframes appSplashIn {
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>
