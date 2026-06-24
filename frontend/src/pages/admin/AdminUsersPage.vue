<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { adminListUsers, adminUpdateUser, type UserRow } from '@/api/admin'

const loading = ref(true)
const savingId = ref<number | null>(null)
const search = ref('')
const page = ref(1)
const total = ref(0)
const rows = ref<UserRow[]>([])
const error = ref('')

const totalPages = computed(() => Math.max(1, Math.ceil(total.value / 20)))

async function load() {
  loading.value = true
  error.value = ''
  try {
    const data = await adminListUsers({
      page: page.value,
      page_size: 20,
      search: search.value.trim() || undefined,
    })
    rows.value = data.results
    total.value = data.count
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '加载失败'
  } finally {
    loading.value = false
  }
}

async function toggleMember(user: UserRow) {
  savingId.value = user.id
  try {
    await adminUpdateUser(user.id, { is_member: !user.is_member })
    await load()
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '更新失败'
  } finally {
    savingId.value = null
  }
}

async function toggleActive(user: UserRow) {
  savingId.value = user.id
  try {
    await adminUpdateUser(user.id, { is_active: !user.is_active })
    await load()
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '更新失败'
  } finally {
    savingId.value = null
  }
}

function doSearch() {
  page.value = 1
  load()
}

onMounted(load)
</script>

<template>
  <div class="space-y-4">
    <div class="rounded-xl border border-black/5 bg-white p-4 flex gap-3">
      <input
        v-model="search"
        type="search"
        placeholder="搜索邮箱"
        class="flex-1 rounded-lg border border-black/10 px-3 py-2 text-sm"
        @keyup.enter="doSearch"
      />
      <button
        type="button"
        class="rounded-lg bg-neutral-900 text-white px-4 py-2 text-sm hover:bg-neutral-800"
        @click="doSearch"
      >
        搜索
      </button>
    </div>

    <p v-if="error" class="text-sm text-red-600">{{ error }}</p>

    <div class="rounded-xl border border-black/5 bg-white overflow-hidden">
      <div v-if="loading" class="p-8 text-center text-neutral-500">加载中...</div>
      <table v-else class="w-full text-sm">
        <thead class="bg-neutral-50 text-neutral-500">
          <tr>
            <th class="text-left px-4 py-3 font-medium">邮箱</th>
            <th class="text-left px-4 py-3 font-medium">会员</th>
            <th class="text-left px-4 py-3 font-medium">状态</th>
            <th class="text-left px-4 py-3 font-medium">注册时间</th>
            <th class="text-left px-4 py-3 font-medium">激活时间</th>
            <th class="text-right px-4 py-3 font-medium">操作</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="user in rows" :key="user.id" class="border-t border-black/5">
            <td class="px-4 py-3">
              <div>{{ user.email }}</div>
              <div v-if="user.is_staff" class="text-xs text-amber-600">管理员</div>
            </td>
            <td class="px-4 py-3">{{ user.is_member ? '是' : '否' }}</td>
            <td class="px-4 py-3">{{ user.is_active ? '正常' : '已停用' }}</td>
            <td class="px-4 py-3">{{ user.created_at }}</td>
            <td class="px-4 py-3">{{ user.member_activated_at || '-' }}</td>
            <td class="px-4 py-3 text-right space-x-2">
              <button
                type="button"
                class="text-neutral-900 hover:underline disabled:opacity-50"
                :disabled="savingId === user.id"
                @click="toggleMember(user)"
              >
                {{ user.is_member ? '取消会员' : '开通会员' }}
              </button>
              <button
                v-if="!user.is_staff"
                type="button"
                class="text-red-600 hover:underline disabled:opacity-50"
                :disabled="savingId === user.id"
                @click="toggleActive(user)"
              >
                {{ user.is_active ? '停用' : '启用' }}
              </button>
            </td>
          </tr>
          <tr v-if="!rows.length">
            <td colspan="6" class="px-4 py-8 text-center text-neutral-500">暂无数据</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-if="totalPages > 1" class="flex justify-center gap-3">
      <button
        type="button"
        class="px-3 py-1.5 text-sm border rounded-lg disabled:opacity-40"
        :disabled="page <= 1"
        @click="page--; load()"
      >
        上一页
      </button>
      <span class="text-sm text-neutral-500">{{ page }} / {{ totalPages }}</span>
      <button
        type="button"
        class="px-3 py-1.5 text-sm border rounded-lg disabled:opacity-40"
        :disabled="page >= totalPages"
        @click="page++; load()"
      >
        下一页
      </button>
    </div>
  </div>
</template>
