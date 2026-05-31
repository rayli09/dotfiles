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
    bat \
    btop \
    build-essential \
    ca-certificates \
    curl \
    direnv \
    fd-find \
    fzf \
    git \
    git-lfs \
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
    zsh
}

install_1password_cli() {
  if has op; then
    return
  fi

  as_root install -d -m 0755 /usr/share/keyrings
  curl -sS https://downloads.1password.com/linux/keys/op.asc \
    | as_root gpg --dearmor --yes --output /usr/share/keyrings/1password-archive-keyring.gpg

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" \
    | as_root tee /etc/apt/sources.list.d/1password.list >/dev/null

  as_root install -d -m 0755 /etc/debsig/policies/AC2D62742012EA22
  curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol \
    | as_root tee /etc/debsig/policies/AC2D62742012EA22/1password.pol >/dev/null

  as_root install -d -m 0755 /usr/share/debsig/keyrings/AC2D62742012EA22
  curl -sS https://downloads.1password.com/linux/keys/op.asc \
    | as_root gpg --dearmor --yes --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg

  as_root apt-get update
  as_root apt-get install -y 1password-cli
}

install_github_cli() {
  if has gh; then
    return
  fi

  as_root install -d -m 0755 /etc/apt/keyrings
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | as_root tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
  as_root chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | as_root tee /etc/apt/sources.list.d/github-cli.list >/dev/null

  as_root apt-get update
  as_root apt-get install -y gh
}

install_cloudflared() {
  if has cloudflared; then
    return
  fi

  as_root install -d -m 0755 /usr/share/keyrings
  curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg \
    | as_root tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null

  echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared any main" \
    | as_root tee /etc/apt/sources.list.d/cloudflared.list >/dev/null

  as_root apt-get update
  as_root apt-get install -y cloudflared
}

install_mise() {
  if has mise; then
    return
  fi

  as_root install -d -m 0755 /etc/apt/keyrings
  curl -fSs https://mise.en.dev/gpg-key.pub \
    | as_root tee /etc/apt/keyrings/mise-archive-keyring.asc >/dev/null

  echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.asc] https://mise.en.dev/deb stable main" \
    | as_root tee /etc/apt/sources.list.d/mise.list >/dev/null

  as_root apt-get update
  as_root apt-get install -y mise
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

install_bun() {
  if has bun; then
    return
  fi

  curl -fsSL https://bun.sh/install | bash
}

install_uv() {
  if has uv; then
    return
  fi

  curl -LsSf https://astral.sh/uv/install.sh | sh
}

enable_corepack() {
  if has corepack; then
    corepack enable || true
  fi
}

install_mise_tools() {
  if ! has mise; then
    return
  fi

  mise install
  eval "$(mise activate bash)"
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

  chsh -s "$(command -v zsh)" || true
}

main() {
  install_apt_packages
  install_1password_cli
  install_github_cli
  install_cloudflared
  install_mise
  install_symlinks
  install_bun
  install_uv
  install_mise_tools
  enable_corepack
  install_node_globals
  install_docker
  install_starship
  set_default_shell
}

main "$@"
