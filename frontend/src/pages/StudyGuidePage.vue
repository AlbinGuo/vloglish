<script setup lang="ts">
import { computed, nextTick, onMounted, onUnmounted, ref } from 'vue'
import { RouterLink, useRoute } from 'vue-router'
import { getEpisodeList } from '@/api/episodes'
import EnglishCatalogNavBar from '@/components/english/EnglishCatalogNavBar.vue'
import EnglishNavTabs from '@/components/english/EnglishNavTabs.vue'
import EpisodeCard from '@/components/EpisodeCard.vue'
import { useAuthStore } from '@/stores/auth'
import type { EpisodeSummary } from '@/types'
import {
  STUDY_METHODS,
  STUDY_NEEDS,
  STUDY_PLANS,
  STUDY_PREMISE,
  STUDY_TIPS,
} from '@/data/studyGuide'

const route = useRoute()
const auth = useAuthStore()
const activeId = ref('')
const sampleById = ref<Record<string, EpisodeSummary>>({})
const samplesLoading = ref(true)
let observer: IntersectionObserver | null = null

const sampleVideoIds = computed(() =>
  STUDY_METHODS.map((m) => m.sampleVideoId).filter((id): id is string => Boolean(id)),
)

function episodePath(ep: EpisodeSummary) {
  if (!auth.isLoggedIn) {
    return `/login?next=${encodeURIComponent(`/english/episode/${ep.video_id}`)}`
  }
  if (ep.requires_membership) return '/pricing'
  return `/english/episode/${ep.video_id}`
}

function scrollToId(id: string) {
  activeId.value = id
  const el = document.getElementById(id)
  if (!el) return
  el.scrollIntoView({ behavior: 'smooth', block: 'start' })
}

onMounted(async () => {
  await nextTick()
  const hash = (route.hash || '').replace(/^#/, '')
  if (hash) scrollToId(hash)

  observer = new IntersectionObserver(
    (entries) => {
      const visible = entries
        .filter((e) => e.isIntersecting)
        .sort((a, b) => b.intersectionRatio - a.intersectionRatio)[0]
      const id = visible?.target?.id
      if (id) activeId.value = id
    },
    { rootMargin: '-20% 0px -60% 0px', threshold: [0.15, 0.4] },
  )
  for (const m of STUDY_METHODS) {
    const el = document.getElementById(m.id)
    if (el) observer.observe(el)
  }

  const ids = sampleVideoIds.value
  if (!ids.length) {
    samplesLoading.value = false
    return
  }
  try {
    const data = await getEpisodeList({
      video_ids: ids.join(','),
      page_size: Math.max(ids.length, 2),
    })
    const map: Record<string, EpisodeSummary> = {}
    for (const ep of data.results) map[ep.video_id] = ep
    sampleById.value = map
  } catch {
    sampleById.value = {}
  } finally {
    samplesLoading.value = false
  }
})

onUnmounted(() => {
  observer?.disconnect()
  observer = null
})
</script>

<template>
  <div>
    <EnglishCatalogNavBar />

    <div class="page-container pt-3 pb-16 sm:py-6">
      <EnglishNavTabs class="hidden sm:block mb-6" />

      <div class="mx-auto max-w-5xl">
        <header
          class="relative overflow-hidden rounded-3xl border border-teal-200/70 dark:border-teal-800/50 bg-gradient-to-br from-teal-50 via-white to-amber-50 dark:from-teal-950/40 dark:via-neutral-900 dark:to-amber-950/20 px-5 py-7 sm:px-8 sm:py-9"
        >
          <p class="text-xs font-semibold tracking-[0.16em] uppercase text-teal-700 dark:text-teal-300">
            Study Playbook
          </p>
          <h1 class="mt-2 text-2xl sm:text-[1.75rem] font-bold tracking-tight text-neutral-900 dark:text-white">
            英语学习方法速查
          </h1>
          <p class="mt-2 text-sm text-neutral-500 dark:text-neutral-400">
            按水平与目标灵活选用 · 和站内视频单句循环、听写、跟读一一对应
          </p>
          <p
            class="mt-4 max-w-2xl text-sm leading-relaxed text-neutral-700 dark:text-neutral-300 rounded-2xl bg-white/70 dark:bg-neutral-950/40 border border-black/5 dark:border-white/10 px-4 py-3"
          >
            {{ STUDY_PREMISE }}
          </p>
        </header>

        <nav
          class="mt-5 -mx-1 flex gap-2 overflow-x-auto px-1 pb-1 lg:hidden"
          aria-label="方法目录"
        >
          <button
            v-for="m in STUDY_METHODS"
            :key="m.id"
            type="button"
            class="shrink-0 rounded-full border px-3 py-1.5 text-xs font-medium transition"
            :class="
              activeId === m.id
                ? 'border-teal-600 bg-teal-600 text-white'
                : 'border-black/10 dark:border-white/10 bg-white dark:bg-neutral-900 text-neutral-600 dark:text-neutral-300'
            "
            @click="scrollToId(m.id)"
          >
            {{ m.no }} {{ m.name }}
          </button>
        </nav>

        <div class="mt-8 lg:grid lg:grid-cols-[minmax(0,1fr)_13.5rem] lg:gap-10 lg:items-start">
          <div class="min-w-0 space-y-10">
            <section>
              <h2 class="text-lg font-semibold tracking-tight">快速选法</h2>
              <p class="mt-1 text-sm text-neutral-500">点一下跳到对应方法，对号入座即可。</p>
              <div class="mt-4 grid gap-3 sm:grid-cols-2">
                <button
                  v-for="item in STUDY_NEEDS"
                  :key="item.id"
                  type="button"
                  class="text-left rounded-2xl border border-black/8 dark:border-white/10 bg-white dark:bg-neutral-900 p-4 hover:border-teal-400/80 hover:shadow-sm transition group"
                  @click="scrollToId(item.methodId)"
                >
                  <p class="text-[13px] font-medium text-neutral-900 dark:text-white leading-snug">
                    {{ item.need }}
                  </p>
                  <p class="mt-2 text-sm text-teal-700 dark:text-teal-300 font-medium">
                    {{ item.methodLabel }}
                    <span class="inline-block text-teal-600 group-hover:translate-x-0.5 transition-transform">→</span>
                  </p>
                  <p class="mt-1 text-xs text-neutral-400">{{ item.extra }}</p>
                </button>
              </div>
            </section>

            <section>
              <h2 class="text-lg font-semibold tracking-tight">方法详解</h2>
              <p class="mt-1 text-sm text-neutral-500">站内可直接用：单句循环、句末停下、倍速、听写、隐藏字幕。</p>

              <article
                v-for="m in STUDY_METHODS"
                :id="m.id"
                :key="m.id"
                class="mt-5 scroll-mt-24 rounded-3xl border border-black/8 dark:border-white/10 bg-white dark:bg-neutral-900 overflow-hidden"
              >
                <div class="px-5 py-4 sm:px-6 sm:py-5 border-b border-black/5 dark:border-white/10 flex items-start gap-3">
                  <span
                    class="shrink-0 mt-0.5 inline-flex h-9 w-9 items-center justify-center rounded-xl bg-teal-600 text-white text-xs font-bold tabular-nums"
                  >
                    {{ m.no }}
                  </span>
                  <div class="min-w-0">
                    <h3 class="text-base font-semibold">
                      {{ m.name }}
                      <span class="ml-1.5 text-xs font-medium text-neutral-400">{{ m.nameEn }}</span>
                    </h3>
                    <p class="mt-1 text-sm text-neutral-500">{{ m.role }}</p>
                    <div class="mt-2.5 flex flex-wrap gap-1.5">
                      <span class="rounded-full bg-neutral-100 dark:bg-neutral-800 px-2.5 py-0.5 text-[11px] text-neutral-600 dark:text-neutral-300">
                        适合 {{ m.fit }}
                      </span>
                      <span class="rounded-full bg-amber-50 dark:bg-amber-950/40 px-2.5 py-0.5 text-[11px] text-amber-800 dark:text-amber-200">
                        {{ m.time }}
                      </span>
                    </div>
                    <p class="mt-3 text-sm leading-relaxed text-neutral-700 dark:text-neutral-300">
                      {{ m.value }}
                    </p>
                  </div>
                </div>
                <ol class="px-5 py-4 sm:px-6 sm:py-5 space-y-2.5">
                  <p class="text-[11px] font-semibold tracking-wide text-neutral-400 uppercase">
                    {{ m.stepsTitle }}
                  </p>
                  <li
                    v-for="(step, i) in m.steps"
                    :key="i"
                    class="flex gap-3 text-sm leading-relaxed text-neutral-700 dark:text-neutral-300"
                  >
                    <span
                      class="shrink-0 mt-0.5 inline-flex h-5 w-5 items-center justify-center rounded-full bg-teal-50 dark:bg-teal-950/50 text-[11px] font-semibold text-teal-700 dark:text-teal-300 tabular-nums"
                    >
                      {{ i + 1 }}
                    </span>
                    <span>{{ step }}</span>
                  </li>
                </ol>
                <div
                  v-if="m.sampleVideoId"
                  class="px-5 pb-5 sm:px-6 sm:pb-6 border-t border-black/5 dark:border-white/10 pt-4"
                >
                  <p class="text-[11px] font-semibold tracking-wide text-neutral-400 uppercase mb-2.5">
                    {{ m.sampleHint || '推荐示范视频' }}
                  </p>
                  <div class="max-w-[17.5rem]">
                    <EpisodeCard
                      v-if="sampleById[m.sampleVideoId]"
                      :episode="sampleById[m.sampleVideoId]"
                      :to="episodePath(sampleById[m.sampleVideoId])"
                    />
                    <div
                      v-else-if="samplesLoading"
                      class="rounded-xl overflow-hidden border border-black/5 dark:border-white/10 bg-neutral-100 dark:bg-neutral-800 animate-pulse"
                    >
                      <div class="aspect-video bg-neutral-200 dark:bg-neutral-700" />
                      <div class="h-16" />
                    </div>
                    <RouterLink
                      v-else
                      :to="`/english/episode/${m.sampleVideoId}`"
                      class="block rounded-xl border border-dashed border-black/15 dark:border-white/15 px-4 py-6 text-center text-sm text-teal-700 dark:text-teal-300 hover:bg-teal-50/60 dark:hover:bg-teal-950/30"
                    >
                      打开示范视频
                    </RouterLink>
                  </div>
                </div>
              </article>
            </section>

            <section>
              <h2 class="text-lg font-semibold tracking-tight">组合建议</h2>
              <div class="mt-4 grid gap-3 sm:grid-cols-2">
                <div
                  v-for="plan in STUDY_PLANS"
                  :key="plan.scene"
                  class="rounded-2xl border border-black/8 dark:border-white/10 bg-white dark:bg-neutral-900 p-5"
                >
                  <p class="text-sm font-semibold">{{ plan.scene }}</p>
                  <p class="mt-2 text-sm leading-relaxed text-neutral-600 dark:text-neutral-300">
                    {{ plan.combo }}
                  </p>
                  <p class="mt-3 text-xs text-teal-700 dark:text-teal-300 font-medium">每日 {{ plan.time }}</p>
                </div>
              </div>
            </section>

            <section>
              <h2 class="text-lg font-semibold tracking-tight">实操小贴士</h2>
              <ul class="mt-4 space-y-3">
                <li
                  v-for="tip in STUDY_TIPS"
                  :key="tip"
                  class="flex gap-3 rounded-2xl bg-amber-50/80 dark:bg-amber-950/25 border border-amber-100 dark:border-amber-900/40 px-4 py-3 text-sm leading-relaxed text-neutral-700 dark:text-neutral-200"
                >
                  <span class="mt-0.5 shrink-0 text-amber-600 dark:text-amber-300" aria-hidden="true">✓</span>
                  <span>{{ tip }}</span>
                </li>
              </ul>
            </section>

            <p class="text-center text-sm text-neutral-400 pt-2">
              选好方法后，回
              <RouterLink to="/english" class="text-teal-700 dark:text-teal-300 hover:underline">视频目录</RouterLink>
              挑一集，用单句循环开始练。
            </p>
          </div>

          <aside class="hidden lg:block">
            <div class="sticky top-24 rounded-2xl border border-black/8 dark:border-white/10 bg-white/90 dark:bg-neutral-900/90 backdrop-blur p-3">
              <p class="px-2 pb-2 text-[11px] font-semibold tracking-wide text-neutral-400">目录</p>
              <nav class="flex flex-col gap-0.5" aria-label="方法目录">
                <button
                  v-for="m in STUDY_METHODS"
                  :key="m.id"
                  type="button"
                  class="text-left rounded-lg px-2.5 py-1.5 text-[13px] transition"
                  :class="
                    activeId === m.id
                      ? 'bg-teal-50 dark:bg-teal-950/50 text-teal-800 dark:text-teal-200 font-medium'
                      : 'text-neutral-600 dark:text-neutral-400 hover:bg-neutral-50 dark:hover:bg-neutral-800'
                  "
                  @click="scrollToId(m.id)"
                >
                  {{ m.name }}
                </button>
              </nav>
            </div>
          </aside>
        </div>
      </div>
    </div>
  </div>
</template>
