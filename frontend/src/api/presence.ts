import api from '@/api/client'

export async function sendPresenceHeartbeat() {
  await api.post('/api/presence/heartbeat/')
}
