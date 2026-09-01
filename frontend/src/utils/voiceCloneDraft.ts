/** 声音复刻录音草稿：按 userId 存 IndexedDB，关页不丢；复刻成功后可清。 */

const DB_NAME = 'vloglish-voice-clone'
const STORE = 'drafts'
const DB_VERSION = 1

export type VoiceCloneDraft = {
  userId: number
  blob: Blob
  mimeType: string
  durationMs: number
  text: string
  updatedAt: number
}

function openDb(): Promise<IDBDatabase> {
  return new Promise((resolve, reject) => {
    if (typeof indexedDB === 'undefined') {
      reject(new Error('IndexedDB 不可用'))
      return
    }
    const req = indexedDB.open(DB_NAME, DB_VERSION)
    req.onupgradeneeded = () => {
      const db = req.result
      if (!db.objectStoreNames.contains(STORE)) {
        db.createObjectStore(STORE, { keyPath: 'userId' })
      }
    }
    req.onsuccess = () => resolve(req.result)
    req.onerror = () => reject(req.error || new Error('打开草稿库失败'))
  })
}

export async function saveVoiceCloneDraft(draft: VoiceCloneDraft): Promise<void> {
  const db = await openDb()
  try {
    await new Promise<void>((resolve, reject) => {
      const tx = db.transaction(STORE, 'readwrite')
      tx.objectStore(STORE).put(draft)
      tx.oncomplete = () => resolve()
      tx.onerror = () => reject(tx.error || new Error('保存草稿失败'))
    })
  } finally {
    db.close()
  }
}

export async function loadVoiceCloneDraft(userId: number): Promise<VoiceCloneDraft | null> {
  const db = await openDb()
  try {
    return await new Promise((resolve, reject) => {
      const tx = db.transaction(STORE, 'readonly')
      const req = tx.objectStore(STORE).get(userId)
      req.onsuccess = () => {
        const row = req.result as VoiceCloneDraft | undefined
        resolve(row && row.blob ? row : null)
      }
      req.onerror = () => reject(req.error || new Error('读取草稿失败'))
    })
  } finally {
    db.close()
  }
}

export async function clearVoiceCloneDraft(userId: number): Promise<void> {
  const db = await openDb()
  try {
    await new Promise<void>((resolve, reject) => {
      const tx = db.transaction(STORE, 'readwrite')
      tx.objectStore(STORE).delete(userId)
      tx.oncomplete = () => resolve()
      tx.onerror = () => reject(tx.error || new Error('清除草稿失败'))
    })
  } finally {
    db.close()
  }
}
