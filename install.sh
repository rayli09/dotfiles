#!/usr/bin/env bash
set -euo pipefail

repo="https://github.com/rayli09/dotfiles.git"

if ! command -v brew >/dev/null 2>&1; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

if ! command -v chezmoi >/dev/null 2>&1; then
  brew install chezmoi
fi

if [[ ! -f "${HOME}/.config/chezmoi/chezmoi.toml" ]]; then
  mkdir -p "${HOME}/.config/chezmoi"
  cat > "${HOME}/.config/chezmoi/chezmoi.toml" <<EOF
[data]
  git_name = "Ruize Li"
  git_email = "rl3250@columbia.edu"
  work_email = ""
EOF
fi

if chezmoi source-path >/dev/null 2>&1; then
  chezmoi update --apply
else
  chezmoi init --apply "$repo"
fi

brew bundle --file="$(chezmoi source-path)/Brewfile"

echo "Dotfiles applied. Restart your shell or run: exec zsh"

