#!/usr/bin/env bash
set -euo pipefail

ZIP_URL="https://github.com/dracula/plymouth/archive/master.zip"
THEMES_DIR="/usr/share/plymouth/themes"
THEME_NAME="dracula"

die() { echo "Error: $*" >&2; exit 1; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing dependency: $1"
}

# Re-run as root if needed
if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  exec sudo -E bash "$0" "$@"
fi

need_cmd unzip
need_cmd plymouth-set-default-theme
if command -v curl >/dev/null 2>&1; then
  DL_CMD=(curl -fsSL -L)
elif command -v wget >/dev/null 2>&1; then
  DL_CMD=(wget -qO-)
else
  die "Need either curl or wget to download the zip."
fi

tmp="$(mktemp -d)"
cleanup() { rm -rf "$tmp"; }
trap cleanup EXIT

echo "Downloading Dracula Plymouth theme zip..."
"${DL_CMD[@]}" "$ZIP_URL" > "$tmp/plymouth.zip"

echo "Extracting..."
mkdir -p "$tmp/extract"
unzip -q "$tmp/plymouth.zip" -d "$tmp/extract"

# Find the theme directory by locating a *.plymouth file
theme_plymouth_file="$(
  find "$tmp/extract" -type f -name "*.plymouth" -print -quit
)"
[[ -n "$theme_plymouth_file" ]] || die "Could not find a *.plymouth file in the zip (unexpected repo layout)."

theme_dir="$(dirname "$theme_plymouth_file")"
echo "Found theme directory: $theme_dir"

echo "Installing to: $THEMES_DIR/$THEME_NAME"
mkdir -p "$THEMES_DIR"
rm -rf "$THEMES_DIR/$THEME_NAME"
cp -a "$theme_dir" "$THEMES_DIR/$THEME_NAME"

echo "Activating theme (regenerating initramfs via -R)..."
plymouth-set-default-theme -R "$THEME_NAME"

echo "Done. Reboot to see the theme."
