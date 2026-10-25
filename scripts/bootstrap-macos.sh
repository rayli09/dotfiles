#!/usr/bin/env bash
set -euo pipefail

source_path="$(chezmoi source-path)"
cd "$source_path"

brew bundle --file="$source_path/Brewfile.macos"

bash "$source_path/scripts/install-tools.sh"
source "$source_path/scripts/tools-env.sh"

if command -v npm >/dev/null 2>&1; then
  npm install -g --prefix "$DOTFILES_TOOLS_PREFIX" wrangler@latest
fi

for editor in code cursor; do
  if command -v "$editor" >/dev/null 2>&1; then
    while IFS= read -r extension || [[ -n "$extension" ]]; do
      [[ -z "$extension" || "$extension" == \#* ]] && continue
      "$editor" --install-extension "$extension" --force
    done < "$source_path/private_dot_config/vscode/extensions.txt"
  fi
done

if command -v fzf >/dev/null 2>&1; then
  "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc
fi

echo "macOS bootstrap complete."
