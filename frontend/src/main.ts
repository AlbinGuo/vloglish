import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'
import './style.css'
import { useHighlightStyle } from './composables/useHighlightStyle'
import { initTheme, syncThemeOnRoute } from './composables/useTheme'
import { applyPlatformClass } from './utils/platform'
import { initNativeShell } from './native/shell'

initTheme()
useHighlightStyle()
applyPlatformClass()

router.afterEach(() => syncThemeOnRoute())

createApp(App).use(createPinia()).use(router).mount('#app')

void initNativeShell()
