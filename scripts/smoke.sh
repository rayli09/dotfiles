#!/usr/bin/env bash
set -euo pipefail

required=(
  chezmoi
  git
  gh
  op
  mise
  node
  npm
  bun
  uv
  python
  go
  wrangler
  cloudflared
  starship
  zoxide
  direnv
)

missing=()

for cmd in "${required[@]}"; do
  if command -v "$cmd" >/dev/null 2>&1; then
    printf "ok   %s: %s\n" "$cmd" "$(command -v "$cmd")"
  else
    printf "miss %s\n" "$cmd"
    missing+=("$cmd")
  fi
done

if ((${#missing[@]})); then
  printf "\nMissing commands: %s\n" "${missing[*]}"
  exit 1
fi

echo "Smoke check passed."
