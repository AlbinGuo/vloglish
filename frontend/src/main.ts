import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'
import './style.css'
import { useHighlightStyle } from './composables/useHighlightStyle'

useHighlightStyle()

createApp(App).use(createPinia()).use(router).mount('#app')
