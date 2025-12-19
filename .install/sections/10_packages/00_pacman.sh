#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Install base Pacman packages
mapfile -t packages < <(grep -v '^#' "$SCRIPT_DIR/80_pacman.packages" | 
grep -v '^$')
sudo pacman -S --noconfirm --needed "${packages[@]}"
