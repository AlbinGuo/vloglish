import api from '@/api/client'
import type { EntryDetail } from '@/types'

export interface WordLookupMeta {
  article_id?: string
  segment_id?: number
  video_id?: string
  subtitle_id?: number
  episode_id?: number
}

const byLookupKey = new Map<string, EntryDetail | null>()
const byEntryId = new Map<number, EntryDetail | null>()
const inflightByKey = new Map<string, Promise<EntryDetail | null>>()
const inflightByEntryId = new Map<number, Promise<EntryDetail | null>>()

/** 与后端 make_cache_key 使用相同归一化规则 */
export function makeWordLookupKey(word: string, type: 1 | 2, context: string): string {
  return `${word.trim().toLowerCase()}|${type}|${context.trim()}`
}

function wordTypeKey(word: string, type: 1 | 2): string {
  return `${word.trim().toLowerCase()}|${type}`
}

function rememberEntry(entry: EntryDetail, word: string, type: 1 | 2, context: string) {
  byEntryId.set(entry.id, entry)
  byLookupKey.set(makeWordLookupKey(word, type, context), entry)
  byLookupKey.set(wordTypeKey(word, type), entry)
  if (entry.headword) {
    byLookupKey.set(makeWordLookupKey(entry.headword, type, context), entry)
    byLookupKey.set(wordTypeKey(entry.headword, type), entry)
  }
}

export function getCachedWordLookup(word: string, type: 1 | 2, context: string): EntryDetail | null | undefined {
  const key = makeWordLookupKey(word, type, context)
  if (byLookupKey.has(key)) return byLookupKey.get(key) ?? null
  const byWord = byLookupKey.get(wordTypeKey(word, type))
  if (byWord !== undefined) return byWord
  return undefined
}

export function getCachedEntryById(entryId: number): EntryDetail | null | undefined {
  if (byEntryId.has(entryId)) return byEntryId.get(entryId) ?? null
  return undefined
}

export function cacheWordLookupEntry(entry: EntryDetail, word: string, type: 1 | 2, context: string) {
  rememberEntry(entry, word, type, context)
}

export function makeLookupStub(
  word: string,
  type: 1 | 2,
  gloss = '',
): EntryDetail {
  return {
    id: 0,
    headword: word,
    category: type === 2 ? '短语' : '单词',
    pronunciations: [],
    definitions: gloss
      ? [
          {
            id: 0,
            pos: '',
            definition_en: '',
            definition_cn: gloss,
            usage_pattern: '',
            note: '',
            order: 0,
            examples: [],
          },
        ]
      : [],
    exam_tags: [],
    favorite: false,
  }
}

async function requestWordLookup(
  word: string,
  type: 1 | 2,
  context: string,
  meta: WordLookupMeta = {},
): Promise<EntryDetail> {
  const { data } = await api.get<EntryDetail>('/api/lookup/', {
    params: { word, type, context, ...meta },
  })
  return data
}

async function requestEntryDetail(entryId: number): Promise<EntryDetail> {
  const { data } = await api.get<EntryDetail>('/api/entry-detail/', {
    params: { entry_id: entryId },
  })
  return data
}

/** 按单词 + 上下文查词（阅读页、视频页通用），带内存缓存与并发去重 */
export async function fetchWordLookup(
  word: string,
  type: 1 | 2,
  context: string,
  meta: WordLookupMeta = {},
): Promise<EntryDetail | null> {
  const key = makeWordLookupKey(word, type, context)
  const exact = byLookupKey.get(key)
  if (exact !== undefined) return exact

  const reused = byLookupKey.get(wordTypeKey(word, type))
  if (reused) {
    if (!inflightByKey.has(key)) {
      const refresh = requestWordLookup(word, type, context, meta)
        .then((entry) => {
          rememberEntry(entry, word, type, context)
          return entry
        })
        .catch(() => reused)
        .finally(() => {
          inflightByKey.delete(key)
        })
      inflightByKey.set(key, refresh)
    }
    return reused
  }

  const pending = inflightByKey.get(key)
  if (pending) return pending

  const promise = requestWordLookup(word, type, context, meta)
    .then((entry) => {
      rememberEntry(entry, word, type, context)
      return entry
    })
    .catch(() => {
      byLookupKey.set(key, null)
      return null
    })
    .finally(() => {
      inflightByKey.delete(key)
    })

  inflightByKey.set(key, promise)
  return promise
}

/** 按 entry_id 获取词条（生词本补全等），带内存缓存 */
export async function fetchEntryById(entryId: number): Promise<EntryDetail | null> {
  const cached = byEntryId.get(entryId)
  if (cached !== undefined) return cached

  const pending = inflightByEntryId.get(entryId)
  if (pending) return pending

  const promise = requestEntryDetail(entryId)
    .then((entry) => {
      byEntryId.set(entryId, entry)
      return entry
    })
    .catch(() => {
      byEntryId.set(entryId, null)
      return null
    })
    .finally(() => {
      inflightByEntryId.delete(entryId)
    })

  inflightByEntryId.set(entryId, promise)
  return promise
}

/** @deprecated 使用 fetchWordLookup */
export const fetchSegmentVocabEntry = (
  word: string,
  type: 1 | 2,
  context: string,
  meta: { article_id: string; segment_id?: number },
) => fetchWordLookup(word, type, context, meta)
