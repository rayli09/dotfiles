#!/usr/bin/env bash
set -euo pipefail

source_path="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_root="$(mktemp -d)"
trap 'rm -rf "$test_root"' EXIT

for os in darwin linux; do
  destination="$test_root/$os"
  mkdir -p "$destination/.agents" "$test_root/legacy-skills"
  # Older installs linked the entire collection into the dotfiles checkout.
  ln -s "$test_root/legacy-skills" "$destination/.agents/skills"
  config="$test_root/$os.toml"
  cat > "$config" <<'CONFIG'
[data]
git_name = "Test Developer"
git_email = "dev@example.test"
work_email = ""
CONFIG
  cm=(chezmoi --source "$source_path" --destination "$destination"
    --config "$config" --persistent-state "$test_root/$os-state.boltdb"
    --cache "$test_root/cache" --override-data "{\"chezmoi\":{\"os\":\"$os\"}}")
  "${cm[@]}" apply --force
  "${cm[@]}" apply --force
  "${cm[@]}" verify

  [[ -d "$destination/.agents/skills" && ! -L "$destination/.agents/skills" ]]
  [[ -L "$destination/.agents/skills/public-market-signal-research" ]]
  [[ -f "$destination/.agents/skills/cloudflare/SKILL.md" ]]
  count=0
  for manifest in "$destination"/.agents/skills/*/SKILL.md; do
    [[ -f "$manifest" ]]
    count=$((count + 1))
  done
  [[ "$count" -eq 25 ]]
  cmp "$destination/.agents/AGENTS.md" "$source_path/agents/AGENTS.md"
  for path in .claude/CLAUDE.md .codex/AGENTS.md .config/opencode/AGENTS.md; do
    cmp "$destination/$path" "$source_path/agents/AGENTS.md"
  done
  [[ -L "$destination/.claude/skills" ]]
  [[ -f "$destination/.claude/skills/agents-sdk/SKILL.md" ]]
  [[ ! -e "$destination/README.md" && ! -e "$destination/agents" ]]
  [[ ! -e "$destination/scripts" && ! -e "$destination/packages" ]]

  if [[ "$os" == linux ]]; then
    [[ ! -e "$destination/Library" ]]
    if grep -q osxkeychain "$destination/.gitconfig" || grep -q UseKeychain "$destination/.ssh/config"; then
      echo "macOS Keychain settings leaked into Linux" >&2
      exit 1
    fi
  else
    grep -q osxkeychain "$destination/.gitconfig"
    grep -q UseKeychain "$destination/.ssh/config"
    [[ -f "$destination/Library/Application Support/Code/User/settings.json" ]]
  fi
  printf 'ok   %s: deployed, linked, and repeat-applied in a disposable home\n' "$os"
done
