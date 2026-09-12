export function wxPlatform(): string {
  try {
    const platform = String(wx.getSystemInfoSync().platform || '').toLowerCase()
    if (['ios', 'android', 'devtools', 'windows', 'mac'].includes(platform)) {
      return platform
    }
  } catch {
    // ignore
  }
  return ''
}

export function wxDeviceKind(): 'ios' | 'android' | 'pc' | '' {
  const platform = wxPlatform()
  if (platform === 'ios') return 'ios'
  if (platform === 'android') return 'android'
  if (platform === 'devtools' || platform === 'windows' || platform === 'mac') return 'pc'
  return ''
}
