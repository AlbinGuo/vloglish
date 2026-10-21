<!--
  统一图标组件。

  用法：
    <AppIcon name="play" />                 默认尺寸
    <AppIcon name="play" :size="18" />       指定像素尺寸
    <AppIcon name="star" class="w-5 h-5" />  用 Tailwind 尺寸类
    <AppIcon name="star" :fill="cond ? 'a' : 'b'" />  动态颜色

  图标由项目里原本散落的 inline <svg> 收敛而来，视觉保持不变；
  同一语义的多个画法变体已归并为同一个 name。
-->
<script setup lang="ts">
import { computed } from 'vue'

interface IconDef {
  vb: string
  fill: string
  stroke: string
  sw: string
  inner: string
}

const props = withDefaults(
  defineProps<{
    name: string
    size?: number | string
    fill?: string
    stroke?: string
    strokeWidth?: number | string
  }>(),
  { size: undefined, fill: undefined, stroke: undefined, strokeWidth: undefined },
)

const ICONS: Record<string, IconDef> = {
  'align-left': { vb: "0 0 24 24", fill: "currentColor", stroke: "none", sw: "1.5", inner: "<path d=\"M4 6h16v2H4V6Zm0 5h10v2H4v-2Zm0 5h16v2H4v-2Z\"/>" },
  'arrow-uturn-left': { vb: "0 0 24 24", fill: "currentColor", stroke: "none", sw: "1.5", inner: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M12 2.25c-5.385 0-9.75 4.365-9.75 9.75s4.365 9.75 9.75 9.75 9.75-4.365 9.75-9.75S17.385 2.25 12 2.25Zm-4.28 9.22a.75.75 0 0 0 0 1.06l3 3a.75.75 0 1 0 1.06-1.06l-1.72-1.72h5.69a.75.75 0 0 0 0-1.5h-5.69l1.72-1.72a.75.75 0 0 0-1.06-1.06l-3 3Z\" />" },
  'arrow-uturn-right': { vb: "0 0 24 24", fill: "currentColor", stroke: "none", sw: "1.5", inner: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M12 2.25c-5.385 0-9.75 4.365-9.75 9.75s4.365 9.75 9.75 9.75 9.75-4.365 9.75-9.75S17.385 2.25 12 2.25Zm4.28 10.28a.75.75 0 0 0 0-1.06l-3-3a.75.75 0 1 0-1.06 1.06l1.72 1.72H8.25a.75.75 0 0 0 0 1.5h5.69l-1.72 1.72a.75.75 0 0 0 1.06 1.06l3-3Z\" />" },
  'article': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "1.8", inner: "<path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M4.5 5.25h10.5A1.5 1.5 0 0 1 16.5 6.75v11.25H6A1.5 1.5 0 0 1 4.5 16.5V5.25Z\" /> <path stroke-linecap=\"round\" d=\"M16.5 6.75h3v11.25a1.5 1.5 0 0 1-1.5 1.5\" />" },
  'bell': { vb: "0 0 24 24", fill: "currentColor", stroke: "none", sw: "1.5", inner: "<path fill-rule=\"evenodd\" d=\"M5.25 9a6.75 6.75 0 0 1 13.5 0v.75c0 2.123.8 4.077 2.125 5.548a.75.75 0 0 1-.513 1.297H3.638a.75.75 0 0 1-.513-1.297A6.75 6.75 0 0 0 5.25 9Zm2.25 0a4.5 4.5 0 1 1 9 0v.75c0 1.214.455 2.34 1.204 3.192a.75.75 0 0 1-.204 1.058H6.5a.75.75 0 0 1-.204-1.058A4.5 4.5 0 0 0 7.5 9.75V9Z\" clip-rule=\"evenodd\" /> <path d=\"M9 18.75a3 3 0 0 0 6 0H9Z\" />" },
  'bell-solid': { vb: "0 0 24 24", fill: "currentColor", stroke: "none", sw: "1.5", inner: "<path fill=\"#fbbf24\" d=\"M12 2.25A6.75 6.75 0 0 0 5.25 9c0 2.387 1.24 4.485 3.12 5.67.3.19.48.52.48.87v.46c0 .41.34.75.75.75h4.8c.41 0 .75-.34.75-.75v-.46c0-.35.18-.68.48-.87A6.74 6.74 0 0 0 18.75 9 6.75 6.75 0 0 0 12 2.25Z\" /> <path fill=\"#f59e0b\" d=\"M9.6 18.6h4.8c.33 0 .6.27.6.6v.15c0 .99-.81 1.8-1.8 1.8h-2.4c-.99 0-1.8-.81-1.8-1.8V19.2c0-.33.27-.6.6-.6Z\" />" },
  'book-open': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "1.75", inner: "<path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M12 6.042A8.967 8.967 0 0 0 6 3.75c-1.052 0-2.062.18-3 .512v14.25A8.987 8.987 0 0 1 6 18c2.305 0 4.408.867 6 2.292m0-14.25a8.966 8.966 0 0 1 6-2.292c1.052 0 2.062.18 3 .512v14.25A8.987 8.987 0 0 0 18 18a8.967 8.967 0 0 0-6 2.292m0-14.25v14.25\" />" },
  'bookmark': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "1.75", inner: "<path stroke-linejoin=\"round\" d=\"M6 4.5A1.5 1.5 0 0 1 7.5 3h9A1.5 1.5 0 0 1 18 4.5V19l-6-3.5L6 19V4.5Z\" />" },
  'brand-mark': { vb: "0 0 32 32", fill: "currentColor", stroke: "none", sw: "1.5", inner: "<circle cx=\"16\" cy=\"16\" r=\"16\" class=\"fill-neutral-900 dark:fill-white\" /> <path d=\"M10.2 9.6h3.05l2.55 8.35L18.35 9.6h3.05L16.95 23.1h-1.9L10.2 9.6Z\" class=\"fill-white dark:fill-neutral-900\" />" },
  'calendar': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "1.75", inner: "<rect x=\"3\" y=\"5\" width=\"18\" height=\"16\" rx=\"2\" /> <path stroke-linecap=\"round\" d=\"M8 3v4M16 3v4M3 10h18\" />" },
  'chart-bar': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "1.75", inner: "<path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M7 19V11M12 19V5M17 19V15\" /> <path stroke-linecap=\"round\" d=\"M4 19h16\" />" },
  'chat-bubble': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "1.75", inner: "<path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M7.5 8.25h9m-9 3.75h5.25M21 12c0 4.556-4.03 8.25-9 8.25a9.76 9.76 0 0 1-2.53-.33l-3.97 1.32a.75.75 0 0 1-.95-.95l1.32-3.97A8.7 8.7 0 0 1 3 12c0-4.556 4.03-8.25 9-8.25s9 3.694 9 8.25Z\" />" },
  'check': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "2.2", inner: "<path d=\"M9 6l6 6-6 6\" stroke-linecap=\"round\" stroke-linejoin=\"round\" />" },
  'check-circle': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "1.8", inner: "<path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M6 9l6 6 6-6\" />" },
  'check-xs': { vb: "0 0 20 20", fill: "currentColor", stroke: "none", sw: "1.5", inner: "<path fill-rule=\"evenodd\" d=\"M16.704 5.29a1 1 0 0 1 .006 1.414l-7.25 7.3a1 1 0 0 1-1.432.012l-3.25-3.2a1 1 0 1 1 1.4-1.426l2.53 2.49 6.54-6.58a1 1 0 0 1 1.456-.01Z\" clip-rule=\"evenodd\" />" },
  'chevron-down': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "2", inner: "<path d=\"m6 9 6 6 6-6\" />" },
  'chevron-down-xs': { vb: "0 0 20 20", fill: "currentColor", stroke: "none", sw: "1.5", inner: "<path fill-rule=\"evenodd\" d=\"M5.23 7.21a.75.75 0 0 1 1.06.02L10 11.17l3.71-3.94a.75.75 0 1 1 1.08 1.04l-4.25 4.5a.75.75 0 0 1-1.08 0l-4.25-4.5a.75.75 0 0 1 .02-1.06Z\" clip-rule=\"evenodd\" />" },
  'chevron-left': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "2", inner: "<path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"m15 18-6-6 6-6\" />" },
  'chevron-left-xs': { vb: "0 0 20 20", fill: "currentColor", stroke: "none", sw: "1.5", inner: "<path fill-rule=\"evenodd\" d=\"M12.79 5.23a.75.75 0 0 1-.02 1.06L8.832 10l3.938 3.71a.75.75 0 1 1-1.04 1.08l-4.5-4.25a.75.75 0 0 1 0-1.08l4.5-4.25a.75.75 0 0 1 1.06.02Z\" clip-rule=\"evenodd\" />" },
  'chevron-right': { vb: "0 0 20 20", fill: "currentColor", stroke: "none", sw: "1.5", inner: "<path fill-rule=\"evenodd\" d=\"M7.21 14.77a.75.75 0 0 1 .02-1.06L11.168 10 7.23 6.29a.75.75 0 1 1 1.04-1.08l4.5 4.25a.75.75 0 0 1 0 1.08l-4.5 4.25a.75.75 0 0 1-1.06-.02Z\" clip-rule=\"evenodd\" />" },
  'clipboard': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "1.75", inner: "<path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M10.5 1.5H8.25A2.25 2.25 0 0 0 6 3.75v16.5a2.25 2.25 0 0 0 2.25 2.25h7.5A2.25 2.25 0 0 0 18 20.25V3.75a2.25 2.25 0 0 0-2.25-2.25H13.5m-3 0V3h3V1.5m-3 0h3m-3 18.75h3\" />" },
  'clipboard-list': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "1.75", inner: "<path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M8.25 6.75h7.5M8.25 12h7.5m-7.5 5.25h4.5M3.75 6.75A2.25 2.25 0 0 1 6 4.5h12A2.25 2.25 0 0 1 20.25 6.75v10.5A2.25 2.25 0 0 1 18 19.5H6a2.25 2.25 0 0 1-2.25-2.25V6.75Z\" />" },
  'clock': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "1.7", inner: "<circle cx=\"12\" cy=\"13\" r=\"8\" /> <path stroke-linecap=\"round\" d=\"M12 9v4l2.5 1.5M9 4h6\" />" },
  'close': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "2", inner: "<path d=\"M18 6L6 18M6 6l12 12\" />" },
  'crown': { vb: "0 0 24 24", fill: "currentColor", stroke: "none", sw: "1.5", inner: "<path d=\"M5 16 3 5l5.5 5L12 4l3.5 6L21 5l-2 11H5Zm0 2h14v2H5v-2Z\" />" },
  'document-text': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "1.7", inner: "<rect x=\"5\" y=\"4\" width=\"14\" height=\"16\" rx=\"2\" /> <path stroke-linecap=\"round\" d=\"M8 8h8M8 12h8M8 16h5\" />" },
  'external-link': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "2", inner: "<path d=\"M15 3h6v6\" stroke-linecap=\"round\" stroke-linejoin=\"round\" /> <path d=\"M10 14 21 3\" stroke-linecap=\"round\" /> <path d=\"M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6\" stroke-linecap=\"round\" stroke-linejoin=\"round\" />" },
  'eye': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "1.5", inner: "<path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z\" /> <path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z\" />" },
  'eye-off': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "1.5", inner: "<path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M3.98 8.223A10.477 10.477 0 0 0 1.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.451 10.451 0 0 1 12 4.5c4.756 0 8.773 3.162 10.065 7.498a10.522 10.522 0 0 1-4.293 5.774M6.228 6.228 3 3m3.228 3.228 3.65 3.65m7.894 7.894L21 21m-3.228-3.228-3.65-3.65m0 0a3 3 0 1 0-4.243-4.243m4.242 4.242L9.88 9.88\" />" },
  'fast-forward': { vb: "0 0 24 24", fill: "currentColor", stroke: "none", sw: "1.5", inner: "<path d=\"M6 6v12l8.5-6L6 6Zm10 0h2v12h-2V6Z\"/>" },
  'flag': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "1.75", inner: "<path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M17.593 3.322c1.1.128 1.907 1.077 1.907 2.185V21L12 17.25 4.5 21V5.507c0-1.108.806-2.057 1.907-2.185a48.507 48.507 0 0 1 11.186 0Z\" />" },
  'flame': { vb: "0 0 24 24", fill: "currentColor", stroke: "none", sw: "1.5", inner: "<path d=\"M12 2c1.2 2.8 3.6 4.2 3.6 7.2 0 2.2-1.4 3.8-3.2 3.8-1.8 0-3.2-1.6-3.2-3.8 0-1.4.6-2.4 1.4-3.4C9.8 5.2 10.8 3.8 12 2Zm0 20c3.6 0 6.5-2.6 6.5-6.1 0-2.8-1.2-4.4-2.6-5.9-.4-.4-1-.1-1 .4.2 1.4-.4 2.8-1.6 3.6-1 .7-1.6 1.8-1.6 3 0 2.2 1.8 4 4 4Z\" />" },
  'fullscreen': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "1.5", inner: "<path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M9 9V4.5M9 9H4.5M9 9 3.75 3.75M9 15v4.5M9 15H4.5M9 15l-5.25 5.25M15 9h4.5M15 9V4.5M15 9l5.25-5.25M15 15h4.5M15 15v4.5m0-4.5 5.25 5.25\" />" },
  'fullscreen-exit': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "1.5", inner: "<path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M3.75 3.75v4.5m0-4.5h4.5m-4.5 0L9 9M3.75 20.25v-4.5m0 4.5h4.5m-4.5 0L9 15M20.25 3.75h-4.5m4.5 0v4.5m0-4.5L15 9m5.25 11.25h-4.5m4.5 0v-4.5m0 4.5L15 15\" />" },
  'headphones': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "1.75", inner: "<path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M3 18v-6a9 9 0 0 1 18 0v6\" /> <path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M21 19a2 2 0 0 1-2 2h-1a2 2 0 0 1-2-2v-3a2 2 0 0 1 2-2h3zM3 19a2 2 0 0 0 2 2h1a2 2 0 0 0 2-2v-3a2 2 0 0 0-2-2H3z\" />" },
  'history': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "1.5", inner: "<path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M12 6v6h4.5m4.5 0a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z\" />" },
  'home': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "1.75", inner: "<path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 0 0 1 1h3m10-11l2 2m-2-2v10a1 1 0 0 1-1 1h-3m-6 0a1 1 0 0 0 1-1v-4a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1v4a1 1 0 0 0 1 1m-6 0h6\" />" },
  'inbox': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "1.75", inner: "<path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M8.25 9.75h7.5m-7.5 3h4.5M4.5 19.5l2.25-2.25H18a2.25 2.25 0 0 0 2.25-2.25V6.75A2.25 2.25 0 0 0 18 4.5H6A2.25 2.25 0 0 0 3.75 6.75v10.5c0 .621.504 1.125 1.125 1.125H4.5Z\" />" },
  'loader-circle': { vb: "0 0 20 20", fill: "none", stroke: "currentColor", sw: "1.5", inner: "<circle cx=\"10\" cy=\"10\" r=\"7\" stroke=\"currentColor\" stroke-width=\"2\" class=\"opacity-25\" /> <path d=\"M17 10a7 7 0 0 0-7-7\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" />" },
  'logout': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "1.75", inner: "<path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M15.75 9V5.25A2.25 2.25 0 0 0 13.5 3h-6a2.25 2.25 0 0 0-2.25 2.25v13.5A2.25 2.25 0 0 0 7.5 21h6a2.25 2.25 0 0 0 2.25-2.25V15M12 9l-3 3m0 0 3 3m-3-3h12.75\" />" },
  'loop': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "1.5", inner: "<path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M19.5 12c0-1.232-.046-2.453-.138-3.662a4.006 4.006 0 0 0-3.7-3.7 48.678 48.678 0 0 0-7.324 0 4.006 4.006 0 0 0-3.7 3.7c-.017.22-.032.441-.046.662M19.5 12l3-3m-3 3-3-3m-12 3c0 1.232.046 2.453.138 3.662a4.006 4.006 0 0 0 3.7 3.7 48.656 48.656 0 0 0 7.324 0 4.006 4.006 0 0 0 3.7-3.7c.017-.22.032-.441.046-.662M4.5 12l3 3m-3-3-3 3\" />" },
  'menu': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "2", inner: "<path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M4 6h16M4 12h16M4 18h16\" />" },
  'mic': { vb: "0 0 24 24", fill: "currentColor", stroke: "none", sw: "1.5", inner: "<path d=\"M12 14a3 3 0 0 0 3-3V6a3 3 0 1 0-6 0v5a3 3 0 0 0 3 3zm5-3a5 5 0 0 1-10 0H5a7 7 0 0 0 6 6.92V21h2v-3.08A7 7 0 0 0 19 11h-2z\" />" },
  'mic-off': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "2", inner: "<path d=\"M9 9v2a3 3 0 0 0 5.1 2.1\" stroke-linecap=\"round\" /> <path d=\"M15 9.5V6a3 3 0 0 0-5.2-2\" stroke-linecap=\"round\" /> <path d=\"M5 11a7 7 0 0 0 11.2 5.5\" stroke-linecap=\"round\" /> <path d=\"M19 11a6.9 6.9 0 0 0-.3-2\" stroke-linecap=\"round\" /> <path d=\"M12 18v3M4 4l16 16\" stroke-linecap=\"round\" />" },
  'moon': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "1.75", inner: "<path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M21 14.5A7.5 7.5 0 0 1 9.5 3 6.5 6.5 0 1 0 21 14.5Z\" />" },
  'more-horizontal': { vb: "0 0 24 24", fill: "currentColor", stroke: "none", sw: "1.5", inner: "<circle cx=\"5\" cy=\"12\" r=\"1.5\" /> <circle cx=\"12\" cy=\"12\" r=\"1.5\" /> <circle cx=\"19\" cy=\"12\" r=\"1.5\" />" },
  'notification': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "1.5", inner: "<path d=\"M4 6h16v12H4zM8 10h.01M12 14l3-3 3 4\" stroke-linecap=\"round\" stroke-linejoin=\"round\" />" },
  'pause': { vb: "0 0 24 24", fill: "currentColor", stroke: "none", sw: "1.5", inner: "<rect x=\"6\" y=\"5\" width=\"4\" height=\"14\" rx=\"1\" /> <rect x=\"14\" y=\"5\" width=\"4\" height=\"14\" rx=\"1\" />" },
  'pause-circle': { vb: "0 0 24 24", fill: "currentColor", stroke: "none", sw: "1.5", inner: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M2.25 12c0-5.385 4.365-9.75 9.75-9.75s9.75 4.365 9.75 9.75-4.365 9.75-9.75 9.75S2.25 17.385 2.25 12ZM9 8.25a.75.75 0 0 0-.75.75v6c0 .414.336.75.75.75h.75a.75.75 0 0 0 .75-.75V9a.75.75 0 0 0-.75-.75H9Zm5.25 0a.75.75 0 0 0-.75.75v6c0 .414.336.75.75.75H15a.75.75 0 0 0 .75-.75V9a.75.75 0 0 0-.75-.75h-.75Z\" />" },
  'pause-square': { vb: "0 0 24 24", fill: "currentColor", stroke: "none", sw: "1.5", inner: "<path d=\"M18 18V6l-8.5 6L18 18ZM6 6h2v12H6V6Z\" />" },
  'play': { vb: "0 0 24 24", fill: "currentColor", stroke: "none", sw: "1.5", inner: "<path d=\"M8 5v14l11-7L8 5z\" />" },
  'play-circle': { vb: "0 0 24 24", fill: "currentColor", stroke: "none", sw: "1.5", inner: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M2.25 12c0-5.385 4.365-9.75 9.75-9.75s9.75 4.365 9.75 9.75-4.365 9.75-9.75 9.75S2.25 17.385 2.25 12Zm14.024-.983a1.125 1.125 0 0 1 0 1.966l-5.603 3.113A1.125 1.125 0 0 1 9 15.113V8.887c0-.857.921-1.4 1.671-.983l5.603 3.113Z\" />" },
  'plus': { vb: "0 0 20 20", fill: "currentColor", stroke: "none", sw: "1.5", inner: "<path d=\"M10.75 4.75a.75.75 0 0 0-1.5 0v4.5h-4.5a.75.75 0 0 0 0 1.5h4.5v4.5a.75.75 0 0 0 1.5 0v-4.5h4.5a.75.75 0 0 0 0-1.5h-4.5v-4.5Z\" />" },
  'pulse-dot': { vb: "0 0 24 24", fill: "currentColor", stroke: "none", sw: "1.5", inner: "<circle cx=\"12\" cy=\"12\" r=\"4\" />" },
  'repeat': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "1.7", inner: "<path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M7 7h8a4 4 0 0 1 0 8h-1M17 17H9a4 4 0 0 1 0-8h1\" /> <path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"m15 5 2 2-2 2M9 19l-2-2 2-2\" />" },
  'search': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "1.75", inner: "<circle cx=\"11\" cy=\"11\" r=\"6\" /> <path stroke-linecap=\"round\" d=\"M20 20l-3.5-3.5\" />" },
  'settings': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "1.75", inner: "<path d=\"M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6Z\" /> <path d=\"M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z\" />" },
  'skip-forward': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "1.7", inner: "<path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M5 6v12l6-6V6l8 6-8 6\" />" },
  'sliders': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "1.75", inner: "<path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M10.5 6h9.75M10.5 6a1.5 1.5 0 1 1-3 0m3 0a1.5 1.5 0 1 0-3 0M3.75 6H7.5m3 12h9.75m-9.75 0a1.5 1.5 0 0 1-3 0m3 0a1.5 1.5 0 0 0-3 0m-3.75 0H7.5m9-6h3.75m-3.75 0a1.5 1.5 0 0 1-3 0m3 0a1.5 1.5 0 0 0-3 0m-9.75 0h9.75\" />" },
  'sparkle': { vb: "0 0 24 24", fill: "currentColor", stroke: "currentColor", sw: "1.8", inner: "<path d=\"M12 2.5l2.7 6.3 6.8.6-5.2 4.5 1.6 6.6L12 16.9 6.1 20.5l1.6-6.6L2.5 9.4l6.8-.6L12 2.5z\" />" },
  'sparkles': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "2", inner: "<path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M12 3l1.6 4.2L18 9l-4.4 1.8L12 15l-1.6-4.2L6 9l4.4-1.8L12 3z\" /> <path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M19 14l.7 1.8L21.5 16.5l-1.8.7L19 19l-.7-1.8L16.5 16.5l1.8-.7L19 14z\" />" },
  'spinner': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "2.2", inner: "<path d=\"M12 3a9 9 0 1 0 9 9\" stroke-linecap=\"round\" />" },
  'star': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "1.5", inner: "<path d=\"M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z\" />" },
  'stop': { vb: "0 0 24 24", fill: "currentColor", stroke: "none", sw: "1.5", inner: "<rect x=\"6\" y=\"6\" width=\"12\" height=\"12\" rx=\"2\" />" },
  'subtitles': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "1.5", inner: "<path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5\" />" },
  'subtitles-off': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "1.5", inner: "<path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M3.75 6.75h16.5M3.75 12h10.5m-10.5 5.25H12\" /> <path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"m15 15 6 6m0-6-6 6\" />" },
  'sun': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "1.75", inner: "<circle cx=\"12\" cy=\"12\" r=\"4\" /> <path stroke-linecap=\"round\" d=\"M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4\" />" },
  'swipe-hint': { vb: "-70 -96 230 230", fill: "currentColor", stroke: "none", sw: "1.5", inner: "<path fill=\"#fff\" d=\"M48.512001037597656,-41.6719970703125 C48.512001037597656,-41.6719970703125 48.512001037597656,41.6719970703125 48.512001037597656,41.6719970703125 C48.512001037597656,68.44577026367188 26.773773193359375,90.18399810791016 0,90.18399810791016 C0,90.18399810791016 0,90.18399810791016 0,90.18399810791016 C-26.773773193359375,90.18399810791016 -48.512001037597656,68.44577026367188 -48.512001037597656,41.6719970703125 C-48.512001037597656,41.6719970703125 -48.512001037597656,-41.6719970703125 -48.512001037597656,-41.6719970703125 C-48.512001037597656,-68.44577026367188 -26.773773193359375,-90.18399810791016 0,-90.18399810791016 C0,-90.18399810791016 0,-90.18399810791016 0,-90.18399810791016 C26.773773193359375,-90.18399810791016 48.512001037597656,-68.44577026367188 48.512001037597656,-41.6719970703125z\" /> <rect x=\"-3.5\" y=\"-58\" width=\"7\" height=\"28\" rx=\"3.5\" fill=\"#c8c8cc\" /> <g class=\"listen-swipe-hint__hand\"> <g transform=\"translate(-36,-8) scale(0.56)\"> <g transform=\"matrix(1,0,0,1,84.54600524902344,114.55500030517578)\"> <path fill=\"#fff\" d=\"M101.375,-82.75 C95.2020034790039,-81.04000091552734 91,-72.375 91.625,-67.75 C92.25,-63.125 121.25,27.625 119.75,29.25 C117.5,30.5 111.375,16 101.75,9.5 C92.25,3.0850000381469727 70.25,9 72.75,16.5 C74.72599792480469,22.429000854492188 122.25,92.375 126.75,98 C130.61700439453125,102.83300018310547 150.75,120.5 174.75,120.25 C198.75,120 224.86700439453125,106.12300109863281 236,85 C245.75,66.5 245.625,54.5 242.125,37.75 C240.22799682617188,28.66900062561035 227.375,-12.75 226.125,-16.25 C224.875,-19.75 219.77099609375,-25.989999771118164 212.625,-26.5 C203.875,-27.125 199.375,-20.5 198.125,-20.625 C196.10000610351562,-20.82699966430664 192.875,-28 182.625,-28 C174.11700439453125,-28 170.25,-20.125 168,-19.875 C165.75,-19.625 163.5,-29 152.875,-29.125 C140.7969970703125,-29.267000198364258 138.5,-21.75 136.25,-20.375 C134.875,-25.25 120.42900085449219,-70.88999938964844 119.375,-74.625 C118,-79.5 109.5,-85 101.375,-82.75z\" /> </g> </g> </g>" },
  'text-lines': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "2", inner: "<path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M4 12c1.5-2 3-3 4.5-3S11 10 12 12s1.5 3 3.5 3 3-1 4.5-3\" /> <path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M4 17c1.5-2 3-3 4.5-3S11 15 12 17s1.5 3 3.5 3 3-1 4.5-3\" />" },
  'trash': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "2", inner: "<path d=\"M3 6h18\" stroke-linecap=\"round\" /> <path d=\"M8 6V4h8v2\" stroke-linecap=\"round\" stroke-linejoin=\"round\" /> <path d=\"M19 6l-1 14H6L5 6\" stroke-linecap=\"round\" stroke-linejoin=\"round\" />" },
  'trash-2': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "2", inner: "<path d=\"M3 6h18M8 6V4h8v2M19 6l-1 14H6L5 6\" stroke-linecap=\"round\" stroke-linejoin=\"round\" />" },
  'user': { vb: "0 0 24 24", fill: "none", stroke: "currentColor", sw: "1.75", inner: "<path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"M12 18v-5.25m0 0a6.01 6.01 0 0 0 1.5-.189m-1.5.189a6.01 6.01 0 0 1-1.5-.189m3.75 7.478a12.06 12.06 0 0 1-4.5 0m3.75 2.383a14.406 14.406 0 0 1-3 0M14.25 18v-.192c0-.983.658-1.823 1.508-2.316a7.5 7.5 0 1 0-7.517 0c.85.493 1.509 1.333 1.509 2.316V18\" />" },
  'volume-up': { vb: "0 0 24 24", fill: "currentColor", stroke: "none", sw: "1.5", inner: "<path d=\"M3 9v6h4l5 5V4L7 9H3zm13.5 3c0-1.77-1.02-3.29-2.5-4.03v8.05c1.48-.73 2.5-2.25 2.5-4.02z\" />" },
}

const def = computed(() => ICONS[props.name])
</script>

<template>
  <svg
    v-if="def"
    :viewBox="def.vb"
    :width="size"
    :height="size"
    :fill="fill ?? def.fill"
    :stroke="stroke ?? def.stroke"
    :stroke-width="strokeWidth ?? def.sw"
    aria-hidden="true"
    focusable="false"
    v-html="def.inner"
  />
</template>
