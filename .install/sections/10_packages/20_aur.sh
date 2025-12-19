#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Install base AUR packages
mapfile -t packages < <(grep -v '^#' "$SCRIPT_DIR/90_aur.packages" | 
grep -v '^$')
yay -S --noconfirm --needed "${packages[@]}"
