#!/usr/bin/env bash
# Install all required packages using pacman

set -euo pipefail

# Re-run as root if needed
if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  exec sudo bash "$0" "$@"
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

mapfile -t packages < <(grep -v '^#' "$script_dir/pacman.packages" | 
grep -v '^$')
pacman -S --noconfirm --needed "${packages[@]}"
