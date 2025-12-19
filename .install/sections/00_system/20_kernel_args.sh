#!/usr/bin/env bash
# Adds quiet and splash options to kernel

set -euo pipefail

ESP="${ESP:-/boot}"
DIR="$ESP/loader/entries"

shopt -s nullglob
for f in "$DIR"/*.conf; do
  # backup
  cp -a -- "$f" "$f.bak"

  # ensure options line exists
  if ! grep -qE '^[[:space:]]*options[[:space:]]' "$f"; then
    printf '\noptions quiet splash\n' >> "$f"
    continue
  fi

  # append tokens if missing (only on the options line)
  grep -qE '^[[:space:]]*options[[:space:]].*\bquiet\b'  "$f" || \
    sed -i -E '/^[[:space:]]*options[[:space:]]/ s/$/ quiet/' "$f"

  grep -qE '^[[:space:]]*options[[:space:]].*\bsplash\b' "$f" || \
    sed -i -E '/^[[:space:]]*options[[:space:]]/ s/$/ splash/' "$f"
done

echo "Quiet and Splash added to kernel args."