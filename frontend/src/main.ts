import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'
import './style.css'
import { useHighlightStyle } from './composables/useHighlightStyle'
import { initTheme, syncThemeOnRoute } from './composables/useTheme'

initTheme()
useHighlightStyle()

router.afterEach(() => syncThemeOnRoute())

createApp(App).use(createPinia()).use(router).mount('#app')
