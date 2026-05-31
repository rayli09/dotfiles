#!/usr/bin/env bash
set -euo pipefail

source_path="$(chezmoi source-path)"

if [[ -f "$source_path/packages/ubuntu.sh" ]]; then
  bash "$source_path/packages/ubuntu.sh"
else
  echo "Missing Linux package script: $source_path/packages/ubuntu.sh"
  exit 1
fi

echo "Linux bootstrap complete."
