#!/bin/sh
# Source in Bash or Zsh. Installed as $DOTFILES_TOOLS_PREFIX/env.sh as well.
export DOTFILES_TOOLS_PREFIX="${DOTFILES_TOOLS_PREFIX:-$HOME/.local/share/dotfiles-tools}"
export PATH="$DOTFILES_TOOLS_PREFIX/bin:$DOTFILES_TOOLS_PREFIX/node/bin:$DOTFILES_TOOLS_PREFIX/go/bin:$PATH"
export GOROOT="$DOTFILES_TOOLS_PREFIX/go"
export GOPATH="$DOTFILES_TOOLS_PREFIX/gopath"
export GOCACHE="$DOTFILES_TOOLS_PREFIX/cache/go"
export GOTOOLCHAIN=local
export UV_PYTHON_INSTALL_DIR="$DOTFILES_TOOLS_PREFIX/python"
export UV_PYTHON_BIN_DIR="$DOTFILES_TOOLS_PREFIX/bin"
export UV_TOOL_DIR="$DOTFILES_TOOLS_PREFIX/uv-tools"
export UV_TOOL_BIN_DIR="$DOTFILES_TOOLS_PREFIX/bin"
export UV_CACHE_DIR="$DOTFILES_TOOLS_PREFIX/cache/uv"
export UV_PYTHON_INSTALL_MIRROR=https://github.com/astral-sh/python-build-standalone/releases/download
export npm_config_cache="$DOTFILES_TOOLS_PREFIX/cache/npm"
