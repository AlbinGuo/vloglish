<script setup lang="ts">
import { RouterView } from 'vue-router'
import AppUpdateDialog from '@/components/app/AppUpdateDialog.vue'
import { useAppUpdateCheck } from '@/composables/useAppUpdateCheck'

const { open, info, later, onUpdateClicked } = useAppUpdateCheck()
</script>

<template>
  <RouterView />
  <AppUpdateDialog :open="open" :info="info" @later="later" @update="onUpdateClicked" />
</template>
