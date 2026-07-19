<script setup lang="ts">
import { MapChart } from 'echarts/charts'
import {
  GeoComponent,
  TooltipComponent,
  VisualMapComponent,
} from 'echarts/components'
import * as echarts from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import type { EChartsOption } from 'echarts'
import { onMounted, onUnmounted, ref, watch } from 'vue'
import { loadGeoJson, shortenChinaGeoJson } from '@/utils/geoMaps'

echarts.use([MapChart, GeoComponent, TooltipComponent, VisualMapComponent, CanvasRenderer])

const props = withDefaults(
  defineProps<{
    mapKind: 'china' | 'world'
    items: { name: string; map_name: string; count: number }[]
    height?: string
  }>(),
  { height: '480px' },
)

const emit = defineEmits<{
  select: [name: string]
}>()

const chartRef = ref<HTMLDivElement | null>(null)
const loading = ref(true)
const error = ref('')
let chart: echarts.ECharts | null = null
let mapReady = false

const MAP_NAME = {
  china: 'teco-china',
  world: 'teco-world',
} as const

async function ensureMap() {
  if (mapReady) return
  loading.value = true
  error.value = ''
  try {
    if (props.mapKind === 'china') {
      const raw = await loadGeoJson('/geo/china.json')
      echarts.registerMap(MAP_NAME.china, shortenChinaGeoJson(raw) as never)
    } else {
      const raw = await loadGeoJson('/geo/world.json')
      echarts.registerMap(MAP_NAME.world, raw as never)
    }
    mapReady = true
  } catch (e) {
    error.value = e instanceof Error ? e.message : '地图加载失败'
  } finally {
    loading.value = false
  }
}

function seriesData() {
  return props.items
    .filter((item) => item.map_name && item.count > 0)
    .map((item) => ({
      name: item.map_name,
      value: item.count,
      displayName: item.name,
    }))
}

function buildOption(): EChartsOption {
  const data = seriesData()
  const max = Math.max(1, ...data.map((d) => d.value))
  const mapName = MAP_NAME[props.mapKind]
  return {
    tooltip: {
      trigger: 'item',
      formatter: (params: unknown) => {
        const p = params as { data?: { displayName?: string; value?: number }; name?: string; value?: number }
        const label = p.data?.displayName || p.name || ''
        const value = p.data?.value ?? p.value
        if (value == null || Number.isNaN(Number(value))) return `${label}<br/>暂无用户`
        return `${label}<br/>注册用户：${value}`
      },
    },
    visualMap: {
      min: 0,
      max,
      left: 12,
      bottom: 12,
      text: ['高', '低'],
      calculable: true,
      inRange: {
        color: ['#fef3c7', '#f59e0b', '#b45309'],
      },
      textStyle: { color: '#737373', fontSize: 11 },
    },
    series: [
      {
        type: 'map',
        map: mapName,
        roam: true,
        scaleLimit: { min: 0.6, max: 8 },
        emphasis: {
          label: { show: props.mapKind === 'china', color: '#171717' },
          itemStyle: { areaColor: '#fbbf24' },
        },
        itemStyle: {
          areaColor: '#f5f5f5',
          borderColor: '#d4d4d4',
          borderWidth: 0.6,
        },
        label: {
          show: false,
        },
        data,
      },
    ],
  }
}

async function renderChart() {
  await ensureMap()
  if (!chartRef.value || error.value || !mapReady) return
  if (!chart) {
    chart = echarts.init(chartRef.value)
    chart.on('click', (params) => {
      const p = params as { data?: { displayName?: string }; name?: string }
      const name = p.data?.displayName || p.name
      if (name) emit('select', name)
    })
  }
  chart.setOption(buildOption(), true)
}

function onResize() {
  chart?.resize()
}

watch(
  () => props.mapKind,
  async () => {
    mapReady = false
    chart?.dispose()
    chart = null
    await renderChart()
  },
)

watch(
  () => props.items,
  () => {
    if (chart && mapReady) chart.setOption(buildOption(), true)
  },
  { deep: true },
)

onMounted(async () => {
  await renderChart()
  window.addEventListener('resize', onResize)
})

onUnmounted(() => {
  window.removeEventListener('resize', onResize)
  chart?.dispose()
  chart = null
})
</script>

<template>
  <div class="relative w-full" :style="{ height }">
    <div
      v-if="loading"
      class="absolute inset-0 flex items-center justify-center text-sm text-neutral-400"
    >
      地图加载中...
    </div>
    <div
      v-else-if="error"
      class="absolute inset-0 flex items-center justify-center text-sm text-red-600 px-4 text-center"
    >
      {{ error }}
    </div>
    <div ref="chartRef" class="w-full h-full" />
  </div>
</template>
