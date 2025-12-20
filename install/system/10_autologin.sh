#!/usr/bin/env bash
# Enables autologin for the current user on tty1

set -euo pipefail

# Re-run as root if needed
if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  exec sudo bash "$0" "$@"
fi

target_user="${SUDO_USER:-${USER:-}}"
dst_dir="/etc/systemd/system/getty@tty1.service.d"
dst_file="$dst_dir/autologin.conf"

mkdir -p "$dst_dir"
tee "$dst_file" >/dev/null <<EOF
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --noreset --noclear --autologin $target_user %I 38400 linux
EOF

systemctl daemon-reload
echo "Autologin configured on tty1 for user: $target_user"
