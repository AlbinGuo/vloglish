<script setup lang="ts">
import { computed } from 'vue'
import { RouterLink, RouterView, useRoute } from 'vue-router'

const route = useRoute()
const immersive = computed(() => Boolean(route.meta.immersive))
</script>

<template>
  <div
    class="flex flex-col bg-neutral-50"
    :class="immersive ? 'h-dvh overflow-hidden' : 'min-h-dvh'"
  >
    <header
      v-if="!immersive"
      class="sticky top-0 z-40 bg-white/90 backdrop-blur border-b border-black/5"
    >
      <div class="max-w-6xl mx-auto px-4 py-3 flex items-center justify-between">
        <RouterLink to="/english" class="flex flex-col">
          <span class="text-lg font-semibold">TEco Lab</span>
          <span class="text-xs text-neutral-500">语库 · 真实语料</span>
        </RouterLink>
        <nav class="hidden sm:flex gap-6 text-sm font-medium">
          <RouterLink to="/english" class="hover:text-neutral-500" active-class="text-black">目录</RouterLink>
          <RouterLink to="/demo" class="hover:text-neutral-500" active-class="text-black">试用</RouterLink>
        </nav>
      </div>
    </header>
    <main class="flex-1" :class="immersive ? 'min-h-0 overflow-hidden' : ''">
      <RouterView />
    </main>
  </div>
</template>