#!/usr/bin/env bash
# Check the health of THIS machine's deployed dotfiles.
#
# scripts/check.sh verifies the repository; doctor checks the live machine:
# deployed files match the source, the pinned tools run, no chezmoi-managed
# symlink is broken, and the tool directories are on PATH. Every section
# runs even if an earlier one fails; the exit code is non-zero on any failure.
set -uo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
scratch_dir="$(mktemp -d)"
trap 'rm -rf "$scratch_dir"' EXIT

failures=0

section() {
  printf '\n== %s ==\n' "$1"
}

ok() {
  printf 'ok   %s\n' "$1"
}

fail() {
  printf 'FAIL %s\n' "$1"
  failures=$((failures + 1))
}

has_chezmoi() {
  command -v chezmoi >/dev/null 2>&1
}

section "Deployed files (chezmoi verify)"
if ! has_chezmoi; then
  fail "chezmoi is not on PATH"
elif chezmoi --source "$repo_root" verify --exclude scripts >/dev/null 2>&1; then
  ok "deployed files match this source"
else
  fail "deployed files differ from this source (inspect with: chezmoi diff)"
fi

section "Portable tools (scripts/check-tools.sh)"
if bash "$repo_root/scripts/check-tools.sh" >"$scratch_dir/tools.log" 2>&1; then
  ok "all pinned tools run at their mise.toml versions"
else
  fail "check-tools.sh reported problems; last lines:"
  tail -n 5 "$scratch_dir/tools.log" | sed 's/^/     /'
fi

section "Symlinks (chezmoi-managed targets)"
if ! has_chezmoi; then
  fail "chezmoi is not on PATH; cannot enumerate managed targets"
else
  broken=0
  while IFS= read -r target; do
    deployed="$HOME/$target"
    if [[ -L "$deployed" && ! -e "$deployed" ]]; then
      printf 'FAIL broken symlink: %s -> %s\n' "$deployed" "$(readlink "$deployed")"
      broken=$((broken + 1))
    fi
  done < <(chezmoi --source "$repo_root" managed --exclude scripts 2>/dev/null)
  if [[ "$broken" -eq 0 ]]; then
    ok "no broken symlinks among managed targets"
  else
    failures=$((failures + broken))
  fi
fi

section "PATH (tool directories)"
tools_prefix="${DOTFILES_TOOLS_PREFIX:-$HOME/.local/share/dotfiles-tools}"
for dir in "$HOME/.local/bin" "$tools_prefix/bin" "$tools_prefix/mise/data/shims"; do
  if [[ ! -d "$dir" ]]; then
    fail "$dir does not exist (not installed)"
    continue
  fi
  case ":$PATH:" in
    *":$dir:"*) ok "$dir is on PATH" ;;
    *) fail "$dir exists but is not on PATH (open a new shell, or source scripts/tools-env.sh)" ;;
  esac
done

printf '\n'
if [[ "$failures" -gt 0 ]]; then
  printf 'doctor: %d check(s) failed\n' "$failures"
  exit 1
fi
printf 'doctor: all checks passed\n'
