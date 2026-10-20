<script setup lang="ts">
import { onMounted, onUnmounted, ref, watch } from 'vue'
import { createFeedback, uploadFeedbackImage } from '@/api/feedback'
import { resolveMediaUrl } from '@/utils/mediaUrl'

const props = defineProps<{
  open: boolean
}>()

const emit = defineEmits<{
  'update:open': [value: boolean]
}>()

const title = ref('')
const body = ref('')
const imageUrls = ref<string[]>([])
const uploading = ref(false)
const submitting = ref(false)
const error = ref('')
const success = ref('')
const fileInput = ref<HTMLInputElement | null>(null)

const MAX_IMAGES = 3

function close() {
  emit('update:open', false)
}

function resetForm() {
  title.value = ''
  body.value = ''
  imageUrls.value = []
  error.value = ''
  success.value = ''
  uploading.value = false
  submitting.value = false
}

watch(
  () => props.open,
  (open) => {
    if (open) {
      error.value = ''
      success.value = ''
    } else {
      resetForm()
    }
  },
)

async function onImageChange(ev: Event) {
  const input = ev.target as HTMLInputElement
  const file = input.files?.[0]
  input.value = ''
  if (!file) return
  if (imageUrls.value.length >= MAX_IMAGES) {
    error.value = `最多上传 ${MAX_IMAGES} 张图片`
    return
  }
  if (!file.type.startsWith('image/')) {
    error.value = '请选择图片文件（JPG / PNG / WEBP / GIF）'
    return
  }
  uploading.value = true
  error.value = ''
  try {
    const data = await uploadFeedbackImage(file)
    imageUrls.value = [...imageUrls.value, data.image_url]
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '图片上传失败'
  } finally {
    uploading.value = false
  }
}

function removeImage(index: number) {
  imageUrls.value = imageUrls.value.filter((_, i) => i !== index)
}

async function submit() {
  const t = title.value.trim()
  const b = body.value.trim()
  if (!t) {
    error.value = '请填写标题'
    return
  }
  if (!b) {
    error.value = '请填写反馈内容'
    return
  }
  submitting.value = true
  error.value = ''
  success.value = ''
  try {
    const data = await createFeedback({
      title: t,
      body: b,
      image_urls: imageUrls.value,
    })
    success.value = data.message || '提交成功，感谢反馈'
    title.value = ''
    body.value = ''
    imageUrls.value = []
    setTimeout(() => close(), 900)
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '提交失败，请稍后重试'
  } finally {
    submitting.value = false
  }
}

function onKeydown(e: KeyboardEvent) {
  if (e.key === 'Escape' && props.open) close()
}

onMounted(() => window.addEventListener('keydown', onKeydown))
onUnmounted(() => window.removeEventListener('keydown', onKeydown))
</script>

<template>
  <Teleport to="body">
    <div
      v-if="open"
      class="fixed inset-0 z-[80] flex items-end sm:items-center justify-center p-0 sm:p-4"
      role="dialog"
      aria-modal="true"
      aria-labelledby="feedback-dialog-title"
    >
      <button
        type="button"
        class="absolute inset-0 bg-black/45 backdrop-blur-[1px]"
        aria-label="关闭"
        @click="close"
      />
      <div
        class="relative w-full sm:max-w-lg max-h-[92dvh] overflow-y-auto rounded-t-2xl sm:rounded-2xl bg-card shadow-xl border border-line-soft"
      >
        <div class="sticky top-0 z-10 flex items-center justify-between gap-3 px-4 py-3 border-b border-black/5 dark:border-white/10 bg-white/95 dark:bg-neutral-900/95 backdrop-blur">
          <h2 id="feedback-dialog-title" class="text-base font-semibold">意见反馈</h2>
          <button
            type="button"
            class="w-8 h-8 rounded-full text-neutral-500 hover:bg-sunken"
            aria-label="关闭"
            @click="close"
          >
            ×
          </button>
        </div>

        <form class="p-4 space-y-4" @submit.prevent="submit">
          <p class="text-xs text-neutral-500 leading-relaxed">
            欢迎提出产品建议、问题反馈或使用体验。我们会认真阅读每一条内容。
          </p>

          <div>
            <label class="block text-sm text-neutral-600 dark:text-neutral-300 mb-1">标题</label>
            <input
              v-model="title"
              type="text"
              maxlength="120"
              placeholder="一句话概括，例如：词卡加载较慢"
              class="w-full rounded-lg border border-line bg-white dark:bg-neutral-950 px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-amber-500/30"
            />
          </div>

          <div>
            <label class="block text-sm text-neutral-600 dark:text-neutral-300 mb-1">详细描述</label>
            <textarea
              v-model="body"
              rows="5"
              maxlength="4000"
              placeholder="请尽量说明出现场景、期望效果，便于我们复现与改进"
              class="w-full rounded-lg border border-line bg-white dark:bg-neutral-950 px-3 py-2 text-sm resize-y min-h-[7rem] focus:outline-none focus:ring-2 focus:ring-amber-500/30"
            />
          </div>

          <div>
            <div class="flex items-center justify-between gap-2 mb-2">
              <label class="text-sm text-neutral-600 dark:text-neutral-300">截图（可选，最多 {{ MAX_IMAGES }} 张）</label>
              <button
                type="button"
                class="text-xs px-2.5 py-1 rounded-lg border border-line hover:bg-sunken disabled:opacity-50"
                :disabled="uploading || imageUrls.length >= MAX_IMAGES"
                @click="fileInput?.click()"
              >
                {{ uploading ? '上传中…' : '添加图片' }}
              </button>
              <input
                ref="fileInput"
                type="file"
                accept="image/jpeg,image/png,image/webp,image/gif"
                class="hidden"
                @change="onImageChange"
              />
            </div>
            <div v-if="imageUrls.length" class="flex flex-wrap gap-2">
              <div
                v-for="(url, i) in imageUrls"
                :key="url"
                class="relative w-20 h-20 rounded-lg overflow-hidden border border-line bg-sunken"
              >
                <img :src="resolveMediaUrl(url)" alt="" class="w-full h-full object-cover" />
                <button
                  type="button"
                  class="absolute top-0.5 right-0.5 w-5 h-5 rounded-full bg-black/60 text-white text-xs leading-none"
                  aria-label="移除图片"
                  @click="removeImage(i)"
                >
                  ×
                </button>
              </div>
            </div>
          </div>

          <p v-if="error" class="text-sm text-red-600 dark:text-red-400">{{ error }}</p>
          <p v-else-if="success" class="text-sm text-emerald-600 dark:text-emerald-400">{{ success }}</p>

          <div class="flex justify-end gap-2 pt-1">
            <button
              type="button"
              class="px-3 py-2 rounded-lg text-sm text-neutral-600 hover:bg-sunken dark:text-neutral-300"
              @click="close"
            >
              取消
            </button>
            <button
              type="submit"
              class="px-4 py-2 rounded-lg text-sm font-medium bg-ink text-white hover:bg-neutral-800 dark:text-neutral-900 dark:hover:bg-white disabled:opacity-50"
              :disabled="submitting || uploading"
            >
              {{ submitting ? '提交中…' : '提交反馈' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </Teleport>
</template>
