#!/usr/bin/env bash
# Add plymouth to hooks, download and install theme

set -euo pipefail

# Re-run as root if needed
if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  exec sudo bash "$0" "$@"
fi

conf_path="/etc/mkinitcpio.conf"
theme_url="https://github.com/dracula/plymouth/archive/master.zip"
themes_dir="/usr/share/plymouth/themes"
theme_name="dracula"

die() { echo "Error: $*" >&2; exit 1; }

tmp="$(mktemp -d)"
trap 'rm -rf -- "$tmp"' EXIT

# Add plymouth hook
backup="${conf_path}.bak.$(date +%Y%m%d-%H%M%S)"
cp -a -- "$conf_path" "$backup"
echo "Backup: $backup"

hooks_line="$(grep -m1 -E '^[[:space:]]*HOOKS=\(' "$conf_path" || true)"
[[ -n "$hooks_line" ]] || die "Could not find HOOKS=(...) in $conf_path"

inner="${hooks_line#*HOOKS=(}"
inner="${inner%)*}"
read -r -a hooks <<<"$inner"

for h in "${hooks[@]}"; do
  [[ "$h" == "plymouth" ]] && { echo "plymouth already present in HOOKS."; goto_theme=1; break; }
done
: "${goto_theme:=0}"

if [[ $goto_theme -eq 0 ]]; then
  insert_at=-1

  for i in "${!hooks[@]}"; do
    if [[ "${hooks[$i]}" == "encrypt" || "${hooks[$i]}" == "sd-encrypt" ]]; then
      insert_at="$i"
      break
    fi
  done

  if [[ "$insert_at" -lt 0 ]]; then
    for i in "${!hooks[@]}"; do
      if [[ "${hooks[$i]}" == "block" ]]; then
        insert_at=$((i + 1))
        break
      fi
    done
    [[ "$insert_at" -lt 0 ]] && insert_at="${#hooks[@]}"
  fi

  new_hooks=()
  for i in "${!hooks[@]}"; do
    [[ "$i" -eq "$insert_at" ]] && new_hooks+=(plymouth)
    new_hooks+=("${hooks[$i]}")
  done
  [[ "$insert_at" -ge "${#hooks[@]}" ]] && new_hooks+=(plymouth)

  new_line="HOOKS=(${new_hooks[*]})"

  awk -v repl="$new_line" '
    BEGIN{done=0}
    /^[[:space:]]*HOOKS=\(/{ if(!done){ print repl; done=1; next } }
    { print }
  ' "$conf_path" >"$tmp/mkinitcpio.conf"

  install -m 0644 -- "$tmp/mkinitcpio.conf" "$conf_path"
  echo "Updated HOOKS to: $new_line"
fi

# Install Dracula Plymouth theme
echo "Downloading Dracula Plymouth theme..."
curl -fsSL -L "$theme_url" >"$tmp/plymouth.zip"
mkdir -p "$tmp/extract"
unzip -q "$tmp/plymouth.zip" -d "$tmp/extract"

theme_plymouth_file="$(find "$tmp/extract" -type f -name "*.plymouth" -print -quit)"
[[ -n "$theme_plymouth_file" ]] || die "Could not find a *.plymouth file in the zip"
theme_dir="$(dirname "$theme_plymouth_file")"

mkdir -p "$themes_dir"
rm -rf -- "$themes_dir/$theme_name"
cp -a -- "$theme_dir" "$themes_dir/$theme_name"
plymouth-set-default-theme "$theme_name"

echo "Rebuilding initramfs..."
mkinitcpio -P
