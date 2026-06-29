const autoplayNextLoad = { value: false }

export function requestEpisodeAutoplay() {
  autoplayNextLoad.value = true
}

export function consumeEpisodeAutoplay() {
  const shouldAutoplay = autoplayNextLoad.value
  autoplayNextLoad.value = false
  return shouldAutoplay
}
