<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import {
  adminCreateAuthor,
  adminDeleteAuthor,
  adminListAuthors,
  adminMergeAuthor,
  adminUpdateAuthor,
  type AdminAuthor,
  type AdminAuthorInput,
} from '@/api/admin'

const loading = ref(true)
const saving = ref(false)
const error = ref('')
const success = ref('')
const rows = ref<AdminAuthor[]>([])
const search = ref('')

const showCreate = ref(false)
const form = ref<AdminAuthorInput>({ name: '', gender: 'm', nationality: '', accent: '' })

const editing = ref<AdminAuthor | null>(null)
const editForm = ref<AdminAuthorInput>({ name: '', gender: 'm', nationality: '', accent: '' })

const merging = ref<AdminAuthor | null>(null)
const mergeTargetId = ref<number | null>(null)

const filtered = computed(() => {
  const q = search.value.trim().toLowerCase()
  if (!q) return rows.value
  return rows.value.filter(
    (a) => a.name.toLowerCase().includes(q) || a.accent.toLowerCase().includes(q),
  )
})

const mergeTargets = computed(() => {
  if (!merging.value) return []
  return rows.value.filter((a) => a.id !== merging.value!.id)
})

async function load() {
  loading.value = true
  error.value = ''
  try {
    rows.value = await adminListAuthors()
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '加载失败'
  } finally {
    loading.value = false
  }
}

async function createAuthor() {
  if (!form.value.name.trim()) {
    error.value = '请填写作者姓名'
    return
  }
  saving.value = true
  error.value = ''
  try {
    await adminCreateAuthor({
      name: form.value.name.trim(),
      gender: form.value.gender,
      nationality: form.value.nationality.trim(),
      accent: form.value.accent.trim(),
    })
    showCreate.value = false
    form.value = { name: '', gender: 'm', nationality: '', accent: '' }
    success.value = '作者已创建'
    await load()
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '创建失败'
  } finally {
    saving.value = false
  }
}

function openEdit(row: AdminAuthor) {
  editing.value = row
  editForm.value = {
    name: row.name,
    gender: row.gender,
    nationality: row.nationality,
    accent: row.accent,
  }
  error.value = ''
  success.value = ''
}

async function saveEdit() {
  if (!editing.value) return
  saving.value = true
  error.value = ''
  try {
    await adminUpdateAuthor(editing.value.id, {
      name: editForm.value.name.trim(),
      gender: editForm.value.gender,
      nationality: editForm.value.nationality.trim(),
      accent: editForm.value.accent.trim(),
    })
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

async function remove(row: AdminAuthor) {
  if (row.episode_count > 0) {
    error.value = `「${row.name}」关联 ${row.episode_count} 个剧集，请使用合并或先修改剧集作者`
    return
  }
  if (!confirm(`确定删除作者「${row.name}」？`)) return
  try {
    await adminDeleteAuthor(row.id)
    success.value = '已删除'
    await load()
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '删除失败'
  }
}

function openMerge(row: AdminAuthor) {
  merging.value = row
  mergeTargetId.value = mergeTargets.value[0]?.id ?? null
}

async function confirmMerge() {
  if (!merging.value || !mergeTargetId.value) return
  const target = rows.value.find((a) => a.id === mergeTargetId.value)
  if (!confirm(`将「${merging.value.name}」的 ${merging.value.episode_count} 个剧集划归「${target?.name}」，并删除源作者？`)) return
  saving.value = true
  error.value = ''
  try {
    await adminMergeAuthor(merging.value.id, mergeTargetId.value)
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
        新建作者
      </button>
      <input
        v-model="search"
        type="search"
        placeholder="搜索姓名 / 口音"
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
            <th class="text-left px-4 py-3 font-medium">姓名</th>
            <th class="text-left px-4 py-3 font-medium">口音</th>
            <th class="text-left px-4 py-3 font-medium">国籍</th>
            <th class="text-left px-4 py-3 font-medium">性别</th>
            <th class="text-left px-4 py-3 font-medium">剧集</th>
            <th class="text-right px-4 py-3 font-medium">操作</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in filtered" :key="row.id" class="border-t border-black/5">
            <td class="px-4 py-3 font-medium">{{ row.name }}</td>
            <td class="px-4 py-3">{{ row.accent || '-' }}</td>
            <td class="px-4 py-3">{{ row.nationality || '-' }}</td>
            <td class="px-4 py-3">{{ row.gender === 'f' ? '女' : '男' }}</td>
            <td class="px-4 py-3">{{ row.episode_count }}</td>
            <td class="px-4 py-3 text-right space-x-3">
              <button type="button" class="hover:underline" @click="openEdit(row)">编辑</button>
              <button v-if="row.episode_count > 0" type="button" class="hover:underline" @click="openMerge(row)">合并</button>
              <button type="button" class="text-red-600 hover:underline" @click="remove(row)">删除</button>
            </td>
          </tr>
          <tr v-if="!filtered.length">
            <td colspan="6" class="px-4 py-8 text-center text-neutral-500">暂无作者</td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- 新建 -->
    <div v-if="showCreate" class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4" @click.self="showCreate = false">
      <div class="bg-white rounded-xl p-6 w-full max-w-md space-y-3">
        <h3 class="font-medium mb-2">新建作者</h3>
        <input v-model="form.name" class="w-full rounded-lg border px-3 py-2 text-sm" placeholder="姓名 *" />
        <input v-model="form.accent" class="w-full rounded-lg border px-3 py-2 text-sm" placeholder="口音，如：美国 / 英国" />
        <input v-model="form.nationality" class="w-full rounded-lg border px-3 py-2 text-sm" placeholder="国籍 emoji，如 🇺🇸" />
        <select v-model="form.gender" class="w-full rounded-lg border px-3 py-2 text-sm">
          <option value="m">男</option>
          <option value="f">女</option>
        </select>
        <div class="flex gap-2 justify-end pt-2">
          <button type="button" class="px-4 py-2 text-sm border rounded-lg" @click="showCreate = false">取消</button>
          <button type="button" class="px-4 py-2 text-sm bg-neutral-900 text-white rounded-lg disabled:opacity-50" :disabled="saving" @click="createAuthor">
            创建
          </button>
        </div>
      </div>
    </div>

    <!-- 编辑 -->
    <div v-if="editing" class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4" @click.self="editing = null">
      <div class="bg-white rounded-xl p-6 w-full max-w-md space-y-3">
        <h3 class="font-medium mb-2">编辑作者</h3>
        <input v-model="editForm.name" class="w-full rounded-lg border px-3 py-2 text-sm" />
        <input v-model="editForm.accent" class="w-full rounded-lg border px-3 py-2 text-sm" />
        <input v-model="editForm.nationality" class="w-full rounded-lg border px-3 py-2 text-sm" />
        <select v-model="editForm.gender" class="w-full rounded-lg border px-3 py-2 text-sm">
          <option value="m">男</option>
          <option value="f">女</option>
        </select>
        <div class="flex gap-2 justify-end pt-2">
          <button type="button" class="px-4 py-2 text-sm border rounded-lg" @click="editing = null">取消</button>
          <button type="button" class="px-4 py-2 text-sm bg-neutral-900 text-white rounded-lg disabled:opacity-50" :disabled="saving" @click="saveEdit">
            保存
          </button>
        </div>
      </div>
    </div>

    <!-- 合并 -->
    <div v-if="merging" class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4" @click.self="merging = null">
      <div class="bg-white rounded-xl p-6 w-full max-w-md space-y-4">
        <h3 class="font-medium">合并作者</h3>
        <p class="text-sm text-neutral-600">将 <strong>{{ merging.name }}</strong> 的全部剧集划归目标作者。</p>
        <select v-model="mergeTargetId" class="w-full rounded-lg border px-3 py-2 text-sm">
          <option v-for="a in mergeTargets" :key="a.id" :value="a.id">
            {{ a.name }}（{{ a.accent }}，{{ a.episode_count }} 期）
          </option>
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
