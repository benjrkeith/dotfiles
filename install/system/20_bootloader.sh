#!/usr/bin/env bash
# Renames boot entry to arch.conf
# Sets boot menu to 0 timeout

set -euo pipefail

# Re-run as root if needed
if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  exec sudo bash "$0" "$@"
fi

loader_dir="/boot/loader"
loader_conf="$loader_dir/loader.conf"
entries_dir="$loader_dir/entries"
target_entry="$entries_dir/arch.conf"

shopt -s nullglob
entries=( "$entries_dir"/*.conf )
shopt -u nullglob

[[ ${#entries[@]} -eq 1 ]] || { echo "Err: too many entries" >&2; exit 1; } 
src_entry="${entries[0]}"

# If it's not already arch.conf, rename it
if [[ "$src_entry" != "$target_entry" ]]; then
  mv -f -- "$src_entry" "$target_entry"
fi

# Write loader.conf
mkdir -p -- "$(dirname -- "$loader_conf")"
cat >"$loader_conf" <<EOF
default  arch.conf
timeout  0
editor   no
console-mode max
EOF

echo "Renamed entry to: $target_entry"
echo "Wrote: $loader_conf"
