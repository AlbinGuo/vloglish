<script setup lang="ts">
import { computed, ref } from 'vue'
import AppIcon from '@/components/AppIcon.vue'

const props = withDefaults(
  defineProps<{
    modelValue: string
    id?: string
    autocomplete?: string
    required?: boolean
    minlength?: number
    placeholder?: string
    inputClass?: string
  }>(),
  {
    required: false,
  },
)

const emit = defineEmits<{
  'update:modelValue': [value: string]
}>()

const visible = ref(false)

const inputType = computed(() => (visible.value ? 'text' : 'password'))

function onInput(event: Event) {
  emit('update:modelValue', (event.target as HTMLInputElement).value)
}
</script>

<template>
  <div class="relative">
    <input
      :id="id"
      :value="modelValue"
      :type="inputType"
      :autocomplete="autocomplete"
      :required="required"
      :minlength="minlength"
      :placeholder="placeholder"
      :class="
        inputClass ||
        'w-full rounded-lg border border-line dark:bg-neutral-800 dark:text-white px-3 py-2 pr-10 text-sm focus:outline-none focus:ring-2 focus:ring-neutral-900/10 dark:focus:ring-white/10'
      "
      @input="onInput"
    />
    <button
      type="button"
      class="absolute inset-y-0 right-0 flex w-11 cursor-pointer items-center justify-center text-neutral-400 transition-colors duration-200 hover:text-neutral-700 dark:hover:text-neutral-200"
      :aria-label="visible ? '隐藏密码' : '显示密码'"
      :title="visible ? '隐藏密码' : '显示密码'"
      @click="visible = !visible"
    >
      <AppIcon name="eye" v-if="visible" class="w-4 h-4" />
      <AppIcon name="eye-off" class="w-4 h-4" />
    </button>
  </div>
</template>
