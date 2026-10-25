#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$repo_root/toolchain.env"
source "$repo_root/scripts/tools-env.sh"
for tool in curl git tar awk; do
  command -v "$tool" >/dev/null || { echo "Missing prerequisite: $tool" >&2; exit 1; }
done
case "$(uname -s)" in Linux) platform=linux ;; Darwin) platform=darwin ;; *) echo 'Linux or macOS required' >&2; exit 1 ;; esac
case "$(uname -m)" in x86_64) node_arch=x64; go_arch=amd64 ;; arm64|aarch64) node_arch=arm64; go_arch=arm64 ;; *) echo 'x64 or arm64 required' >&2; exit 1 ;; esac
mkdir -p "$DOTFILES_TOOLS_PREFIX/bin"
download_dir="$(mktemp -d)"
trap 'rm -rf "$download_dir"' EXIT

verify_archive() {
  local file="$1" expected="$2" actual
  if command -v sha256sum >/dev/null; then
    actual="$(sha256sum "$file" | awk '{print $1}')"
  else
    actual="$(shasum -a 256 "$file" | awk '{print $1}')"
  fi
  [[ "$actual" == "$expected" ]] || { echo "Checksum mismatch: $file" >&2; exit 1; }
}

if [[ ! -x "$DOTFILES_TOOLS_PREFIX/node-$NODE_VERSION/bin/node" ]]; then
  archive="node-v$NODE_VERSION-$platform-$node_arch.tar.gz"
  curl -fsSL "https://nodejs.org/dist/v$NODE_VERSION/$archive" -o "$download_dir/$archive"
  checksum_var="NODE_SHA256_${platform}_${node_arch}"
  verify_archive "$download_dir/$archive" "${!checksum_var}"
  tar -xzf "$download_dir/$archive" -C "$download_dir"
  mv "$download_dir/node-v$NODE_VERSION-$platform-$node_arch" "$DOTFILES_TOOLS_PREFIX/node-$NODE_VERSION"
fi
if [[ ! -x "$DOTFILES_TOOLS_PREFIX/go-$GO_VERSION/bin/go" ]]; then
  archive="go$GO_VERSION.$platform-$go_arch.tar.gz"
  curl -fsSL "https://dl.google.com/go/$archive" -o "$download_dir/$archive"
  checksum_var="GO_SHA256_${platform}_${go_arch}"
  verify_archive "$download_dir/$archive" "${!checksum_var}"
  tar -xzf "$download_dir/$archive" -C "$download_dir"
  mv "$download_dir/go" "$DOTFILES_TOOLS_PREFIX/go-$GO_VERSION"
fi

ln -sfn "node-$NODE_VERSION" "$DOTFILES_TOOLS_PREFIX/node"
ln -sfn "go-$GO_VERSION" "$DOTFILES_TOOLS_PREFIX/go"

npm install --global --prefix "$DOTFILES_TOOLS_PREFIX" --allow-scripts=bun,pnpm \
  "npm@$NPM_VERSION" "bun@$BUN_VERSION" "pnpm@$PNPM_VERSION" "oxlint@$OXLINT_VERSION" \
  "oxfmt@$OXFMT_VERSION" "typescript@$TYPESCRIPT_VERSION"
if [[ "$("$DOTFILES_TOOLS_PREFIX/bin/uv" --version 2>/dev/null | awk '{print $2}' || true)" != "$UV_VERSION" ]]; then
  curl -fsSL "https://github.com/astral-sh/uv/releases/download/$UV_VERSION/uv-installer.sh" -o "$download_dir/uv-installer.sh"
  UV_UNMANAGED_INSTALL="$DOTFILES_TOOLS_PREFIX/bin" UV_INSTALLER_GITHUB_BASE_URL=https://github.com sh "$download_dir/uv-installer.sh"
fi
uv python install "$PYTHON_VERSION" --default --force --preview-features python-install-default
uv tool install --python "$PYTHON_VERSION" "ruff==$RUFF_VERSION"
uv tool install --python "$PYTHON_VERSION" "ty==$TY_VERSION"

bash "$repo_root/scripts/check-tools.sh"
install -m 0644 "$repo_root/scripts/tools-env.sh" "$DOTFILES_TOOLS_PREFIX/env.sh"
printf 'Tools installed. Activate with: source "%s/env.sh"\n' "$DOTFILES_TOOLS_PREFIX"
