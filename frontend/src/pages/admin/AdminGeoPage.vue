<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import UserGeoBarChart from '@/components/charts/UserGeoBarChart.vue'
import UserGeoMapChart from '@/components/charts/UserGeoMapChart.vue'
import { adminFetchUserGeoStats, type AdminUserGeoStats } from '@/api/admin'

type TabKey = 'china' | 'world'

const loading = ref(true)
const error = ref('')
const stats = ref<AdminUserGeoStats | null>(null)
const tab = ref<TabKey>('china')
const selectedProvince = ref('')

async function load() {
  loading.value = true
  error.value = ''
  try {
    stats.value = await adminFetchUserGeoStats()
    if (stats.value && (stats.value.china_users ?? 0) === 0 && (stats.value.overseas_users ?? 0) > 0) {
      tab.value = 'world'
    }
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '加载失败'
  } finally {
    loading.value = false
  }
}

const mapItems = computed(() => {
  if (!stats.value) return []
  if (tab.value === 'china') return stats.value.by_province ?? []
  return stats.value.by_country ?? []
})

const sideList = computed(() => {
  if (!stats.value) return []
  if (tab.value === 'china') {
    return (stats.value.by_province ?? []).map((item) => ({
      label: item.name,
      count: item.count,
      key: item.name,
    }))
  }
  return (stats.value.by_country ?? []).map((item) => ({
    label: item.name,
    count: item.count,
    key: item.name,
  }))
})

const cityList = computed(() => {
  if (!stats.value || tab.value !== 'china' || !selectedProvince.value) return []
  return (stats.value.by_city ?? []).filter((c) => c.province === selectedProvince.value)
})

function onMapSelect(name: string) {
  if (tab.value !== 'china') return
  selectedProvince.value = name
}

function onSideClick(name: string) {
  if (tab.value === 'china') selectedProvince.value = name
}

function switchTab(next: TabKey) {
  tab.value = next
  selectedProvince.value = ''
}

onMounted(load)
</script>

<template>
  <div class="space-y-4">
    <div class="flex flex-wrap items-end justify-between gap-3">
      <div>
        <p class="text-sm text-neutral-500">
          注册地区分布（IP 推断，非真实住址）
        </p>
      </div>
      <div class="flex rounded-lg border border-black/10 bg-white p-0.5 text-sm">
        <button
          type="button"
          class="px-3 py-1.5 rounded-md transition"
          :class="tab === 'china' ? 'bg-neutral-900 text-white' : 'text-neutral-600 hover:bg-neutral-50'"
          @click="switchTab('china')"
        >
          中国地图
        </button>
        <button
          type="button"
          class="px-3 py-1.5 rounded-md transition"
          :class="tab === 'world' ? 'bg-neutral-900 text-white' : 'text-neutral-600 hover:bg-neutral-50'"
          @click="switchTab('world')"
        >
          世界地图
        </button>
      </div>
    </div>

    <p v-if="error" class="text-sm text-red-600">{{ error }}</p>
    <div v-if="loading" class="text-sm text-neutral-500">加载中...</div>

    <template v-else-if="stats">
      <div class="grid grid-cols-2 lg:grid-cols-5 gap-3">
        <div class="rounded-xl border border-black/5 bg-white p-4 shadow-sm">
          <p class="text-xs text-neutral-500 mb-1">用户总数</p>
          <p class="text-2xl font-semibold tabular-nums">{{ stats.total_users }}</p>
        </div>
        <div class="rounded-xl border border-black/5 bg-white p-4 shadow-sm">
          <p class="text-xs text-neutral-500 mb-1">已知地区</p>
          <p class="text-2xl font-semibold tabular-nums">{{ stats.known_users }}</p>
        </div>
        <div class="rounded-xl border border-black/5 bg-white p-4 shadow-sm">
          <p class="text-xs text-neutral-500 mb-1">未知地区</p>
          <p class="text-2xl font-semibold tabular-nums">{{ stats.unknown_users }}</p>
        </div>
        <div class="rounded-xl border border-black/5 bg-white p-4 shadow-sm">
          <p class="text-xs text-neutral-500 mb-1">中国</p>
          <p class="text-2xl font-semibold tabular-nums">{{ stats.china_users ?? 0 }}</p>
        </div>
        <div class="rounded-xl border border-black/5 bg-white p-4 shadow-sm col-span-2 lg:col-span-1">
          <p class="text-xs text-neutral-500 mb-1">海外</p>
          <p class="text-2xl font-semibold tabular-nums">{{ stats.overseas_users ?? 0 }}</p>
        </div>
      </div>

      <div class="grid grid-cols-1 xl:grid-cols-[1fr_280px] gap-4">
        <section class="rounded-xl border border-black/5 bg-white p-4 shadow-sm min-w-0">
          <div class="flex flex-wrap items-center justify-between gap-2 mb-2">
            <h2 class="font-medium text-sm">
              {{ tab === 'china' ? '中国省级分布' : '世界国家分布' }}
            </h2>
            <p class="text-xs text-neutral-400">
              {{ tab === 'china' ? '点击省份查看城市' : '可拖拽缩放' }}
            </p>
          </div>
          <UserGeoMapChart
            :map-kind="tab"
            :items="mapItems"
            height="520px"
            @select="onMapSelect"
          />
        </section>

        <aside class="space-y-4 min-w-0">
          <section class="rounded-xl border border-black/5 bg-white p-4 shadow-sm">
            <h2 class="font-medium text-sm mb-3">
              {{ tab === 'china' ? '省份排行' : '国家排行' }}
            </h2>
            <ul v-if="sideList.length" class="max-h-[280px] overflow-auto space-y-1 text-sm">
              <li v-for="item in sideList" :key="item.key">
                <button
                  type="button"
                  class="w-full flex items-center justify-between gap-2 rounded-lg px-2 py-1.5 text-left hover:bg-neutral-50"
                  :class="selectedProvince === item.label ? 'bg-amber-50 text-amber-900' : ''"
                  @click="onSideClick(item.label)"
                >
                  <span class="truncate">{{ item.label }}</span>
                  <span class="tabular-nums text-neutral-500 shrink-0">{{ item.count }}</span>
                </button>
              </li>
            </ul>
            <p v-else class="text-xs text-neutral-400">暂无数据</p>
          </section>

          <section
            v-if="tab === 'china'"
            class="rounded-xl border border-black/5 bg-white p-4 shadow-sm"
          >
            <h2 class="font-medium text-sm mb-1">城市排行</h2>
            <p class="text-xs text-neutral-400 mb-3">
              {{ selectedProvince ? `${selectedProvince} · 点击地图或左侧省份` : '请先选择省份' }}
            </p>
            <ul v-if="cityList.length" class="max-h-[200px] overflow-auto space-y-1 text-sm">
              <li
                v-for="city in cityList"
                :key="`${city.province}-${city.name}`"
                class="flex items-center justify-between gap-2 px-2 py-1"
              >
                <span class="truncate">{{ city.name }}</span>
                <span class="tabular-nums text-neutral-500 shrink-0">{{ city.count }}</span>
              </li>
            </ul>
            <p v-else-if="selectedProvince" class="text-xs text-neutral-400">该省暂无城市明细</p>
          </section>
        </aside>
      </div>

      <section
        v-if="stats.by_region.length"
        class="rounded-xl border border-black/5 bg-white p-5 shadow-sm"
      >
        <h2 class="font-medium text-sm mb-1">地区 Top（原始标签）</h2>
        <p class="text-xs text-neutral-400 mb-3">与仪表盘一致，按注册时原始省/国家字段</p>
        <UserGeoBarChart :items="stats.by_region" height="240px" />
      </section>
    </template>
  </div>
</template>
