<template>
  <article class="rounded-xl overflow-hidden border border-black/5 bg-white h-full">
    <div class="aspect-video bg-neutral-200 animate-pulse" />
    <div class="p-3 space-y-2.5">
      <div class="flex items-center justify-between gap-2">
        <div class="h-3 w-14 bg-neutral-200/80 rounded animate-pulse" />
        <div class="flex gap-0.5">
          <div v-for="n in 5" :key="n" class="h-3 w-3 bg-neutral-200/70 rounded-sm animate-pulse" />
        </div>
      </div>
      <div class="flex gap-1">
        <div class="h-4 w-12 bg-neutral-100 rounded animate-pulse" />
        <div class="h-4 w-10 bg-neutral-100 rounded animate-pulse" />
      </div>
      <div class="h-4 w-full bg-neutral-200/70 rounded animate-pulse" />
      <div class="h-4 w-4/5 bg-neutral-100 rounded animate-pulse" />
      <div class="flex items-center justify-between pt-1.5 border-t border-black/5">
        <div class="h-3 w-10 bg-neutral-100 rounded animate-pulse" />
        <div class="h-3 w-10 bg-neutral-100 rounded animate-pulse" />
        <div class="h-3 w-16 bg-neutral-100 rounded animate-pulse" />
      </div>
    </div>
  </article>
</template>
