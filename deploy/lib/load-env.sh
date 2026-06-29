#!/usr/bin/env bash
# 安全加载 .env（不触发 bash 对 $、#、! 的解析）
load_env_file() {
  local file="$1"
  local line key val

  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%%$'\r'}"
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    [[ "$line" =~ ^([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]] || continue

    key="${BASH_REMATCH[1]}"
    val="${BASH_REMATCH[2]}"

    if [[ "$val" =~ ^\'(.*)\'$ ]]; then
      val="${BASH_REMATCH[1]}"
    elif [[ "$val" =~ ^\"(.*)\"$ ]]; then
      val="${BASH_REMATCH[1]}"
    fi

    export "${key}=${val}"
  done < "$file"
}
