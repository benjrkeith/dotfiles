#!/usr/bin/env bash
set -euo pipefail

CONF="/etc/mkinitcpio.conf"
BACKUP="/etc/mkinitcpio.conf.bak.$(date +%Y%m%d-%H%M%S)"

# Re-run as root if needed
if [[ $EUID -ne 0 ]]; then
  exec sudo -E bash "$0" "$@"
fi

[[ -f "$CONF" ]] || { echo "Missing $CONF"; exit 1; }
command -v mkinitcpio >/dev/null || { echo "mkinitcpio not found"; exit 1; }

cp -a "$CONF" "$BACKUP"
echo "Backup: $BACKUP"

hooks_line="$(grep -E '^[[:space:]]*HOOKS=\(' "$CONF" | head -n1 || true)"
[[ -n "$hooks_line" ]] || { echo "Could not find HOOKS=(...) in $CONF"; exit 1; }

inner="${hooks_line#*HOOKS=(}"
inner="${inner%)*}"
read -r -a hooks <<<"$inner"

# If already present, just rebuild
for h in "${hooks[@]}"; do
  if [[ "$h" == "plymouth" ]]; then
    echo "plymouth already present in HOOKS."
    mkinitcpio -P
    exit 0
  fi
done

# Find encrypt (or sd-encrypt) and insert plymouth right before it
insert_at=-1
for i in "${!hooks[@]}"; do
  if [[ "${hooks[$i]}" == "encrypt" || "${hooks[$i]}" == "sd-encrypt" ]]; then
    insert_at="$i"
    break
  fi
done

if [[ "$insert_at" -lt 0 ]]; then
  echo "No encrypt/sd-encrypt hook found; inserting plymouth after block if possible."
  for i in "${!hooks[@]}"; do
    if [[ "${hooks[$i]}" == "block" ]]; then
      insert_at=$((i+1))
      break
    fi
  done
  [[ "$insert_at" -lt 0 ]] && insert_at="${#hooks[@]}"
fi

new_hooks=()
for i in "${!hooks[@]}"; do
  if [[ "$i" -eq "$insert_at" ]]; then
    new_hooks+=("plymouth")
  fi
  new_hooks+=("${hooks[$i]}")
done
if [[ "$insert_at" -ge "${#hooks[@]}" ]]; then
  new_hooks+=("plymouth")
fi

new_line="HOOKS=(${new_hooks[*]})"

tmp="$(mktemp)"
awk -v repl="$new_line" '
  BEGIN{done=0}
  /^[[:space:]]*HOOKS=\(/{ if(!done){ print repl; done=1; next } }
  { print }
' "$CONF" >"$tmp"
install -m 0644 "$tmp" "$CONF"
rm -f "$tmp"

echo "Updated HOOKS to:"
echo "  $new_line"
echo "Rebuilding initramfs..."
mkinitcpio -P
echo "Done."
