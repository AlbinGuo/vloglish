<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { RouterLink } from 'vue-router'
import { storeToRefs } from 'pinia'
import { useClipsStore } from '@/stores/clips'
import type { SubtitleClip } from '@/api/learning'
import { getErrorDetail } from '@/api/tokens'
import { extractErrorDetail, isAiQuotaExhaustedDetail } from '@/utils/aiQuotaGate'

const clips = useClipsStore()
const { items, loading, error, refreshing } = storeToRefs(clips)

const editingId = ref<number | null>(null)
const draftText = ref('')
const draftNote = ref('')
const saving = ref(false)
const saveError = ref('')
const removingId = ref<number | null>(null)
const generatingId = ref<number | null>(null)
const exampleErrorId = ref<number | null>(null)
const exampleError = ref('')

const grouped = computed(() => {
  const map = new Map<string, { key: string; title: string; videoId: string; items: SubtitleClip[]; latestAt: number }>()
  for (const item of items.value) {
    const videoId = (item.video_id || '').trim()
    const key = videoId || `clip-${item.id}`
    const title = (item.episode_title || '').trim() || (videoId ? '未命名视频' : '未知来源')
    const t = Date.parse(item.created_at.replace(' ', 'T') + 'Z')
    const latestAt = Number.isFinite(t) ? t : 0
    const group = map.get(key)
    if (group) {
      group.items.push(item)
      group.latestAt = Math.max(group.latestAt, latestAt)
    } else {
      map.set(key, { key, title, videoId, items: [item], latestAt })
    }
  }
  return [...map.values()].sort((a, b) => b.latestAt - a.latestAt)
})

function sourcePath(item: SubtitleClip) {
  const ref = (item.video_id || '').trim()
  if (!ref) return ''
  const query: Record<string, string> = { from: 'clips' }
  if (item.subtitle_id) query.subtitle = String(item.subtitle_id)
  return `/english/episode/${ref}?${new URLSearchParams(query).toString()}`
}

function groupSourcePath(group: { videoId: string; items: SubtitleClip[] }) {
  const withAnchor = group.items.find((item) => sourcePath(item))
  return withAnchor ? sourcePath(withAnchor) : group.videoId ? `/english/episode/${group.videoId}?from=clips` : ''
}

function startEdit(item: SubtitleClip) {
  editingId.value = item.id
  draftText.value = item.text
  draftNote.value = item.note || ''
  saveError.value = ''
}

function cancelEdit() {
  editingId.value = null
  draftText.value = ''
  draftNote.value = ''
  saveError.value = ''
}

async function saveEdit(item: SubtitleClip) {
  const text = draftText.value.replace(/\s+/g, ' ').trim()
  if (!text) {
    saveError.value = '摘录不能为空'
    return
  }
  saving.value = true
  saveError.value = ''
  try {
    await clips.update(item.id, { text, note: draftNote.value.trim() })
    cancelEdit()
  } catch {
    saveError.value = '保存失败，请重试'
  } finally {
    saving.value = false
  }
}

async function removeItem(item: SubtitleClip) {
  if (!window.confirm('从摘录本移除这一条？')) return
  removingId.value = item.id
  try {
    await clips.remove(item.id)
    if (editingId.value === item.id) cancelEdit()
  } finally {
    removingId.value = null
  }
}

async function generateExamples(item: SubtitleClip, force: boolean) {
  generatingId.value = item.id
  exampleError.value = ''
  exampleErrorId.value = null
  try {
    await clips.generateExamples(item.id, force)
  } catch (e) {
    if (isAiQuotaExhaustedDetail(extractErrorDetail(e))) return
    exampleErrorId.value = item.id
    exampleError.value = getErrorDetail(e) || '生成失败，请稍后重试'
  } finally {
    generatingId.value = null
  }
}

onMounted(() => {
  void clips.load()
})
</script>

<template>
  <div class="page-container py-6 max-w-4xl">
    <div class="mb-6 flex items-center gap-3 text-sm min-w-0">
      <RouterLink
        to="/english/learning"
        class="text-ink-faint hover:text-ink shrink-0"
      >
        ← 学习统计
      </RouterLink>
      <span class="text-neutral-300 dark:text-neutral-600">·</span>
      <span class="font-medium tracking-tight">我的摘录</span>
      <span v-if="items.length" class="text-[11px] tabular-nums text-neutral-400">{{ items.length }} 条</span>
      <span v-if="refreshing" class="text-[11px] text-neutral-400">更新中…</span>
    </div>

    <p class="text-[13px] text-neutral-500 dark:text-neutral-400 mb-5">
      在学习页划选字幕即可收藏：电脑用鼠标直接划；手机先打开「划选」再长按圈字。收藏后原句会用天蓝底纹标出。举一反三走每日 AI 次数，会员不限。
    </p>

    <p v-if="error" class="text-sm text-red-600 dark:text-red-400 mb-4">{{ error }}</p>

    <div v-if="loading && !items.length" class="text-neutral-500 dark:text-neutral-400 text-sm">加载中...</div>
    <div
      v-else-if="!items.length"
      class="rounded-2xl border border-dashed border-black/10 dark:border-white/12 bg-white/60 dark:bg-neutral-900/50 p-12 text-center text-neutral-500 dark:text-neutral-400 text-sm"
    >
      还没有摘录。打开一集视频：电脑用鼠标划选字幕，手机先开「划选」再圈字，然后点「加入摘录」。
    </div>

    <div v-else class="space-y-8">
      <section v-for="group in grouped" :key="group.key" class="space-y-3">
        <div class="flex items-center justify-between gap-3 min-w-0">
          <div class="min-w-0 flex items-center gap-2">
            <span class="shrink-0 w-1 h-4 rounded-full bg-sky-400" aria-hidden="true" />
            <h2 class="text-sm font-medium truncate text-neutral-800 dark:text-neutral-100">
              {{ group.title }}
            </h2>
            <span class="shrink-0 text-[11px] text-neutral-400 tabular-nums">{{ group.items.length }}</span>
          </div>
          <RouterLink
            v-if="groupSourcePath(group)"
            :to="groupSourcePath(group)"
            class="shrink-0 text-xs text-sky-700 dark:text-sky-400 hover:underline"
          >
            回看本集
          </RouterLink>
        </div>

        <ul class="space-y-3">
          <li
            v-for="item in group.items"
            :key="item.id"
            class="rounded-2xl border border-black/[0.05] dark:border-white/[0.07] bg-white/80 dark:bg-neutral-900/70 p-4"
          >
            <template v-if="editingId === item.id">
              <label class="block text-xs text-neutral-500 mb-1">英文</label>
              <textarea
                v-model="draftText"
                rows="2"
                class="w-full rounded-xl border border-line-strong bg-white dark:bg-neutral-950 px-3 py-2 text-sm leading-relaxed"
              />
              <label class="block text-xs text-neutral-500 mt-3 mb-1">备注 / 中文</label>
              <textarea
                v-model="draftNote"
                rows="2"
                class="w-full rounded-xl border border-line-strong bg-white dark:bg-neutral-950 px-3 py-2 text-sm leading-relaxed"
                placeholder="可选，例如句型或自己的理解"
              />
              <p v-if="saveError" class="text-xs text-red-600 dark:text-red-400 mt-2">{{ saveError }}</p>
              <div class="mt-3 flex flex-wrap gap-2">
                <button
                  type="button"
                  class="px-3 py-1.5 rounded-lg text-sm font-medium bg-sky-600 text-white hover:bg-sky-500 disabled:opacity-60"
                  :disabled="saving"
                  @click="saveEdit(item)"
                >
                  {{ saving ? '保存中' : '保存' }}
                </button>
                <button
                  type="button"
                  class="px-3 py-1.5 rounded-lg text-sm border border-line-strong"
                  :disabled="saving"
                  @click="cancelEdit"
                >
                  取消
                </button>
              </div>
            </template>
            <template v-else>
              <p class="text-[15px] font-medium leading-relaxed text-neutral-900 dark:text-neutral-50">
                {{ item.text }}
              </p>
              <p v-if="item.note" class="mt-1.5 text-sm text-neutral-600 dark:text-neutral-300 leading-relaxed">
                {{ item.note }}
              </p>
              <p
                v-if="item.context_english && item.context_english.trim() !== item.text.trim()"
                class="mt-2 text-xs text-neutral-400 dark:text-neutral-500 leading-relaxed"
              >
                原句：{{ item.context_english }}
              </p>
              <div
                v-if="item.examples?.length"
                class="mt-3 rounded-xl border border-sky-100/90 dark:border-sky-900/50 bg-sky-50/70 dark:bg-sky-950/25 px-3 py-2.5 space-y-2"
              >
                <p class="text-[11px] font-medium text-sky-800/80 dark:text-sky-300/80">举一反三</p>
                <p
                  v-if="item.examples_stale"
                  class="text-[11px] text-amber-700 dark:text-amber-300"
                >
                  摘录已改，例句可能过时，可重新生成
                </p>
                <ol class="space-y-2">
                  <li v-for="(ex, i) in item.examples" :key="i">
                    <p class="text-sm leading-relaxed text-neutral-800 dark:text-neutral-100">{{ ex.en }}</p>
                    <p v-if="ex.zh" class="mt-0.5 text-xs text-neutral-500 dark:text-neutral-400 leading-relaxed">
                      {{ ex.zh }}
                    </p>
                  </li>
                </ol>
              </div>
              <p
                v-if="exampleErrorId === item.id && exampleError"
                class="mt-2 text-xs text-red-600 dark:text-red-400"
              >
                {{ exampleError }}
              </p>
              <div class="mt-3 flex flex-wrap items-center gap-2">
                <RouterLink
                  v-if="sourcePath(item)"
                  :to="sourcePath(item)"
                  class="text-xs text-sky-700 dark:text-sky-400 hover:underline"
                >
                  跳回原句
                </RouterLink>
                <button
                  type="button"
                  class="text-xs text-sky-700 dark:text-sky-400 hover:underline disabled:opacity-50"
                  :disabled="generatingId === item.id"
                  @click="generateExamples(item, Boolean(item.examples?.length))"
                >
                  {{
                    generatingId === item.id
                      ? '生成中…'
                      : item.examples?.length
                        ? '重新生成'
                        : '举一反三'
                  }}
                </button>
                <button
                  type="button"
                  class="text-xs text-neutral-500 hover:text-ink-soft"
                  @click="startEdit(item)"
                >
                  编辑
                </button>
                <button
                  type="button"
                  class="text-xs text-neutral-400 hover:text-red-600 dark:hover:text-red-400"
                  :disabled="removingId === item.id"
                  @click="removeItem(item)"
                >
                  移除
                </button>
              </div>
            </template>
          </li>
        </ul>
      </section>
    </div>
  </div>
</template>
