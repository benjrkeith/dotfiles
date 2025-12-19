#!/usr/bin/env bash
# Allows passwordless sudo for current user

set -euo pipefail

TARGET_USER="${SUDO_USER:-${USER:-}}"
DST="/etc/sudoers.d/00_${TARGET_USER}"

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

# Write the sudoers snippet
printf '%s ALL=(ALL) NOPASSWD: ALL\n' "$TARGET_USER" >"$tmp"

# Validate syntax before installing
sudo visudo -cf "$tmp" >/dev/null

# Install with correct owner/perms
sudo install -o root -g root -m 0440 "$tmp" "$DST"

echo "Passwordless sudo enabled for: $TARGET_USER"
echo "File installed: $DST"
