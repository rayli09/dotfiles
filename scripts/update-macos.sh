#!/usr/bin/env bash
set -euo pipefail

source_path="$(chezmoi source-path 2>/dev/null || pwd)"
cd "$source_path"

brew update
brew upgrade
brew bundle --file="$source_path/Brewfile.macos"
brew cleanup

if command -v mas >/dev/null 2>&1; then
  mas upgrade
fi

bash "$source_path/scripts/install-tools.sh"
source "$source_path/scripts/tools-env.sh"

bash "$source_path/scripts/install-editor-extensions.sh"

echo "macOS update complete."
