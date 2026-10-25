#!/bin/sh
# Source in Bash or Zsh; mise shims honor project configuration after activation.
export DOTFILES_TOOLS_PREFIX="${DOTFILES_TOOLS_PREFIX:-$HOME/.local/share/dotfiles-tools}"
export MISE_CONFIG_DIR="$DOTFILES_TOOLS_PREFIX/mise/config"
export MISE_GLOBAL_CONFIG_FILE="$MISE_CONFIG_DIR/config.toml"
export MISE_DATA_DIR="$DOTFILES_TOOLS_PREFIX/mise/data"
export MISE_CACHE_DIR="$DOTFILES_TOOLS_PREFIX/cache/mise"
export MISE_STATE_DIR="$DOTFILES_TOOLS_PREFIX/mise/state"
export PATH="$MISE_DATA_DIR/shims:$DOTFILES_TOOLS_PREFIX/bin:$PATH"
export GOPATH="$DOTFILES_TOOLS_PREFIX/gopath"
export GOCACHE="$DOTFILES_TOOLS_PREFIX/cache/go"
export GOTOOLCHAIN=local
export UV_TOOL_DIR="$DOTFILES_TOOLS_PREFIX/uv-tools"
export UV_TOOL_BIN_DIR="$DOTFILES_TOOLS_PREFIX/bin"
export UV_CACHE_DIR="$DOTFILES_TOOLS_PREFIX/cache/uv"
export UV_PYTHON_INSTALL_MIRROR=https://github.com/astral-sh/python-build-standalone/releases/download
export npm_config_cache="$DOTFILES_TOOLS_PREFIX/cache/npm"
