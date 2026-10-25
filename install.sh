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
  # Only prerequisites needed to fetch dotfiles and register package repositories.
  as_root apt-get install -y \
    ca-certificates \
    curl \
    git \
    gnupg \
    sudo
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
EOF
}

prepare_dotfiles() {
  log "Preparing dotfiles source"

  local source_path remote
  source_path="$(chezmoi source-path)"
  if [[ -d "$source_path/.git" ]]; then
    # Validate the stored origin; Git URL rewrites may point it at a mirror.
    remote="$(git -C "$source_path" config --get remote.origin.url)"
    case "$remote" in
      https://github.com/rayli09/dotfiles|https://github.com/rayli09/dotfiles.git|git@github.com:rayli09/dotfiles.git) ;;
      *) echo "Existing chezmoi source belongs to another repo: $source_path" >&2; exit 1 ;;
    esac
    chezmoi update --apply=false
  else
    chezmoi init --apply=false "$REPO"
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
  prepare_dotfiles
  install_packages
  chezmoi apply

  log "Done. Restart your shell or run: exec zsh"
}

main "$@"
