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

update_apt() {
  as_root apt-get update
  as_root apt-get upgrade -y
  as_root apt-get autoremove -y
}

update_bun() {
  if has bun; then
    bun upgrade
  fi
}

update_uv() {
  if has uv; then
    uv self update
  fi
}

update_mise() {
  if has mise; then
    mise upgrade
    mise install
    eval "$(mise activate bash)"
  fi
}

update_node_globals() {
  if has npm; then
    npm install -g wrangler@latest
  fi
}

main() {
  update_apt
  update_bun
  update_uv
  update_mise
  update_node_globals
}

main "$@"
