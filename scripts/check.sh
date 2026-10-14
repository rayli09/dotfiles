#!/usr/bin/env bash
set -euo pipefail

source_path="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$source_path"

scripts=(
  install.sh
  packages/ubuntu.sh
  scripts/assert-macos-preferences.sh
  scripts/bootstrap-linux.sh
  scripts/bootstrap-macos.sh
  scripts/bootstrap-root.sh
  scripts/check.sh
  scripts/export-macos-preferences.sh
  scripts/macos-defaults.sh
  scripts/smoke.sh
  scripts/test-chezmoi.sh
  scripts/update-macos.sh
  scripts/update-ubuntu.sh
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
shellcheck "${scripts[@]}"

echo "Checking macOS defaults dry-run"
scripts/macos-defaults.sh --dry-run >/tmp/macos-defaults-dry-run.txt
grep -q 'defaults write com.apple.finder ShowPathbar' /tmp/macos-defaults-dry-run.txt
grep -q 'killall Dock' /tmp/macos-defaults-dry-run.txt

echo "Check passed."
