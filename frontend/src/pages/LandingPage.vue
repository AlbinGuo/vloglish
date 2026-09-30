<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref } from 'vue'
import { RouterLink } from 'vue-router'
import BrandLogo from '@/components/BrandLogo.vue'
import { LANDING_DESK_VIEWS, LANDING_FEATURES, LANDING_METHODS, LANDING_MOCKS, LANDING_PATH } from '@/data/landing'
import { useAppDownloadAvailability } from '@/composables/useAppDownloadAvailability'

const menuOpen = ref(false)
const scrolled = ref(false)
const deskViewId = ref<(typeof LANDING_DESK_VIEWS)[number]['id']>('cues')
const { showEntry, ensureLoaded } = useAppDownloadAvailability()

const deskView = computed(() => LANDING_DESK_VIEWS.find((view) => view.id === deskViewId.value) ?? LANDING_DESK_VIEWS[0])

function selectDesk(id: (typeof LANDING_DESK_VIEWS)[number]['id']) {
  deskViewId.value = id
}

function onScroll() {
  scrolled.value = window.scrollY > 8
}

function closeMenu() {
  menuOpen.value = false
}

onMounted(() => {
  window.addEventListener('scroll', onScroll, { passive: true })
  onScroll()
  void ensureLoaded()
})

onUnmounted(() => {
  window.removeEventListener('scroll', onScroll)
})
</script>

<template>
  <div class="landing min-h-dvh bg-[#f6f6f6] text-neutral-900">
    <header
      class="sticky top-0 z-40 border-b transition-colors duration-200"
      :class="scrolled || menuOpen ? 'border-black/8 bg-[#f6f6f6]/90 backdrop-blur-md' : 'border-transparent bg-[#f6f6f6]'"
    >
      <div class="mx-auto flex h-[3.75rem] max-w-6xl items-center justify-between px-5 sm:px-8">
        <a href="#top" class="inline-flex items-center gap-2" @click="closeMenu">
          <BrandLogo :size="28" />
          <span class="text-[1.02rem] font-semibold tracking-[-0.02em]">Vloglish</span>
        </a>
        <nav class="hidden items-center gap-8 text-sm text-neutral-500 md:flex" aria-label="落地页导航">
          <a href="#catalog" class="transition-colors hover:text-neutral-900">样机</a>
          <a href="#features" class="transition-colors hover:text-neutral-900">功能</a>
          <a href="#methods" class="transition-colors hover:text-neutral-900">方法</a>
          <a v-if="showEntry" href="/download" class="transition-colors hover:text-neutral-900">下载</a>
        </nav>
        <div class="hidden items-center gap-4 md:flex">
          <RouterLink to="/login" class="text-sm text-neutral-500 transition-colors hover:text-neutral-900">登录</RouterLink>
          <RouterLink
            to="/signup"
            class="rounded-full bg-neutral-900 px-4 py-1.5 text-sm font-medium text-white transition-colors hover:bg-neutral-800"
          >
            开始练习
          </RouterLink>
        </div>
        <button
          type="button"
          class="inline-flex h-10 w-10 cursor-pointer items-center justify-center md:hidden"
          :aria-expanded="menuOpen"
          aria-label="打开菜单"
          @click="menuOpen = !menuOpen"
        >
          <svg viewBox="0 0 24 24" class="h-5 w-5" fill="none" stroke="currentColor" stroke-width="1.8">
            <path v-if="!menuOpen" stroke-linecap="round" d="M5 8h14M5 12h14M5 16h14" />
            <path v-else stroke-linecap="round" d="M7 7l10 10M17 7L7 17" />
          </svg>
        </button>
      </div>
      <div v-if="menuOpen" class="border-t border-black/8 px-5 py-3 text-sm md:hidden">
        <a href="#catalog" class="block py-2 text-neutral-600" @click="closeMenu">样机</a>
        <a href="#features" class="block py-2 text-neutral-600" @click="closeMenu">功能</a>
        <a href="#methods" class="block py-2 text-neutral-600" @click="closeMenu">方法</a>
        <a v-if="showEntry" href="/download" class="block py-2 text-neutral-600" @click="closeMenu">下载</a>
        <div class="mt-2 flex items-center gap-4">
          <RouterLink to="/login" class="text-neutral-600" @click="closeMenu">登录</RouterLink>
          <RouterLink to="/signup" class="font-medium" @click="closeMenu">开始练习</RouterLink>
        </div>
      </div>
    </header>

    <main>
      <section id="top" class="px-5 pb-10 pt-20 text-center sm:px-8 sm:pb-14 sm:pt-28">
        <p class="text-sm text-neutral-500">真实 vlog · 一句一练</p>
        <h1 class="mx-auto mt-5 max-w-4xl text-[2.4rem] font-semibold leading-[1.12] tracking-tight sm:text-6xl">
          把一集生活视频，<br />练成听得懂的英语
        </h1>
        <p class="mx-auto mt-6 max-w-xl text-[15px] leading-relaxed text-neutral-500">
          Vloglish 不是词书，也不是题库。选一集真实口语，同一句可以精听、听写、跟读，再拿去听。
        </p>
        <div class="mt-9 flex flex-wrap justify-center gap-3">
          <RouterLink
            to="/signup"
            class="inline-flex h-11 cursor-pointer items-center rounded-full bg-neutral-900 px-5 text-sm font-medium text-white transition-colors hover:bg-neutral-800"
          >
            开始练习
          </RouterLink>
          <a
            href="#features"
            class="inline-flex h-11 items-center rounded-full px-5 text-sm text-neutral-600 transition-colors hover:text-neutral-900"
          >
            功能一览
          </a>
        </div>
      </section>

      <section id="catalog" class="scroll-mt-20 px-2 pb-6 sm:px-6 sm:pb-10">
        <img
          :src="LANDING_MOCKS.macCatalog"
          alt="电脑端视频目录"
          class="mx-auto w-full max-w-6xl"
        />
      </section>

      <section id="desk" class="scroll-mt-20 px-5 py-16 sm:px-8 sm:py-24">
        <div class="mx-auto max-w-2xl text-center">
          <p class="text-sm text-neutral-400">书桌</p>
          <h2 class="mt-3 text-3xl font-semibold tracking-tight sm:text-4xl">左视频，右这一句</h2>
          <p class="mt-4 text-sm leading-relaxed text-neutral-500">
            电脑上看精听。播放器不用挪，右侧可以换成字幕、句单、语境或背景。
          </p>
        </div>
        <img
          :src="deskView.image"
          :alt="`书桌 · ${deskView.label}`"
          class="mx-auto mt-10 w-full max-w-6xl"
        />
        <div class="mx-auto mt-6 grid max-w-3xl grid-cols-2 gap-3 sm:grid-cols-4">
          <button
            v-for="view in LANDING_DESK_VIEWS"
            :key="view.id"
            type="button"
            class="cursor-pointer rounded-2xl border px-3 py-3 text-left transition-colors duration-200"
            :class="deskViewId === view.id ? 'border-neutral-900' : 'border-black/8 hover:border-black/20'"
            @click="selectDesk(view.id)"
          >
            <p class="text-sm font-medium">{{ view.label }}</p>
            <p class="mt-1 text-[12px] leading-snug text-neutral-400">{{ view.hint }}</p>
          </button>
        </div>
      </section>

      <section class="px-2 py-6 sm:px-6">
        <img
          :src="LANDING_MOCKS.tabletDesk"
          alt="平板端精听"
          class="mx-auto w-full max-w-5xl"
        />
      </section>

      <section id="devices" class="scroll-mt-20 px-5 py-16 sm:px-8 sm:py-24">
        <div class="mx-auto max-w-2xl text-center">
          <p class="text-sm text-neutral-400">多端</p>
          <h2 class="mt-3 text-3xl font-semibold tracking-tight sm:text-4xl">手机和平板，同一套目录</h2>
          <p class="mt-4 text-sm leading-relaxed text-neutral-500">
            走路用手机选片，坐下来用平板或电脑把同一句听清楚。
          </p>
        </div>
        <div class="mx-auto mt-10 max-w-6xl">
          <img :src="LANDING_MOCKS.tabletCatalog" alt="平板端目录" class="mx-auto w-full max-w-5xl" />
          <img :src="LANDING_MOCKS.phoneCatalog" alt="手机端目录" class="mx-auto mt-4 w-full max-w-lg" />
        </div>
      </section>

      <section id="features" class="scroll-mt-20 border-t border-black/8 bg-white px-5 py-20 sm:px-8 sm:py-28">
        <div class="mx-auto max-w-2xl text-center">
          <p class="text-sm text-neutral-400">功能一览</p>
          <h2 class="mt-3 text-3xl font-semibold tracking-tight sm:text-4xl">播放器里就能练完</h2>
          <p class="mt-4 text-sm leading-relaxed text-neutral-500">
            目录、精听、语境、手机和平板，都是同一套进度。
          </p>
        </div>
        <ul class="mx-auto mt-12 grid max-w-6xl gap-5 sm:grid-cols-2 lg:grid-cols-4">
          <li v-for="feature in LANDING_FEATURES" :key="feature.title">
            <article class="overflow-hidden rounded-2xl bg-[#f6f6f6]">
              <img :src="feature.image" :alt="feature.title" class="aspect-[16/11] w-full object-cover object-center" />
              <div class="px-4 py-4">
                <h3 class="text-sm font-semibold">{{ feature.title }}</h3>
                <p class="mt-1.5 text-[13px] leading-relaxed text-neutral-500">{{ feature.summary }}</p>
              </div>
            </article>
          </li>
        </ul>
      </section>

      <section id="methods" class="scroll-mt-20 px-5 py-20 sm:px-8 sm:py-28">
        <div class="mx-auto max-w-2xl text-center">
          <p class="text-sm text-neutral-400">学习方法</p>
          <h2 class="mt-3 text-3xl font-semibold tracking-tight sm:text-4xl">一步一步，围着同一句</h2>
          <p class="mt-4 text-sm leading-relaxed text-neutral-500">
            不求一遍看完。先听懂一句，再把它写下来、说出去。
          </p>
        </div>
        <ol class="mx-auto mt-14 grid max-w-5xl gap-10 sm:grid-cols-2 lg:grid-cols-4">
          <li v-for="(step, index) in LANDING_PATH" :key="step.id">
            <p class="text-sm tabular-nums text-neutral-400">0{{ index + 1 }}</p>
            <h3 class="mt-3 text-lg font-semibold leading-snug">{{ step.name }}</h3>
            <p class="mt-2 text-sm leading-relaxed text-neutral-500">{{ step.summary }}</p>
          </li>
        </ol>
        <div class="mx-auto mt-16 max-w-5xl border-t border-black/8 pt-12">
          <p class="text-center text-sm text-neutral-400">同一句上的四种练法</p>
          <ol class="mt-8 grid gap-8 sm:grid-cols-2 lg:grid-cols-4">
            <li v-for="method in LANDING_METHODS" :key="method.id">
              <h3 class="text-base font-semibold">{{ method.name }}</h3>
              <p class="mt-2 text-sm leading-relaxed text-neutral-500">{{ method.summary }}</p>
            </li>
          </ol>
        </div>
      </section>

      <section class="px-5 pb-24 pt-4 text-center sm:px-8 sm:pb-32">
        <h2 class="text-3xl font-semibold tracking-tight sm:text-4xl">从一集真实 vlog 开始</h2>
        <p class="mx-auto mt-4 max-w-md text-sm text-neutral-500">
          注册即可练习。先听懂一句，再把它写下来、说出去。
        </p>
        <div class="mt-8 flex flex-wrap justify-center gap-3">
          <RouterLink
            to="/signup"
            class="inline-flex h-11 cursor-pointer items-center rounded-full bg-neutral-900 px-5 text-sm font-medium text-white transition-colors hover:bg-neutral-800"
          >
            开始练习
          </RouterLink>
          <RouterLink
            to="/login"
            class="inline-flex h-11 items-center rounded-full px-5 text-sm text-neutral-600 transition-colors hover:text-neutral-900"
          >
            已有账号
          </RouterLink>
        </div>
        <p v-if="showEntry" class="mt-6 text-sm">
          <RouterLink to="/download" class="text-neutral-500 underline decoration-neutral-300 underline-offset-4 hover:text-neutral-900">
            下载 App
          </RouterLink>
        </p>
      </section>
    </main>

    <footer class="border-t border-black/8 px-5 py-6 text-center text-xs text-neutral-400">
      Vloglish
    </footer>
  </div>
</template>

<style scoped>
/* 落地页固定浅底，商标不受 html.dark 改成白底 */
.landing :deep(svg circle) {
  fill: #171717;
}
.landing :deep(svg path) {
  fill: #fff;
}
</style>
