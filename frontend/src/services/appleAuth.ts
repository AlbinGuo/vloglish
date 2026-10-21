/**
 * Sign in with Apple 桥接。
 *
 * 依赖原生插件 @capacitor-community/apple-sign-in（已装到 app/，jsName = SignInWithApple）。
 * 通过 Capacitor 运行时动态拿插件，避免把插件 Web 实现打包进前端；仅在 iOS 原生壳内可用。
 */
import { getNativePlatform, isNativePlatform } from '@/utils/platform'

/** 与 App 的 Bundle ID 一致；Apple 原生授权会忽略该值，但保持正确以防万一 */
const APPLE_CLIENT_ID = 'cc.vloglish.app'

export interface AppleSignInProfile {
  identityToken: string
  authorizationCode: string
  fullName?: string
}

type ApplePlugin = {
  authorize: (options: Record<string, unknown>) => Promise<AppleAuthorizeResponse>
}

interface AppleAuthorizeResponse {
  response?: {
    user?: string | null
    email?: string | null
    givenName?: string | null
    familyName?: string | null
    identityToken?: string
    authorizationCode?: string
  }
}

function getApplePlugin(): ApplePlugin | null {
  try {
    const Cap = (window as unknown as { Capacitor?: { registerPlugin?: (n: string) => ApplePlugin } })
      .Capacitor
    if (Cap?.registerPlugin) return Cap.registerPlugin('SignInWithApple')
  } catch {
    /* ignore */
  }
  return null
}

/** 仅 iOS 原生 App 内可用（Web / Android 隐藏入口） */
export function isAppleSignInAvailable(): boolean {
  return isNativePlatform() && getNativePlatform() === 'ios'
}

function randomNonce(len = 16): string {
  const bytes = new Uint8Array(len)
  crypto.getRandomValues(bytes)
  return Array.from(bytes, (b) => b.toString(16).padStart(2, '0')).join('')
}

/** 唤起 Apple 授权，返回 identityToken 等，供后端校验 */
export async function signInWithApple(): Promise<AppleSignInProfile> {
  if (!isAppleSignInAvailable()) throw new Error('当前环境不支持 Apple 登录')
  const plugin = getApplePlugin()
  if (!plugin) throw new Error('Apple 登录组件未就绪，请更新到最新版本 App')

  const res = await plugin.authorize({
    clientId: APPLE_CLIENT_ID,
    redirectURI: '',
    scopes: 'name email',
    state: 'vloglish',
    nonce: randomNonce(),
  })
  const r = res?.response
  if (!r?.identityToken) throw new Error('未获取到 Apple 身份令牌')

  const nameParts = [r.givenName, r.familyName].map((s) => (s || '').trim()).filter(Boolean)
  return {
    identityToken: r.identityToken,
    authorizationCode: r.authorizationCode || '',
    fullName: nameParts.length ? nameParts.join(' ') : undefined,
  }
}
