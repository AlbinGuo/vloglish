/// <reference path="./types/index.d.ts" />

interface IMiniUser {
  id: number
  email: string
  nickname: string | null
  phone: string | null
  is_member: boolean
  avatar_key: string | null
  member_until?: string | null
  wx_bound?: boolean
  wechat_only?: boolean
}

interface IAppOption {
  globalData: {
    user: IMiniUser | null
    loggingIn: boolean
  }
  ensureLogin: () => Promise<IMiniUser | null>
}
