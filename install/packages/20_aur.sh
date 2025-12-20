#!/usr/bin/env bash
# Install all required packages from aur using yay

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

mapfile -t packages < <(grep -v '^#' "$script_dir/90_aur.packages" | 
grep -v '^$')
yay -S --noconfirm --needed "${packages[@]}"
