<script setup lang="ts">
import { ref, watch } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { DEFAULT_AVATAR_KEYS } from '@/utils/defaultAvatars'
import UserAvatar from '@/components/UserAvatar.vue'
import AppIcon from '@/components/AppIcon.vue'

const props = withDefaults(defineProps<{
  open: boolean
}>(), { open: false })

const emit = defineEmits<{
  (e: 'update:open', value: boolean): void
  (e: 'avatar-changed'): void
}>()

const auth = useAuthStore()

const nickname = ref('')
const savingName = ref(false)
const uploading = ref(false)
const error = ref('')
const success = ref('')
const fileInput = ref<HTMLInputElement | null>(null)

const MAX_BYTES = 5 * 1024 * 1024

watch(
  () => props.open,
  (val) => {
    if (val) {
      nickname.value = (auth.user?.nickname || '').trim()
      error.value = ''
      success.value = ''
    }
  },
)

function close() {
  emit('update:open', false)
}

function flash(message: string) {
  success.value = message
  error.value = ''
  window.setTimeout(() => {
    if (success.value === message) success.value = ''
  }, 1800)
}

function fail(message: string) {
  error.value = message
  success.value = ''
}

/** 压缩到最长边 512px 的 JPEG，减小上传体积（移动端拍照常见数 MB） */
async function compressImage(file: File, maxSize = 512): Promise<Blob> {
  if (!file.type.startsWith('image/') || file.type === 'image/gif') return file
  try {
    const dataUrl = await new Promise<string>((resolve, reject) => {
      const reader = new FileReader()
      reader.onload = () => resolve(String(reader.result || ''))
      reader.onerror = () => reject(reader.error)
      reader.readAsDataURL(file)
    })
    const img = await new Promise<HTMLImageElement>((resolve, reject) => {
      const image = new Image()
      image.onload = () => resolve(image)
      image.onerror = () => reject(new Error('image load failed'))
      image.src = dataUrl
    })
    const scale = Math.min(1, maxSize / Math.max(img.width || 1, img.height || 1))
    const w = Math.max(1, Math.round((img.width || 1) * scale))
    const h = Math.max(1, Math.round((img.height || 1) * scale))
    const canvas = document.createElement('canvas')
    canvas.width = w
    canvas.height = h
    const ctx = canvas.getContext('2d')
    if (!ctx) return file
    ctx.drawImage(img, 0, 0, w, h)
    const blob = await new Promise<Blob | null>((resolve) =>
      canvas.toBlob(resolve, 'image/jpeg', 0.85),
    )
    return blob && blob.size > 0 ? blob : file
  } catch {
    return file
  }
}

function pickPhoto() {
  if (uploading.value) return
  fileInput.value?.click()
}

async function onFileChange(e: Event) {
  const input = e.target as HTMLInputElement
  const file = input.files?.[0]
  input.value = ''
  if (!file) return
  if (!file.type.startsWith('image/')) {
    fail('请选择图片文件')
    return
  }
  if (file.size > MAX_BYTES) {
    fail('图片不能超过 5MB')
    return
  }
  uploading.value = true
  error.value = ''
  success.value = ''
  try {
    const blob = await compressImage(file)
    if (blob.size > MAX_BYTES) {
      fail('图片压缩后仍超过 5MB，请换一张')
      return
    }
    await auth.uploadAvatar(blob, 'avatar.jpg')
    flash('头像已更新')
    emit('avatar-changed')
  } catch (err: unknown) {
    const detail =
      (err as { response?: { data?: { detail?: string } } })?.response?.data?.detail ||
      '上传失败，请重试'
    fail(detail)
  } finally {
    uploading.value = false
  }
}

async function selectPreset(key: string) {
  if (uploading.value) return
  if ((auth.user?.avatar_key || '') === key && !auth.user?.avatar_url) return
  uploading.value = true
  error.value = ''
  success.value = ''
  try {
    await auth.updateProfile({ avatar_key: key })
    flash('已切换为预设头像')
    emit('avatar-changed')
  } catch (err: unknown) {
    const detail =
      (err as { response?: { data?: { detail?: string } } })?.response?.data?.detail ||
      '切换失败'
    fail(detail)
  } finally {
    uploading.value = false
  }
}

async function saveNickname() {
  if (savingName.value) return
  savingName.value = true
  error.value = ''
  success.value = ''
  try {
    await auth.updateProfile({ nickname: nickname.value.trim() })
    flash('昵称已保存')
  } catch (err: unknown) {
    const detail =
      (err as { response?: { data?: { detail?: string } } })?.response?.data?.detail ||
      '保存失败'
    fail(detail)
  } finally {
    savingName.value = false
  }
}
</script>

<template>
  <div
    v-if="open"
    class="fixed inset-0 z-50 flex items-center justify-center bg-black/40 p-4 sm:p-8"
    @click.self="close"
  >
    <div
      class="max-h-[90vh] w-full max-w-md overflow-y-auto rounded-2xl border border-black/5 bg-white p-6 shadow-xl dark:border-white/10 dark:bg-neutral-800"
    >
      <div class="mb-4 flex items-center justify-between">
        <h3 class="text-lg font-medium">编辑资料</h3>
        <button type="button" class="text-ink-faint hover:text-ink" @click="close">
          <AppIcon name="close" class="h-5 w-5" />
        </button>
      </div>

      <!-- 头像预览 + 上传 -->
      <div class="flex flex-col items-center">
        <button
          type="button"
          class="group relative rounded-full ring-2 ring-brand transition active:scale-95 disabled:opacity-70"
          :disabled="uploading"
          aria-label="更换头像"
          @click="pickPhoto"
        >
          <UserAvatar
            :avatar-url="auth.user?.avatar_url"
            :avatar-key="auth.user?.avatar_key"
            :user-id="auth.user?.id"
            size-class="w-20 h-20"
            alt=""
          />
          <span
            class="absolute -bottom-1 -right-1 flex h-7 w-7 items-center justify-center rounded-full bg-ink text-ink-inverse shadow ring-2 ring-card"
          >
            <AppIcon :name="uploading ? 'spinner' : 'plus'" class="h-4 w-4" />
          </span>
        </button>
        <input ref="fileInput" type="file" accept="image/*" class="hidden" @change="onFileChange" />
        <button
          type="button"
          class="mt-2 text-[12px] font-medium text-brand disabled:opacity-60"
          :disabled="uploading"
          @click="pickPhoto"
        >
          {{ uploading ? '上传中…' : '从相册选择照片' }}
        </button>
        <p class="mt-1 text-[11px] text-neutral-400">支持 JPG / PNG / WebP / GIF，最大 5MB</p>
      </div>

      <!-- 预设头像 -->
      <div class="mt-5">
        <label class="mb-2 block text-sm text-neutral-600 dark:text-neutral-300">或选择预设头像</label>
        <div class="grid grid-cols-6 gap-2">
          <button
            v-for="key in DEFAULT_AVATAR_KEYS"
            :key="key"
            type="button"
            :class="[
              'flex items-center justify-center rounded-lg border p-1 transition',
              !auth.user?.avatar_url && auth.user?.avatar_key === key
                ? 'border-brand bg-brand-50 dark:bg-brand-900/20'
                : 'border-transparent hover:bg-neutral-50 dark:hover:bg-neutral-700/50',
            ]"
            :disabled="uploading"
            @click="selectPreset(key)"
          >
            <UserAvatar :avatar-key="key" size-class="w-9 h-9" alt="" />
          </button>
        </div>
      </div>

      <!-- 昵称 -->
      <div class="mt-5">
        <label class="mb-2 block text-sm text-neutral-600 dark:text-neutral-300">昵称</label>
        <div class="flex gap-2">
          <input
            v-model="nickname"
            type="text"
            maxlength="64"
            placeholder="请输入昵称"
            class="w-full rounded-lg border border-black/10 bg-white px-3 py-2 text-sm focus:ring-2 focus:ring-brand dark:border-white/10 dark:bg-neutral-800"
            @keyup.enter="saveNickname"
          />
          <button
            type="button"
            class="shrink-0 rounded-lg bg-neutral-900 px-4 py-2 text-sm text-white hover:bg-neutral-800 disabled:opacity-60"
            :disabled="savingName"
            @click="saveNickname"
          >
            {{ savingName ? '保存中…' : '保存昵称' }}
          </button>
        </div>
        <p class="mt-1 text-[11px] text-neutral-400">留空则使用邮箱作为显示名称</p>
      </div>

      <p v-if="error" class="mt-3 text-sm text-red-600">{{ error }}</p>
      <p v-if="success" class="mt-3 text-sm text-green-600">{{ success }}</p>

      <div class="mt-6 flex justify-end">
        <button
          type="button"
          class="rounded-lg border border-black/10 px-4 py-2 text-sm hover:bg-neutral-50 dark:border-white/10 dark:text-white dark:hover:bg-white/10"
          @click="close"
        >
          完成
        </button>
      </div>
    </div>
  </div>
</template>
