<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import {
  adminGetAppRelease,
  adminPatchAppRelease,
  adminUploadAppApk,
  type AdminAppRelease,
} from '@/api/admin'
import { downloadDataUrl, makeQrDataUrl } from '@/utils/qrcodeDownload'

const loading = ref(true)
const saving = ref(false)
const uploading = ref(false)
const error = ref('')
const success = ref('')
const fileInput = ref<HTMLInputElement | null>(null)

const form = ref<AdminAppRelease>({
  enabled: true,
  android_version: '',
  android_apk_url: '',
  android_changelog: '',
  ios_note: 'iOS 版尚未上架 App Store，敬请期待。',
  ios_link: '',
})

const landingUrl = computed(() => `${window.location.origin}/download`)
const qrDataUrl = ref('')
const qrBusy = ref(false)
const copied = ref('')

async function refreshQr() {
  qrBusy.value = true
  try {
    qrDataUrl.value = await makeQrDataUrl(landingUrl.value, 280)
  } catch {
    qrDataUrl.value = ''
  } finally {
    qrBusy.value = false
  }
}

async function load() {
  loading.value = true
  error.value = ''
  try {
    form.value = await adminGetAppRelease()
    await refreshQr()
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '加载失败'
  } finally {
    loading.value = false
  }
}

async function save() {
  saving.value = true
  error.value = ''
  success.value = ''
  try {
    form.value = await adminPatchAppRelease({
      enabled: form.value.enabled,
      android_version: form.value.android_version.trim(),
      android_apk_url: form.value.android_apk_url.trim(),
      android_changelog: form.value.android_changelog.trim(),
      ios_note: form.value.ios_note.trim(),
      ios_link: form.value.ios_link.trim(),
    })
    success.value = '已保存'
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || '保存失败'
  } finally {
    saving.value = false
  }
}

async function onApkChange(ev: Event) {
  const input = ev.target as HTMLInputElement
  const file = input.files?.[0]
  input.value = ''
  if (!file) return
  const name = file.name.toLowerCase()
  if (!name.endsWith('.apk')) {
    error.value = '请选择 .apk 文件'
    return
  }
  uploading.value = true
  error.value = ''
  success.value = ''
  try {
    const data = await adminUploadAppApk(file)
    form.value.android_apk_url = data.android_apk_url
    form.value.enabled = true
    success.value = 'APK 已上传，请填写版本号后保存'
  } catch (e: unknown) {
    const msg = (e as { response?: { data?: { detail?: string } } })?.response?.data?.detail
    error.value = msg || 'APK 上传失败'
  } finally {
    uploading.value = false
  }
}

async function copyText(text: string, key: string) {
  try {
    await navigator.clipboard.writeText(text)
    copied.value = key
    setTimeout(() => {
      if (copied.value === key) copied.value = ''
    }, 1600)
  } catch {
    error.value = '复制失败，请手动选择复制'
  }
}

function downloadLandingQr() {
  if (!qrDataUrl.value) return
  downloadDataUrl(qrDataUrl.value, 'vloglish-download-qr.png')
}

watch(landingUrl, () => {
  void refreshQr()
})

onMounted(() => {
  void load()
})
</script>

<template>
  <div class="max-w-3xl space-y-6">
    <div>
      <h1 class="text-xl font-semibold text-neutral-900 dark:text-neutral-50">App 管理</h1>
      <p class="mt-1 text-sm text-neutral-500 dark:text-neutral-400">
        上传 Android 安装包，生成固定落地页二维码（换包不用换码）。
      </p>
    </div>

    <p v-if="error" class="rounded-lg bg-rose-50 dark:bg-rose-950/40 px-3 py-2 text-sm text-rose-700 dark:text-rose-200">
      {{ error }}
    </p>
    <p v-if="success" class="rounded-lg bg-emerald-50 dark:bg-emerald-950/40 px-3 py-2 text-sm text-emerald-800 dark:text-emerald-200">
      {{ success }}
    </p>

    <div v-if="loading" class="text-sm text-neutral-500">加载中…</div>

    <template v-else>
      <!-- 落地页二维码（固定） -->
      <section class="rounded-2xl border border-black/8 dark:border-white/10 bg-white dark:bg-neutral-900 p-4 sm:p-5 space-y-3">
        <div class="flex items-start justify-between gap-3">
          <div>
            <h2 class="text-sm font-semibold text-neutral-900 dark:text-neutral-50">落地页二维码（印刷用）</h2>
            <p class="mt-1 text-xs text-neutral-500">指向固定地址，更新 APK 后用户扫同一码即可。</p>
          </div>
          <label class="inline-flex items-center gap-2 text-xs font-medium text-neutral-700 dark:text-neutral-200">
            <input v-model="form.enabled" type="checkbox" class="rounded border-neutral-300" />
            公开页启用
          </label>
        </div>

        <div class="flex flex-col sm:flex-row gap-4 items-start">
          <div class="shrink-0 rounded-xl border border-black/8 dark:border-white/10 bg-white p-2">
            <img
              v-if="qrDataUrl"
              :src="qrDataUrl"
              alt="下载页二维码"
              class="w-[140px] h-[140px]"
              width="140"
              height="140"
            />
            <div v-else class="w-[140px] h-[140px] flex items-center justify-center text-xs text-neutral-400">
              {{ qrBusy ? '生成中…' : '无二维码' }}
            </div>
          </div>
          <div class="min-w-0 flex-1 space-y-2">
            <div class="flex flex-wrap items-center gap-2">
              <code class="text-xs break-all rounded-lg bg-neutral-100 dark:bg-neutral-800 px-2 py-1.5 text-neutral-800 dark:text-neutral-100">
                {{ landingUrl }}
              </code>
            </div>
            <div class="flex flex-wrap gap-2">
              <button
                type="button"
                class="px-3 py-1.5 rounded-lg text-xs font-semibold border border-black/10 dark:border-white/15 hover:bg-neutral-50 dark:hover:bg-neutral-800"
                @click="copyText(landingUrl, 'landing')"
              >
                {{ copied === 'landing' ? '已复制' : '复制落地页地址' }}
              </button>
              <button
                type="button"
                class="px-3 py-1.5 rounded-lg text-xs font-semibold bg-neutral-900 text-white dark:bg-neutral-100 dark:text-neutral-900 disabled:opacity-50"
                :disabled="!qrDataUrl"
                @click="downloadLandingQr"
              >
                下载二维码 PNG
              </button>
              <a
                :href="landingUrl"
                target="_blank"
                rel="noopener"
                class="px-3 py-1.5 rounded-lg text-xs font-semibold border border-black/10 dark:border-white/15 hover:bg-neutral-50 dark:hover:bg-neutral-800 inline-flex items-center"
              >
                预览落地页
              </a>
            </div>
          </div>
        </div>
      </section>

      <!-- Android -->
      <section class="rounded-2xl border border-black/8 dark:border-white/10 bg-white dark:bg-neutral-900 p-4 sm:p-5 space-y-3">
        <h2 class="text-sm font-semibold text-neutral-900 dark:text-neutral-50">Android</h2>

        <div class="grid sm:grid-cols-2 gap-3">
          <label class="block text-xs space-y-1">
            <span class="text-neutral-500">版本号</span>
            <input
              v-model="form.android_version"
              type="text"
              placeholder="例如 1.0.2"
              class="w-full rounded-lg border border-black/10 dark:border-white/15 bg-transparent px-3 py-2 text-sm"
            />
          </label>
          <div class="block text-xs space-y-1">
            <span class="text-neutral-500">安装包</span>
            <div class="flex gap-2">
              <input ref="fileInput" type="file" accept=".apk,application/vnd.android.package-archive" class="hidden" @change="onApkChange" />
              <button
                type="button"
                class="px-3 py-2 rounded-lg text-sm font-semibold bg-teal-600 text-white hover:bg-teal-500 disabled:opacity-50"
                :disabled="uploading"
                @click="fileInput?.click()"
              >
                {{ uploading ? '上传中…' : '上传 APK' }}
              </button>
            </div>
          </div>
        </div>

        <label class="block text-xs space-y-1">
          <span class="text-neutral-500">APK 下载地址</span>
          <div class="flex gap-2">
            <input
              v-model="form.android_apk_url"
              type="url"
              placeholder="上传后自动填充，也可粘贴外链"
              class="min-w-0 flex-1 rounded-lg border border-black/10 dark:border-white/15 bg-transparent px-3 py-2 text-sm"
            />
            <button
              type="button"
              class="shrink-0 px-3 py-2 rounded-lg text-xs font-semibold border border-black/10 dark:border-white/15 disabled:opacity-40"
              :disabled="!form.android_apk_url"
              @click="copyText(form.android_apk_url, 'apk')"
            >
              {{ copied === 'apk' ? '已复制' : '复制' }}
            </button>
          </div>
        </label>

        <label class="block text-xs space-y-1">
          <span class="text-neutral-500">更新说明（可选）</span>
          <textarea
            v-model="form.android_changelog"
            rows="3"
            placeholder="本次更新要点"
            class="w-full rounded-lg border border-black/10 dark:border-white/15 bg-transparent px-3 py-2 text-sm"
          />
        </label>
      </section>

      <!-- iOS -->
      <section class="rounded-2xl border border-black/8 dark:border-white/10 bg-white dark:bg-neutral-900 p-4 sm:p-5 space-y-3">
        <h2 class="text-sm font-semibold text-neutral-900 dark:text-neutral-50">iOS</h2>
        <label class="block text-xs space-y-1">
          <span class="text-neutral-500">未上架说明</span>
          <textarea
            v-model="form.ios_note"
            rows="2"
            class="w-full rounded-lg border border-black/10 dark:border-white/15 bg-transparent px-3 py-2 text-sm"
          />
        </label>
        <label class="block text-xs space-y-1">
          <span class="text-neutral-500">可选外链（TestFlight / 官网等）</span>
          <input
            v-model="form.ios_link"
            type="url"
            placeholder="https://"
            class="w-full rounded-lg border border-black/10 dark:border-white/15 bg-transparent px-3 py-2 text-sm"
          />
        </label>
      </section>

      <div class="flex gap-2">
        <button
          type="button"
          class="px-4 py-2 rounded-xl text-sm font-semibold bg-neutral-900 text-white dark:bg-neutral-100 dark:text-neutral-900 disabled:opacity-50"
          :disabled="saving || uploading"
          @click="save"
        >
          {{ saving ? '保存中…' : '保存设置' }}
        </button>
      </div>
    </template>
  </div>
</template>
