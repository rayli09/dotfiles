#!/usr/bin/env bash
set -euo pipefail

brew bundle --file="$(chezmoi source-path)/Brewfile.macos"

if command -v mise >/dev/null 2>&1; then
  mise install
  eval "$(mise activate bash)"
fi

if command -v corepack >/dev/null 2>&1; then
  corepack enable || true
fi

if command -v npm >/dev/null 2>&1; then
  npm install -g wrangler@latest
fi

if command -v fzf >/dev/null 2>&1; then
  "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc
fi

echo "macOS bootstrap complete."
