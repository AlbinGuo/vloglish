<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import {
  adminCreateDemoCode,
  adminDeleteDemoCode,
  adminGetDemoCode,
  adminListDemoCodes,
  adminListEpisodes,
  adminUpdateDemoCode,
  type DemoCodeDetail,
  type DemoCodeRow,
} from '@/api/admin'

const loading = ref(true)
const saving = ref(false)
const error = ref('')
const success = ref('')
const rows = ref<DemoCodeRow[]>([])
const editing = ref<DemoCodeDetail | null>(null)
const episodeOptions = ref<{ id: number; label: string }[]>([])
const selectedEpisodeIds = ref<number[]>([])
const episodeSearch = ref('')

const showCreate = ref(false)
const newCode = ref('')
const newAffiliate = ref('')

const filteredOptions = computed(() => {
  const q = episodeSearch.value.trim().toLowerCase()
  if (!q) return episodeOptions.value
  return episodeOptions.value.filter((o) => o.label.toLowerCase().includes(q))
})

async function load() {
  loading.value = true
  error.value = ''
  try {
    rows.value = await adminListDemoCodes()
    const epData = await adminListEpisodes({ page: 1, page_size: 100 })
    episodeOptions.value = epData.results.map((e) => ({
      id: e.id,
      label: `${e.short_title} (${e.video_id})`,
    }))
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '加载失败'
  } finally {
    loading.value = false
  }
}

async function openEdit(row: DemoCodeRow) {
  error.value = ''
  success.value = ''
  try {
    editing.value = await adminGetDemoCode(row.id)
    selectedEpisodeIds.value = [...editing.value.episode_ids]
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '加载详情失败'
  }
}

function closeEdit() {
  editing.value = null
  selectedEpisodeIds.value = []
}

function toggleEpisode(id: number) {
  const set = new Set(selectedEpisodeIds.value)
  if (set.has(id)) set.delete(id)
  else set.add(id)
  selectedEpisodeIds.value = [...set]
}

async function saveEdit() {
  if (!editing.value) return
  saving.value = true
  error.value = ''
  success.value = ''
  try {
    await adminUpdateDemoCode(editing.value.id, {
      active: editing.value.active,
      affiliate_code: editing.value.affiliate_code,
      episode_ids: selectedEpisodeIds.value,
    })
    success.value = '已保存'
    await load()
    editing.value = await adminGetDemoCode(editing.value.id)
    selectedEpisodeIds.value = [...editing.value.episode_ids]
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '保存失败'
  } finally {
    saving.value = false
  }
}

async function createCode() {
  const code = newCode.value.trim().toUpperCase()
  if (!code) {
    error.value = '请填写体验码'
    return
  }
  saving.value = true
  error.value = ''
  try {
    await adminCreateDemoCode({
      code,
      affiliate_code: newAffiliate.value.trim() || null,
      active: true,
      episode_ids: [],
    })
    showCreate.value = false
    newCode.value = ''
    newAffiliate.value = ''
    success.value = '体验码已创建'
    await load()
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '创建失败'
  } finally {
    saving.value = false
  }
}

async function remove(row: DemoCodeRow) {
  if (row.code === 'ALICE') return
  if (!confirm(`确定删除体验码 ${row.code}？`)) return
  try {
    await adminDeleteDemoCode(row.id)
    if (editing.value?.id === row.id) closeEdit()
    await load()
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '删除失败'
  }
}

onMounted(load)
</script>

<template>
  <div class="space-y-4">
    <div class="rounded-lg border border-amber-200 bg-amber-50 px-4 py-3 text-sm text-amber-900">
      前台 <code class="text-xs">/api/demo/get-episodes/</code> 目前读取 <strong>ALICE</strong> 绑定的剧集列表。请在此为 ALICE 勾选 Demo 内容。
    </div>

    <div class="flex flex-wrap gap-3">
      <button
        type="button"
        class="rounded-lg bg-neutral-900 text-white px-4 py-2 text-sm hover:bg-neutral-800"
        @click="showCreate = true"
      >
        新建体验码
      </button>
    </div>

    <p v-if="error" class="text-sm text-red-600">{{ error }}</p>
    <p v-if="success" class="text-sm text-green-600">{{ success }}</p>

    <div class="rounded-xl border border-black/5 bg-white overflow-hidden">
      <div v-if="loading" class="p-8 text-center text-neutral-500">加载中...</div>
      <table v-else class="w-full text-sm">
        <thead class="bg-neutral-50 text-neutral-500">
          <tr>
            <th class="text-left px-4 py-3 font-medium">体验码</th>
            <th class="text-left px-4 py-3 font-medium">推广码</th>
            <th class="text-left px-4 py-3 font-medium">状态</th>
            <th class="text-left px-4 py-3 font-medium">绑定剧集</th>
            <th class="text-right px-4 py-3 font-medium">操作</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in rows" :key="row.id" class="border-t border-black/5">
            <td class="px-4 py-3 font-mono font-medium">{{ row.code }}</td>
            <td class="px-4 py-3">{{ row.affiliate_code || '-' }}</td>
            <td class="px-4 py-3">{{ row.active ? '启用' : '停用' }}</td>
            <td class="px-4 py-3">{{ row.episode_count }} 期</td>
            <td class="px-4 py-3 text-right space-x-3">
              <button type="button" class="text-neutral-900 hover:underline" @click="openEdit(row)">配置</button>
              <button
                v-if="row.code !== 'ALICE'"
                type="button"
                class="text-red-600 hover:underline"
                @click="remove(row)"
              >
                删除
              </button>
            </td>
          </tr>
          <tr v-if="!rows.length">
            <td colspan="5" class="px-4 py-8 text-center text-neutral-500">暂无体验码</td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- 创建弹层 -->
    <div v-if="showCreate" class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4" @click.self="showCreate = false">
      <div class="bg-white rounded-xl p-6 w-full max-w-md space-y-4">
        <h3 class="font-medium">新建体验码</h3>
        <label class="block text-sm">
          <span class="text-neutral-500">体验码</span>
          <input v-model="newCode" class="mt-1 w-full rounded-lg border px-3 py-2 uppercase" placeholder="例如 PROMO01" />
        </label>
        <label class="block text-sm">
          <span class="text-neutral-500">推广码（可选）</span>
          <input v-model="newAffiliate" class="mt-1 w-full rounded-lg border px-3 py-2" />
        </label>
        <div class="flex gap-2 justify-end">
          <button type="button" class="px-4 py-2 text-sm border rounded-lg" @click="showCreate = false">取消</button>
          <button type="button" class="px-4 py-2 text-sm bg-neutral-900 text-white rounded-lg" :disabled="saving" @click="createCode">
            创建
          </button>
        </div>
      </div>
    </div>

    <!-- 编辑弹层 -->
    <div v-if="editing" class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4" @click.self="closeEdit">
      <div class="bg-white rounded-xl w-full max-w-2xl max-h-[90vh] flex flex-col">
        <div class="p-5 border-b flex items-center justify-between">
          <div>
            <h3 class="font-medium font-mono">{{ editing.code }}</h3>
            <p class="text-xs text-neutral-500 mt-1">已选 {{ selectedEpisodeIds.length }} 期</p>
          </div>
          <label class="flex items-center gap-2 text-sm">
            <input v-model="editing.active" type="checkbox" class="rounded" />
            启用
          </label>
        </div>

        <div class="p-5 space-y-3 overflow-auto flex-1">
          <label class="block text-sm">
            <span class="text-neutral-500">推广码 affiliate_code</span>
            <input v-model="editing.affiliate_code" class="mt-1 w-full rounded-lg border px-3 py-2" />
          </label>

          <input
            v-model="episodeSearch"
            type="search"
            placeholder="搜索剧集..."
            class="w-full rounded-lg border px-3 py-2 text-sm"
          />

          <div class="border rounded-lg max-h-64 overflow-auto divide-y">
            <label
              v-for="opt in filteredOptions"
              :key="opt.id"
              class="flex items-center gap-3 px-3 py-2 text-sm hover:bg-neutral-50 cursor-pointer"
            >
              <input
                type="checkbox"
                :checked="selectedEpisodeIds.includes(opt.id)"
                @change="toggleEpisode(opt.id)"
              />
              <span class="truncate">{{ opt.label }}</span>
            </label>
            <p v-if="!filteredOptions.length" class="px-4 py-6 text-center text-neutral-400 text-sm">无匹配剧集</p>
          </div>
        </div>

        <div class="p-5 border-t flex gap-2 justify-end">
          <button type="button" class="px-4 py-2 text-sm border rounded-lg" @click="closeEdit">取消</button>
          <button type="button" class="px-4 py-2 text-sm bg-neutral-900 text-white rounded-lg disabled:opacity-50" :disabled="saving" @click="saveEdit">
            {{ saving ? '保存中...' : '保存绑定' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
