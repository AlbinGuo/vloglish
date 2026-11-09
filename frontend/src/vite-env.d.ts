/// <reference types="vite/client" />

declare const __APP_VERSION__: string

interface ImportMetaEnv {
  readonly VITE_APP_TARGET?: 'mobile' | string
  readonly VITE_API_BASE_URL?: string
  readonly VITE_API_PROXY?: string
  readonly VITE_APP_TEST_MODE?: string
  /** Android FCM 推送开关：'true' 时启用（需已放置 google-services.json） */
  readonly VITE_ANDROID_PUSH_ENABLED?: string
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}

declare module '*.svg' {
  const src: string
  export default src
}

declare module '*.vue' {
  import type { DefineComponent } from 'vue'
  const component: DefineComponent<object, object, unknown>
  export default component
}
