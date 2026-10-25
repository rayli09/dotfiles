#!/usr/bin/env bash
set -euo pipefail

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

install_apt_packages() {
  as_root apt-get update
  as_root apt-get install -y \
    1password-cli \
    bat \
    btop \
    build-essential \
    ca-certificates \
    cloudflared \
    curl \
    direnv \
    fd-find \
    fzf \
    git \
    git-lfs \
    gh \
    gnupg \
    htop \
    jq \
    libbz2-dev \
    libffi-dev \
    liblzma-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    pkg-config \
    python3 \
    python3-pip \
    python3-venv \
    ripgrep \
    shellcheck \
    shfmt \
    tmux \
    tk-dev \
    unzip \
    wget \
    xz-utils \
    zlib1g-dev \
    zoxide \
    zsh
}

configure_1password_cli_repository() {
  if [[ -f /etc/apt/sources.list.d/1password.list ]]; then
    return
  fi

  as_root install -d -m 0755 /usr/share/keyrings
  curl -fsSL https://downloads.1password.com/linux/keys/1password.asc \
    | as_root gpg --dearmor --yes --output /usr/share/keyrings/1password-archive-keyring.gpg

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" \
    | as_root tee /etc/apt/sources.list.d/1password.list >/dev/null

  as_root install -d -m 0755 /etc/debsig/policies/AC2D62742012EA22
  curl -fsSL https://downloads.1password.com/linux/debian/debsig/1password.pol \
    | as_root tee /etc/debsig/policies/AC2D62742012EA22/1password.pol >/dev/null

  as_root install -d -m 0755 /usr/share/debsig/keyrings/AC2D62742012EA22
  curl -fsSL https://downloads.1password.com/linux/keys/1password.asc \
    | as_root gpg --dearmor --yes --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
}

configure_github_cli_repository() {
  if [[ -f /etc/apt/sources.list.d/github-cli.list ]]; then
    return
  fi

  as_root install -d -m 0755 /etc/apt/keyrings
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | as_root tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
  as_root chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | as_root tee /etc/apt/sources.list.d/github-cli.list >/dev/null
}

configure_cloudflared_repository() {
  if [[ -f /etc/apt/sources.list.d/cloudflared.list ]]; then
    return
  fi

  as_root install -d -m 0755 /usr/share/keyrings
  curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg \
    | as_root tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null

  echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main" \
    | as_root tee /etc/apt/sources.list.d/cloudflared.list >/dev/null
}

install_symlinks() {
  mkdir -p "$HOME/.local/bin"

  if has fdfind && ! has fd; then
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  fi

  if has batcat && ! has bat; then
    ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
  fi
}

install_node_globals() {
  if ! has npm; then
    return
  fi

  npm install -g wrangler@latest
}

install_docker() {
  if has docker; then
    return
  fi

  curl -fsSL https://get.docker.com | sh
  as_root usermod -aG docker "$USER"
}

install_starship() {
  if has starship; then
    return
  fi

  curl -sS https://starship.rs/install.sh | sh -s -- -y
}

set_default_shell() {
  if [[ "${SHELL:-}" == *zsh ]]; then
    return
  fi

  as_root chsh -s "$(command -v zsh)" "$USER"
}

main() {
  configure_1password_cli_repository
  configure_github_cli_repository
  configure_cloudflared_repository
  install_apt_packages
  install_symlinks
  bash "$(chezmoi source-path)/scripts/install-tools.sh"
  source "$(chezmoi source-path)/scripts/tools-env.sh"
  install_node_globals
  install_docker
  install_starship
  set_default_shell
}

main "$@"
