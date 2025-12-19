#!/usr/bin/env bash
set -euo pipefail

# Exit early if yay already installed
if command -v yay >/dev/null 2>&1; then
  echo "yay is already installed: $(command -v yay)"
  exit 0
fi

# Build/install yay from AUR
workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT

git clone https://aur.archlinux.org/yay.git "$workdir/yay"
cd "$workdir/yay"
makepkg -si --noconfirm
