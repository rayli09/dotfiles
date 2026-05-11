#!/usr/bin/env bash
set -euo pipefail

brew bundle --file="$(chezmoi source-path)/Brewfile"

if command -v fzf >/dev/null 2>&1; then
  "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc
fi

echo "macOS bootstrap complete."

