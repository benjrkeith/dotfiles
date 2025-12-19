#!/usr/bin/env bash
set -euo pipefail

CONF="/etc/mkinitcpio.conf"
REQ_MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)

die() { echo "Error: $*" >&2; exit 1; }

# Re-run as root if needed
if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  exec sudo -E bash "$0" "$@"
fi

[[ -f "$CONF" ]] || die "Not found: $CONF"

backup="${CONF}.bak.$(date +%Y%m%d-%H%M%S)"
cp -a "$CONF" "$backup"
echo "Backup: $backup"

# Read existing MODULES line (if any)
modules_line="$(grep -E '^[[:space:]]*MODULES=' "$CONF" || true)"

declare -a current=()
if [[ -n "$modules_line" ]]; then
  # Extract inside parentheses: MODULES=( ... )
  rhs="${modules_line#*=}"
  rhs="${rhs#"${rhs%%[![:space:]]*}"}"         # ltrim
  rhs="${rhs%"${rhs##*[![:space:]]}"}"         # rtrim
  rhs="${rhs#\(}"; rhs="${rhs%\)}"

  # Split on whitespace (module names don't contain spaces)
  read -r -a current <<< "$rhs"

  # Strip quotes if present
  for i in "${!current[@]}"; do
    current[$i]="${current[$i]//\"/}"
    current[$i]="${current[$i]//\'/}"
  done
fi

# Build new list: keep existing order, append required modules if missing
declare -a out=()
declare -A seen=()

for m in "${current[@]}"; do
  [[ -n "$m" ]] || continue
  if [[ -z "${seen[$m]:-}" ]]; then
    out+=("$m")
    seen[$m]=1
  fi
done

for m in "${REQ_MODULES[@]}"; do
  if [[ -z "${seen[$m]:-}" ]]; then
    out+=("$m")
    seen[$m]=1
  fi
done

new_line="MODULES=(${out[*]})"

if [[ -n "$modules_line" ]]; then
  # Replace existing MODULES line
  sed -i -E "s|^[[:space:]]*MODULES=.*$|$new_line|" "$CONF"
  echo "Updated: $new_line"
else
  # Add MODULES line (append)
  {
    echo
    echo "# Added by script to ensure early NVIDIA module loading (nvidia-open uses the same module names)"
    echo "$new_line"
  } >> "$CONF"
  echo "Added: $new_line"
fi

echo "Regenerating initramfs (mkinitcpio -P)..."
mkinitcpio -P
