#!/usr/bin/env bash
# Run the verification suites the changed paths require.
# Usage: verify.sh [--plan] [path ...]
# With no paths, every uncommitted change is used.
set -euo pipefail

source_path="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$source_path"

usage() {
  cat <<'USAGE'
Usage: verify.sh [--plan] [path ...]

Selects the verification suites the changed paths require and runs them.

  --plan   print the selected suites without running them
  path     a changed path; repeatable. Defaults to every uncommitted change.

Suites: check, test-scripts, test-chezmoi, test-skills, test-tools.
scripts/test-linux-install.sh needs its container image and never runs here.
USAGE
}

plan_only=false
paths=()
for argument in "$@"; do
  case "$argument" in
    --plan) plan_only=true ;;
    -h|--help) usage; exit 0 ;;
    -*) printf 'verify: unknown option: %s\n' "$argument" >&2; exit 2 ;;
    *) paths+=("$argument") ;;
  esac
done

if ((${#paths[@]} == 0)); then
  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    entry="${line:3}"
    paths+=("${entry##* -> }")
  done < <(git status --porcelain)
fi

selected=(check)
add() {
  local suite
  for suite in "${selected[@]}"; do
    [[ "$suite" == "$1" ]] && return 0
  done
  selected+=("$1")
}

for path in "${paths[@]}"; do
  case "$path" in
    scripts/*.sh|scripts/*.mjs|scripts/*.ps1) add test-scripts ;;
  esac
  case "$path" in
    dot_*|private_*|executable_*|.chezmoi*|agents/AGENTS.md|install.sh|Brewfile.macos|packages/*)
      add test-chezmoi
      ;;
  esac
  case "$path" in
    skills-lock.json|scripts/skills.mjs|agents/personal-skills/*|agents/runtime/*|scripts/*skill*)
      add test-skills
      ;;
  esac
  case "$path" in
    mise.toml|mise.lock|.mise/*|Brewfile.macos|packages/*|scripts/*tool*)
      add test-tools
      ;;
  esac
done

if $plan_only; then
  printf 'plan: %s\n' "${selected[*]}"
  exit 0
fi

for suite in "${selected[@]}"; do
  printf 'run  scripts/%s.sh\n' "$suite"
  if ! bash "scripts/$suite.sh"; then
    printf 'verify: failed in scripts/%s.sh\n' "$suite" >&2
    exit 1
  fi
done

if [[ " ${selected[*]} " == *' test-chezmoi '* ]]; then
  printf 'note scripts/test-linux-install.sh needs its container and did not run\n'
fi
printf 'verify: %s suite(s) passed\n' "${#selected[@]}"
