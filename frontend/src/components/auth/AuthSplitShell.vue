<script setup lang="ts">
import { RouterLink } from 'vue-router'
import BrandLogo from '@/components/BrandLogo.vue'
import { LANDING_MOCKS } from '@/data/landing'
</script>

<template>
  <div
    class="auth-shell relative grid min-h-dvh grid-cols-1 bg-gradient-to-br from-[#f8f8f6] via-[#f5f5f4] to-[#eef3f1] text-neutral-900 lg:h-dvh lg:grid-cols-[minmax(0,1fr)_26.5rem] lg:overflow-hidden xl:grid-cols-[minmax(0,1fr)_28.5rem]"
  >
    <aside class="relative flex flex-col overflow-hidden lg:h-full" aria-label="产品介绍">
      <div
        class="relative z-10 flex items-center justify-between px-5 pt-[max(0.85rem,env(safe-area-inset-top))] sm:px-8 lg:block lg:px-12 lg:pt-10"
      >
        <RouterLink
          to="/"
          class="inline-flex min-h-11 w-fit cursor-pointer items-center gap-2.5 transition-opacity duration-200 hover:opacity-70"
        >
          <BrandLogo :size="28" />
          <span class="text-[1.02rem] font-semibold tracking-[-0.02em]">Vloglish</span>
        </RouterLink>
      </div>

      <div class="hidden min-h-0 flex-1 items-center justify-center px-6 py-6 lg:flex lg:px-10">
        <div class="relative w-full rounded-[1.75rem] bg-white/60 p-3 ring-1 ring-black/5 shadow-[0_30px_60px_-30px_rgba(15,23,42,0.25)] backdrop-blur">
          <img
            :src="LANDING_MOCKS.macCues"
            alt="书桌精听"
            class="h-full w-full rounded-[1.25rem] object-contain"
          />
        </div>
      </div>

      <div class="hidden px-12 pb-10 lg:block">
        <h1 class="max-w-md text-[1.75rem] font-semibold leading-snug tracking-tight">
          把一集生活视频，练成听得懂的英语
        </h1>
      </div>
    </aside>

    <main
      class="flex items-start justify-center px-5 pb-[max(2rem,env(safe-area-inset-bottom))] pt-6 sm:px-8 lg:items-center lg:overflow-y-auto lg:px-9 lg:py-12"
    >
      <div class="w-full max-w-md rounded-[1.75rem] bg-white/80 p-6 shadow-[0_20px_50px_-25px_rgba(15,23,42,0.25)] ring-1 ring-black/5 backdrop-blur sm:p-8 lg:max-w-[21.5rem] lg:p-7">
        <slot />
      </div>
    </main>
  </div>
</template>

<style scoped>
.auth-shell :deep(svg circle) {
  fill: #171717;
}
.auth-shell :deep(svg path) {
  fill: #fff;
}
</style>
