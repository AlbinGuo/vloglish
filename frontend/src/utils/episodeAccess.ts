/** 该集是否对普通用户开放。旧接口没有字段时，用当前用户是否被拦下来兜底。 */
export function isOpenToFreeUsers(ep: {
  open_to_free_users?: boolean
  requires_membership?: boolean
}): boolean {
  if (typeof ep.open_to_free_users === 'boolean') return ep.open_to_free_users
  return !ep.requires_membership
}
