<template>
  <div class="flex items-stretch gap-3 border-b border-black/5 bg-white px-0 py-3">
    <div class="w-10 shrink-0 flex items-center justify-center">
      <div class="h-3 w-4 bg-neutral-200/80 rounded animate-pulse" />
    </div>

    <div class="flex flex-1 min-w-0 items-center gap-3 pr-2">
      <div class="w-28 sm:w-32 shrink-0 aspect-video rounded-lg bg-neutral-200 animate-pulse" />

      <div class="flex-1 min-w-0 space-y-2">
        <div class="flex flex-wrap items-center gap-2">
          <div class="h-3 w-14 bg-neutral-200/80 rounded animate-pulse" />
          <div class="flex gap-0.5">
            <div v-for="n in 5" :key="n" class="h-3 w-3 bg-neutral-200/70 rounded-sm animate-pulse" />
          </div>
          <div class="h-4 w-12 bg-neutral-100 rounded animate-pulse" />
        </div>
        <div class="h-4 w-3/4 bg-neutral-200/70 rounded animate-pulse" />
        <div class="h-3 w-full bg-neutral-100 rounded animate-pulse" />
        <div class="h-3 w-40 bg-neutral-100 rounded animate-pulse" />
      </div>
    </div>

    <div class="shrink-0 flex items-center pr-3">
      <div class="w-8 h-8 rounded-full bg-neutral-200/80 animate-pulse" />
    </div>
  </div>
</template>
