#!/usr/bin/env bash
set -euo pipefail

source_path="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$source_path"

scripts=(
  install.sh
  packages/*.sh
  scripts/*.sh
)

echo "Checking shell syntax"
for script in "${scripts[@]}"; do
  bash -n "$script"
done

echo "Running shellcheck"
if ! command -v shellcheck >/dev/null 2>&1; then
  echo "Missing shellcheck. Install it with: brew install shellcheck" >&2
  exit 127
fi
shellcheck -x "${scripts[@]}"

echo "Checking macOS defaults dry-run"
dry_run="$(mktemp)"
trap 'rm -f "$dry_run"' EXIT
scripts/macos-defaults.sh --dry-run > "$dry_run"
grep -q 'defaults write com.apple.finder ShowPathbar' "$dry_run"
grep -q 'killall Dock' "$dry_run"

echo "Check passed."
