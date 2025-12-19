#!/usr/bin/env bash
# Renames boot loader entry to arch.conf
# Sets loader.conf to timeout 0 and default arch.conf

set -euo pipefail

ESP="${ESP:-/boot}"
ENTRIES_DIR="$ESP/loader/entries"
LOADER_CONF="$ESP/loader/loader.conf"
TARGET_ENTRY="$ENTRIES_DIR/arch.conf"

die() { echo "error: $*" >&2; exit 1; }

[[ -d "$ENTRIES_DIR" ]] || die "entries dir not found: $ENTRIES_DIR"

shopt -s nullglob
entries=("$ENTRIES_DIR"/*.conf)
shopt -u nullglob
((${#entries[@]})) || die "no entry files found in $ENTRIES_DIR"

pick_entry() {
  local f

  # 1) Prefer: /vmlinuz-linux + /initramfs-linux.img
  for f in "${entries[@]}"; do
    grep -qE '^[[:space:]]*linux[[:space:]]+/vmlinuz-linux([[:space:]]*)$' "$f" || continue
    grep -qE '^[[:space:]]*initrd[[:space:]]+/initramfs-linux\.img([[:space:]]*)$' "$f" || continue
    echo "$f"
    return 0
  done

  # 2) Next: /vmlinuz-linux + not a fallback initramfs line
  for f in "${entries[@]}"; do
    grep -qE '^[[:space:]]*linux[[:space:]]+/vmlinuz-linux([[:space:]]*)$' "$f" || continue
    grep -qE '^[[:space:]]*initrd[[:space:]]+/.+fallback' "$f" && continue
    echo "$f"
    return 0
  done

  # 3) Last resort: newest file that references /vmlinuz-linux
  local newest=""
  local newest_mtime=0
  for f in "${entries[@]}"; do
    grep -qE '^[[:space:]]*linux[[:space:]]+/vmlinuz-linux([[:space:]]*)$' "$f" || continue
    mtime="$(stat -c %Y "$f")"
    if (( mtime > newest_mtime )); then
      newest_mtime="$mtime"
      newest="$f"
    fi
  done

  [[ -n "$newest" ]] || return 1
  echo "$newest"
}

src="$(pick_entry)" || die "could not find an entry that boots /vmlinuz-linux"

echo "Selected entry: $src"

# Backup an existing arch.conf if present (avoids clobbering)
if [[ -e "$TARGET_ENTRY" && "$(readlink -f "$TARGET_ENTRY")" != "$(readlink -f "$src")" ]]; then
  ts="$(date +%Y%m%d-%H%M%S)"
  sudo mv "$TARGET_ENTRY" "${TARGET_ENTRY}.bak-${ts}"
fi

# Rename the discovered entry to arch.conf (move)
if [[ "$(readlink -f "$src")" != "$(readlink -f "$TARGET_ENTRY")" ]]; then
  sudo mv "$src" "$TARGET_ENTRY"
fi

# Write loader.conf
sudo mkdir -p "$(dirname "$LOADER_CONF")"
sudo tee "$LOADER_CONF" >/dev/null <<'EOF'
default  arch.conf
timeout  0
editor   no
console-mode max
EOF

echo "Wrote: $LOADER_CONF"
echo "Renamed entry to: $TARGET_ENTRY"
