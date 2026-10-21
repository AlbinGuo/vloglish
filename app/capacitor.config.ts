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
      backgroundColor: '#fafafa',
    },
    StatusBar: {
      // 与 frontend/src/native/shell.ts 一致：Android 不叠加，避免 header 被状态栏遮挡
      overlaysWebView: false,
      style: 'DARK',
      backgroundColor: '#ffffff',
    },
  },
}

export default config
