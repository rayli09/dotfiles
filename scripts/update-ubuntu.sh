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
    bun upgrade || true
  fi
}

update_uv() {
  if has uv; then
    uv self update || true
  fi
}

update_mise() {
  if has mise; then
    mise self-update -y || true
    mise upgrade || true
  fi
}

main() {
  update_apt
  update_bun
  update_uv
  update_mise
}

main "$@"
