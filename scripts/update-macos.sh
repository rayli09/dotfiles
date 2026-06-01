#!/usr/bin/env bash
set -euo pipefail

source_path="$(chezmoi source-path 2>/dev/null || pwd)"

brew update
brew upgrade
brew bundle --file="$source_path/Brewfile.macos"
brew cleanup

if command -v mas >/dev/null 2>&1; then
  mas upgrade || true
fi

if command -v mise >/dev/null 2>&1; then
  mise upgrade || true
  mise install || true
  eval "$(mise activate bash)"
fi

if command -v bun >/dev/null 2>&1; then
  brew upgrade bun || bun upgrade || true
fi

if command -v uv >/dev/null 2>&1; then
  brew upgrade uv || uv self update || true
fi

if command -v npm >/dev/null 2>&1; then
  npm install -g wrangler@latest || true
fi

if command -v code >/dev/null 2>&1; then
  code --install-extension dracula-theme.theme-dracula --force || true
fi

if command -v cursor >/dev/null 2>&1; then
  cursor --install-extension dracula-theme.theme-dracula --force || true
fi

echo "macOS update complete."
