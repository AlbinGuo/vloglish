<script setup lang="ts">
import { computed, ref } from 'vue'
import { useCatalogStore } from '@/stores/catalog'

const store = useCatalogStore()

const viewDate = ref(new Date())

const monthLabel = computed(() => {
  const y = viewDate.value.getFullYear()
  const m = viewDate.value.getMonth() + 1
  return `${y} 年 ${m} 月`
})

const weeks = computed(() => {
  const year = viewDate.value.getFullYear()
  const month = viewDate.value.getMonth()
  const first = new Date(year, month, 1)
  const startOffset = (first.getDay() + 6) % 7
  const daysInMonth = new Date(year, month + 1, 0).getDate()
  const cells: { date: string; day: number; disabled: boolean; isToday: boolean }[] = []

  for (let i = 0; i < startOffset; i++) cells.push({ date: '', day: 0, disabled: true, isToday: false })

  const today = new Date()
  for (let d = 1; d <= daysInMonth; d++) {
    const dt = new Date(year, month, d)
    const iso = `${year}-${String(month + 1).padStart(2, '0')}-${String(d).padStart(2, '0')}`
    cells.push({
      date: iso,
      day: d,
      disabled: dt > today,
      isToday:
        dt.getFullYear() === today.getFullYear() &&
        dt.getMonth() === today.getMonth() &&
        dt.getDate() === today.getDate(),
    })
  }
  return cells
})

function prevMonth() {
  viewDate.value = new Date(viewDate.value.getFullYear(), viewDate.value.getMonth() - 1, 1)
}

function nextMonth() {
  viewDate.value = new Date(viewDate.value.getFullYear(), viewDate.value.getMonth() + 1, 1)
}

function selectDay(cell: (typeof weeks.value)[number]) {
  if (!cell.date || cell.disabled) return
  const next = store.filters.date === cell.date ? undefined : cell.date
  store.setDateFilter(next)
}
</script>

<template>
  <div class="rounded-2xl border border-line-soft bg-card p-4">
    <div class="flex items-center justify-between mb-3">
      <button type="button" class="p-1 rounded hover:bg-sunken text-neutral-500" @click="prevMonth">‹</button>
      <span class="text-sm font-medium">{{ monthLabel }}</span>
      <button type="button" class="p-1 rounded hover:bg-sunken text-neutral-500" @click="nextMonth">›</button>
    </div>
    <div class="grid grid-cols-7 gap-1 text-center text-[10px] text-neutral-400 mb-1">
      <span v-for="w in ['一', '二', '三', '四', '五', '六', '日']" :key="w">{{ w }}</span>
    </div>
    <div class="grid grid-cols-7 gap-1">
      <button
        v-for="(cell, i) in weeks"
        :key="i"
        type="button"
        class="aspect-square rounded-lg text-xs flex items-center justify-center transition cursor-pointer"
        :class="[
          !cell.day ? 'invisible' : '',
          cell.disabled ? 'text-neutral-300 dark:text-neutral-600 cursor-not-allowed' : 'hover:bg-sunken',
          store.filters.date === cell.date ? 'bg-ink text-ink-inverse hover:bg-neutral-800 dark:hover:bg-neutral-200' : '',
          cell.isToday && store.filters.date !== cell.date ? 'ring-1 ring-neutral-300 dark:ring-neutral-600' : '',
        ]"
        :disabled="!cell.date || cell.disabled"
        @click="selectDay(cell)"
      >
        {{ cell.day || '' }}
      </button>
    </div>
  </div>
</template>
