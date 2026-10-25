#!/usr/bin/env bash
set -euo pipefail

# This installs packages and changes the test user's home. Run only in the
# disposable integration image, never against a developer's home.
if [[ ! -f /.dockerenv || "$USER" != tester || "$HOME" != /home/tester ]]; then
  echo "Run this test in Containerfile.integration as tester." >&2
  exit 1
fi

source_path="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Snapshot COPY'd files (including unpublished edits) as the installer remote.
# URL rewriting is container-local; install.sh exercises its normal clone/pull.
git -C "$source_path" init -b main
git -C "$source_path" add .
git -C "$source_path" -c user.name=Test -c user.email=test@example.test \
  commit -m "Integration test snapshot"
export GIT_CONFIG_COUNT=1
export GIT_CONFIG_KEY_0="url.file://$source_path.insteadOf"
export GIT_CONFIG_VALUE_0=https://github.com/rayli09/dotfiles.git

echo "Fresh installation"
bash "$source_path/install.sh"
export PATH="$HOME/.local/bin:$HOME/.bun/bin:$PATH"
installed_source="$(chezmoi source-path)"
test "$(git -C "$installed_source" rev-parse HEAD)" = "$(git -C "$source_path" rev-parse HEAD)"

echo "Repeat installation"
bash "$source_path/install.sh"
test "$(git -C "$installed_source" rev-parse HEAD)" = "$(git -C "$source_path" rev-parse HEAD)"
chezmoi verify

echo "Package updates"
bash "$installed_source/scripts/update-ubuntu.sh"

echo "Fresh shell verification"
zsh -lic '
  set -e
  cd "$HOME"
  bash "$(chezmoi source-path)/scripts/smoke.sh"
  for tool in node python go; do
    resolved="$(command -v "$tool")"
    [[ "$resolved" == "$HOME/.local/share/dotfiles-tools/"* ]]
    printf "shared tools own %s: %s\n" "$tool" "$resolved"
  done
  node --version
  python --version
  go version
  bun --version
  uv --version
  wrangler --version
  docker --version
  [[ -L "$HOME/.claude/skills" ]]
  [[ -f "$HOME/.agents/skills/cloudflare/SKILL.md" ]]
  [[ -L "$HOME/.agents/AGENTS.md" ]]
'

echo "Linux installation, repeat setup, updates, and runtime ownership passed."
