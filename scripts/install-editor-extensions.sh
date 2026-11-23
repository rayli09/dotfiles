#!/usr/bin/env bash
set -euo pipefail

source_path="$(chezmoi source-path)"

for editor in code cursor; do
  if command -v "$editor" >/dev/null 2>&1; then
    while IFS= read -r extension || [[ -n "$extension" ]]; do
      [[ -z "$extension" || "$extension" == \#* ]] && continue
      "$editor" --install-extension "$extension" --force
    done < "$source_path/private_dot_config/vscode/extensions.txt"
  fi
done
