<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { createWish, listWishes, toggleWishLike, type WishItem } from '@/api/wishWall'
import WishStickyNote from '@/components/wish/WishStickyNote.vue'

const loading = ref(true)
const submitting = ref(false)
const likingId = ref<number | null>(null)
const error = ref('')
const formError = ref('')
const formOk = ref('')
const items = ref<WishItem[]>([])
const total = ref(0)
const sort = ref<'hot' | 'new'>('hot')
const title = ref('')
const body = ref('')

const PAGE_SIZE = 40
const hasMore = computed(() => items.value.length < total.value)

async function load(reset = true) {
  if (reset) loading.value = true
  error.value = ''
  try {
    const page = reset ? 1 : Math.floor(items.value.length / PAGE_SIZE) + 1
    const data = await listWishes({
      sort: sort.value,
      page,
      page_size: PAGE_SIZE,
    })
    total.value = data.count
    items.value = reset ? data.results : [...items.value, ...data.results]
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '加载失败'
  } finally {
    loading.value = false
  }
}

async function changeSort(next: 'hot' | 'new') {
  if (sort.value === next) return
  sort.value = next
  await load(true)
}

async function submit() {
  formError.value = ''
  formOk.value = ''
  const t = title.value.trim()
  const b = body.value.trim()
  if (t.length < 2) {
    formError.value = '标题至少 2 个字'
    return
  }
  if (b.length < 8) {
    formError.value = '请再写清楚一点，至少 8 个字'
    return
  }
  submitting.value = true
  try {
    await createWish({ title: t, body: b })
    title.value = ''
    body.value = ''
    formOk.value = '已经贴到墙上了'
    sort.value = 'new'
    await load(true)
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    formError.value = msg || '提交失败'
  } finally {
    submitting.value = false
  }
}

async function onLike(item: WishItem) {
  if (likingId.value) return
  likingId.value = item.id
  const prevLiked = item.liked
  const prevCount = item.like_count
  item.liked = !item.liked
  item.like_count = Math.max(0, item.like_count + (item.liked ? 1 : -1))
  try {
    const data = await toggleWishLike(item.id)
    item.liked = data.liked
    item.like_count = data.like_count
  } catch {
    item.liked = prevLiked
    item.like_count = prevCount
  } finally {
    likingId.value = null
  }
}

onMounted(() => {
  void load(true)
})
</script>

<template>
  <div class="wish-page">
    <div class="page-container wish-page-inner">
      <header class="wish-hero">
        <div class="wish-bulb" aria-hidden="true">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" class="w-9 h-9">
            <path
              fill="#fbbf24"
              d="M12 2.25A6.75 6.75 0 0 0 5.25 9c0 2.387 1.24 4.485 3.12 5.67.3.19.48.52.48.87v.46c0 .41.34.75.75.75h4.8c.41 0 .75-.34.75-.75v-.46c0-.35.18-.68.48-.87A6.74 6.74 0 0 0 18.75 9 6.75 6.75 0 0 0 12 2.25Z"
            />
            <path fill="#f59e0b" d="M9.6 18.6h4.8c.33 0 .6.27.6.6v.15c0 .99-.81 1.8-1.8 1.8h-2.4c-.99 0-1.8-.81-1.8-1.8V19.2c0-.33.27-.6.6-.6Z" />
          </svg>
        </div>
        <h1>需求墙</h1>
        <p>说出你的想法，一起让 Vloglish 变得更好</p>
      </header>

      <div class="wish-layout">
        <section class="wish-board" aria-label="需求墙">
          <div class="wish-board-bar">
            <button
              type="button"
              :class="sort === 'hot' ? 'is-on' : ''"
              @click="changeSort('hot')"
            >
              热门
            </button>
            <button
              type="button"
              :class="sort === 'new' ? 'is-on' : ''"
              @click="changeSort('new')"
            >
              最新
            </button>
            <span class="wish-count">{{ total }} 条</span>
          </div>

          <p v-if="error" class="wish-error">{{ error }}</p>
          <p v-else-if="loading" class="wish-empty">正在揭开便利贴…</p>
          <p v-else-if="!items.length" class="wish-empty">墙上还空着，来贴第一条吧</p>

          <div v-else class="wish-grid">
            <WishStickyNote
              v-for="item in items"
              :key="item.id"
              :item="item"
              :liking="likingId === item.id"
              @like="onLike(item)"
            />
          </div>

          <button
            v-if="hasMore && !loading"
            type="button"
            class="wish-more"
            @click="load(false)"
          >
            再看一些
          </button>
        </section>

        <aside id="wish-submit" class="wish-submit" aria-labelledby="wish-submit-title">
          <h2 id="wish-submit-title">提交新需求</h2>
          <form class="wish-form" @submit.prevent="submit">
            <input
              v-model="title"
              type="text"
              maxlength="80"
              placeholder="简短的标题（必填）"
              autocomplete="off"
            />
            <textarea
              v-model="body"
              maxlength="2000"
              rows="5"
              placeholder="详细描述你的需求…"
            />
            <p v-if="formError" class="wish-form-msg is-error">{{ formError }}</p>
            <p v-else-if="formOk" class="wish-form-msg is-ok">{{ formOk }}</p>
            <button type="submit" class="wish-submit-btn" :disabled="submitting">
              {{ submitting ? '正在贴上…' : '贴上需求墙' }}
            </button>
            <p class="wish-hint">每天最多 5 条。点赞多的需求会优先被看到。</p>
          </form>
        </aside>
      </div>

      <a href="#wish-submit" class="wish-fab">写需求</a>
    </div>
  </div>
</template>

<style scoped>
.wish-page {
  min-height: calc(100dvh - 4.25rem);
  background:
    radial-gradient(ellipse 80% 40% at 50% -10%, rgba(196, 181, 253, 0.55), transparent 70%),
    linear-gradient(180deg, #efe7fb 0%, #f7f3fc 32%, #faf8f6 100%);
}
.wish-page-inner {
  padding-top: 1.25rem;
  padding-bottom: 3rem;
  max-width: 1120px;
}
.wish-hero {
  text-align: center;
  margin-bottom: 1.25rem;
}
.wish-bulb {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 3.5rem;
  height: 3.5rem;
  border-radius: 999px;
  background: radial-gradient(circle, rgba(253, 224, 71, 0.55), rgba(253, 224, 71, 0.08) 70%);
  filter: drop-shadow(0 0 12px rgba(251, 191, 36, 0.55));
}
.wish-hero h1 {
  margin-top: 0.35rem;
  font-size: 1.85rem;
  font-weight: 800;
  letter-spacing: 0.04em;
  color: #1e3a5f;
}
.wish-hero p {
  margin-top: 0.3rem;
  font-size: 0.86rem;
  color: #94a3b8;
}
.wish-layout {
  display: grid;
  gap: 1.25rem;
}
.wish-board {
  background:
    repeating-linear-gradient(
      0deg,
      transparent,
      transparent 23px,
      rgba(140, 100, 50, 0.08) 24px
    ),
    repeating-linear-gradient(
      90deg,
      transparent,
      transparent 23px,
      rgba(140, 100, 50, 0.08) 24px
    ),
    linear-gradient(180deg, #ead7b4 0%, #e0c49a 100%);
  border-radius: 18px;
  padding: 1rem 0.85rem 1.15rem;
  box-shadow:
    0 1px 0 rgba(255, 255, 255, 0.35) inset,
    0 10px 28px rgba(90, 55, 20, 0.12);
  min-height: 18rem;
}
.wish-board-bar {
  display: flex;
  align-items: center;
  gap: 0.4rem;
  margin-bottom: 0.85rem;
}
.wish-board-bar button {
  font-size: 0.75rem;
  padding: 0.2rem 0.7rem;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.45);
  color: #6b5344;
}
.wish-board-bar button.is-on {
  background: #1e3a5f;
  color: #fff;
}
.wish-count {
  margin-left: auto;
  font-size: 0.72rem;
  color: #8a6f55;
}
.wish-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 0.85rem 0.7rem;
  align-items: start;
}
.wish-empty,
.wish-error {
  text-align: center;
  padding: 3.5rem 1rem;
  font-size: 0.9rem;
  color: #7c644c;
}
.wish-error {
  color: #b91c1c;
}
.wish-more {
  display: block;
  margin: 1rem auto 0;
  font-size: 0.8rem;
  padding: 0.4rem 1rem;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.55);
  color: #5b4636;
}
.wish-submit h2 {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 1.05rem;
  font-weight: 800;
  color: #1e3a5f;
  margin-bottom: 0.75rem;
}
.wish-submit h2::before {
  content: '';
  width: 5px;
  height: 1.05rem;
  border-radius: 99px;
  background: #7c3aed;
}
.wish-form {
  background: #fff;
  border-radius: 16px;
  padding: 0.9rem;
  box-shadow: 0 8px 24px rgba(80, 50, 120, 0.08);
  display: flex;
  flex-direction: column;
  gap: 0.65rem;
}
.wish-form input,
.wish-form textarea {
  width: 100%;
  border-radius: 10px;
  border: 0;
  background: #eaf4ff;
  padding: 0.7rem 0.85rem;
  font-size: 0.88rem;
  color: #1e3a5f;
  outline: none;
  resize: vertical;
}
.wish-form textarea {
  min-height: 7.5rem;
}
.wish-form input::placeholder,
.wish-form textarea::placeholder {
  color: #94a3b8;
}
.wish-form input:focus,
.wish-form textarea:focus {
  box-shadow: 0 0 0 2px rgba(124, 58, 237, 0.28);
}
.wish-form-msg {
  font-size: 0.78rem;
}
.wish-form-msg.is-error {
  color: #dc2626;
}
.wish-form-msg.is-ok {
  color: #059669;
}
.wish-submit-btn {
  width: 100%;
  border-radius: 10px;
  background: #7c3aed;
  color: #fff;
  font-size: 0.9rem;
  font-weight: 600;
  padding: 0.7rem;
}
.wish-submit-btn:hover:not(:disabled) {
  background: #6d28d9;
}
.wish-submit-btn:disabled {
  opacity: 0.65;
}
.wish-hint {
  font-size: 0.72rem;
  color: #94a3b8;
  line-height: 1.5;
}
.wish-fab {
  position: fixed;
  right: 1rem;
  bottom: calc(1.1rem + env(safe-area-inset-bottom, 0px));
  z-index: 20;
  padding: 0.65rem 1.05rem;
  border-radius: 999px;
  background: #7c3aed;
  color: #fff;
  font-size: 0.85rem;
  font-weight: 600;
  box-shadow: 0 8px 20px rgba(124, 58, 237, 0.35);
}

@media (min-width: 768px) {
  .wish-grid {
    grid-template-columns: repeat(3, 1fr);
    gap: 1rem 0.85rem;
  }
  .wish-board {
    padding: 1.15rem 1.1rem 1.35rem;
  }
}

@media (min-width: 1024px) {
  .wish-layout {
    grid-template-columns: minmax(0, 1fr) 20rem;
    align-items: start;
  }
  .wish-submit {
    position: sticky;
    top: 5.5rem;
  }
  .wish-fab {
    display: none;
  }
}

@media (min-width: 1440px) {
  .wish-page-inner {
    max-width: 1280px;
  }
  .wish-grid {
    grid-template-columns: repeat(4, 1fr);
  }
}
</style>
