<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { adminFetchAiUsageStats, type AdminAiUsageStats } from '@/api/admin'

const loading = ref(true)
const error = ref('')
const days = ref(7)
const stats = ref<AdminAiUsageStats | null>(null)

const maxDaily = computed(() => {
  const list = stats.value?.daily ?? []
  return Math.max(1, ...list.map((d) => Math.max(d.total, d.billed)))
})

async function load() {
  loading.value = true
  error.value = ''
  try {
    stats.value = await adminFetchAiUsageStats(days.value)
  } catch (e: unknown) {
    error.value = e instanceof Error && e.message.trim() ? e.message.trim() : '加载失败'
    stats.value = null
  } finally {
    loading.value = false
  }
}

watch(days, () => {
  void load()
})

onMounted(() => {
  void load()
})
</script>

<template>
  <div class="space-y-6 max-w-5xl">
    <div class="flex flex-wrap items-center justify-between gap-3">
      <p class="text-sm text-neutral-500">
        统计东八区自然日。计费次数 = 实际调用外部 API（不含 TTS/查词缓存命中、规则点评）。
      </p>
      <label class="inline-flex items-center gap-2 text-sm text-neutral-600">
        区间
        <select
          v-model.number="days"
          class="rounded-lg border border-black/10 bg-white px-2.5 py-1.5 text-sm"
        >
          <option :value="7">近 7 日</option>
          <option :value="14">近 14 日</option>
          <option :value="30">近 30 日</option>
        </select>
      </label>
    </div>

    <div v-if="loading" class="text-neutral-500">加载中...</div>
    <div v-else-if="error" class="text-sm text-rose-600">{{ error }}</div>
    <template v-else-if="stats">
      <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
        <div class="rounded-xl border border-black/5 bg-white p-5 shadow-sm">
          <p class="text-sm text-neutral-500 mb-2">今日调用</p>
          <p class="text-3xl font-semibold tabular-nums">{{ stats.today_total }}</p>
          <p class="mt-1 text-xs text-neutral-400">{{ stats.today }}</p>
        </div>
        <div class="rounded-xl border border-black/5 bg-white p-5 shadow-sm">
          <p class="text-sm text-neutral-500 mb-2">今日计费</p>
          <p class="text-3xl font-semibold tabular-nums text-amber-700">{{ stats.today_billed }}</p>
          <p class="mt-1 text-xs text-neutral-400">外部 API 实际消耗</p>
        </div>
        <div class="rounded-xl border border-black/5 bg-white p-5 shadow-sm">
          <p class="text-sm text-neutral-500 mb-2">区间计费</p>
          <p class="text-3xl font-semibold tabular-nums">{{ stats.period_billed }}</p>
          <p class="mt-1 text-xs text-neutral-400">共 {{ stats.period_total }} 次记录</p>
        </div>
        <div class="rounded-xl border border-black/5 bg-white p-5 shadow-sm">
          <p class="text-sm text-neutral-500 mb-2">免费额度消耗（今日）</p>
          <p class="text-3xl font-semibold tabular-nums">{{ stats.free_quota_used_today }}</p>
          <p class="mt-1 text-xs text-neutral-400">每人上限 {{ stats.free_daily_limit }} 次/日</p>
        </div>
      </div>

      <section class="rounded-xl border border-black/5 bg-white p-5 shadow-sm">
        <h2 class="font-medium mb-1">近 {{ stats.days }} 日趋势</h2>
        <p class="text-xs text-neutral-400 mb-4">灰条为总调用，琥珀条为计费调用</p>
        <div class="flex items-end gap-1.5 h-36">
          <div
            v-for="d in stats.daily"
            :key="d.date"
            class="flex-1 min-w-0 flex flex-col items-center justify-end gap-0.5 h-full"
            :title="`${d.date}：总 ${d.total} / 计费 ${d.billed}`"
          >
            <div class="w-full flex items-end gap-0.5 h-[7.5rem]">
              <div
                class="flex-1 rounded-t bg-neutral-200"
                :style="{ height: `${Math.max(2, (d.total / maxDaily) * 100)}%` }"
              />
              <div
                class="flex-1 rounded-t bg-amber-400/90"
                :style="{ height: `${Math.max(d.billed ? 2 : 0, (d.billed / maxDaily) * 100)}%` }"
              />
            </div>
            <span class="text-[10px] text-neutral-400 tabular-nums truncate w-full text-center">
              {{ d.date.slice(5) }}
            </span>
          </div>
        </div>
      </section>

      <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <section class="rounded-xl border border-black/5 bg-white p-5 shadow-sm">
          <h2 class="font-medium mb-4">按能力</h2>
          <div v-if="!stats.by_action.length" class="text-sm text-neutral-400">暂无数据</div>
          <table v-else class="w-full text-sm">
            <thead>
              <tr class="text-left text-neutral-500 border-b border-black/5">
                <th class="pb-2 font-medium">能力</th>
                <th class="pb-2 font-medium text-right">总计</th>
                <th class="pb-2 font-medium text-right">计费</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="row in stats.by_action"
                :key="row.action"
                class="border-b border-black/5 last:border-0"
              >
                <td class="py-2.5 pr-4">
                  <p class="font-medium">{{ row.label }}</p>
                  <p class="text-xs text-neutral-400">{{ row.action }}</p>
                </td>
                <td class="py-2.5 text-right tabular-nums">{{ row.total }}</td>
                <td class="py-2.5 text-right tabular-nums text-amber-700">{{ row.billed }}</td>
              </tr>
            </tbody>
          </table>
        </section>

        <section class="rounded-xl border border-black/5 bg-white p-5 shadow-sm">
          <h2 class="font-medium mb-4">用量 Top 用户</h2>
          <div v-if="!stats.top_users.length" class="text-sm text-neutral-400">暂无数据</div>
          <table v-else class="w-full text-sm">
            <thead>
              <tr class="text-left text-neutral-500 border-b border-black/5">
                <th class="pb-2 font-medium">用户</th>
                <th class="pb-2 font-medium text-right">总计</th>
                <th class="pb-2 font-medium text-right">计费</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="u in stats.top_users"
                :key="u.user_id"
                class="border-b border-black/5 last:border-0"
              >
                <td class="py-2.5 pr-4">
                  <p class="font-medium truncate max-w-[14rem]">{{ u.email }}</p>
                  <p class="text-xs text-neutral-400">#{{ u.user_id }}</p>
                </td>
                <td class="py-2.5 text-right tabular-nums">{{ u.total }}</td>
                <td class="py-2.5 text-right tabular-nums text-amber-700">{{ u.billed }}</td>
              </tr>
            </tbody>
          </table>
        </section>
      </div>
    </template>
  </div>
</template>
