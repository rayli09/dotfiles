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
  scripts/install-tools.sh
  scripts/install-skills.sh
  scripts/check-skills.sh
  scripts/test-skills.sh
  scripts/tools-env.sh
  scripts/check-tools.sh
  scripts/test-tools.sh
  scripts/test-chezmoi.sh
  scripts/test-linux-install.sh
  scripts/test-scripts.sh
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
shellcheck -x "${scripts[@]}"

echo "Checking macOS defaults dry-run"
dry_run="$(mktemp)"
trap 'rm -f "$dry_run"' EXIT
scripts/macos-defaults.sh --dry-run > "$dry_run"
grep -q 'defaults write com.apple.finder ShowPathbar' "$dry_run"
grep -q 'killall Dock' "$dry_run"

echo "Check passed."
