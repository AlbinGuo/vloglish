<script setup lang="ts">
import { computed } from 'vue'
import type { WishItem } from '@/api/wishWall'

const props = defineProps<{
  item: WishItem
  liking?: boolean
}>()

const emit = defineEmits<{
  like: []
}>()

const NOTE_COLORS = ['#fff3b0', '#cfe8ff', '#ffd4e5', '#e4d4ff', '#d4f0c4']

const color = computed(() => NOTE_COLORS[props.item.id % NOTE_COLORS.length])
const tilt = computed(() => ((props.item.id * 17) % 7) - 3)

const statusLabel = computed(() => {
  if (props.item.status === 'done') return '已实现'
  if (props.item.status === 'replied' || props.item.admin_reply) return '已回复'
  return ''
})
</script>

<template>
  <article
    class="wish-note"
    :style="{ background: color, '--tilt': `${tilt}deg` }"
  >
    <span class="wish-tape" aria-hidden="true" />
    <span class="wish-pin" aria-hidden="true" />

    <div class="wish-note-head">
      <div class="min-w-0 flex-1">
        <h3 class="wish-note-title">{{ item.title }}</h3>
        <span v-if="statusLabel" class="wish-badge">{{ statusLabel }}</span>
      </div>
      <button
        type="button"
        class="wish-heart"
        :class="item.liked ? 'is-liked' : ''"
        :disabled="liking"
        :aria-label="item.liked ? '取消点赞' : '点赞'"
        @click.stop="emit('like')"
      >
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" class="w-3.5 h-3.5" aria-hidden="true">
          <path
            :fill="item.liked ? 'currentColor' : 'none'"
            stroke="currentColor"
            stroke-width="1.8"
            stroke-linecap="round"
            stroke-linejoin="round"
            d="M21 8.25c0-2.485-2.099-4.5-4.688-4.5-1.935 0-3.597 1.126-4.312 2.733-.715-1.607-2.377-2.733-4.313-2.733C5.1 3.75 3 5.765 3 8.25c0 7.22 9 12 9 12s9-4.78 9-12Z"
          />
        </svg>
        <span>{{ item.like_count }}</span>
      </button>
    </div>

    <p class="wish-note-body">{{ item.body }}</p>

    <div v-if="item.admin_reply" class="wish-reply">
      <p>{{ item.admin_reply }}</p>
    </div>
  </article>
</template>

<style scoped>
.wish-note {
  position: relative;
  display: flex;
  flex-direction: column;
  min-height: 11.5rem;
  padding: 1.15rem 0.85rem 0.85rem;
  border-radius: 3px 3px 10px 10px;
  box-shadow:
    0 1px 0 rgba(255, 255, 255, 0.55) inset,
    2px 4px 10px rgba(90, 55, 20, 0.18);
  transform: rotate(var(--tilt, 0deg));
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}
.wish-note:hover {
  transform: rotate(0deg) translateY(-2px);
  z-index: 2;
  box-shadow:
    0 1px 0 rgba(255, 255, 255, 0.55) inset,
    4px 10px 18px rgba(90, 55, 20, 0.22);
}
.wish-tape {
  position: absolute;
  top: -7px;
  left: 10px;
  width: 28px;
  height: 14px;
  background: rgba(255, 255, 255, 0.72);
  border-radius: 1px;
  transform: rotate(-18deg);
  box-shadow: 0 1px 2px rgba(80, 50, 20, 0.12);
}
.wish-pin {
  position: absolute;
  top: -7px;
  left: 50%;
  width: 12px;
  height: 12px;
  margin-left: -6px;
  border-radius: 50%;
  background: radial-gradient(circle at 35% 30%, #ff8b8b, #e11d2e 62%, #9f1239);
  box-shadow: 0 2px 3px rgba(80, 20, 20, 0.35);
}
.wish-note-head {
  display: flex;
  align-items: flex-start;
  gap: 0.35rem;
}
.wish-note-title {
  font-size: 0.82rem;
  font-weight: 700;
  line-height: 1.35;
  color: #1e3a5f;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
.wish-badge {
  display: inline-block;
  margin-top: 0.28rem;
  padding: 0.08rem 0.45rem;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.62);
  color: #64748b;
  font-size: 10px;
  line-height: 1.4;
}
.wish-heart {
  display: inline-flex;
  align-items: center;
  gap: 0.15rem;
  flex-shrink: 0;
  margin-top: -2px;
  padding: 0.1rem 0.15rem;
  color: #94a3b8;
  font-size: 11px;
  font-weight: 600;
  border-radius: 999px;
}
.wish-heart:hover:not(:disabled) {
  color: #fb7185;
}
.wish-heart.is-liked {
  color: #e11d48;
}
.wish-heart:disabled {
  opacity: 0.55;
}
.wish-note-body {
  margin-top: 0.45rem;
  font-size: 0.72rem;
  line-height: 1.55;
  color: #334155;
  display: -webkit-box;
  -webkit-line-clamp: 5;
  line-clamp: 5;
  -webkit-box-orient: vertical;
  overflow: hidden;
  flex: 1;
}
.wish-reply {
  margin-top: 0.55rem;
  padding: 0.45rem 0.5rem;
  border-radius: 6px;
  background: rgba(30, 58, 95, 0.08);
  font-size: 0.68rem;
  line-height: 1.5;
  color: #3f4f63;
  display: -webkit-box;
  -webkit-line-clamp: 4;
  line-clamp: 4;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
