#!/usr/bin/env bash
set -euo pipefail

source_path="$(chezmoi source-path)"
cd "$source_path"

brew bundle --file="$source_path/Brewfile.macos"

bash "$source_path/scripts/install-tools.sh"
source "$source_path/scripts/tools-env.sh"

bash "$source_path/scripts/install-editor-extensions.sh"

if command -v fzf >/dev/null 2>&1; then
  "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc
fi

echo "macOS bootstrap complete."
