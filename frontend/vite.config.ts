import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import tailwindcss from '@tailwindcss/vite'
import { fileURLToPath, URL } from 'node:url'
import { readFileSync } from 'node:fs'

const pkg = JSON.parse(readFileSync(new URL('./package.json', import.meta.url), 'utf-8')) as {
  version: string
}

export default defineConfig(({ mode }) => {
  const isApp = mode === 'app'

  return {
    // Capacitor 本地加载需要相对资源路径
    base: isApp ? './' : '/',
    define: {
      __APP_VERSION__: JSON.stringify(pkg.version),
    },
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
          // 两小时长视频：下载 + 可能转码 + 上传七牛，整条链路按 4 小时预留
          timeout: 14_400_000,
          proxyTimeout: 14_400_000,
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
