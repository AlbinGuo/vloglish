<script setup lang="ts">
import { BarChart } from 'echarts/charts'
import { GridComponent, TooltipComponent } from 'echarts/components'
import * as echarts from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import type { EChartsOption } from 'echarts'
import { onMounted, onUnmounted, ref, watch } from 'vue'
import type { AdminVisitHourBucket } from '@/api/admin'

echarts.use([BarChart, GridComponent, TooltipComponent, CanvasRenderer])

const props = withDefaults(
  defineProps<{
    hours: AdminVisitHourBucket[]
    peakHour?: number | null
    lowHour?: number | null
    height?: string
  }>(),
  { peakHour: null, lowHour: null, height: '280px' },
)

const chartRef = ref<HTMLDivElement | null>(null)
let chart: echarts.ECharts | null = null

function buildOption(): EChartsOption {
  const labels = props.hours.map((item) => item.label)
  const users = props.hours.map((item) => item.users)
  const colors = props.hours.map((item) => {
    if (props.peakHour != null && item.hour === props.peakHour) return '#d97706'
    if (props.lowHour != null && item.hour === props.lowHour) return '#a3a3a3'
    return '#525252'
  })

  return {
    grid: { left: 40, right: 16, top: 24, bottom: 36 },
    tooltip: {
      trigger: 'axis',
      axisPointer: { type: 'shadow' },
      formatter(params) {
        const list = Array.isArray(params) ? params : [params]
        const idx = list[0]?.dataIndex ?? 0
        const bucket = props.hours[idx]
        if (!bucket) return ''
        return `${bucket.label}<br/>到访人数：${bucket.users}<br/>会话次数：${bucket.sessions}`
      },
    },
    xAxis: {
      type: 'category',
      data: labels,
      axisLabel: {
        color: '#737373',
        interval: 1,
        fontSize: 10,
      },
      axisTick: { alignWithLabel: true },
    },
    yAxis: {
      type: 'value',
      minInterval: 1,
      name: '人数',
      nameTextStyle: { color: '#a3a3a3', fontSize: 11 },
      axisLabel: { color: '#737373' },
      splitLine: { lineStyle: { color: '#f0f0f0' } },
    },
    series: [
      {
        name: '到访人数',
        type: 'bar',
        data: users.map((value, index) => ({
          value,
          itemStyle: { color: colors[index], borderRadius: [4, 4, 0, 0] },
        })),
        barMaxWidth: 18,
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
  () => [props.hours, props.peakHour, props.lowHour],
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
