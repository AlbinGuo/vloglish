<script setup lang="ts">
import { LineChart } from 'echarts/charts'
import { GridComponent, TooltipComponent } from 'echarts/components'
import * as echarts from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import type { EChartsOption } from 'echarts'
import { onMounted, onUnmounted, ref, watch } from 'vue'

echarts.use([LineChart, GridComponent, TooltipComponent, CanvasRenderer])

const props = withDefaults(
  defineProps<{
    points: { date: string; dau: number }[]
    height?: string
  }>(),
  { height: '260px' },
)

const chartRef = ref<HTMLDivElement | null>(null)
let chart: echarts.ECharts | null = null

function shortDate(iso: string) {
  const parts = iso.split('-')
  if (parts.length < 3) return iso
  return `${Number(parts[1])}/${Number(parts[2])}`
}

function buildOption(): EChartsOption {
  return {
    grid: { left: 40, right: 16, top: 24, bottom: 32 },
    tooltip: {
      trigger: 'axis',
      formatter(params) {
        const list = Array.isArray(params) ? params : [params]
        const p = list[0]
        if (!p) return ''
        const idx = p.dataIndex ?? 0
        const point = props.points[idx]
        if (!point) return ''
        return `${point.date}<br/>DAU：${point.dau}`
      },
    },
    xAxis: {
      type: 'category',
      data: props.points.map((p) => shortDate(p.date)),
      boundaryGap: false,
      axisLabel: { color: '#737373', fontSize: 10, interval: 2 },
      axisTick: { show: false },
    },
    yAxis: {
      type: 'value',
      minInterval: 1,
      name: 'DAU',
      nameTextStyle: { color: '#a3a3a3', fontSize: 11 },
      axisLabel: { color: '#737373' },
      splitLine: { lineStyle: { color: '#f0f0f0' } },
    },
    series: [
      {
        type: 'line',
        data: props.points.map((p) => p.dau),
        smooth: true,
        symbol: 'circle',
        symbolSize: 6,
        showSymbol: props.points.length <= 14,
        lineStyle: { color: '#d97706', width: 2 },
        itemStyle: { color: '#d97706' },
        areaStyle: { color: 'rgba(217, 119, 6, 0.12)' },
      },
    ],
  }
}

function renderChart() {
  if (!chartRef.value) return
  if (!chart) chart = echarts.init(chartRef.value)
  chart.setOption(buildOption(), true)
}

function onResize() {
  chart?.resize()
}

watch(
  () => props.points,
  () => renderChart(),
  { deep: true },
)

onMounted(() => {
  renderChart()
  window.addEventListener('resize', onResize)
})

onUnmounted(() => {
  window.removeEventListener('resize', onResize)
  chart?.dispose()
  chart = null
})
</script>

<template>
  <div ref="chartRef" :style="{ height }" class="w-full" />
</template>
