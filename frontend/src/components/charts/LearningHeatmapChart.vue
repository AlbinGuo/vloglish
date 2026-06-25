<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref, watch } from 'vue'
import {
  CalendarComponent,
  TooltipComponent,
  VisualMapComponent,
} from 'echarts/components'
import { HeatmapChart } from 'echarts/charts'
import * as echarts from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import type { EChartsOption } from 'echarts'

export interface LearningCalendarDay {
  date: string
  watch_time_sec: number
  sessions?: number
}

const props = withDefaults(
  defineProps<{
    days: LearningCalendarDay[]
    rangeDays?: number
    theme?: 'amber' | 'blue'
    height?: string
  }>(),
  {
    rangeDays: 90,
    theme: 'amber',
    height: '200px',
  },
)

echarts.use([CalendarComponent, TooltipComponent, VisualMapComponent, HeatmapChart, CanvasRenderer])

const chartRef = ref<HTMLDivElement | null>(null)
let chart: echarts.ECharts | null = null

function padDate(d: Date) {
  const y = d.getFullYear()
  const m = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `${y}-${m}-${day}`
}

function formatDuration(sec: number) {
  const h = Math.floor(sec / 3600)
  const m = Math.floor((sec % 3600) / 60)
  if (h > 0) return `${h} 小时 ${m} 分`
  if (m > 0) return `${m} 分钟`
  return `${sec} 秒`
}

function buildSeriesData() {
  const map = new Map(props.days.map((d) => [d.date, d]))
  const end = new Date()
  end.setHours(0, 0, 0, 0)
  const start = new Date(end)
  start.setDate(start.getDate() - (props.rangeDays - 1))

  const data: [string, number][] = []
  const cursor = new Date(start)
  while (cursor <= end) {
    const key = padDate(cursor)
    data.push([key, map.get(key)?.watch_time_sec ?? 0])
    cursor.setDate(cursor.getDate() + 1)
  }
  return { data, range: [padDate(start), padDate(end)] as [string, string] }
}

const maxValue = computed(() => {
  const values = props.days.map((d) => d.watch_time_sec)
  return Math.max(60, ...values, 0)
})

const colorRange = computed(() => {
  if (props.theme === 'blue') {
    return ['#f5f5f5', '#dbeafe', '#93c5fd', '#3b82f6', '#1d4ed8']
  }
  return ['#f5f5f5', '#fef3c7', '#fcd34d', '#f59e0b', '#d97706']
})

function buildOption(): EChartsOption {
  const { data, range } = buildSeriesData()
  const hasActivity = data.some(([, v]) => v > 0)

  return {
    tooltip: {
      formatter(params) {
        const item = (Array.isArray(params) ? params[0] : params) as { data?: [string, number] }
        if (!item?.data) return ''
        const [date, sec] = item.data
        const day = props.days.find((d) => d.date === date)
        const sessions = day?.sessions
        const sessionText = sessions != null ? `<br/>学习 ${sessions} 期` : ''
        return `${date}<br/>学习时长：${formatDuration(sec)}${sessionText}`
      },
    },
    visualMap: {
      show: hasActivity,
      min: 0,
      max: maxValue.value,
      calculable: true,
      orient: 'horizontal',
      left: 'center',
      bottom: 0,
      inRange: { color: colorRange.value },
      text: ['多', '少'],
      textStyle: { color: '#737373', fontSize: 11 },
    },
    calendar: {
      top: 36,
      left: 24,
      right: 24,
      bottom: hasActivity ? 48 : 16,
      range,
      cellSize: ['auto', 14],
      splitLine: { show: false },
      itemStyle: {
        borderWidth: 3,
        borderColor: '#fff',
        borderRadius: 2,
      },
      dayLabel: {
        firstDay: 1,
        nameMap: ['日', '一', '二', '三', '四', '五', '六'],
        color: '#a3a3a3',
        fontSize: 11,
      },
      monthLabel: {
        nameMap: 'cn',
        color: '#737373',
        fontSize: 11,
      },
      yearLabel: { show: false },
    },
    series: [
      {
        type: 'heatmap',
        coordinateSystem: 'calendar',
        data,
      },
    ],
  }
}

function renderChart() {
  if (!chartRef.value) return
  if (!chart) {
    chart = echarts.init(chartRef.value)
  }
  chart.setOption(buildOption(), true)
}

function handleResize() {
  chart?.resize()
}

onMounted(() => {
  renderChart()
  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  window.removeEventListener('resize', handleResize)
  chart?.dispose()
  chart = null
})

watch(
  () => [props.days, props.rangeDays, props.theme],
  () => renderChart(),
  { deep: true },
)
</script>

<template>
  <div ref="chartRef" class="w-full min-w-0" :style="{ height }" />
</template>
