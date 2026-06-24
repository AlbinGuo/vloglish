import ukIcon from '@/assets/svg/uk.svg'
import usIcon from '@/assets/svg/us.svg'

export const accentOptions = [
  { value: '美国', label: '美式', icon: ukIcon },
  { value: '英国', label: '英式', icon: usIcon },
] as const

export function accentIconFor(accent: string) {
  return accentOptions.find((opt) => opt.value === accent)?.icon
}
