#!/usr/bin/env bash
# Set NVIDIA kernel modules

set -euo pipefail

# Re-run as root if needed
if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  exec sudo bash "$0" "$@"
fi

conf_path="/etc/mkinitcpio.conf"
new_modules='MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)'

backup="${conf_path}.bak.$(date +%Y%m%d-%H%M%S)"
cp -a -- "$conf_path" "$backup"
echo "Backup: $backup"

if grep -qE '^[[:space:]]*MODULES=' "$conf_path"; then
  sed -i -E "s|^[[:space:]]*MODULES=.*$|$new_modules|" "$conf_path"
  echo "Updated: $new_modules"
else
  echo "$new_modules" >> "$conf_path"
  echo "Added: $new_modules"
fi

echo "Regenerating initramfs (mkinitcpio -P)..."
mkinitcpio -P
