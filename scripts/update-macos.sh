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

if command -v npm >/dev/null 2>&1; then
  npm install -g wrangler@latest || true
fi

for editor in code cursor; do
  if command -v "$editor" >/dev/null 2>&1; then
    while IFS= read -r extension || [[ -n "$extension" ]]; do
      [[ -z "$extension" || "$extension" == \#* ]] && continue
      "$editor" --install-extension "$extension" --force
    done < "$source_path/private_dot_config/vscode/extensions.txt"
  fi
done

echo "macOS update complete."
