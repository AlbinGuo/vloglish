<script setup lang="ts">
// 登录 / 注册共用的全屏外壳：绿色品牌背景、右上角巨大的 V 水印、居中内容列。
</script>

<template>
  <div class="auth-screen">
    <div class="auth-screen__decor" aria-hidden="true">
      <span class="auth-screen__glow auth-screen__glow--tr" />
      <span class="auth-screen__glow auth-screen__glow--bl" />
      <span class="auth-screen__watermark">V</span>
    </div>
    <div class="auth-screen__content">
      <slot />
    </div>
  </div>
</template>

<style>
.auth-screen {
  position: relative;
  min-height: 100dvh;
  width: 100%;
  background: #fbfdfc;
  color: var(--color-ink);
}

.dark .auth-screen {
  background: #050b09;
}

.auth-screen__decor {
  position: absolute;
  inset: 0;
  overflow: hidden;
  pointer-events: none;
}

.auth-screen__glow {
  position: absolute;
  border-radius: 9999px;
  filter: blur(60px);
}

.auth-screen__glow--tr {
  top: -8rem;
  right: -6rem;
  width: 22rem;
  height: 22rem;
  background: radial-gradient(circle, rgba(34, 197, 94, 0.35), rgba(34, 197, 94, 0) 70%);
}

.auth-screen__glow--bl {
  bottom: -10rem;
  left: -8rem;
  width: 24rem;
  height: 24rem;
  background: radial-gradient(circle, rgba(45, 212, 191, 0.22), rgba(45, 212, 191, 0) 70%);
}

.dark .auth-screen__glow--tr {
  background: radial-gradient(circle, rgba(34, 197, 94, 0.28), rgba(34, 197, 94, 0) 70%);
}

.dark .auth-screen__glow--bl {
  background: radial-gradient(circle, rgba(20, 184, 166, 0.16), rgba(20, 184, 166, 0) 70%);
}

.auth-screen__watermark {
  position: absolute;
  top: -2.2rem;
  right: -1.4rem;
  font-size: clamp(12rem, 40vw, 17rem);
  font-weight: 900;
  line-height: 1;
  background: linear-gradient(140deg, rgba(74, 222, 128, 0.55), rgba(22, 163, 74, 0.08));
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
  transform: rotate(8deg);
  user-select: none;
}

.dark .auth-screen__watermark {
  background: linear-gradient(140deg, rgba(52, 211, 153, 0.5), rgba(16, 185, 129, 0.05));
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
}

.auth-screen__content {
  position: relative;
  z-index: 1;
  display: flex;
  flex-direction: column;
  width: 100%;
  max-width: 28rem;
  min-height: 100dvh;
  margin: 0 auto;
  padding: calc(env(safe-area-inset-top, 0px) + 1.5rem) 1.5rem
    calc(env(safe-area-inset-bottom, 0px) + 1.5rem);
}

/* ---------- 共用控件 ---------- */
.auth-vmark {
  display: inline-grid;
  place-items: center;
  flex-shrink: 0;
  background: linear-gradient(150deg, #86efac 0%, #34d399 45%, #16a34a 100%);
  box-shadow:
    inset 0 1px 1px rgba(255, 255, 255, 0.55),
    0 6px 16px -6px rgba(16, 163, 74, 0.6);
}

.auth-input {
  width: 100%;
  height: 3.2rem;
  border-radius: 1rem;
  padding: 0 1rem 0 2.85rem;
  font-size: 0.95rem;
  color: var(--color-ink);
  background: #eef2f0;
  border: 1px solid transparent;
  transition:
    border-color 0.18s ease,
    background 0.18s ease,
    box-shadow 0.18s ease;
}

.auth-input::placeholder {
  color: var(--color-ink-faint);
}

.dark .auth-input {
  background: rgba(255, 255, 255, 0.06);
}

.auth-input:focus {
  outline: none;
  border-color: #22c55e;
  box-shadow: 0 0 0 4px rgba(34, 197, 94, 0.14);
}

.auth-input--pw {
  padding-right: 2.85rem;
}

.auth-primary {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.4rem;
  width: 100%;
  height: 3.2rem;
  border-radius: 1rem;
  font-size: 1rem;
  font-weight: 700;
  color: #053b22;
  background: linear-gradient(100deg, #6ee7b7 0%, #22c55e 55%, #16a34a 100%);
  box-shadow: 0 10px 24px -10px rgba(22, 163, 74, 0.65);
  transition:
    transform 0.12s ease,
    filter 0.18s ease,
    opacity 0.18s ease;
}

.auth-primary:hover {
  filter: brightness(1.03);
}

.auth-primary:active {
  transform: scale(0.99);
}

.auth-primary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.auth-link {
  font-weight: 600;
  color: #16a34a;
  cursor: pointer;
}

.dark .auth-link {
  color: #34d399;
}

.auth-field-icon {
  position: absolute;
  left: 0.95rem;
  top: 50%;
  transform: translateY(-50%);
  width: 18px;
  height: 18px;
  color: var(--color-ink-faint);
  pointer-events: none;
}
</style>
