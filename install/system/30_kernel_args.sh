#!/usr/bin/env bash
# Adds required args to kernel in /boot/loader/entries/arch.conf

set -euo pipefail

# re-run as root so redirects/sed work cleanly
if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  exec sudo bash "$0" "$@"
fi

f="/boot/loader/entries/arch.conf"

[[ -f "$f" ]] || { echo "Err: $f not found" >&2; exit 1; }
cp -a -- "$f" "$f.bak"

add=()

# add new args here 
grep -qE '^[[:space:]]*options[[:space:]].*\bquiet\b'  "$f" || add+=(quiet)
grep -qE '^[[:space:]]*options[[:space:]].*\bsplash\b' "$f" || add+=(splash)

if ((${#add[@]})); then
  sed -i -E "/^[[:space:]]*options[[:space:]]/ s/\$/ ${add[*]}/" "$f"
fi

echo "Updated: $f (backup: $f.bak)"
