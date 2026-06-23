const POS_MAP: Record<string, string> = {
  noun: '名词',
  verb: '动词',
  adjective: '形容词',
  adverb: '副词',
  preposition: '介词',
  conjunction: '连词',
  pronoun: '代词',
  interjection: '感叹词',
  determiner: '限定词',
  phrase: '短语',
  idiom: '习语',
  abbreviation: '缩写',
}

export function posLabel(pos: string): string {
  const key = pos.trim().toLowerCase()
  return POS_MAP[key] ?? pos
}
