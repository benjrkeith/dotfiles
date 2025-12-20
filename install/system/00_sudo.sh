#!/usr/bin/env bash
# Allows no password sudo for current user

set -euo pipefail

# Re-run as root if needed
if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  exec sudo bash "$0" "$@"
fi

target_user="${SUDO_USER:-${USER:-}}"
sudo_file="/etc/sudoers.d/00_${target_user}"

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

printf '%s ALL=(ALL) NOPASSWD: ALL\n' "$target_user" >"$tmp"
visudo -cf "$tmp" >/dev/null
install -o root -g root -m 0440 "$tmp" "$sudo_file"

echo "File installed: $sudo_file"
