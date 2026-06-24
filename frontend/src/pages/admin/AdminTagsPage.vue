<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import {
  adminCreateTag,
  adminDeleteTag,
  adminListTags,
  adminMergeTag,
  adminUpdateTag,
  type AdminTag,
} from '@/api/admin'

const loading = ref(true)
const saving = ref(false)
const error = ref('')
const success = ref('')
const rows = ref<AdminTag[]>([])
const search = ref('')

const showCreate = ref(false)
const newName = ref('')

const editing = ref<AdminTag | null>(null)
const editName = ref('')

const merging = ref<AdminTag | null>(null)
const mergeTargetId = ref<number | null>(null)

const filtered = computed(() => {
  const q = search.value.trim().toLowerCase()
  if (!q) return rows.value
  return rows.value.filter((t) => t.name.toLowerCase().includes(q))
})

const mergeTargets = computed(() => {
  if (!merging.value) return []
  return rows.value.filter((t) => t.id !== merging.value!.id)
})

async function load() {
  loading.value = true
  error.value = ''
  try {
    rows.value = await adminListTags()
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '加载失败'
  } finally {
    loading.value = false
  }
}

async function createTag() {
  const name = newName.value.trim()
  if (!name) {
    error.value = '请填写标签名'
    return
  }
  saving.value = true
  error.value = ''
  try {
    await adminCreateTag(name)
    showCreate.value = false
    newName.value = ''
    success.value = '标签已创建'
    await load()
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '创建失败'
  } finally {
    saving.value = false
  }
}

function openEdit(row: AdminTag) {
  editing.value = row
  editName.value = row.name
  error.value = ''
  success.value = ''
}

async function saveEdit() {
  if (!editing.value) return
  saving.value = true
  error.value = ''
  try {
    await adminUpdateTag(editing.value.id, editName.value.trim())
    editing.value = null
    success.value = '已保存'
    await load()
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '保存失败'
  } finally {
    saving.value = false
  }
}

async function remove(row: AdminTag) {
  const msg =
    row.episode_count > 0
      ? `标签「${row.name}」关联 ${row.episode_count} 个剧集，删除后这些剧集将失去该标签。确定删除？`
      : `确定删除标签「${row.name}」？`
  if (!confirm(msg)) return
  try {
    await adminDeleteTag(row.id)
    success.value = '已删除'
    await load()
  } catch (e: unknown) {
    const detail = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = detail || '删除失败'
  }
}

function openMerge(row: AdminTag) {
  merging.value = row
  mergeTargetId.value = mergeTargets.value[0]?.id ?? null
}

async function confirmMerge() {
  if (!merging.value || !mergeTargetId.value) return
  const target = rows.value.find((t) => t.id === mergeTargetId.value)
  if (!confirm(`将「${merging.value.name}」合并到「${target?.name}」？`)) return
  saving.value = true
  error.value = ''
  try {
    await adminMergeTag(merging.value.id, mergeTargetId.value)
    merging.value = null
    success.value = '合并完成'
    await load()
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '合并失败'
  } finally {
    saving.value = false
  }
}

onMounted(load)
</script>

<template>
  <div class="space-y-4">
    <div class="flex flex-wrap gap-3">
      <button
        type="button"
        class="rounded-lg bg-neutral-900 text-white px-4 py-2 text-sm hover:bg-neutral-800"
        @click="showCreate = true"
      >
        新建标签
      </button>
      <input
        v-model="search"
        type="search"
        placeholder="搜索标签"
        class="rounded-lg border border-black/10 px-3 py-2 text-sm min-w-[200px]"
      />
    </div>

    <p v-if="error" class="text-sm text-red-600">{{ error }}</p>
    <p v-if="success" class="text-sm text-green-600">{{ success }}</p>

    <div class="rounded-xl border border-black/5 bg-white overflow-hidden">
      <div v-if="loading" class="p-8 text-center text-neutral-500">加载中...</div>
      <table v-else class="w-full text-sm">
        <thead class="bg-neutral-50 text-neutral-500">
          <tr>
            <th class="text-left px-4 py-3 font-medium">ID</th>
            <th class="text-left px-4 py-3 font-medium">名称</th>
            <th class="text-left px-4 py-3 font-medium">关联剧集</th>
            <th class="text-right px-4 py-3 font-medium">操作</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in filtered" :key="row.id" class="border-t border-black/5">
            <td class="px-4 py-3 text-neutral-400">{{ row.id }}</td>
            <td class="px-4 py-3 font-medium">{{ row.name }}</td>
            <td class="px-4 py-3">{{ row.episode_count }}</td>
            <td class="px-4 py-3 text-right space-x-3">
              <button type="button" class="hover:underline" @click="openEdit(row)">编辑</button>
              <button type="button" class="hover:underline" @click="openMerge(row)">合并</button>
              <button type="button" class="text-red-600 hover:underline" @click="remove(row)">删除</button>
            </td>
          </tr>
          <tr v-if="!filtered.length">
            <td colspan="4" class="px-4 py-8 text-center text-neutral-500">暂无标签</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-if="showCreate" class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4" @click.self="showCreate = false">
      <div class="bg-white rounded-xl p-6 w-full max-w-md space-y-4">
        <h3 class="font-medium">新建标签</h3>
        <input v-model="newName" class="w-full rounded-lg border px-3 py-2" placeholder="例如：旅行" @keyup.enter="createTag" />
        <div class="flex gap-2 justify-end">
          <button type="button" class="px-4 py-2 text-sm border rounded-lg" @click="showCreate = false">取消</button>
          <button type="button" class="px-4 py-2 text-sm bg-neutral-900 text-white rounded-lg disabled:opacity-50" :disabled="saving" @click="createTag">
            创建
          </button>
        </div>
      </div>
    </div>

    <div v-if="editing" class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4" @click.self="editing = null">
      <div class="bg-white rounded-xl p-6 w-full max-w-md space-y-4">
        <h3 class="font-medium">编辑标签</h3>
        <input v-model="editName" class="w-full rounded-lg border px-3 py-2" @keyup.enter="saveEdit" />
        <div class="flex gap-2 justify-end">
          <button type="button" class="px-4 py-2 text-sm border rounded-lg" @click="editing = null">取消</button>
          <button type="button" class="px-4 py-2 text-sm bg-neutral-900 text-white rounded-lg disabled:opacity-50" :disabled="saving" @click="saveEdit">
            保存
          </button>
        </div>
      </div>
    </div>

    <div v-if="merging" class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4" @click.self="merging = null">
      <div class="bg-white rounded-xl p-6 w-full max-w-md space-y-4">
        <h3 class="font-medium">合并标签</h3>
        <p class="text-sm text-neutral-600">将 <strong>{{ merging.name }}</strong> 的剧集全部归入目标标签，并删除源标签。</p>
        <select v-model="mergeTargetId" class="w-full rounded-lg border px-3 py-2 text-sm">
          <option v-for="t in mergeTargets" :key="t.id" :value="t.id">{{ t.name }}（{{ t.episode_count }} 期）</option>
        </select>
        <div class="flex gap-2 justify-end">
          <button type="button" class="px-4 py-2 text-sm border rounded-lg" @click="merging = null">取消</button>
          <button type="button" class="px-4 py-2 text-sm bg-neutral-900 text-white rounded-lg disabled:opacity-50" :disabled="saving || !mergeTargetId" @click="confirmMerge">
            确认合并
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
