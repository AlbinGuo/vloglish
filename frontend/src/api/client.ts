import axios from 'axios'

const DEVICE_KEY = 'device_id'
const DEMO_CODE_KEY = 'demo_code'
const DEMO_VERIFIED_KEY = 'demo_code_verified'

export function getDeviceId(): string {
  let id = localStorage.getItem(DEVICE_KEY)
  if (!id) {
    id = crypto.randomUUID()
    localStorage.setItem(DEVICE_KEY, id)
  }
  return id
}

export function isDemoVerified(): boolean {
  return localStorage.getItem(DEMO_VERIFIED_KEY) === 'true'
}

export function getDemoCode(): string | null {
  return localStorage.getItem(DEMO_CODE_KEY)
}

export function setDemoVerified(code: string, affiliateCode?: string | null) {
  localStorage.setItem(DEMO_CODE_KEY, code)
  localStorage.setItem(DEMO_VERIFIED_KEY, 'true')
  if (affiliateCode) localStorage.setItem('a_code', affiliateCode)
}

const api = axios.create({
  baseURL: '',
  timeout: 30000,
  withCredentials: true,
  headers: { 'Content-Type': 'application/json' },
})

api.interceptors.request.use((config) => {
  config.headers = config.headers ?? {}
  config.headers['X-Device-Id'] = getDeviceId()
  config.headers['X-Timestamp'] = String(Math.floor(Date.now() / 1000))
  config.headers['X-Nonce'] = crypto.randomUUID()
  return config
})

export default api

export { DEVICE_KEY, DEMO_CODE_KEY, DEMO_VERIFIED_KEY }
