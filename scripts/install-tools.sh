#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$repo_root/mise-bootstrap.env"
source "$repo_root/scripts/tools-env.sh"
case "$(uname -s)" in Linux) platform=linux ;; Darwin) platform=macos ;; *) echo 'Linux or macOS required' >&2; exit 1 ;; esac
case "$(uname -m)" in x86_64) arch=x64 ;; arm64|aarch64) arch=arm64 ;; *) echo 'x64 or arm64 required' >&2; exit 1 ;; esac
mkdir -p "$DOTFILES_TOOLS_PREFIX/bin" "$MISE_CONFIG_DIR"
download_dir="$(mktemp -d)"
trap 'rm -rf "$download_dir"' EXIT

if [[ "$("$DOTFILES_TOOLS_PREFIX/bin/mise" --version 2>/dev/null | awk '{print $1}' || true)" != "$MISE_VERSION" ]]; then
  curl -fsSL "https://github.com/jdx/mise/releases/download/v$MISE_VERSION/mise-v$MISE_VERSION-$platform-$arch" -o "$download_dir/mise"
  checksum_var="MISE_SHA256_${platform}_${arch}"
  if command -v sha256sum >/dev/null; then
    actual="$(sha256sum "$download_dir/mise" | awk '{print $1}')"
  else
    actual="$(shasum -a 256 "$download_dir/mise" | awk '{print $1}')"
  fi
  [[ "$actual" == "${!checksum_var}" ]] || { echo 'mise checksum mismatch' >&2; exit 1; }
  install -m 0755 "$download_dir/mise" "$DOTFILES_TOOLS_PREFIX/bin/mise"
fi

# Deploy the reviewed configuration as this prefix's global defaults. Projects
# can override those defaults; the install itself ignores parent project files.
cp "$repo_root/mise.toml" "$MISE_GLOBAL_CONFIG_FILE"
cp "$repo_root/mise.lock" "$MISE_CONFIG_DIR/mise.lock"
mkdir -p "$MISE_CONFIG_DIR/.mise"
rm -rf "$MISE_CONFIG_DIR/.mise/locks"
cp -R "$repo_root/.mise/locks" "$MISE_CONFIG_DIR/.mise/"
mise trust "$repo_root/mise.toml"
MISE_CEILING_PATHS="$DOTFILES_TOOLS_PREFIX" mise --cd "$DOTFILES_TOOLS_PREFIX" install --locked
MISE_CEILING_PATHS="$DOTFILES_TOOLS_PREFIX" mise --cd "$DOTFILES_TOOLS_PREFIX" reshim
bash "$repo_root/scripts/check-tools.sh"
install -m 0644 "$repo_root/scripts/tools-env.sh" "$DOTFILES_TOOLS_PREFIX/env.sh"
printf 'Tools installed. Activate with: source "%s/env.sh"\n' "$DOTFILES_TOOLS_PREFIX"
