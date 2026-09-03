import { request } from '../utils/request'

export type LearningSummary = {
  vocabulary_count: number
  streak_days: number
  learning_days: number
}

export type VocabularyItem = {
  id: number
  entry_id: number
  word: string
  ipa?: string
  definition_cn?: string
  source_episode_title?: string
  source_type?: string
  created_at: string
}

export function getLearningSummary() {
  return request<LearningSummary>({ url: '/api/learning/summary/' })
}

export function getVocabulary() {
  return request<VocabularyItem[]>({ url: '/api/learning/vocabulary/' })
}

export function removeVocabulary(entryId: number) {
  return request<void>({
    url: `/api/learning/vocabulary/${entryId}/`,
    method: 'DELETE',
  })
}
