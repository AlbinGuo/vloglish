<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import {
  adminCreateEpisode,
  adminGetEpisode,
  adminImportVtt,
  adminListTags,
  adminUpdateEpisode,
  type AdminEpisodePayload,
  type AdminSubtitle,
} from '@/api/admin'

const route = useRoute()
const router = useRouter()

const isNew = computed(() => route.name === 'AdminEpisodeNew')
const episodeId = computed(() => (isNew.value ? null : Number(route.params.id)))

const loading = ref(!isNew.value)
const saving = ref(false)
const importing = ref(false)
const error = ref('')
const success = ref('')
const tagSuggestions = ref<string[]>([])
const vttText = ref('')

const form = ref<AdminEpisodePayload>({
  video_id: '',
  index: 0,
  short_title: '',
  summary: '',
  remark: '',
  stars: 3,
  voca_size: 0,
  cover: '',
  video_url: '',
  audio_url: '',
  thumbnail_url: '',
  original_video_url: '',
  is_demo: false,
  status: 'draft',
  author: { name: '', gender: 'm', nationality: '', accent: '' },
  tag_names: [],
  subtitles: [],
})

const tagsInput = ref('')

function syncTagsFromInput() {
  form.value.tag_names = tagsInput.value
    .split(/[,，]/)
    .map((s) => s.trim())
    .filter(Boolean)
}

function syncTagsToInput() {
  tagsInput.value = form.value.tag_names.join('，')
}

function reindexSubtitles() {
  form.value.subtitles.forEach((s, i) => {
    s.index = i
  })
}

function addSubtitle() {
  const last = form.value.subtitles[form.value.subtitles.length - 1]
  form.value.subtitles.push({
    index: form.value.subtitles.length,
    start: last ? last.end : 0,
    end: last ? last.end + 3 : 3,
    english: '',
    chinese: '',
    ipa: '',
    english_html: '',
  })
}

function removeSubtitle(index: number) {
  form.value.subtitles.splice(index, 1)
  reindexSubtitles()
}

async function loadEpisode() {
  if (!episodeId.value) return
  loading.value = true
  error.value = ''
  try {
    const data = await adminGetEpisode(episodeId.value)
    form.value = {
      video_id: data.video_id,
      index: data.index,
      short_title: data.short_title,
      summary: data.summary,
      remark: data.remark,
      stars: data.stars,
      voca_size: data.voca_size,
      cover: data.cover,
      video_url: data.video_url,
      audio_url: data.audio_url,
      thumbnail_url: data.thumbnail_url,
      original_video_url: data.original_video_url,
      is_demo: data.is_demo,
      status: data.status,
      author: { ...data.author },
      tag_names: [...data.tag_names],
      subtitles: data.subtitles.map((s) => ({ ...s })),
    }
    syncTagsToInput()
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '加载失败'
  } finally {
    loading.value = false
  }
}

async function loadTags() {
  try {
    const tags = await adminListTags()
    tagSuggestions.value = tags.map((t) => t.name)
  } catch {
    tagSuggestions.value = []
  }
}

async function save() {
  syncTagsFromInput()
  if (!form.value.short_title.trim()) {
    error.value = '请填写标题'
    return
  }
  if (!form.value.author.name.trim()) {
    error.value = '请填写作者'
    return
  }

  saving.value = true
  error.value = ''
  success.value = ''
  try {
    const payload = { ...form.value, subtitles: form.value.subtitles.map((s) => ({ ...s })) }
    if (isNew.value) {
      if (!payload.video_id?.trim()) delete payload.video_id
      await adminCreateEpisode(payload)
      success.value = '创建成功'
      await router.replace('/gnadmin/episodes')
    } else if (episodeId.value) {
      await adminUpdateEpisode(episodeId.value, payload)
      success.value = '已保存'
      await loadEpisode()
    }
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '保存失败'
  } finally {
    saving.value = false
  }
}

async function importVtt() {
  if (!vttText.value.trim()) {
    error.value = '请粘贴 VTT 内容'
    return
  }
  importing.value = true
  error.value = ''
  try {
    const data = await adminImportVtt(vttText.value)
    form.value.subtitles = data.subtitles.map((s: AdminSubtitle) => ({ ...s }))
    success.value = `已导入 ${data.subtitle_count} 条字幕`
    vttText.value = ''
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || 'VTT 解析失败'
  } finally {
    importing.value = false
  }
}

async function onVttFileChange(event: Event) {
  const input = event.target as HTMLInputElement
  const file = input.files?.[0]
  if (!file) return
  vttText.value = await file.text()
  input.value = ''
}

onMounted(async () => {
  await loadTags()
  await loadEpisode()
})
</script>

<template>
  <div class="space-y-6 max-w-5xl">
    <div class="flex items-center gap-3 text-sm">
      <RouterLink to="/gnadmin/episodes" class="text-neutral-500 hover:text-neutral-900">← 返回列表</RouterLink>
      <span class="text-neutral-300">|</span>
      <span class="font-medium">{{ isNew ? '新建剧集' : '编辑剧集' }}</span>
    </div>

    <p v-if="error" class="text-sm text-red-600">{{ error }}</p>
    <p v-if="success" class="text-sm text-green-600">{{ success }}</p>

    <div v-if="loading" class="text-neutral-500">加载中...</div>

    <template v-else>
      <section class="rounded-xl border border-black/5 bg-white p-5 space-y-4">
        <h2 class="font-medium">基本信息</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <label class="block text-sm">
            <span class="text-neutral-500">标题 *</span>
            <input v-model="form.short_title" class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2" />
          </label>
          <label class="block text-sm">
            <span class="text-neutral-500">video_id</span>
            <input
              v-model="form.video_id"
              :readonly="!isNew"
              :placeholder="isNew ? '留空自动生成' : ''"
              class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2"
              :class="{ 'bg-neutral-50': !isNew }"
            />
          </label>
          <label class="block text-sm">
            <span class="text-neutral-500">排序 index</span>
            <input v-model.number="form.index" type="number" class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2" />
          </label>
          <label class="block text-sm">
            <span class="text-neutral-500">难度 (1-5)</span>
            <input v-model.number="form.stars" type="number" min="1" max="5" class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2" />
          </label>
          <label class="block text-sm">
            <span class="text-neutral-500">状态</span>
            <select v-model="form.status" class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2">
              <option value="draft">草稿</option>
              <option value="published">已发布</option>
              <option value="archived">已下架</option>
            </select>
          </label>
          <label class="block text-sm flex items-end gap-2 pb-2">
            <input v-model="form.is_demo" type="checkbox" class="rounded" />
            <span>Demo 体验内容</span>
          </label>
          <label class="block text-sm md:col-span-2">
            <span class="text-neutral-500">摘要</span>
            <textarea v-model="form.summary" rows="2" class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2" />
          </label>
          <label class="block text-sm md:col-span-2">
            <span class="text-neutral-500">备注（内部）</span>
            <textarea v-model="form.remark" rows="2" class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2" />
          </label>
          <label class="block text-sm md:col-span-2">
            <span class="text-neutral-500">标签（逗号分隔）</span>
            <input
              v-model="tagsInput"
              list="tag-suggestions"
              placeholder="旅行，知识"
              class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2"
            />
            <datalist id="tag-suggestions">
              <option v-for="name in tagSuggestions" :key="name" :value="name" />
            </datalist>
          </label>
          <label class="block text-sm">
            <span class="text-neutral-500">词汇量</span>
            <input v-model.number="form.voca_size" type="number" min="0" class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2" />
          </label>
        </div>
      </section>

      <section class="rounded-xl border border-black/5 bg-white p-5 space-y-4">
        <h2 class="font-medium">作者</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <label class="block text-sm">
            <span class="text-neutral-500">姓名 *</span>
            <input v-model="form.author.name" class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2" />
          </label>
          <label class="block text-sm">
            <span class="text-neutral-500">口音</span>
            <input v-model="form.author.accent" placeholder="美国 / 英国" class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2" />
          </label>
          <label class="block text-sm">
            <span class="text-neutral-500">国籍 emoji</span>
            <input v-model="form.author.nationality" placeholder="🇺🇸" class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2" />
          </label>
          <label class="block text-sm">
            <span class="text-neutral-500">性别</span>
            <select v-model="form.author.gender" class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2">
              <option value="m">男</option>
              <option value="f">女</option>
            </select>
          </label>
        </div>
      </section>

      <section class="rounded-xl border border-black/5 bg-white p-5 space-y-4">
        <h2 class="font-medium">媒体 URL（手动填写）</h2>
        <div class="grid grid-cols-1 gap-4">
          <label class="block text-sm">
            <span class="text-neutral-500">封面 cover</span>
            <input v-model="form.cover" class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2" />
          </label>
          <label class="block text-sm">
            <span class="text-neutral-500">视频 video_url</span>
            <input v-model="form.video_url" class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2" />
          </label>
          <label class="block text-sm">
            <span class="text-neutral-500">音频 audio_url</span>
            <input v-model="form.audio_url" class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2" />
          </label>
          <label class="block text-sm">
            <span class="text-neutral-500">缩略图 thumbnail_url</span>
            <input v-model="form.thumbnail_url" class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2" />
          </label>
          <label class="block text-sm">
            <span class="text-neutral-500">YouTube 原链</span>
            <input v-model="form.original_video_url" class="mt-1 w-full rounded-lg border border-black/10 px-3 py-2" />
          </label>
        </div>
      </section>

      <section class="rounded-xl border border-black/5 bg-white p-5 space-y-4">
        <div class="flex flex-wrap items-center justify-between gap-3">
          <h2 class="font-medium">字幕（{{ form.subtitles.length }} 条）</h2>
          <div class="flex flex-wrap gap-2">
            <button type="button" class="text-sm px-3 py-1.5 border rounded-lg hover:bg-neutral-50" @click="addSubtitle">
              添加一行
            </button>
          </div>
        </div>

        <div class="rounded-lg border border-black/10 p-4 space-y-3 bg-neutral-50">
          <p class="text-sm text-neutral-600">从 VTT 导入（粘贴内容或选择文件）</p>
          <textarea
            v-model="vttText"
            rows="4"
            placeholder="WEBVTT&#10;00:00:00.000 --> 00:00:03.000&#10;Hello world."
            class="w-full rounded-lg border border-black/10 px-3 py-2 text-sm font-mono"
          />
          <div class="flex flex-wrap gap-2">
            <label class="text-sm px-3 py-1.5 border rounded-lg bg-white cursor-pointer hover:bg-neutral-50">
              选择 .vtt 文件
              <input type="file" accept=".vtt,text/vtt" class="hidden" @change="onVttFileChange" />
            </label>
            <button
              type="button"
              class="text-sm px-3 py-1.5 rounded-lg bg-neutral-900 text-white disabled:opacity-50"
              :disabled="importing"
              @click="importVtt"
            >
              {{ importing ? '解析中...' : '解析并替换字幕' }}
            </button>
          </div>
        </div>

        <div class="overflow-auto max-h-[480px] border border-black/5 rounded-lg">
          <table class="w-full text-sm min-w-[720px]">
            <thead class="bg-neutral-50 text-neutral-500 sticky top-0">
              <tr>
                <th class="px-2 py-2 text-left w-10">#</th>
                <th class="px-2 py-2 text-left w-20">开始</th>
                <th class="px-2 py-2 text-left w-20">结束</th>
                <th class="px-2 py-2 text-left">英文</th>
                <th class="px-2 py-2 text-left">中文</th>
                <th class="px-2 py-2 w-12"></th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(sub, i) in form.subtitles" :key="i" class="border-t border-black/5 align-top">
                <td class="px-2 py-2 text-neutral-400">{{ i + 1 }}</td>
                <td class="px-2 py-2">
                  <input v-model.number="sub.start" type="number" step="0.001" class="w-full rounded border border-black/10 px-2 py-1" />
                </td>
                <td class="px-2 py-2">
                  <input v-model.number="sub.end" type="number" step="0.001" class="w-full rounded border border-black/10 px-2 py-1" />
                </td>
                <td class="px-2 py-2">
                  <textarea v-model="sub.english" rows="2" class="w-full rounded border border-black/10 px-2 py-1" />
                </td>
                <td class="px-2 py-2">
                  <textarea v-model="sub.chinese" rows="2" class="w-full rounded border border-black/10 px-2 py-1" />
                </td>
                <td class="px-2 py-2">
                  <button type="button" class="text-red-600 text-xs hover:underline" @click="removeSubtitle(i)">删</button>
                </td>
              </tr>
              <tr v-if="!form.subtitles.length">
                <td colspan="6" class="px-4 py-6 text-center text-neutral-400">暂无字幕，可导入 VTT 或手动添加</td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>

      <div class="flex flex-wrap gap-3 pb-8">
        <button
          type="button"
          class="rounded-lg bg-neutral-900 text-white px-6 py-2.5 text-sm hover:bg-neutral-800 disabled:opacity-50"
          :disabled="saving"
          @click="save"
        >
          {{ saving ? '保存中...' : '保存' }}
        </button>
        <a
          v-if="!isNew && form.status === 'published' && form.video_id"
          :href="`/english/episode/${form.video_id}`"
          target="_blank"
          class="rounded-lg border px-6 py-2.5 text-sm hover:bg-neutral-50"
        >
          前台预览
        </a>
      </div>
    </template>
  </div>
</template>
