#!/usr/bin/env bash
set -euo pipefail
source_path="$(chezmoi source-path)"
cd "$source_path"

if [[ "$EUID" -eq 0 ]]; then
  apt-get update
  apt-get upgrade -y
  apt-get autoremove -y
else
  sudo apt-get update
  sudo apt-get upgrade -y
  sudo apt-get autoremove -y
fi

bash "$source_path/scripts/install-tools.sh"
source "$source_path/scripts/tools-env.sh"
npm install -g --prefix "$DOTFILES_TOOLS_PREFIX" wrangler@latest
