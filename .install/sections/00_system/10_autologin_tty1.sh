#!/usr/bin/env bash
# Sets auto passwordless login for the current user on tty1

set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

TARGET_USER="${SUDO_USER:-${USER:-}}"
DST_DIR="/etc/systemd/system/getty@tty1.service.d"
DST_FILE="$DST_DIR/autologin.conf"

# Write a drop-in
sudo mkdir -p "$DST_DIR"
sudo tee "$DST_FILE" >/dev/null <<EOF
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --noreset --noclear --autologin $TARGET_USER %I 38400 linux
EOF

sudo systemctl daemon-reload
echo "Autologin configured on tty1 for user: $TARGET_USER"
