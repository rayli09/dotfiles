#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_root="$(mktemp -d)"
trap 'rm -rf "$test_root"' EXIT

# Run as an unprivileged user in Containerfile.tools. Installation must leave
# personal shell/Git/agent configuration alone.
export DOTFILES_TOOLS_PREFIX="$test_root/tools"
snapshot_personal_config() {
  for path in .zshrc .bashrc .profile .gitconfig .config/mise/config.toml .config/mise/mise.lock .agents .agents/AGENTS.md .claude/CLAUDE.md; do
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
  # Old manually installed commands must not shadow mise's managed tools.
  for tool in node npm bun python3; do
    printf '#!/bin/sh\nexit 99\n' > "$DOTFILES_TOOLS_PREFIX/bin/$tool"
    chmod +x "$DOTFILES_TOOLS_PREFIX/bin/$tool"
  done
  bash --noprofile --norc -c '
    set -e
    source "$DOTFILES_TOOLS_PREFIX/env.sh"
    for tool in node npm bun python3; do
      [[ "$(command -v "$tool")" == "$MISE_DATA_DIR/shims/$tool" ]]
    done
    bash "$1/scripts/check-tools.sh"
  ' _ "$repo_root"
  cmp "$repo_root/mise.lock" "$DOTFILES_TOOLS_PREFIX/mise/config/mise.lock"
  diff -r "$repo_root/.mise/locks" "$DOTFILES_TOOLS_PREFIX/mise/config/.mise/locks"
  snapshot_personal_config > "$test_root/personal.after"
  diff -u "$test_root/personal.before" "$test_root/personal.after"
  printf 'ok   %s portable tool installation and fresh-shell activation\n' "$phase"
done

# Project configuration remains active after loading the shared defaults.
# shellcheck source=scripts/tools-env.sh
source "$DOTFILES_TOOLS_PREFIX/env.sh"
mkdir -p "$test_root/project"
cat > "$test_root/project/mise.toml" <<'PROJECT'
[env]
DOTFILES_TEST_PROJECT = "active"
PROJECT
mise trust "$test_root/project/mise.toml"
(
  cd "$test_root/project"
  [[ "$(node -p 'process.env.DOTFILES_TEST_PROJECT')" == active ]]
)

# A changed request cannot silently resolve a new version during locked setup.
cp "$MISE_GLOBAL_CONFIG_FILE" "$test_root/config.saved"
sed 's/^node = .*/node = "0.0.0"/' "$test_root/config.saved" > "$MISE_GLOBAL_CONFIG_FILE"
if MISE_CEILING_PATHS="$DOTFILES_TOOLS_PREFIX" mise --cd "$DOTFILES_TOOLS_PREFIX" install --locked > "$test_root/locked-error" 2>&1; then
  echo 'Locked installation accepted an unpinned request' >&2
  exit 1
fi
grep -qi lock "$test_root/locked-error"
cp "$test_root/config.saved" "$MISE_GLOBAL_CONFIG_FILE"
printf 'ok   project configuration overrides and locked-install rejection\n'
