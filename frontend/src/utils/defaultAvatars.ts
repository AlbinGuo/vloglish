import bear from '@/assets/avatars/bear.svg'
import cat from '@/assets/avatars/cat.svg'
import deer from '@/assets/avatars/deer.svg'
import fox from '@/assets/avatars/fox.svg'
import koala from '@/assets/avatars/koala.svg'
import otter from '@/assets/avatars/otter.svg'
import owl from '@/assets/avatars/owl.svg'
import panda from '@/assets/avatars/panda.svg'
import penguin from '@/assets/avatars/penguin.svg'
import rabbit from '@/assets/avatars/rabbit.svg'
import sparrow from '@/assets/avatars/sparrow.svg'
import whale from '@/assets/avatars/whale.svg'

export const DEFAULT_AVATAR_KEYS = [
  'fox',
  'owl',
  'cat',
  'bear',
  'rabbit',
  'whale',
  'panda',
  'deer',
  'penguin',
  'koala',
  'sparrow',
  'otter',
] as const

export type DefaultAvatarKey = (typeof DEFAULT_AVATAR_KEYS)[number]

const AVATAR_SRC: Record<DefaultAvatarKey, string> = {
  fox,
  owl,
  cat,
  bear,
  rabbit,
  whale,
  panda,
  deer,
  penguin,
  koala,
  sparrow,
  otter,
}

export function isDefaultAvatarKey(key: string | null | undefined): key is DefaultAvatarKey {
  return Boolean(key && key in AVATAR_SRC)
}

export function avatarSrc(key?: string | null, userId?: number): string {
  if (isDefaultAvatarKey(key)) return AVATAR_SRC[key]
  const idx = Math.abs(Number(userId) || 0) % DEFAULT_AVATAR_KEYS.length
  return AVATAR_SRC[DEFAULT_AVATAR_KEYS[idx]]
}
