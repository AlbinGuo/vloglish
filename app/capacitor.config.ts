import type { CapacitorConfig } from '@capacitor/cli'

const config: CapacitorConfig = {
  appId: 'cc.vloglish.app',
  appName: 'Vloglish',
  webDir: 'www',
  server: {
    androidScheme: 'https',
  },
  plugins: {
    SplashScreen: {
      launchAutoHide: true,
      backgroundColor: '#111111',
    },
    StatusBar: {
      // 启动阶段（WebView 还没执行 JS、shell.ts 尚未按平台纠正之前）也要和
      // 深色启动图(#111111)一致：否则 iOS 状态栏那条会先显示系统白底，
      // 随后 shell.ts 切到叠加模式再变深色 —— 表现为「顶部闪一下」。
      // 运行期仍由 frontend/src/native/shell.ts 按平台纠正：
      // iOS 叠加(immersive)，Android 不叠加（避免 header 被状态栏遮挡）。
      overlaysWebView: true,
      style: 'DARK',
      backgroundColor: '#111111',
    },
  },
}

export default config
