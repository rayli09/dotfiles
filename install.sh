#!/usr/bin/env bash
set -euo pipefail

REPO="https://github.com/rayli09/dotfiles.git"
OS="$(uname -s)"

log() {
  printf "\n==> %s\n" "$*"
}

has() {
  command -v "$1" >/dev/null 2>&1
}

as_root() {
  if [[ "${EUID}" -eq 0 ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

load_homebrew() {
  if has brew; then
    return
  fi

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
}

install_homebrew() {
  load_homebrew

  if has brew; then
    return
  fi

  log "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  load_homebrew
}

install_linux_basics() {
  log "Installing Linux basics"

  if ! has apt-get; then
    echo "Unsupported Linux distro: missing apt-get"
    exit 1
  fi

  as_root apt-get update
  as_root apt-get install -y \
    build-essential \
    ca-certificates \
    curl \
    file \
    git \
    gnupg \
    lsb-release \
    procps \
    software-properties-common \
    sudo \
    unzip \
    zsh
}

install_chezmoi() {
  if has chezmoi; then
    return
  fi

  log "Installing chezmoi"

  if has brew; then
    brew install chezmoi
  else
    mkdir -p "$HOME/.local/bin"
    sh -c "$(curl -fsLS https://get.chezmoi.io)" -- -b "$HOME/.local/bin"
    export PATH="$HOME/.local/bin:$PATH"
  fi
}

ensure_chezmoi_config() {
  local config="$HOME/.config/chezmoi/chezmoi.toml"

  if [[ -f "$config" ]]; then
    return
  fi

  log "Creating chezmoi local config"
  mkdir -p "$(dirname "$config")"

  cat > "$config" <<EOF
[data]
  git_name = "Ruize Li"
  git_email = "you@example.com"
  work_email = ""
EOF
}

apply_dotfiles() {
  log "Applying dotfiles"

  if chezmoi source-path >/dev/null 2>&1; then
    chezmoi update --apply
  else
    chezmoi init --apply "$REPO"
  fi
}

install_packages() {
  local source_path
  source_path="$(chezmoi source-path)"

  case "$OS" in
    Darwin)
      install_homebrew
      log "Installing macOS packages"
      bash "$source_path/scripts/bootstrap-macos.sh"
      ;;
    Linux)
      log "Installing Linux packages"
      bash "$source_path/scripts/bootstrap-linux.sh"
      ;;
    *)
      echo "Unsupported OS: $OS"
      exit 1
      ;;
  esac
}

main() {
  case "$OS" in
    Darwin)
      install_homebrew
      ;;
    Linux)
      install_linux_basics
      ;;
    *)
      echo "Unsupported OS: $OS"
      exit 1
      ;;
  esac

  install_chezmoi
  ensure_chezmoi_config
  apply_dotfiles
  install_packages

  log "Done. Restart your shell or run: exec zsh"
}

main "$@"
