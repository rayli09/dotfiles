#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run this script as root."
  exit 1
fi

USER_NAME="${1:-ruize}"
USER_HOME="/home/$USER_NAME"

if ! id "$USER_NAME" >/dev/null 2>&1; then
  adduser --disabled-password --gecos "" "$USER_NAME"
fi

usermod -aG sudo "$USER_NAME"

if [[ -f /root/.ssh/authorized_keys ]]; then
  install -d -m 0700 -o "$USER_NAME" -g "$USER_NAME" "$USER_HOME/.ssh"
  install -m 0600 -o "$USER_NAME" -g "$USER_NAME" /root/.ssh/authorized_keys "$USER_HOME/.ssh/authorized_keys"
fi

cat > "/etc/sudoers.d/$USER_NAME" <<EOF
$USER_NAME ALL=(ALL) NOPASSWD:ALL
EOF
chmod 0440 "/etc/sudoers.d/$USER_NAME"

echo "Created or updated user: $USER_NAME"
echo "Now run: su - $USER_NAME"
