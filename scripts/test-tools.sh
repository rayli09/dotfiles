#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_root="$(mktemp -d)"
trap 'rm -rf "$test_root"' EXIT

# Run as an unprivileged user in Containerfile.tools. Installation must leave
# personal shell/Git/agent configuration alone.
export DOTFILES_TOOLS_PREFIX="$test_root/tools"
snapshot_personal_config() {
  for path in .zshrc .bashrc .profile .gitconfig .agents .agents/AGENTS.md .claude/CLAUDE.md; do
    printf '%s: ' "$path"
    if [[ -f "$HOME/$path" ]]; then
      cksum "$HOME/$path"
    elif [[ -d "$HOME/$path" ]]; then
      printf 'directory\n'
    else
      printf 'absent\n'
    fi
  done
}
snapshot_personal_config > "$test_root/personal.before"
for phase in fresh repeat; do
  bash "$repo_root/scripts/install-tools.sh"
  bash --noprofile --norc -c 'source "$DOTFILES_TOOLS_PREFIX/env.sh"; bash "$1/scripts/check-tools.sh"' _ "$repo_root"
  snapshot_personal_config > "$test_root/personal.after"
  diff -u "$test_root/personal.before" "$test_root/personal.after"
  printf 'ok   %s portable tool installation and fresh-shell activation\n' "$phase"
done
