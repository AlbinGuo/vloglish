import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import tailwindcss from '@tailwindcss/vite'
import { fileURLToPath, URL } from 'node:url'

export default defineConfig(({ mode }) => {
  const isApp = mode === 'app'

  return {
    // Capacitor 本地加载需要相对资源路径
    base: isApp ? './' : '/',
    plugins: [vue(), tailwindcss()],
    resolve: {
      alias: {
        '@': fileURLToPath(new URL('./src', import.meta.url)),
      },
    },
    server: {
      proxy: {
        '/api': {
          target: process.env.VITE_API_PROXY || 'http://127.0.0.1:8000',
          changeOrigin: true,
          // 字幕导入含 DeepSeek 翻译/高亮，大文件可能需数分钟
          timeout: 900_000,
          proxyTimeout: 900_000,
          configure: (proxy) => {
            proxy.on('error', (_err, _req, res) => {
              if (res && 'writeHead' in res && !res.headersSent) {
                res.writeHead(502, { 'Content-Type': 'application/json' })
                res.end(
                  JSON.stringify({
                    detail: '后端未启动或代理中断，请确认 8000 端口 uvicorn 正在运行',
                  }),
                )
              }
            })
          },
        },
      },
    },
  }
})
